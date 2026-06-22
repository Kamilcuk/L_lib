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

struct subcommand_def {
  const char *name;
  sh_builtin_func_t *func;
  char **doc;
};

static struct subcommand_def subcommands[] = {
  { "lseek", lseek_subcommand, lseek_doc },
  { "poll", poll_subcommand, poll_doc },
#ifdef HAVE_PPOLL
  { "ppoll", ppoll_subcommand, ppoll_doc },
#endif
  { "sigmask", sigmask_subcommand, sigmask_doc },
  { "sigunmask", sigunmask_subcommand, sigunmask_doc },
  { "pipe", pipe_subcommand, pipe_doc },
#ifdef HAVE_LUA
  { "lua", lua_subcommand, lua_doc },
#endif
  { NULL, NULL, NULL }
};

static struct subcommand_def *
find_subcommand (const char *name)
{
  for (int i = 0; subcommands[i].name; i++)
    {
      if (strcmp (name, subcommands[i].name) == 0)
	return &subcommands[i];
    }
  return NULL;
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

  char *subcommand_name = list->word->word;
  struct subcommand_def *sub = find_subcommand (subcommand_name);

  if (sub == NULL)
    {
      builtin_error ("%s: invalid subcommand", subcommand_name);
      return (EX_USAGE);
    }

  /* Check for help request for subcommand */
  if (list->next && (strcmp (list->next->word->word, "-h") == 0 || strcmp (list->next->word->word, "--help") == 0))
    {
      if (sub->doc)
	{
	  for (int i = 0; sub->doc[i]; i++)
	    printf ("%s\n", sub->doc[i]);
	}
      return (EXECUTION_SUCCESS);
    }

  return (*sub->func) (list->next);
}

char *L_builtin_doc[] = {
    "L_lib helper builtins.",
    "",
    "L_builtin <subcommand> [options] [args]",
    "",
    "Available subcommands:",
    "  lseek      Reposition file offset",
    "  poll       Wait for file descriptors to become ready",
#ifdef HAVE_PPOLL
    "  ppoll      Wait for FDs and unblock signals atomically",
#endif
    "  sigmask    Block or unblock signals",
    "  sigunmask  Unblock signals and run a command",
    "  pipe       Create a pipe",
#ifdef HAVE_LUA
    "  lua        Execute LuaJIT script",
#endif
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
