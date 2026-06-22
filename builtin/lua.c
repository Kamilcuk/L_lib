#include <config.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include "builtins.h"
#include "shell.h"
#include "bashgetopt.h"
#include "common.h"
#include "variables.h"
#include "array.h"
#include "execute_cmd.h"
#include "make_cmd.h"
#include "subst.h"
#include "L_builtin.h"

static lua_State *L = NULL;

static int
l_bash_get (lua_State *L)
{
  const char *name = luaL_checkstring (L, 1);
  SHELL_VAR *v = find_variable ((char *)name);
  if (v && !invisible_p (v))
    {
      char *val = get_variable_value (v);
      if (val)
	lua_pushstring (L, val);
      else
	lua_pushstring (L, "");
    }
  else
    lua_pushnil (L);
  return 1;
}

static int
l_bash_set (lua_State *L)
{
  const char *name = luaL_checkstring (L, 1);
  const char *value = luaL_checkstring (L, 2);
  
  SHELL_VAR *v = find_variable ((char *)name);
  if (v && readonly_p (v))
    return luaL_error (L, "bash error: variable %s is read-only", name);

  if (bind_variable ((char *)name, (char *)value, 0) == NULL)
    return luaL_error (L, "bash error: failed to set variable %s", name);

  return 0;
}

static int
l_bash_get_array (lua_State *L)
{
  const char *name = luaL_checkstring (L, 1);
  SHELL_VAR *v = find_variable ((char *)name);
  if (!v || invisible_p (v) || !array_p (v))
    {
      lua_pushnil (L);
      return 1;
    }
  
  ARRAY *a = array_cell (v);
  lua_newtable (L);
  if (!a) return 1;

  ARRAY_ELEMENT *ae;
  int i = 1;
  for (ae = element_forw(a->head); ae != a->head; ae = element_forw(ae))
    {
      char *val = element_value (ae);
      lua_pushstring (L, val ? val : "");
      lua_rawseti (L, -2, i++);
    }
  return 1;
}

static int
l_bash_set_array (lua_State *L)
{
  const char *name = luaL_checkstring (L, 1);
  luaL_checktype (L, 2, LUA_TTABLE);

  SHELL_VAR *v = find_variable ((char *)name);
  if (v)
    {
      if (readonly_p (v))
	return luaL_error (L, "bash error: variable %s is read-only", name);
      if (!array_p (v))
	return luaL_error (L, "bash error: %s is not an indexed array", name);
    }
  else
    {
      v = make_new_array_variable ((char *)name);
    }

  if (!v)
    return luaL_error (L, "bash error: failed to create array variable %s", name);
  
  ARRAY *a = array_cell (v);
  if (!a) return luaL_error (L, "bash error: internal array error for %s", name);
  
  array_flush (a);

  int n = lua_objlen (L, 2);
  for (int i = 1; i <= n; i++)
    {
      lua_rawgeti (L, 2, i);
      const char *val = lua_tostring (L, -1);
      if (val)
	array_insert (a, i - 1, (char *)val);
      lua_pop (L, 1);
    }
  return 0;
}

static int
l_bash_call (lua_State *L)
{
  const char *name = luaL_checkstring (L, 1);
  SHELL_VAR *v = find_function (name);
  if (!v)
    return luaL_error (L, "bash error: function not found: %s", name);

  WORD_LIST *list = NULL;
  int n = lua_gettop (L);
  
  for (int i = n; i >= 2; i--)
    {
      const char *arg = lua_tostring (L, i);
      if (!arg) arg = "";
      list = make_word_list (make_word (arg), list);
    }

  list = make_word_list (make_word (name), list);

  int ret = execute_shell_function (v, list);
  dispose_words (list);

  lua_pushinteger (L, ret);
  return 1;
}

static int
l_bash_expand (lua_State *L)
{
  const char *s = luaL_checkstring (L, 1);
  char *expanded = expand_string_to_string ((char *)s, Q_DOUBLE_QUOTES);
  lua_pushstring (L, expanded ? expanded : "");
  if (expanded) free (expanded);
  return 1;
}

static int
l_bash_expand_list (lua_State *L)
{
  const char *s = luaL_checkstring (L, 1);
  WORD_LIST *list = expand_string ((char *)s, 0);
  
  lua_newtable (L);
  if (list)
    {
      int i = 1;
      WORD_LIST *l;
      for (l = list; l; l = l->next)
	{
	  lua_pushstring (L, l->word->word ? l->word->word : "");
	  lua_rawseti (L, -2, i++);
	}
      dispose_words (list);
    }
  return 1;
}

static void
init_lua (void)
{
  if (L) return;
  L = luaL_newstate ();
  if (!L) return;
  luaL_openlibs (L);

  lua_newtable (L);
  lua_pushcfunction (L, l_bash_get);
  lua_setfield (L, -2, "get");
  lua_pushcfunction (L, l_bash_set);
  lua_setfield (L, -2, "set");
  lua_pushcfunction (L, l_bash_get_array);
  lua_setfield (L, -2, "get_array");
  lua_pushcfunction (L, l_bash_set_array);
  lua_setfield (L, -2, "set_array");
  lua_pushcfunction (L, l_bash_call);
  lua_setfield (L, -2, "call");
  lua_pushcfunction (L, l_bash_expand);
  lua_setfield (L, -2, "expand");
  lua_pushcfunction (L, l_bash_expand_list);
  lua_setfield (L, -2, "expand_list");
  lua_setglobal (L, "bash");
}

int
lua_subcommand (WORD_LIST *list)
{
  char *script = NULL;
  char *ret_var = NULL;
  int opt;

  init_lua ();
  if (!L)
    {
      builtin_error ("lua error: failed to initialize Lua state");
      return (EXECUTION_FAILURE);
    }

  reset_internal_getopt ();
  while ((opt = internal_getopt (list, "e:v:h")) != -1)
    {
      switch (opt)
	{
	case 'e': script = list_optarg; break;
	case 'v': ret_var = list_optarg; break;
	case 'h':
	case GETOPT_HELP: builtin_usage (); return (EX_USAGE);
	default: builtin_usage (); return (EX_USAGE);
	}
    }
  list = loptend;

  if (script == NULL && list == 0)
    {
      builtin_usage ();
      return (EX_USAGE);
    }

  lua_newtable (L);
  int i = 1;
  while (list)
    {
      lua_pushstring (L, list->word->word);
      lua_rawseti (L, -2, i++);
      list = list->next;
    }
  lua_setglobal (L, "arg");

  int status;
  if (script)
    status = luaL_dostring (L, script);
  else
    status = luaL_dostring (L, loptend->word->word);

  if (status != 0)
    {
      builtin_error ("lua error: %s", lua_tostring (L, -1));
      lua_pop (L, 1);
      return (EXECUTION_FAILURE);
    }

  if (ret_var && lua_gettop (L) > 0)
    {
      const char *res = lua_tostring (L, -1);
      if (res)
	{
	  if (bind_variable (ret_var, (char *)res, 0) == NULL)
	    builtin_error ("%s: cannot bind return value", ret_var);
	}
      lua_pop (L, 1);
    }

  return (EXECUTION_SUCCESS);
}

char *lua_doc[] = {
    "Execute LuaJIT script.",
    "",
    "L_builtin lua [-e SCRIPT] [-v VAR] [args...]",
    "",
    "Execute Lua code within the shell process. The Lua state persists",
    "between calls. A global 'bash' table provides get/set access to",
    "shell variables (including arrays), function calls, and expansions.",
    "",
    "bash.get(name)           - Get a scalar variable (returns nil if not found)",
    "bash.set(name, val)      - Set a scalar variable (errors if read-only)",
    "bash.get_array(name)     - Get an indexed array as a table",
    "bash.set_array(name, t)  - Set an indexed array from a table",
    "bash.call(name, ...)     - Call a Bash function and return exit status",
    "bash.expand(s)           - Expand string s (vars, arithmetic, subshell)",
    "bash.expand_list(s)      - Expand string s into a list (splitting/globbing)",
    "",
    "Exit Status:",
    "Returns success unless a Lua error or a Bash binding error occurs.",
    (char *)NULL
};
