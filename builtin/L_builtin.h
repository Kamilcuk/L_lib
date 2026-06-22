#ifndef L_BUILTIN_H
#define L_BUILTIN_H

#include "builtins.h"

int lseek_subcommand(WORD_LIST *list);
int select_subcommand(WORD_LIST *list);
int pselect_subcommand(WORD_LIST *list);
int sigmask_subcommand(WORD_LIST *list);
int sigunmask_subcommand(WORD_LIST *list);

extern char *lseek_doc[];
extern char *select_doc[];
extern char *pselect_doc[];
extern char *sigmask_doc[];
extern char *sigunmask_doc[];

#endif
