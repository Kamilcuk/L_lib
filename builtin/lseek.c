#include <config.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

#include "builtins.h"
#include "shell.h"
#include "bashgetopt.h"
#include "common.h"
#include "variables.h"
#include "L_builtin.h"

int
lseek_subcommand (WORD_LIST *list)
{
  char *ret_var = NULL;
  int opt;
  off_t offset, result;
  int fd, whence = SEEK_SET;

  reset_internal_getopt ();
  while ((opt = internal_getopt (list, "v:h")) != -1)
    {
      switch (opt)
	{
	case 'v':
	  ret_var = list_optarg;
	  break;
	case 'h':
	case GETOPT_HELP:
	  builtin_usage ();
	  return (EX_USAGE);
	default:
	  builtin_usage ();
	  return (EX_USAGE);
	}
    }
  list = loptend;

  if (list == 0 || list->next == 0)
    {
      builtin_usage ();
      return (EX_USAGE);
    }

  fd = atoi (list->word->word);
  offset = atoll (list->next->word->word);

  if (list->next->next)
    {
      char *w = list->next->next->word->word;
      if (strcmp (w, "SET") == 0 || strcmp (w, "0") == 0) whence = SEEK_SET;
      else if (strcmp (w, "CUR") == 0 || strcmp (w, "1") == 0) whence = SEEK_CUR;
      else if (strcmp (w, "END") == 0 || strcmp (w, "2") == 0) whence = SEEK_END;
      else
	{
	  builtin_error ("%s: invalid whence", w);
	  return (EX_USAGE);
	}
    }

  result = lseek (fd, offset, whence);
  if (result == (off_t)-1)
    {
      builtin_error ("lseek error: %s", strerror (errno));
      return (EXECUTION_FAILURE);
    }

  if (ret_var)
    {
      char buf[32];
      sprintf (buf, "%lld", (long long)result);
      if (bind_variable (ret_var, buf, 0) == NULL)
	{
	  builtin_error ("%s: cannot bind variable", ret_var);
	  return (EXECUTION_FAILURE);
	}
    }

  return (EXECUTION_SUCCESS);
}

char *lseek_doc[] = {
    "Reposition file offset.",
    "",
    "L_builtin lseek [-v var] fd offset [whence]",
    "",
    "Adjust the file offset of file descriptor FD to OFFSET bytes",
    "according to WHENCE.",
    "",
    "WHENCE can be one of:",
    "  0 or SET  Seek from the beginning (default)",
    "  1 or CUR  Seek from the current position",
    "  2 or END  Seek from the end",
    "",
    "If -v VAR is provided, the new offset is stored in VAR.",
    "",
    "Exit Status:",
    "Returns success unless an error occurs during lseek or variable binding.",
    (char *)NULL
};
