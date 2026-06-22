#ifndef L_BUILTIN_H
#define L_BUILTIN_H

#include "builtins.h"

int lseek_subcommand(WORD_LIST *list);
int select_subcommand(WORD_LIST *list);

extern char *lseek_doc[];
extern char *select_doc[];

#endif
