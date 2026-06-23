#include <config.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <time.h>

#include "builtins.h"
#include "shell.h"
#include "variables.h"
#include "common.h"
#include "bashgetopt.h"
#include "L_builtin.h"

static unsigned char *hex_decode(const char *hex, size_t *out_len)
{
  size_t len = strlen(hex);
  if (len % 2 != 0)
    return NULL;
  size_t out_size = len / 2;
  unsigned char *out = malloc(out_size);
  if (!out)
    return NULL;
  for (size_t i = 0; i < out_size; i++) {
    unsigned int val;
    if (sscanf(hex + i * 2, "%2x", &val) != 1) {
      free(out);
      return NULL;
    }
    out[i] = (unsigned char)val;
  }
  *out_len = out_size;
  return out;
}

static char *hex_encode(const unsigned char *data, size_t len)
{
  char *out = malloc(len * 2 + 1);
  if (!out)
    return NULL;
  for (size_t i = 0; i < len; i++) {
    snprintf(out + i * 2, 3, "%02x", data[i]);
  }
  out[len * 2] = '\0';
  return out;
}

int listen_subcommand(WORD_LIST *list)
{
  char *listenfd_var = NULL;
  char *ip = NULL;
  char *port = NULL;
  char *port_var = NULL;
  int opt;

  reset_internal_getopt();
  while ((opt = internal_getopt(list, "p:h")) != -1) {
    switch (opt) {
    case 'p':
      port_var = list_optarg;
      break;
    case 'h':
    case GETOPT_HELP:
      builtin_usage();
      return (EX_USAGE);
    default:
      builtin_usage();
      return (EX_USAGE);
    }
  }
  list = loptend;

  if (list == 0) {
    builtin_usage();
    return (EX_USAGE);
  }

  listenfd_var = list->word->word;
  if (list->next == 0) {
    ip = "127.0.0.1";
    port = "0";
  } else if (list->next->next == 0) {
    ip = list->next->word->word;
    port = "0";
  } else {
    ip = list->next->word->word;
    port = list->next->next->word->word;
  }

  if (strcmp(port, "0") == 0 && port_var == NULL) {
    builtin_error("-p PORT_VAR option is required when port is 0");
    return (EX_USAGE);
  }

  struct addrinfo hints, *res;
  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_PASSIVE;

  int status = getaddrinfo(ip, port, &hints, &res);
  if (status != 0) {
    builtin_error("getaddrinfo: %s", gai_strerror(status));
    return (EXECUTION_FAILURE);
  }

  int sfd = -1;
  struct addrinfo *rp;
  for (rp = res; rp != NULL; rp = rp->ai_next) {
    sfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
    if (sfd == -1)
      continue;

    int optval = 1;
    setsockopt(sfd, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval));

    if (bind(sfd, rp->ai_addr, rp->ai_addrlen) == 0) {
      break; /* Success */
    }
    close(sfd);
    sfd = -1;
  }
  freeaddrinfo(res);

  if (sfd == -1) {
    builtin_error("bind failed: %s", strerror(errno));
    return (EXECUTION_FAILURE);
  }

  if (listen(sfd, 128) < 0) {
    close(sfd);
    builtin_error("listen failed: %s", strerror(errno));
    return (EXECUTION_FAILURE);
  }

  if (port_var) {
    struct sockaddr_storage local_addr = {0};
    socklen_t local_len = sizeof(local_addr);
    int port_num = 0;
    if (getsockname(sfd, (struct sockaddr *)&local_addr, &local_len) == 0) {
      if (local_addr.ss_family == AF_INET) {
        port_num = ntohs(((struct sockaddr_in *)&local_addr)->sin_port);
      } else if (local_addr.ss_family == AF_INET6) {
        port_num = ntohs(((struct sockaddr_in6 *)&local_addr)->sin6_port);
      }
    }
    char pbuf[16];
    snprintf(pbuf, sizeof(pbuf), "%d", port_num);
    if (bind_variable(port_var, pbuf, 0) == NULL) {
      close(sfd);
      builtin_error("%s: cannot bind port variable", port_var);
      return (EXECUTION_FAILURE);
    }
  }

  char buf[32];
  snprintf(buf, sizeof(buf), "%d", sfd);
  if (bind_variable(listenfd_var, buf, 0) == NULL) {
    close(sfd);
    builtin_error("%s: cannot bind variable", listenfd_var);
    return (EXECUTION_FAILURE);
  }

  return (EXECUTION_SUCCESS);
}

int accept_subcommand(WORD_LIST *list)
{
  char *clientfd_var = NULL;
  char *addr_var = NULL;
  int listenfd = -1;
  int opt;

  reset_internal_getopt();
  while ((opt = internal_getopt(list, "h")) != -1) {
    switch (opt) {
    case 'h':
    case GETOPT_HELP:
      builtin_usage();
      return (EX_USAGE);
    default:
      builtin_usage();
      return (EX_USAGE);
    }
  }
  list = loptend;

  if (list == 0 || list->next == 0 || list->next->next == 0) {
    builtin_usage();
    return (EX_USAGE);
  }

  clientfd_var = list->word->word;
  addr_var = list->next->word->word;
  listenfd = atoi(list->next->next->word->word);

  struct sockaddr_storage addr = {0};
  socklen_t addrlen = sizeof(addr);
  int clientfd = accept(listenfd, (struct sockaddr *)&addr, &addrlen);
  if (clientfd < 0) {
    builtin_error("accept failed: %s", strerror(errno));
    return (EXECUTION_FAILURE);
  }

  char ipstr[INET6_ADDRSTRLEN];
  int port = 0;
  if (addr.ss_family == AF_INET) {
    struct sockaddr_in *s = (struct sockaddr_in *)&addr;
    inet_ntop(AF_INET, &s->sin_addr, ipstr, sizeof(ipstr));
    port = ntohs(s->sin_port);
  } else if (addr.ss_family == AF_INET6) {
    struct sockaddr_in6 *s = (struct sockaddr_in6 *)&addr;
    inet_ntop(AF_INET6, &s->sin6_addr, ipstr, sizeof(ipstr));
    port = ntohs(s->sin6_port);
  } else {
    strcpy(ipstr, "unknown");
  }

  char buf[32];
  snprintf(buf, sizeof(buf), "%d", clientfd);
  if (bind_variable(clientfd_var, buf, 0) == NULL) {
    close(clientfd);
    builtin_error("%s: cannot bind variable", clientfd_var);
    return (EXECUTION_FAILURE);
  }

  char addr_buf[INET6_ADDRSTRLEN + 16];
  snprintf(addr_buf, sizeof(addr_buf), "%s:%d", ipstr, port);
  if (bind_variable(addr_var, addr_buf, 0) == NULL) {
    builtin_error("%s: cannot bind variable", addr_var);
    return (EXECUTION_FAILURE);
  }

  return (EXECUTION_SUCCESS);
}

int connect_subcommand(WORD_LIST *list)
{
  char *clientfd_var = NULL;
  char *ip = NULL;
  char *port = NULL;
  int opt;

  reset_internal_getopt();
  while ((opt = internal_getopt(list, "h")) != -1) {
    switch (opt) {
    case 'h':
    case GETOPT_HELP:
      builtin_usage();
      return (EX_USAGE);
    default:
      builtin_usage();
      return (EX_USAGE);
    }
  }
  list = loptend;

  if (list == 0 || list->next == 0 || list->next->next == 0) {
    builtin_usage();
    return (EX_USAGE);
  }

  clientfd_var = list->word->word;
  ip = list->next->word->word;
  port = list->next->next->word->word;

  struct addrinfo hints, *res;
  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;

  int status = getaddrinfo(ip, port, &hints, &res);
  if (status != 0) {
    builtin_error("getaddrinfo: %s", gai_strerror(status));
    return (EXECUTION_FAILURE);
  }

  int sfd = -1;
  struct addrinfo *rp;
  for (rp = res; rp != NULL; rp = rp->ai_next) {
    sfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
    if (sfd == -1)
      continue;

    if (connect(sfd, rp->ai_addr, rp->ai_addrlen) == 0) {
      break; /* Success */
    }
    close(sfd);
    sfd = -1;
  }
  freeaddrinfo(res);

  if (sfd == -1) {
    builtin_error("connect failed: %s", strerror(errno));
    return (EXECUTION_FAILURE);
  }

  char buf[32];
  snprintf(buf, sizeof(buf), "%d", sfd);
  if (bind_variable(clientfd_var, buf, 0) == NULL) {
    close(sfd);
    builtin_error("%s: cannot bind variable", clientfd_var);
    return (EXECUTION_FAILURE);
  }

  return (EXECUTION_SUCCESS);
}

int shutdown_subcommand(WORD_LIST *list)
{
  int fd;
  int how = SHUT_RDWR;
  int opt;

  reset_internal_getopt();
  while ((opt = internal_getopt(list, "h")) != -1) {
    switch (opt) {
    case 'h':
    case GETOPT_HELP:
      builtin_usage();
      return (EX_USAGE);
    default:
      builtin_usage();
      return (EX_USAGE);
    }
  }
  list = loptend;

  if (list == 0) {
    builtin_usage();
    return (EX_USAGE);
  }

  fd = atoi(list->word->word);

  if (list->next) {
    char *h = list->next->word->word;
    if (strcmp(h, "RD") == 0 || strcmp(h, "0") == 0)
      how = SHUT_RD;
    else if (strcmp(h, "WR") == 0 || strcmp(h, "1") == 0)
      how = SHUT_WR;
    else if (strcmp(h, "RDWR") == 0 || strcmp(h, "2") == 0)
      how = SHUT_RDWR;
    else {
      builtin_error("%s: invalid shutdown mode", h);
      return (EX_USAGE);
    }
  }

  if (shutdown(fd, how) < 0) {
    builtin_error("shutdown failed: %s", strerror(errno));
    return (EXECUTION_FAILURE);
  }

  return (EXECUTION_SUCCESS);
}

int send_subcommand(WORD_LIST *list)
{
  char *sent_var = NULL;
  char *format = "raw";
  int opt;

  reset_internal_getopt();
  while ((opt = internal_getopt(list, "f:v:h")) != -1) {
    switch (opt) {
    case 'f':
      format = list_optarg;
      break;
    case 'v':
      sent_var = list_optarg;
      break;
    case 'h':
    case GETOPT_HELP:
      builtin_usage();
      return (EX_USAGE);
    default:
      builtin_usage();
      return (EX_USAGE);
    }
  }
  list = loptend;

  if (list == 0 || list->next == 0) {
    builtin_usage();
    return (EX_USAGE);
  }

  int fd = atoi(list->word->word);
  char *data_str = list->next->word->word;

  unsigned char *data = NULL;
  size_t data_len = 0;
  int is_hex = (strcmp(format, "hex") == 0);

  if (is_hex) {
    data = hex_decode(data_str, &data_len);
    if (!data) {
      builtin_error("invalid hex string");
      return (EXECUTION_FAILURE);
    }
  } else if (strcmp(format, "raw") == 0) {
    data = (unsigned char *)data_str;
    data_len = strlen(data_str);
  } else {
    builtin_error("%s: invalid format (must be raw or hex)", format);
    return (EX_USAGE);
  }

  ssize_t sent = send(fd, data, data_len, 0);
  if (is_hex) {
    free(data);
  }

  if (sent < 0) {
    builtin_error("send failed: %s", strerror(errno));
    return (EXECUTION_FAILURE);
  }

  if (sent_var) {
    char buf[32];
    snprintf(buf, sizeof(buf), "%zd", sent);
    if (bind_variable(sent_var, buf, 0) == NULL) {
      builtin_error("%s: cannot bind variable", sent_var);
      return (EXECUTION_FAILURE);
    }
  }

  return (EXECUTION_SUCCESS);
}

int recv_subcommand(WORD_LIST *list)
{
  char *recv_var = NULL;
  char *format = "raw";
  int non_blocking = 0;
  int opt;

  reset_internal_getopt();
  while ((opt = internal_getopt(list, "f:v:nh")) != -1) {
    switch (opt) {
    case 'f':
      format = list_optarg;
      break;
    case 'v':
      recv_var = list_optarg;
      break;
    case 'n':
      non_blocking = 1;
      break;
    case 'h':
    case GETOPT_HELP:
      builtin_usage();
      return (EX_USAGE);
    default:
      builtin_usage();
      return (EX_USAGE);
    }
  }
  list = loptend;

  if (list == 0 || list->next == 0) {
    builtin_usage();
    return (EX_USAGE);
  }

  int fd = atoi(list->word->word);
  size_t size = (size_t)atoll(list->next->word->word);

  if (strcmp(format, "raw") != 0 && strcmp(format, "hex") != 0) {
    builtin_error("%s: invalid format (must be raw or hex)", format);
    return (EX_USAGE);
  }

  unsigned char *buf = malloc(size + 1);
  if (!buf) {
    builtin_error("out of memory");
    return (EXECUTION_FAILURE);
  }

  int flags = non_blocking ? MSG_DONTWAIT : 0;
  ssize_t received = recv(fd, buf, size, flags);
  if (received < 0) {
    if (non_blocking && (errno == EAGAIN || errno == EWOULDBLOCK)) {
      received = 0;
    } else {
      free(buf);
      builtin_error("recv failed: %s", strerror(errno));
      return (EXECUTION_FAILURE);
    }
  }

  buf[received] = '\0';

  if (recv_var) {
    char *out_str = NULL;
    int is_hex = (strcmp(format, "hex") == 0);
    if (is_hex) {
      out_str = hex_encode(buf, (size_t)received);
      if (!out_str) {
        free(buf);
        builtin_error("out of memory");
        return (EXECUTION_FAILURE);
      }
    } else {
      out_str = (char *)buf;
    }

    if (bind_variable(recv_var, out_str, 0) == NULL) {
      if (is_hex) {
        free(out_str);
      }
      free(buf);
      builtin_error("%s: cannot bind variable", recv_var);
      return (EXECUTION_FAILURE);
    }

    if (is_hex) {
      free(out_str);
    }
  }

  free(buf);
  return (EXECUTION_SUCCESS);
}

int sleep_subcommand(WORD_LIST *list)
{
  double seconds;
  int opt;

  reset_internal_getopt();
  while ((opt = internal_getopt(list, "h")) != -1) {
    switch (opt) {
    case 'h':
    case GETOPT_HELP:
      builtin_usage();
      return (EX_USAGE);
    default:
      builtin_usage();
      return (EX_USAGE);
    }
  }
  list = loptend;

  if (list == 0) {
    builtin_usage();
    return (EX_USAGE);
  }

  seconds = atof(list->word->word);
  if (seconds < 0.0) {
    builtin_error("invalid sleep duration");
    return (EX_USAGE);
  }

  struct timespec ts;
  ts.tv_sec = (time_t)seconds;
  ts.tv_nsec = (long)((seconds - ts.tv_sec) * 1e9);

  while (nanosleep(&ts, &ts) == -1 && errno == EINTR) {
    /* Continue sleeping if interrupted by signal */
  }

  return (EXECUTION_SUCCESS);
}

char *listen_doc[] = {
  "Create a listening TCP socket.",
  "",
  "L_builtin listen [-p PORT_VAR] LISTENFD_VAR [IP] [PORT]",
  "",
  "Create a new socket, bind it to IP and PORT, listen for incoming",
  "connections, and store the resulting socket file descriptor in the",
  "variable LISTENFD_VAR.",
  "",
  "If IP is omitted, it defaults to 127.0.0.1.",
  "If PORT is omitted, it defaults to 0 (ephemeral port allocation).",
  "",
  "If -p PORT_VAR is provided, the actual bound port (useful when passing 0",
  "for ephemeral port allocation) is stored in PORT_VAR.",
  "",
  "Exit Status:",
  "Returns success unless socket/bind/listen fails or variable binding fails.",
  (char *)NULL
};

char *accept_doc[] = {
  "Accept a network connection.",
  "",
  "L_builtin accept CLIENTFD_VAR ADDR_VAR LISTENFD",
  "",
  "Accept an incoming connection on the listening socket file descriptor LISTENFD.",
  "The new socket file descriptor for the client is stored in CLIENTFD_VAR.",
  "The client's address (IP:PORT) is stored in ADDR_VAR.",
  "",
  "Exit Status:",
  "Returns success unless accept fails or variable binding fails.",
  (char *)NULL
};

char *connect_doc[] = {
  "Establish a TCP connection.",
  "",
  "L_builtin connect CLIENTFD_VAR IP PORT",
  "",
  "Establish an outgoing connection to IP on PORT, and store the resulting",
  "socket file descriptor in CLIENTFD_VAR.",
  "",
  "Exit Status:",
  "Returns success unless connection fails or variable binding fails.",
  (char *)NULL
};

char *shutdown_doc[] = {
  "Semi-close a network socket.",
  "",
  "L_builtin shutdown FD [how]",
  "",
  "Close parts or all of a full-duplex connection on network socket FD.",
  "how can be one of:",
  "  RD or 0    Further receptions will be disallowed",
  "  WR or 1    Further transmissions will be disallowed",
  "  RDWR or 2  Further receptions and transmissions will be disallowed (default)",
  "",
  "Exit Status:",
  "Returns success unless shutdown fails.",
  (char *)NULL
};

char *send_doc[] = {
  "Send bytes over a socket.",
  "",
  "L_builtin send [-f format] [-v SENT_VAR] FD DATA",
  "",
  "Transmit raw or encoded data over the socket file descriptor FD.",
  "Supported formats (-f):",
  "  raw   Transmit DATA as raw characters (default)",
  "  hex   Transmit DATA after decoding from hex representation",
  "",
  "If -v SENT_VAR is provided, the number of bytes successfully transmitted",
  "is stored in SENT_VAR.",
  "",
  "Exit Status:",
  "Returns success unless send fails or variable binding fails.",
  (char *)NULL
};

char *recv_doc[] = {
  "Receive bytes from a socket.",
  "",
  "L_builtin recv [-f format] [-v RECV_VAR] [-n] FD SIZE",
  "",
  "Receive up to SIZE bytes from the socket file descriptor FD.",
  "Supported formats (-f):",
  "  raw   Store raw bytes directly into RECV_VAR (null-byte unsafe) (default)",
  "  hex   Store received bytes as hexadecimal string into RECV_VAR (null-byte safe)",
  "",
  "If -n is provided, the recv call will be non-blocking. If no data is currently",
  "available, it will return success immediately with an empty string.",
  "",
  "Exit Status:",
  "Returns success unless recv fails or variable binding fails.",
  (char *)NULL
};

char *sleep_doc[] = {
  "High-precision sub-second sleep.",
  "",
  "L_builtin sleep SECONDS",
  "",
  "Sleep for the specified number of SECONDS. SECONDS can be a floating-point",
  "number to request sub-second/microsecond-level precision.",
  "",
  "Exit Status:",
  "Returns success unless sleep fails.",
  (char *)NULL
};
