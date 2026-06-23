#include <config.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "builtins.h"
#include "shell.h"
#include "variables.h"
#include "array.h"
#include "common.h"
#include "bashgetopt.h"
#include "L_builtin.h"

#if defined(__GNUC__) && __GNUC__ >= 10
#pragma GCC diagnostic ignored "-Wanalyzer-fd-leak"
#endif

int pipe_subcommand(WORD_LIST *list)
{
  char *array_name = NULL;
  int opt;
  int fds[2];

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

  array_name = list->word->word;

  if (pipe(fds) < 0) {
    builtin_error("pipe: %s", strerror(errno));
    return (EXECUTION_FAILURE);
  }

  SHELL_VAR *v = find_variable(array_name);
  if (v && !array_p(v)) {
    close(fds[0]);
    close(fds[1]);
    builtin_error("%s: not an indexed array", array_name);
    return (EXECUTION_FAILURE);
  }

  if (v == NULL)
    v = make_new_array_variable(array_name);

  if (v == NULL) {
    close(fds[0]);
    close(fds[1]);
    builtin_error("%s: cannot create array variable", array_name);
    return (EXECUTION_FAILURE);
  }

  ARRAY *a = array_cell(v);
  array_flush(a);

  char buf[32];
  snprintf(buf, sizeof(buf), "%d", fds[0]);
  array_insert(a, 0, buf);
  snprintf(buf, sizeof(buf), "%d", fds[1]);
  array_insert(a, 1, buf);

  return (EXECUTION_SUCCESS);
}

char *pipe_doc[] = {
  "Create a pipe.",
  "",
  "L_builtin pipe ARRAY",
  "",
  "Create a new pipe and store the file descriptors in the indexed",
  "array ARRAY. ARRAY[0] is the read end, ARRAY[1] is the write end.",
  "",
  "Exit Status:",
  "Returns success unless the pipe cannot be created or ARRAY is invalid.",
  (char *)NULL
};
