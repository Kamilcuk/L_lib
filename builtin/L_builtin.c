#include <config.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "builtins.h"
#include "shell.h"
#include "common.h"
#include "L_builtin.h"

int
L_builtin_builtin (WORD_LIST *list)
{
  if (list == 0)
    {
      builtin_usage ();
      return (EX_USAGE);
    }

  char *subcommand = list->word->word;
  if (strcmp (subcommand, "lseek") == 0)
    return lseek_subcommand (list->next);
  else if (strcmp (subcommand, "select") == 0)
    return select_subcommand (list->next);
  else
    {
      builtin_error ("%s: invalid subcommand", subcommand);
      return (EX_USAGE);
    }
}

char *L_builtin_doc[] = {
    "L_lib helper builtins.",
    "",
    "L_builtin <subcommand> [options] [args]",
    "",
    "Available subcommands:",
    "  lseek   Reposition file offset",
    "  select  Wait for file descriptors to become ready",
    "",
    "Use 'help L_builtin <subcommand>' for more information.",
    (char *)NULL
};

struct builtin L_builtin_struct = {
    "L_builtin",
    L_builtin_builtin,
    BUILTIN_ENABLED,
    L_builtin_doc,
    "L_builtin <subcommand> [options] [args]",
    0
};
