#include <config.h>
#include <stdio.h>
#include <sys/select.h>
#include <sys/time.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>

#include "builtins.h"
#include "shell.h"
#include "bashgetopt.h"
#include "common.h"
#include "array.h"
#include "variables.h"

static int
populate_fd_set(char *name, fd_set *set, int *maxfd)
{
  if (!name) return 0;
  SHELL_VAR *v = find_variable(name);
  if (!v || !array_p(v)) {
      builtin_error("%s: not an indexed array", name);
      return -1;
  }
  ARRAY *a = array_cell(v);
  ARRAY_ELEMENT *ae;
  if (!a) return 0;
  for (ae = element_forw(a->head); ae != a->head; ae = element_forw(ae)) {
      char *val = element_value(ae);
      int fd = atoi(val);
      if (fd >= 0 && fd < FD_SETSIZE) {
          FD_SET(fd, set);
          if (fd > *maxfd) *maxfd = fd;
      }
  }
  return 0;
}

static int
update_array(char *name, fd_set *set, int maxfd)
{
  if (!name) return 0;
  SHELL_VAR *v = find_variable(name);
  if (!v || !array_p(v)) return 0;
  ARRAY *a = array_cell(v);
  if (!a) return 0;
  
  array_flush(a);
  int count = 0;
  for (int i = 0; i <= maxfd; i++) {
      if (FD_ISSET(i, set)) {
          char buf[32];
          sprintf(buf, "%d", i);
          array_insert(a, count++, buf);
      }
  }
  return 0;
}

int
bash_select_builtin (WORD_LIST *list)
{
  char *readfds_name = NULL;
  char *writefds_name = NULL;
  char *exceptfds_name = NULL;
  char *timeout_str = NULL;
  char *ret_var = NULL;
  int opt;

  reset_internal_getopt ();
  while ((opt = internal_getopt (list, "r:w:e:t:v:")) != -1)
    {
      switch (opt)
	{
	case 'r':
	  readfds_name = list_optarg;
	  break;
	case 'w':
	  writefds_name = list_optarg;
	  break;
	case 'e':
	  exceptfds_name = list_optarg;
	  break;
	case 't':
	  timeout_str = list_optarg;
	  break;
	case 'v':
	  ret_var = list_optarg;
	  break;
	CASE_HELPOPT;
	default:
	  builtin_usage ();
	  return (EX_USAGE);
	}
    }
  list = loptend;

  fd_set rfds, wfds, efds;
  FD_ZERO (&rfds);
  FD_ZERO (&wfds);
  FD_ZERO (&efds);
  int maxfd = -1;

  if (populate_fd_set(readfds_name, &rfds, &maxfd) < 0) return EXECUTION_FAILURE;
  if (populate_fd_set(writefds_name, &wfds, &maxfd) < 0) return EXECUTION_FAILURE;
  if (populate_fd_set(exceptfds_name, &efds, &maxfd) < 0) return EXECUTION_FAILURE;

  struct timeval tv, *tvp = NULL;
  if (timeout_str) {
      double t = atof(timeout_str);
      tv.tv_sec = (long)t;
      tv.tv_usec = (long)((t - (long)t) * 1000000);
      tvp = &tv;
  }

  int ret = select(maxfd + 1, &rfds, &wfds, &efds, tvp);

  if (ret_var) {
      char buf[32];
      sprintf(buf, "%d", ret);
      bind_variable(ret_var, buf, 0);
  }

  if (ret > 0) {
      update_array(readfds_name, &rfds, maxfd);
      update_array(writefds_name, &wfds, maxfd);
      update_array(exceptfds_name, &efds, maxfd);
  } else {
      /* On timeout (0) or error (<0), clear all arrays if they were provided */
      if (readfds_name) {
          SHELL_VAR *v = find_variable(readfds_name);
          if (v && array_p(v)) array_flush(array_cell(v));
      }
      if (writefds_name) {
          SHELL_VAR *v = find_variable(writefds_name);
          if (v && array_p(v)) array_flush(array_cell(v));
      }
      if (exceptfds_name) {
          SHELL_VAR *v = find_variable(exceptfds_name);
          if (v && array_p(v)) array_flush(array_cell(v));
      }
  }

  return (ret >= 0 ? EXECUTION_SUCCESS : EXECUTION_FAILURE);
}

char *bash_select_doc[] = {
    "Wait for file descriptors to become ready.",
    "",
    "bash_select [-r READFDS] [-w WRITEFDS] [-e EXCEPTFDS] [-t TIMEOUT] [-v RETVAR]",
    "",
    "Poll multiple file descriptors using select(2).",
    "READFDS, WRITEFDS, and EXCEPTFDS are names of indexed arrays containing FDs.",
    "On return, the arrays are modified to contain only the ready FDs.",
    "TIMEOUT is in seconds (can be fractional).",
    "RETVAR is the name of a variable to store the return value of select(2).",
    (char *)NULL
};

struct builtin bash_select_struct = {
    "bash_select",
    bash_select_builtin,
    BUILTIN_ENABLED,
    bash_select_doc,
    "bash_select [-r readfds] [-w writefds] [-e exceptfds] [-t timeout] [-v retvar]",
    0
};
