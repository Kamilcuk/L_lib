#include <config.h>
#include <stdio.h>
#include <signal.h>
#include <errno.h>

#include "builtins.h"
#include "shell.h"
#include "bashgetopt.h"
#include "common.h"
#include "trap.h"
#include "quit.h"
#include "sig.h"
#include "execute_cmd.h"
#include "make_cmd.h"
#include "unwind_prot.h"
#include "L_builtin.h"

/* Missing extern declarations from Bash headers */
extern sigset_t top_level_mask;
extern int pending_traps[NSIG];
extern int line_number;

static void
restore_process_sigmask (void *arg)
{
  sigset_t *mask = (sigset_t *)arg;
  sigprocmask (SIG_SETMASK, mask, NULL);
}

static int
parse_sigspec (WORD_LIST *list, sigset_t *set)
{
  int sig;
  while (list)
    {
      sig = decode_signal (list->word->word, DSIG_NOCASE|DSIG_SIGPREFIX);
      if (sig == NO_SIG)
	{
	  sh_invalidsig (list->word->word);
	  return -1;
	}
      sigaddset (set, sig);
      list = list->next;
    }
  return 0;
}

int
sigmask_subcommand (WORD_LIST *list)
{
  sigset_t set, old;
  int opt, mode = SIG_BLOCK;

  int any_opt = 0;
  sigemptyset (&set);
  reset_internal_getopt ();
  while ((opt = internal_getopt (list, "s:u:h")) != -1)
    {
      any_opt = 1;
      switch (opt)
	{
	case 's':
	  mode = SIG_BLOCK;
	  {
	    int s = decode_signal (list_optarg, DSIG_NOCASE|DSIG_SIGPREFIX);
	    if (s == NO_SIG)
	      {
		sh_invalidsig (list_optarg);
		return (EXECUTION_FAILURE);
	      }
	    sigaddset (&set, s);
	  }
	  break;
	case 'u':
	  mode = SIG_UNBLOCK;
	  {
	    int s = decode_signal (list_optarg, DSIG_NOCASE|DSIG_SIGPREFIX);
	    if (s == NO_SIG)
	      {
		sh_invalidsig (list_optarg);
		return (EXECUTION_FAILURE);
	      }
	    sigaddset (&set, s);
	  }
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

  if (any_opt == 0 && list == 0)
    {
      sigemptyset(&set);
      sigprocmask(SIG_BLOCK, &set, &old);
      for (int i = 1; i < NSIG; i++)
	{
	  if (sigismember(&old, i))
	    printf("%s ", signal_name(i));
	}
      printf("\n");
      return (EXECUTION_SUCCESS);
    }

  if (list && parse_sigspec(list, &set) < 0)
    return (EXECUTION_FAILURE);

  if (sigprocmask (mode, &set, &old) < 0)
    {
      builtin_error ("sigprocmask: %s", strerror (errno));
      return (EXECUTION_FAILURE);
    }

  sigprocmask (SIG_BLOCK, NULL, &top_level_mask);

  return (EXECUTION_SUCCESS);
}

int
sigunmask_subcommand (WORD_LIST *list)
{
  sigset_t set, old, unblocked;
  int opt;

  sigemptyset (&unblocked);
  reset_internal_getopt ();
  while ((opt = internal_getopt (list, "s:h")) != -1)
    {
      switch (opt)
	{
	case 's':
	  {
	    int sig = decode_signal (list_optarg, DSIG_NOCASE|DSIG_SIGPREFIX);
	    if (sig == NO_SIG)
	      {
		sh_invalidsig (list_optarg);
		return (EXECUTION_FAILURE);
	      }
	    sigaddset (&unblocked, sig);
	  }
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

  if (list == 0)
    {
      builtin_usage ();
      return (EX_USAGE);
    }

  sigemptyset(&set);
  sigprocmask(SIG_BLOCK, &set, &old);
  
  sigset_t newmask = old;
  for (int i = 1; i < NSIG; i++)
    {
      if (sigismember(&unblocked, i))
	sigdelset(&newmask, i);
    }

  begin_unwind_frame ("sigunmask");
  
  unwind_protect_mem ((char *)&top_level_mask, sizeof(sigset_t));
  top_level_mask = newmask;

  sigset_t *pold = (sigset_t *)xmalloc (sizeof(sigset_t));
  *pold = old;
  add_unwind_protect (xfree, pold);
  add_unwind_protect (restore_process_sigmask, pold);

  sigprocmask (SIG_SETMASK, &newmask, NULL);

  QUIT;
  
  int caught = 0;
  for (int i = 1; i < NSIG; i++)
    {
      if (sigismember(&unblocked, i) && pending_traps[i])
	{
	  caught = i;
	  break;
	}
    }

  if (caught)
    {
      run_pending_traps ();
      run_unwind_frame ("sigunmask");
      return (128 + caught);
    }

  run_pending_traps();
  
  int result;
  COMMAND *cmd = make_bare_simple_command (line_number);
  cmd->value.Simple->words = copy_word_list (list);
  
  result = execute_command (cmd);
  
  dispose_command (cmd);
  
  run_unwind_frame ("sigunmask");

  return (result);
}

char *sigmask_doc[] = {
    "Block or unblock signals.",
    "",
    "L_builtin sigmask [-s sigspec] [-u sigspec] [sigspec ...]",
    "",
    "Block or unblock signals in the shell process. Without options, it",
    "prints the current signal mask. -s blocks, -u unblocks.",
    (char *)NULL
};

char *sigunmask_doc[] = {
    "Unblock signals and run a command.",
    "",
    "L_builtin sigunmask [-h] -s sigspec cmd [args...]",
    "",
    "Temporarily unblocks the specified signal and executes the command.",
    "If the signal was pending, the trap is executed and the command is skipped.",
    "The command can be any shell command (builtin, function, or external).",
    "",
    "WARNING: There is a small window between unblocking and starting the command.",
    "If a signal arrives in this window, it may be delivered to the command itself",
    "rather than being caught by this builtin's check.",
    (char *)NULL
};
