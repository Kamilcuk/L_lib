#include <config.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

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
  while ((opt = internal_getopt (list, "v:")) != -1)
    {
      switch (opt)
	{
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

  if (list == 0 || list->next == 0)
    {
      builtin_usage ();
      return (EX_USAGE);
    }

  fd = atoi (list->word->word);
  list = list->next;
  
  offset = (off_t) atoll (list->word->word);
  list = list->next;

  if (list)
    {
      if (strcmp (list->word->word, "SET") == 0 || strcmp (list->word->word, "0") == 0)
	whence = SEEK_SET;
      else if (strcmp (list->word->word, "CUR") == 0 || strcmp (list->word->word, "1") == 0)
	whence = SEEK_CUR;
      else if (strcmp (list->word->word, "END") == 0 || strcmp (list->word->word, "2") == 0)
	whence = SEEK_END;
      else
	{
	  builtin_error ("%s: invalid whence", list->word->word);
	  return (EXECUTION_FAILURE);
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
      char buf[64];
      sprintf (buf, "%lld", (long long)result);
      bind_variable (ret_var, buf, 0);
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
    (char *)NULL
};
