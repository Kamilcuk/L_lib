#!/usr/bin/env bash

. bin/L_lib.sh

# action... \t index multi \t source function \t signals... \n
C_wordlist() {
  declare -g _L_finally_data=""
  finally() {
    local i signals="$1"
    printf -v i "%q " "${@:2}"
    printf -v _L_finally_data "%s%s #\t%s %s\t%q %s\t%s\n" \
      "$_L_finally_data" "$i" 0 0 "${BASH_SOURCE[0]}" "${FUNCNAME[1]}" " $signals "
  }
  handler() {
    local L_SIGNAL="$1" _L_location="${2:-}" _L_i _L_p=$'+([^\t\n])'
	  _L_i=${_L_finally_data//$'\t'$_L_p$'\t'$_L_p$'\t'$_L_p $L_SIGNAL $_L_p$'\n'/$'\n'}
	  _L_finally_data=${_L_finally_data//$_L_p$'\t'$_L_p" 0"$'\t'$_L_p$'\t'$_L_p" $L_SIGNAL "$_L_p$'\n'}
	  eval "${_L_i//$_L_p$'\t'$_L_p$'\t'$_L_p$'\t'$_L_p$'\n'}"
	}
}

# ( signals "source function" index multi action )
#      1          2             3     4      5
C_array() {
  declare -ga _L_finally_arr=()
  finally() {
    local i
    printf -v i " %q" "${@:2}"
    _L_finally_arr+=(" $1 " "${BASH_SOURCE[0]} ${FUNCNAME[1]}" 0 0 "${i# }")
  }
  handler() {
    local L_SIGNAL="$1" _L_i=0
    while ((_L_i < ${#_L_finally_arr[@]})); do
      if [[ " ${_L_finally_arr[_L_i]} " == *" $L_SIGNAL "* ]]; then
        # eval "${_L_finally_arr[_L_i+4]}"
        _L_finally_arr=("${_L_finally_arr[@]::_L_i}" "${_L_finally_arr[@]:_L_i+5}")
        _L_i+=5
      else
        _L_i+=5
      fi
    done
  }
}

C_arraydyn() {
  declare -ga _L_finally_arr=()
  finally() {
    local signals="$1"
    shift
    _L_finally_arr+=(
      "$(($# + 6))"
      " $signals "
      "${BASH_SOURCE[0]}"
      "${FUNCNAME[1]}"
      0
      0
      "$@"
     )
   }
  handler() {
    local _L_i _L_e
    while (( _L_i < ${#_L_finally_arr[@]} )); do
      local _L_e=$(( _L_i + _L_finally_arr[_L_i] ))
      if [[ "${_L_finally_arr[_L_i+1]}" == *" $1 "* ]]; then
        eval "${_L_finally_arr[@]:_L_i+6:_L_finally_arr[_L_i]-6}"
        _L_finally_arr=(
          "${_L_finally_arr[@]:0:_L_i}"
          "${_L_finally_arr[@]:_L_i + _L_finally_arr[_L_i]}"
        )
      else
        _L_i=$((_L_i + _L_finally_arr[_L_i]))
      fi
    done
  }
}



C_nested() {
  declare -ga _L_FINALLY=()
  finally() {
    local i
    printf -v i " %q" "${@:2}"
    printf -v i "%s , 0 %q %q%s" " $1 " "${BASH_SOURCE[0+up]}" "${FUNCNAME[1+up]}" "$i"
    _L_FINALLY+=("$i")
  }
  handler() {
    local L_SIGNAL="$1" _L_i
    for ((_L_i = ${#_L_FINALLY[@]} - 1; _L_i >= 0; --_L_i)); do
      if [[ " ${_L_FINALLY[_L_i]%%,*} " == *" $L_SIGNAL "* ]]; then
        local -a _L_e="(${_L_FINALLY[_L_i]#*,})"
        if ((!_L_e[L_i])); then
          unset "_L_FINALLY[$_L_i]"
        fi
        "${_L_e[@]:3}"
      fi
    done
  }
}

C_nested2() {
  declare -ga _L_FINALLY=()
  finally() {
    local i
    printf -v i " %q" "${@:2}"
    printf -v i "%s , %s #\t %q %q" " $1 " "$i" "${BASH_SOURCE[0+up]}" "${FUNCNAME[1+up]}"
    _L_FINALLY+=("$i")
  }
  handler() {
    local L_SIGNAL="$1" _L_i _L_e
    for ((_L_i = ${#_L_FINALLY[@]} - 1; _L_i >= 0; --_L_i)); do
      if [[ " ${_L_FINALLY[_L_i]%%,*} " == *" $L_SIGNAL "*${_L_location:+$'\t'$_L_location} ]]; then
        _L_e=${_L_FINALLY[_L_i]#*,}
        unset "_L_FINALLY[$_L_i]"
        eval "${_L_e##\#$'\t'*}"
      fi
    done
  }
}

C_nested3() {
  declare -ga _L_FINALLY=()
  finally() {
    local i
    printf -v i " %q" "${@:2}"
    printf -v i "%s\t%s #\2%d\3%d\t%q %s" "$1" "${i# }" "1" "2" "${BASH_SOURCE[0+up]}" "${FUNCNAME[1+up]}"
    _L_FINALLY+=("$i")
  }
  handler() {
    local L_SIGNAL="$1" _L_i=0 _L_e IFS=$'\t'
    while ((_L_i < ${#_L_FINALLY[@]})); do
      if [[ " ${_L_FINALLY[_L_i]%%$'\t'*} " == *" $L_SIGNAL "*${_L_location:+$'\t'$_L_location} ]]; then
        _L_e=${_L_FINALLY[_L_i]#*$'\t'}
        if [[ "$_L_e" == *$'\2'"0"$'\3'* ]]; then
          _L_FINALLY=("${_L_FINALLY[@]::_L_i}" "${_L_FINALLY[@]:_L_i+1}")
        else
          _L_i=$((_L_i+1))
        fi
        eval "$_L_e"
      else
        _L_i=$((_L_i+1))
      fi
    done
  }
}

C_nested4() {
  declare -ga _L_finally_arr=()
  # =( # signals... \t multi index \t source func \t action... )
  finally() {
    local i j signals="$1"
    shift
    printf -v i " %q" "$@"
    printf -v j "%q" "${BASH_SOURCE[0]}"
    _L_finally_arr+=("# $signals "$'\t'"0 0"$'\t'"$j ${FUNCNAME[1]}"$'\t'"${i# }"$'\n')
  }
  handler() {
    local L_SIGNAL="$1" _L_location="${2:-*}"
    eval "${_L_finally_arr[@]###* $L_SIGNAL *$'\t'*$'\t'$_L_location$'\t'}"
    _L_finally_arr=("${_L_finally_arr[@]###* $L_SIGNAL *$'\t'0 *$'\t'$_L_location$'\t'*}")
  }
}

C_wordlist2() {
  declare -g _L_finally_data=""
  # =( # signals... \t multi index \t source func \t action... )
  finally() {
    local i j signals="$1"
    shift
    printf -v i " %q" "$@"
    printf -v j "%q" "${BASH_SOURCE[0]}"
    _L_finally_data+=$'\t'"# $signals "$'\t'"0 0"$'\t'"$j ${FUNCNAME[1]}"$'\t'"${i# }"$'\n'
  }
  handler() {
    local L_SIGNAL="$1" _L_location="${2:-}" _L_p=$'*([^\t\n])'
    eval "${_L_finally_data//$'\t'#$_L_p $L_SIGNAL $_L_p$'\t'$_L_p$'\t'${_L_location:-$_L_p}$'\t'}"
    _L_finally_data="${_L_finally_data//$'\t'#$_L_p $L_SIGNAL $_L_p$'\t'0 $_L_p$'\t'${_L_location:-$_L_p}$'\t'$_L_p$'\n'}"
  }
}


setup() {
  finally EXIT echo 1
  finally EXIT echo 2
  finally INT echo 2
  finally 'EXIT INT' echo 3
  finally EXIT echo 4
}

shopt -s extglob
if [[ "${1:-}" == -d ]]; then
  set -x
  ./scripts/perfbash "$@" \
    'bash ./scripts/finally_speed.sh C_'{array,nested,nested2,nested3}' >/dev/null'
elif (($#)); then
  C_"$1"
  setup
  handler EXIT
else
  for i in $(compgen -A function C_); do
    "$i"
    a=$(
      setup
      time handler EXIT
    )
    if [[ "$a" != $'1\n2\n3\n4' ]]; then
      echo "$i" ERROR
    else
      echo "$i" OK
    fi
  done
fi
