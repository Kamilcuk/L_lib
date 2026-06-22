#ifndef L_BUILTIN_H
#define L_BUILTIN_H

#include "builtins.h"

int lseek_subcommand(WORD_LIST *list);
int poll_subcommand(WORD_LIST *list);
int ppoll_subcommand(WORD_LIST *list);
int sigmask_subcommand(WORD_LIST *list);
int sigunmask_subcommand(WORD_LIST *list);
int pipe_subcommand(WORD_LIST *list);

extern char *lseek_doc[];
extern char *poll_doc[];
extern char *ppoll_doc[];
extern char *sigmask_doc[];
extern char *sigunmask_doc[];
extern char *pipe_doc[];

#endif
