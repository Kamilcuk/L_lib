#ifndef L_BUILTIN_H
#define L_BUILTIN_H

struct word_list;

#ifndef GETOPT_HELP
#define GETOPT_HELP -99
#endif

int lseek_subcommand(struct word_list *list);
int poll_subcommand(struct word_list *list);
#ifdef HAVE_PPOLL
int ppoll_subcommand(struct word_list *list);
#endif
int sigmask_subcommand(struct word_list *list);
int sigunmask_subcommand(struct word_list *list);
int pipe_subcommand(struct word_list *list);
int listen_subcommand(struct word_list *list);
int accept_subcommand(struct word_list *list);
int connect_subcommand(struct word_list *list);
int shutdown_subcommand(struct word_list *list);
int send_subcommand(struct word_list *list);
int recv_subcommand(struct word_list *list);
int sleep_subcommand(struct word_list *list);

#ifdef HAVE_LUA
int lua_subcommand(struct word_list *list);
#endif

extern char *lseek_doc[];
extern char *poll_doc[];
#ifdef HAVE_PPOLL
extern char *ppoll_doc[];
#endif
extern char *sigmask_doc[];
extern char *sigunmask_doc[];
extern char *pipe_doc[];
extern char *listen_doc[];
extern char *accept_doc[];
extern char *connect_doc[];
extern char *shutdown_doc[];
extern char *send_doc[];
extern char *recv_doc[];
extern char *sleep_doc[];

#ifdef HAVE_LUA
extern char *lua_doc[];
#endif

#endif
