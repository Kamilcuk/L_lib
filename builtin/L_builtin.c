#include <config.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "builtins.h"
#include "shell.h"
#include "common.h"
#include "L_builtin.h"

extern char *this_command_name;
extern struct builtin L_builtin_struct;

static void
L_builtin_help_subcommand (char *subcommand)
{
  char **doc = NULL;
  if (strcmp (subcommand, "lseek") == 0) doc = lseek_doc;
  else if (strcmp (subcommand, "select") == 0) doc = select_doc;
  else if (strcmp (subcommand, "pselect") == 0) doc = pselect_doc;
  else if (strcmp (subcommand, "sigmask") == 0) doc = sigmask_doc;
  else if (strcmp (subcommand, "sigunmask") == 0) doc = sigunmask_doc;

  if (doc)
    {
      for (int i = 0; doc[i]; i++)
	printf ("%s\n", doc[i]);
    }
}

int
L_builtin_builtin (WORD_LIST *list)
{
  if (list == 0)
    {
      if (this_command_name && *this_command_name)
	fprintf (stderr, "%s: usage: ", this_command_name);
      fprintf (stderr, "%s\n", L_builtin_struct.short_doc);
      return (EX_USAGE);
    }

  char *subcommand = list->word->word;
  
  /* Check for help request for subcommand */
  if (list->next && (strcmp (list->next->word->word, "-h") == 0 || strcmp (list->next->word->word, "--help") == 0))
    {
      L_builtin_help_subcommand (subcommand);
      return (EXECUTION_SUCCESS);
    }

  if (strcmp (subcommand, "lseek") == 0)
    return lseek_subcommand (list->next);
  else if (strcmp (subcommand, "select") == 0)
    return select_subcommand (list->next);
  else if (strcmp (subcommand, "pselect") == 0)
    return pselect_subcommand (list->next);
  else if (strcmp (subcommand, "sigmask") == 0)
    return sigmask_subcommand (list->next);
  else if (strcmp (subcommand, "sigunmask") == 0)
    return sigunmask_subcommand (list->next);
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
    "  lseek      Reposition file offset",
    "  select     Wait for file descriptors to become ready",
    "  pselect    Wait for FDs and unblock signals atomically",
    "  sigmask    Block or unblock signals",
    "  sigunmask  Unblock signals and run a command",
    "",
    "Use 'L_builtin <subcommand> -h' for more information.",
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
