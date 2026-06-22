#ifndef L_BUILTIN_H
#define L_BUILTIN_H

#include "builtins.h"

int lseek_subcommand(WORD_LIST *list);
int poll_subcommand(WORD_LIST *list);
#ifdef HAVE_PPOLL
int ppoll_subcommand(WORD_LIST *list);
#endif
int sigmask_subcommand(WORD_LIST *list);
int sigunmask_subcommand(WORD_LIST *list);
int pipe_subcommand(WORD_LIST *list);

#ifdef HAVE_LUA
int lua_subcommand(WORD_LIST *list);
#endif

extern char *lseek_doc[];
extern char *poll_doc[];
#ifdef HAVE_PPOLL
extern char *ppoll_doc[];
#endif
extern char *sigmask_doc[];
extern char *sigunmask_doc[];
extern char *pipe_doc[];

#ifdef HAVE_LUA
extern char *lua_doc[];
#endif

#endif
