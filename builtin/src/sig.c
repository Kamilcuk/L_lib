#include <config.h>
#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>

#include "builtins.h"
#include "shell.h"
#include "common.h"
#include "bashgetopt.h"
#include "execute_cmd.h"
#include "make_cmd.h"
#include "quit.h"
#include "sig.h"
#include "trap.h"
#include "unwind_prot.h"
#include "L_builtin.h"

/* Missing extern declarations from Bash headers */
extern sigset_t top_level_mask;
extern int pending_traps[NSIG];
extern int line_number;

static void restore_process_sigmask(void *arg)
{
  sigset_t *mask = (sigset_t *)arg;
  sigprocmask(SIG_SETMASK, mask, NULL);
}

static int parse_sigspec(WORD_LIST *list, sigset_t *set)
{
  int sig;
  while (list) {
    if (strcasecmp(list->word->word, "all") == 0) {
      sigfillset(set);
    } else {
      sig = decode_signal(list->word->word, DSIG_NOCASE | DSIG_SIGPREFIX);
      if (sig == NO_SIG) {
        sh_invalidsig(list->word->word);
        return -1;
      }
      sigaddset(set, sig);
    }
    list = list->next;
  }
  return 0;
}

int sigmask_subcommand(WORD_LIST *list)
{
  sigset_t block_set, unblock_set, old;
  int opt;
  int any_opt = 0;
  int has_block = 0;
  int has_unblock = 0;

  sigemptyset(&block_set);
  sigemptyset(&unblock_set);

  reset_internal_getopt();
  while ((opt = internal_getopt(list, "s:u:h")) != -1) {
    any_opt = 1;
    switch (opt) {
    case 's':
      if (strcasecmp(list_optarg, "all") == 0) {
        sigfillset(&block_set);
        has_block = 1;
      } else {
        int s = decode_signal(list_optarg, DSIG_NOCASE | DSIG_SIGPREFIX);
        if (s == NO_SIG) {
          sh_invalidsig(list_optarg);
          return (EXECUTION_FAILURE);
        }
        sigaddset(&block_set, s);
        has_block = 1;
      }
      break;
    case 'u':
      if (strcasecmp(list_optarg, "all") == 0) {
        sigfillset(&unblock_set);
        has_unblock = 1;
      } else {
        int s = decode_signal(list_optarg, DSIG_NOCASE | DSIG_SIGPREFIX);
        if (s == NO_SIG) {
          sh_invalidsig(list_optarg);
          return (EXECUTION_FAILURE);
        }
        sigaddset(&unblock_set, s);
        has_unblock = 1;
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

  if (any_opt == 0 && list == 0) {
    sigemptyset(&block_set);
    if (sigprocmask(SIG_BLOCK, &block_set, &old) < 0) {
      builtin_error("sigprocmask: %s", strerror(errno));
      return (EXECUTION_FAILURE);
    }
    for (int i = 1; i < NSIG; i++) {
      if (sigismember(&old, i))
        printf("%s ", signal_name(i));
    }
    printf("\n");
    return (EXECUTION_SUCCESS);
  }

  if (list) {
    if (parse_sigspec(list, &block_set) < 0)
      return (EXECUTION_FAILURE);
    has_block = 1;
  }

  if (has_block) {
    if (sigprocmask(SIG_BLOCK, &block_set, &old) < 0) {
      builtin_error("sigprocmask (block): %s", strerror(errno));
      return (EXECUTION_FAILURE);
    }
  }

  if (has_unblock) {
    if (sigprocmask(SIG_UNBLOCK, &unblock_set, &old) < 0) {
      builtin_error("sigprocmask (unblock): %s", strerror(errno));
      return (EXECUTION_FAILURE);
    }
  }

  /* Update top_level_mask so it persists across command executions. */
  sigprocmask(SIG_BLOCK, NULL, &top_level_mask);

  return (EXECUTION_SUCCESS);
}

int sigunmask_subcommand(WORD_LIST *list)
{
  sigset_t set, old, unblocked;
  int opt;

  sigemptyset(&unblocked);
  reset_internal_getopt();
  while ((opt = internal_getopt(list, "s:h")) != -1) {
    switch (opt) {
    case 's':
      if (strcasecmp(list_optarg, "all") == 0) {
        sigfillset(&unblocked);
      } else {
        int sig = decode_signal(list_optarg, DSIG_NOCASE | DSIG_SIGPREFIX);
        if (sig == NO_SIG) {
          sh_invalidsig(list_optarg);
          return (EXECUTION_FAILURE);
        }
        sigaddset(&unblocked, sig);
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

  if (list == 0) {
    builtin_usage();
    return (EX_USAGE);
  }

  sigemptyset(&set);
  if (sigprocmask(SIG_BLOCK, &set, &old) < 0) {
    builtin_error("sigprocmask: %s", strerror(errno));
    return (EXECUTION_FAILURE);
  }

  sigset_t newmask = old;
  for (int i = 1; i < NSIG; i++) {
    if (sigismember(&unblocked, i))
      sigdelset(&newmask, i);
  }

  begin_unwind_frame("sigunmask");

  unwind_protect_mem((char *)&top_level_mask, sizeof(sigset_t));
  top_level_mask = newmask;

  sigset_t *pold = (sigset_t *)xmalloc(sizeof(sigset_t));
  *pold = old;
  add_unwind_protect(xfree, pold);
  add_unwind_protect(restore_process_sigmask, pold);

  if (sigprocmask(SIG_SETMASK, &newmask, NULL) < 0) {
    builtin_error("sigprocmask: %s", strerror(errno));
    run_unwind_frame("sigunmask");
    return (EXECUTION_FAILURE);
  }

  QUIT;

  int caught = 0;
  for (int i = 1; i < NSIG; i++) {
    if (sigismember(&unblocked, i) && pending_traps[i]) {
      caught = i;
      break;
    }
  }

  if (caught) {
    run_pending_traps();
    run_unwind_frame("sigunmask");
    return (128 + caught);
  }

  run_pending_traps();

  int result;
#if defined(BASH_MAJOR_VERSION) && BASH_MAJOR_VERSION < 5
  COMMAND *cmd = make_bare_simple_command();
#else
  COMMAND *cmd = make_bare_simple_command(line_number);
#endif
  cmd->value.Simple->words = copy_word_list(list);

  result = execute_command(cmd);

  dispose_command(cmd);

  run_unwind_frame("sigunmask");

  return (result);
}

char *sigmask_doc[] = {
  "Block or unblock signals.",
  "",
  "L_builtin sigmask [-s sigspec] [-u sigspec] [sigspec ...]",
  "",
  "Block or unblock signals in the shell process. Without options, it",
  "prints the current signal mask. -s blocks, -u unblocks.",
  "Use 'ALL' (case-insensitive) with -s or -u to block or unblock all",
  "signals respectively. Positional arguments are always blocked.",
  "",
  "Exit Status:",
  "Returns success unless an invalid signal is provided or a system error "
  "occurs.",
  (char *)NULL
};

char *sigunmask_doc[] = {
  "Unblock signals and run a command.",
  "",
  "L_builtin sigunmask [-h] -s sigspec cmd [args...]",
  "",
  "Temporarily unblocks the specified signal and executes the command.",
  "Use 'ALL' (case-insensitive) with -s to unblock all signals.",
  "If the signal was pending, the trap is executed and the command is "
  "skipped.",
  "The command can be any shell command (builtin, function, or external).",
  "",
  "WARNING: There is a small window between unblocking and starting the "
  "command.",
  "If a signal arrives in this window, it may be delivered to the command "
  "itself",
  "rather than being caught by this builtin's check.",
  "",
  "Exit Status:",
  "Returns the status of the command, or 128+signum if a signal was caught.",
  (char *)NULL
};
