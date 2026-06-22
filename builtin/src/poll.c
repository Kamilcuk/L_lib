#include <config.h>
#include <errno.h>
#include <poll.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>

#include "builtins.h"
#include "shell.h"
#include "variables.h"
#include "array.h"
#include "common.h"
#include "bashgetopt.h"
#include "sig.h"
#include "trap.h"
#include "L_builtin.h"

static short parse_events(const char *s) {
  short ev = 0;
  if (!s || !*s)
    return POLLIN;
  while (*s) {
    switch (*s) {
    case 'r':
      ev |= POLLIN;
      break;
    case 'w':
      ev |= POLLOUT;
      break;
    case 'p':
      ev |= POLLPRI;
      break;
    }
    s++;
  }
  return ev ? ev : POLLIN;
}

static char *format_revents(short revents) {
  static char buf[8];
  int p = 0;
  if (revents & POLLIN)
    buf[p++] = 'r';
  if (revents & POLLOUT)
    buf[p++] = 'w';
  if (revents & POLLPRI)
    buf[p++] = 'p';
  if (revents & POLLHUP)
    buf[p++] = 'h';
  if (revents & POLLERR)
    buf[p++] = 'e';
  if (revents & POLLNVAL)
    buf[p++] = 'n';
  buf[p] = '\0';
  return buf;
}

static int do_poll(struct pollfd *pfds, int nfds, struct timespec *tsp,
                   sigset_t *sigmask, int is_ppoll) {
#ifdef HAVE_PPOLL
  if (is_ppoll)
    return ppoll(pfds, nfds, tsp, sigmask);
  else
#endif
  {
    int timeout = -1;
    if (tsp)
      timeout = (int)(tsp->tv_sec * 1000 + tsp->tv_nsec / 1000000);
    return poll(pfds, nfds, timeout);
  }
}

static int poll_internal(WORD_LIST *list, int is_ppoll) {
  char *ret_var = NULL;
  char *timeout_str = NULL;
  sigset_t unblock_set, current_mask, new_mask;
  int opt, unblock_any = 0;

  sigemptyset(&unblock_set);
  reset_internal_getopt();

  const char *optstr = is_ppoll ? "t:v:u:h" : "t:v:h";

  while ((opt = internal_getopt(list, (char *)optstr)) != -1) {
    switch (opt) {
    case 't':
      timeout_str = list_optarg;
      break;
    case 'v':
      ret_var = list_optarg;
      break;
    case 'u':
      if (strcasecmp(list_optarg, "all") == 0) {
        sigfillset(&unblock_set);
        unblock_any = 1;
      } else {
        int sig = decode_signal(list_optarg, DSIG_NOCASE | DSIG_SIGPREFIX);
        if (sig == NO_SIG) {
          sh_invalidsig(list_optarg);
          return (EXECUTION_FAILURE);
        }
        sigaddset(&unblock_set, sig);
        unblock_any = 1;
      }
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

  int nfds = 0;
  WORD_LIST *l;
  for (l = list; l; l = l->next)
    nfds++;

  struct pollfd *pfds = NULL;
  if (nfds > 0) {
    pfds = (struct pollfd *)xmalloc(nfds * sizeof(struct pollfd));
    l = list;
    for (int i = 0; i < nfds; i++, l = l->next) {
      char *s = l->word->word;
      char *sep = strchr(s, ':');
      if (sep) {
        *sep = '\0';
        pfds[i].fd = atoi(s);
        pfds[i].events = parse_events(sep + 1);
        *sep = ':';
      } else {
        pfds[i].fd = atoi(s);
        pfds[i].events = POLLIN;
      }
      pfds[i].revents = 0;
    }
  }

  struct timespec ts, *tsp = NULL;
  if (timeout_str) {
    double t = atof(timeout_str);
    ts.tv_sec = (long)t;
    ts.tv_nsec = (long)((t - (long)t) * 1000000000);
    tsp = &ts;
  }

  sigemptyset(&new_mask);
  if (is_ppoll) {
    if (sigprocmask(SIG_BLOCK, NULL, &current_mask) < 0) {
      builtin_error("sigprocmask: %s", strerror(errno));
      if (pfds)
        free(pfds);
      return (EXECUTION_FAILURE);
    }
    new_mask = current_mask;
    if (unblock_any) {
      for (int i = 1; i < NSIG; i++)
        if (sigismember(&unblock_set, i))
          sigdelset(&new_mask, i);
    }
  }

  int ret = do_poll(pfds, nfds, tsp, &new_mask, is_ppoll);

  if (ret < 0 && errno != EINTR)
    builtin_error("poll: %s", strerror(errno));

  if (ret_var) {
    SHELL_VAR *v = find_variable(ret_var);
    if (v && !array_p(v)) {
      builtin_error("%s: not an indexed array", ret_var);
      if (pfds)
        free(pfds);
      return (EXECUTION_FAILURE);
    }
    if (!v)
      v = make_new_array_variable(ret_var);
    if (!v) {
      builtin_error("%s: cannot create array", ret_var);
      if (pfds)
        free(pfds);
      return (EXECUTION_FAILURE);
    }
    ARRAY *a = array_cell(v);
    array_flush(a);

    if (ret > 0) {
      int count = 0;
      for (int i = 0; i < nfds; i++) {
        if (pfds[i].revents) {
          char entry[64];
          sprintf(entry, "%d:%s", pfds[i].fd, format_revents(pfds[i].revents));
          array_insert(a, count++, entry);
        }
      }
    }
  }

  if (pfds)
    free(pfds);
  return (ret >= 0 ? EXECUTION_SUCCESS : EXECUTION_FAILURE);
}

int poll_subcommand(WORD_LIST *list) { return poll_internal(list, 0); }

#ifdef HAVE_PPOLL
int ppoll_subcommand(WORD_LIST *list) { return poll_internal(list, 1); }
#endif

char *poll_doc[] = {
    "Wait for file descriptors to become ready.",
    "",
    "L_builtin poll [-t TIMEOUT] [-v ARRAY_VAR] [FD[:EVENTS] ...]",
    "",
    "Poll file descriptors using poll(2). EVENTS can be 'r', 'w', or 'p'.",
    "Results are stored in the indexed array ARRAY_VAR as FD:REVENTS.",
    "REVENTS contains 'r', 'w', 'p', 'h' (hangup), 'e' (error), or 'n' "
    "(invalid).",
    "",
    "Exit Status:",
    "Returns success if poll succeeds, even if it timed out. Returns failure "
    "on",
    "system errors.",
    (char *)NULL};

#ifdef HAVE_PPOLL
char *ppoll_doc[] = {
    "Wait for file descriptors and unblock signals atomically.",
    "",
    "L_builtin ppoll [-t TIMEOUT] [-v ARRAY_VAR] [-u SIGSPEC] [FD[:EVENTS] "
    "...]",
    "",
    "Poll file descriptors and unblock signals using ppoll(2).",
    "Results are stored in the indexed array ARRAY_VAR as FD:REVENTS.",
    "",
    "Use -u SIGSPEC to temporarily unblock specified signals during ppoll.",
    "Use -u 'ALL' (case-insensitive) to unblock all signals.",
    "",
    "EVENTS and REVENTS format:",
    "  EVENTS can be a combination of 'r' (read, default if omitted),",
    "  'w' (write), or 'p' (priority).",
    "  REVENTS contains 'r', 'w', 'p', 'h' (hangup), 'e' (error), or 'n' "
    "(invalid).",
    "",
    "Example:",
    "  # Poll fd 0 for reading with a 2.5 second timeout, unblocking all "
    "signals",
    "  L_builtin ppoll -t 2.5 -v results -u ALL 0:r",
    "",
    "Exit Status:",
    "Returns success if ppoll succeeds. Returns failure on system errors.",
    (char *)NULL};
#endif
