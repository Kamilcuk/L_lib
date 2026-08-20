#!/bin/bash
set -euo pipefail

# . ./bin/L_lib.sh -s -n

shopt -s extglob

###############################################################################
# L_yaml.sh -- a small streaming, indentation-based YAML parser for bash,
# written in the same callback style as L_json.sh (start/end/key/value cb).
#
# Supported subset:
#   - Block mappings:  key: value   /   key:\n  nested...
#   - Block sequences: - item       /   - \n  nested...
#   - Sequence items that are themselves mappings: "- key: value"
#   - Flow collections on a single line: {a: 1, b: [1,2,3]}  and  [1,2,3]
#   - Scalars: single/double quoted strings, plain scalars, ints/floats,
#     true/false (any case), null/~/empty
#   - '#' comments (outside of quotes) and blank lines
#   - '---' document start / '...' document end markers (skipped)
#
# NOT supported (out of scope for this "parsing loop"):
#   - anchors & aliases (&x / *x), tags (!!str), merge keys (<<)
#   - block scalars (| and >) beyond simple literal capture is not attempted
#   - multi-line flow collections
#   - multiple documents (only the first / only one stream is read)
#   - the comment stripper is quote-aware but plain (unquoted) scalars can
#     legitimately contain a stray ' or " (e.g. "it's fine"); such a
#     scalar can confuse the comment stripper into treating what follows
#     as still "inside a string". Quote your scalars if they contain
#     apostrophes/quotes and need a trailing comment on the same line.
#
# Callback protocol (mirrors L_json.sh's _L_json_read):
#   "$_L_yaml_cb" start "{"|"["      -- context = the container's own path
#   "$_L_yaml_cb" key   "<name>"     -- context = the *parent* map's path
#   "$_L_yaml_cb" value "<json>" <string|number|bool|null>
#                                    -- context = path of the value itself
#   "$_L_yaml_cb" end   "}"|"]"      -- context = the container's own path
#
# The path/context is a tab-separated string identical in shape to
# L_json.sh's $_L_json_context, e.g. $'\t"a"\t0\t"b"', so that
# L_json_to_obj-style consumers (see L_yaml_to_obj below) work unchanged.
###############################################################################

# @description JSON-escape and quote a raw (already unescaped) string.
_L_json_quote_vL_RET() {
	local _L_s="$1" _L_out='"' _L_c _L_i
	for (( _L_i=0; _L_i<${#_L_s}; _L_i++ )); do
		_L_c="${_L_s:_L_i:1}"
		case "$_L_c" in
			'"') _L_out+='\"' ;;
			'\') _L_out+='\\' ;;
			$'\n') _L_out+='\n' ;;
			$'\t') _L_out+='\t' ;;
			$'\r') _L_out+='\r' ;;
			*) _L_out+="$_L_c" ;;
		esac
	done
	L_RET="${_L_out}\""
}

# @description Unquote a single- or double-quoted YAML scalar token.
_L_yaml_unquote_vL_RET() {
	local _L_s="$1"
	case "$_L_s" in
		'"'*'"')
			_L_s="${_L_s:1:${#_L_s}-2}"
			# reuse double-quote (JSON-compatible-ish) escaping rules
			_L_s="${_L_s//\\\//\/}"
			eval "L_RET=\$'${_L_s//$'\n'/\\n}'" 2>/dev/null || L_RET="$_L_s"
			;;
		"'"*"'")
			_L_s="${_L_s:1:${#_L_s}-2}"
			L_RET="${_L_s//\'\'/\'}"
			;;
		*)
			L_RET="$_L_s"
			;;
	esac
}

# @description Classify a raw (unquoted) plain scalar as string/number/bool/null.
_L_yaml_scalar_type() {
  case "$1" in
    ""|'~'|null|Null|NULL) _L_yaml_stype=null ;;
    true|True|TRUE|false|False|FALSE) _L_yaml_stype=bool ;;
    *-*([0-9])|*([0-9])|*([0-9]).*([0-9])|*([0-9])e[+-]*([0-9])|*([0-9])E[+-]*([0-9])) _L_yaml_stype=number ;;
    *) _L_yaml_stype=string ;;
  esac
}

# @description Convert a raw scalar token (as found on the line, possibly
# quoted) into a JSON-encoded literal plus its type.
# Sets L_RET (json literal text) and _L_yaml_vtype (string|number|bool|null).
_L_yaml_scalar_to_json() {
	local _L_tok="$1" _L_raw
	case "$_L_tok" in
		'"'*'"'|"'"*"'")
			_L_yaml_unquote_vL_RET "$_L_tok"
			_L_json_quote_vL_RET "$L_RET"
			_L_yaml_vtype=string
			;;
		*)
			_L_raw="$_L_tok"
			_L_yaml_scalar_type "$_L_raw"
			_L_yaml_vtype="$_L_yaml_stype"
			case "$_L_yaml_stype" in
				number) L_RET="$_L_raw" ;;
				bool)
					case "$_L_raw" in
						true|True|TRUE) L_RET=true ;;
						*) L_RET=false ;;
					esac
					;;
				null) L_RET=null ;;
				string) _L_json_quote_vL_RET "$_L_raw" ;;
			esac
			;;
	esac
}

# @description Strip a trailing '# comment' from a line, respecting quotes.
# A '#' only starts a comment when preceded by start-of-line or whitespace.
_L_yaml_strip_comment_vL_RET() {
	if [[ "$1" =~ $_L_yaml_comment_re ]]; then
		L_RET="${BASH_REMATCH[1]}"
	else
		# trim trailing spaces/tabs
		L_RET="${1%%*([$' \t'])}"
	fi
}

###############################################################################
# Flow collections ({...} / [...]) -- parsed with a small recursive-descent
# reader over a plain string, independent of line/indent tracking.
###############################################################################

_L_yaml_flow_lstrip() { _L_yaml_flow=${_L_yaml_flow#"${_L_yaml_flow%%[!$' \t']*}"}; }

_L_yaml_split_colon_re=$'^("([^"\x01-\x1f\\]|\\\\["\\\\/bfnrt]|\\\\u[0-9a-fA-F]{4})*"|\'([^\']|\'\')*\'|[^"\'[:space:]#,{}&*!%@`|?-]+)[ \t]*:[ \t]*'
_L_yaml_token_re=$'("([^"\x01-\x1f\\]|\\\\["\\\\/bfnrt]|\\\\u[0-9a-fA-F]{4})*"|\'([^\']|\'\')*\'|[]{}:,[]})'
_L_yaml_comment_re=$'^(#|(("([^"\\]|\\.)*")|(\'[^\']*\')|[^\"\'\#])*)[ \t]\#[ \t]*'

# Reads one flow scalar token, stopping at , ] } : (outside quotes).
_L_yaml_flow_read_token_vL_RET() {
	if [[ "$_L_yaml_flow" =~ $_L_yaml_token_re ]]; then
		L_RET="${BASH_REMATCH[0]}"
	else
		L_RET="$_L_yaml_flow"
	fi
	# trim trailing spaces/tabs
	L_RET="${L_RET%%*([$' \t'])}"
	_L_yaml_flow=${_L_yaml_flow::${#_L_yaml_flow}-${#L_RET}}
}

# @description Parse a flow value (scalar, {..} or [..]) at the current
# $_L_yaml_flow position, emitting cb events under context $1.
_L_yaml_flow_read_value() {
	local _L_ctx="$1"
	_L_yaml_flow_lstrip
	case "$_L_yaml_flow" in
		'{'*)
			_L_yaml_context="$_L_ctx"; "$_L_yaml_cb" start "{" || return
			_L_yaml_flow="${_L_yaml_flow:1}"; _L_yaml_flow_lstrip
			if [[ "$_L_yaml_flow" == '}'* ]]; then
				_L_yaml_flow="${_L_yaml_flow:1}"
			else
				while (( 1 )); do
					_L_yaml_flow_lstrip
					_L_yaml_flow_read_token_vL_RET; local _L_key="$L_RET"
					_L_yaml_unquote_vL_RET "$_L_key"; local _L_keyname="$L_RET"
					_L_yaml_flow_lstrip
					_L_yaml_flow="${_L_yaml_flow#:}"
					_L_json_quote_vL_RET "$_L_keyname"; local _L_keytok="$L_RET"
					_L_yaml_context="$_L_ctx"; "$_L_yaml_cb" key "$_L_keyname" || return
					_L_yaml_flow_read_value "$_L_ctx"$'\t'"$_L_keytok" || return
					_L_yaml_flow_lstrip
					case "$_L_yaml_flow" in
						,*) _L_yaml_flow="${_L_yaml_flow:1}" ;;
						'}'*) _L_yaml_flow="${_L_yaml_flow:1}"; break ;;
						*) break ;;
					esac
				done
			fi
			_L_yaml_context="$_L_ctx"; "$_L_yaml_cb" end "}" || return
			;;
		'['*)
			_L_yaml_context="$_L_ctx"; "$_L_yaml_cb" start "[" || return
			_L_yaml_flow="${_L_yaml_flow:1}"; _L_yaml_flow_lstrip
			local _L_idx=0
			if [[ "$_L_yaml_flow" == ']'* ]]; then
				_L_yaml_flow="${_L_yaml_flow:1}"
			else
				while (( 1 )); do
					_L_yaml_flow_read_value "$_L_ctx"$'\t'"$_L_idx" || return
					_L_idx=$(( _L_idx + 1 ))
					_L_yaml_flow_lstrip
					case "$_L_yaml_flow" in
						,*) _L_yaml_flow="${_L_yaml_flow:1}" ;;
						']'*) _L_yaml_flow="${_L_yaml_flow:1}"; break ;;
						*) break ;;
					esac
				done
			fi
			_L_yaml_context="$_L_ctx"; "$_L_yaml_cb" end "]" || return
			;;
		*)
			_L_yaml_flow_read_token_vL_RET; local _L_tok="$L_RET"
			_L_yaml_scalar_to_json "$_L_tok"
			_L_yaml_context="$_L_ctx"; "$_L_yaml_cb" value "$L_RET" "$_L_yaml_vtype" || return
			;;
	esac
}

###############################################################################
# Block (indentation based) parsing loop
###############################################################################

# Stack of open containers. Index 0 is a virtual root.
#   _L_yb_indent[d]  -- indentation of the *items* belonging to this frame
#   _L_yb_kind[d]    -- "map" | "seq"
#   _L_yb_ctx[d]     -- this frame's own context path
#   _L_yb_seqn[d]    -- next sequence index to assign (seq frames only)
_L_yb_open() {
	local _L_indent="$1" _L_kind="$2" _L_ctx="$3"
	_L_yb_depth=$(( _L_yb_depth + 1 ))
	_L_yb_indent[_L_yb_depth]="$_L_indent"
	_L_yb_kind[_L_yb_depth]="$_L_kind"
	_L_yb_ctx[_L_yb_depth]="$_L_ctx"
	_L_yb_seqn[_L_yb_depth]=0
	_L_yaml_context="$_L_ctx"
	if [[ "$_L_kind" == map ]]; then
		"$_L_yaml_cb" start "{" || return
	else
		"$_L_yaml_cb" start "[" || return
	fi
}
_L_yb_close() {
	_L_yaml_context="${_L_yb_ctx[_L_yb_depth]}"
	if [[ "${_L_yb_kind[_L_yb_depth]}" == map ]]; then
		"$_L_yaml_cb" end "}" || return
	else
		"$_L_yaml_cb" end "]" || return
	fi
	_L_yb_depth=$(( _L_yb_depth - 1 ))
}
# Emit a null value for a still-pending key/item (no value was ever given).
_L_yb_flush_pending_null() {
	if [[ -n "${_L_yb_pending_ctx:-}" ]]; then
		_L_yaml_context="$_L_yb_pending_ctx"
		"$_L_yaml_cb" value null null || return
		_L_yb_pending_ctx=""
	fi
}

# @description The main YAML parsing loop. Reads $_L_yaml (a full YAML
# document, line-oriented) and invokes callback $1 for every event.
_L_yaml_read() {
	local _L_yaml_cb="$1"
	local -a _L_lines
	mapfile -t _L_lines <<<"$_L_yaml"

	local -a _L_yb_indent=(-1) _L_yb_kind=("") _L_yb_ctx=("") _L_yb_seqn=(0)
	local _L_yb_depth=0
	local _L_yb_pending_ctx="" _L_yb_pending_indent=-1
	local _L_yaml_context=""
	local _L_root_emitted=0 _L_root_is_scalar=0

	local _L_idx _L_line _L_indent _L_content
	for (( _L_idx=0; _L_idx<${#_L_lines[@]}; _L_idx++ )); do
		_L_line="${_L_lines[_L_idx]%$'\r'}"
		_L_yaml_strip_comment_vL_RET "$_L_line"
		_L_line="$L_RET"
		[[ -z "${_L_line//[$' \t']/}" ]] && continue
		if [[ "$_L_line" == "---" || "$_L_line" == "..." ]]; then continue; fi

		[[ "$_L_line" =~ ^([$' ']*) ]]
		_L_indent="${#BASH_REMATCH[1]}"
		_L_content="${_L_line:_L_indent}"

		# Resolve a pending key/item now that we've seen the next real line.
		# A block sequence is allowed to sit at the SAME indent as its
		# parent mapping key (a very common YAML idiom), so treat a dash
		# line at indent == pending indent as "deeper" too.
		if [[ -n "$_L_yb_pending_ctx" ]]; then
			if (( _L_indent > _L_yb_pending_indent )) \
				|| { (( _L_indent == _L_yb_pending_indent )) && [[ "$_L_content" == "-" || "$_L_content" == "- "* ]]; }; then
				local _L_kind=map
				[[ "$_L_content" == "-" || "$_L_content" == "- "* ]] && _L_kind=seq
				_L_yb_open "$_L_indent" "$_L_kind" "$_L_yb_pending_ctx" || return
				_L_yb_pending_ctx=""
			else
				_L_yb_flush_pending_null || return
			fi
		fi

		# Close containers whose item-indent is deeper than this line.
		while (( _L_yb_depth > 0 && _L_yb_indent[_L_yb_depth] > _L_indent )); do
			_L_yb_close || return
		done
		# A same-indent-as-parent-key sequence ends as soon as a non-dash
		# line reappears at that indent (and symmetrically for a dash line
		# hitting a map frame) -- close the mismatched frame.
		if (( _L_yb_depth > 0 )) && [[ "${_L_yb_indent[_L_yb_depth]}" == "$_L_indent" ]]; then
			if [[ "$_L_content" == "-" || "$_L_content" == "- "* ]]; then
				[[ "${_L_yb_kind[_L_yb_depth]}" == map ]] && { _L_yb_close || return; }
			else
				[[ "${_L_yb_kind[_L_yb_depth]}" == seq ]] && { _L_yb_close || return; }
			fi
		fi

		# Unwrap any number of leading "- " sequence markers (handles both
		# plain seq items and "- key: value" seq-of-maps items).
		while [[ "$_L_content" == "-" || "$_L_content" == "- "* ]]; do
			if (( _L_yb_depth == 0 )); then
				_L_yb_open "$_L_indent" seq "" || return
			elif [[ "${_L_yb_indent[_L_yb_depth]}" != "$_L_indent" || "${_L_yb_kind[_L_yb_depth]}" != seq ]]; then
				while (( _L_yb_depth > 0 && _L_yb_indent[_L_yb_depth] >= _L_indent )); do
					_L_yb_close || return
				done
				_L_yb_open "$_L_indent" seq "${_L_yb_ctx[_L_yb_depth]:-}" || return
			fi
			local _L_this_idx="${_L_yb_seqn[_L_yb_depth]}"
			_L_yb_seqn[_L_yb_depth]=$(( _L_yb_seqn[_L_yb_depth] + 1 ))
			local _L_item_ctx="${_L_yb_ctx[_L_yb_depth]}"$'\t'"$_L_this_idx"
			local _L_rest="${_L_content:1}"
			_L_rest="${_L_rest# }"
			if [[ -z "$_L_rest" ]]; then
				_L_yb_pending_ctx="$_L_item_ctx"
				_L_yb_pending_indent="$_L_indent"
				_L_content=""
				break
			fi
			local _L_off=$(( ${#_L_content} - ${#_L_rest} ))
			_L_indent=$(( _L_indent + _L_off ))
			_L_content="$_L_rest"
			# loop again if nested seq ("- - x"); otherwise decide what kind
			# of value this item holds: a map entry, a flow collection, or
			# a plain scalar.
			if [[ "$_L_content" == "-" || "$_L_content" == "- "* ]]; then
				_L_yb_open "$_L_indent" seq "$_L_item_ctx" || return
				continue
			elif [[ "$_L_content" == '{'* || "$_L_content" == '['* ]]; then
				local _L_yaml_flow="$_L_content"
				_L_yaml_flow_read_value "$_L_item_ctx" || return
				_L_content=""
			elif _L_yaml_find_key_colon "$_L_content"; then
				_L_yb_open "$_L_indent" map "$_L_item_ctx" || return
			else
				_L_yaml_scalar_to_json "$_L_content"
				_L_yaml_context="$_L_item_ctx"
				"$_L_yaml_cb" value "$L_RET" "$_L_yaml_vtype" || return
				_L_content=""
			fi
			break
		done
		[[ -z "$_L_content" ]] && continue

		# Flow collection filling an already-pushed map/seq context (from the
		# seq-item unwrap above) is handled by the generic key/scalar code
		# below since _L_yb_depth/_L_yb_ctx now point at the right frame.

		if [[ "$_L_content" == '{'* || "$_L_content" == '['* ]]; then
			# A bare flow collection as a whole line (root, or seq item value).
			local _L_target_ctx=""
			(( _L_yb_depth > 0 )) && _L_target_ctx="${_L_yb_ctx[_L_yb_depth]}"
			local _L_yaml_flow="$_L_content"
			_L_yaml_flow_read_value "$_L_target_ctx" || return
			continue
		fi

		# Mapping entry: KEY: VALUE  (colon followed by space/EOL, outside quotes)
		local _L_key="" _L_val="" _L_is_map_entry=0
		if _L_yaml_find_key_colon "$_L_content"; then
			_L_is_map_entry=1
			_L_key="${_L_yaml_key}"
			_L_val="${_L_yaml_val}"
		fi

		if (( _L_is_map_entry )); then
			if (( _L_yb_depth == 0 )); then
				_L_yb_open "$_L_indent" map "" || return
			elif [[ "${_L_yb_indent[_L_yb_depth]}" != "$_L_indent" || "${_L_yb_kind[_L_yb_depth]}" != map ]]; then
				while (( _L_yb_depth > 0 && _L_yb_indent[_L_yb_depth] > _L_indent )); do
					_L_yb_close || return
				done
				if (( _L_yb_indent[_L_yb_depth] != _L_indent )); then
					_L_yb_open "$_L_indent" map "${_L_yb_ctx[_L_yb_depth]:-}" || return
				fi
			fi
			_L_yaml_unquote_vL_RET "$_L_key"
			local _L_keyname="$L_RET"
			_L_json_quote_vL_RET "$_L_keyname"
			local _L_keytok="$L_RET"
			_L_yaml_context="${_L_yb_ctx[_L_yb_depth]}"
			"$_L_yaml_cb" key "$_L_keyname" || return
			local _L_val_ctx="${_L_yb_ctx[_L_yb_depth]}"$'\t'"$_L_keytok"
			if [[ -z "$_L_val" ]]; then
				_L_yb_pending_ctx="$_L_val_ctx"
				_L_yb_pending_indent="$_L_indent"
			elif [[ "$_L_val" == '{'* || "$_L_val" == '['* ]]; then
				local _L_yaml_flow="$_L_val"
				_L_yaml_flow_read_value "$_L_val_ctx" || return
			else
				_L_yaml_scalar_to_json "$_L_val"
				_L_yaml_context="$_L_val_ctx"
				"$_L_yaml_cb" value "$L_RET" "$_L_yaml_vtype" || return
			fi
		else
			# Plain scalar line: only meaningful as a lone document scalar,
			# or as the (rare) value of a seq item opened above.
			local _L_target_ctx=""
			(( _L_yb_depth > 0 )) && _L_target_ctx="${_L_yb_ctx[_L_yb_depth]}"
			_L_yaml_scalar_to_json "$_L_content"
			_L_yaml_context="$_L_target_ctx"
			"$_L_yaml_cb" value "$L_RET" "$_L_yaml_vtype" || return
		fi
	done

	_L_yb_flush_pending_null || return
	while (( _L_yb_depth > 0 )); do
		_L_yb_close || return
	done
}

_L_yaml_find_key_colon() {
  [[ "$1" =~ $_L_yaml_split_colon_re ]] && {
    _L_yaml_key="${BASH_REMATCH[1]}"
    _L_yaml_val="${1:${#BASH_REMATCH[0]}}"
    _L_yaml_val="${_L_yaml_val%%*([$' \t'])}"
  }
}

###############################################################################
# Convenience wrappers, mirroring L_json.sh's L_json_to_obj / is_valid
###############################################################################

_L_yaml_to_obj_cb() {
	if [[ "$1" == value ]]; then
		_L_a["$_L_yaml_context"]="$2"
	elif [[ "$1" == start && -z "$_L_yaml_context" ]]; then
		_L_a[$'\t__root_type__']="$2"
	fi
}
L_yaml_to_obj() {
	local -n _L_a="$1"
	local _L_yaml="$2"
	_L_a=()
	_L_yaml_read _L_yaml_to_obj_cb
}

L_yaml_is_valid() {
	_L_yaml_cb() { :; }
	local _L_yaml="$1"
	_L_yaml_read _L_yaml_cb
}

_L_yaml_test() {
	_L_yaml_cb() { local IFS=' '; printf '!! %q %s\n' "$_L_yaml_context" "$*"; }
	local _L_yaml="$1"
	_L_yaml_read _L_yaml_cb
}

###############################################################################

_L_YAML_TESTS=(
  # Basic key-value
  "key: value"
  "key: value # comment"

  # Quoted keys/values
  "'single': value"
  '"double": value'
  "'quoted:key': value"
  '"quoted:key": value'

  # Multi-line (block style)
  "key:
    nested: value"

  # Flow collections
  "flow: {a: 1, b: 2}"
  "list: [1, 2, 3]"

  # Special scalars
  "null: ~"
  "bool: true"
  "number: 123"
  "float: 1.23e-4"

  # Edge cases
  "url: http://example.com"
  "hyphen-key: value"
  "empty: ''"
  "space key: value"  # Unquoted key with space (invalid YAML, but test robustness)
  "key:value"        # No space after : (invalid)
  "'': empty string"
  "nested:
    - item1
    - item2"

	$'name: Kamil\ncity: Warsaw\ntags:\n  - dev\n  - poland\nlibs:\n  - name: L_json\n    lang: bash\n  - name: L_yaml\n    lang: bash\nmeta: {ok: true, count: 3}\nempty:\nflow: [1, 2, 3]\n'

$'
# Full-line comment
key: value # trailing comment
quoted: "value # not a comment" # real comment
list: [a, b] # flow comment
nested:
  - item # indented comment
  - "item # in quotes" # outer comment
url: "http://example.com" # URL with :// and comment
empty: ~ # comment after null value
bool: true # comment after boolean
number: 123 # comment after number
'
)

for i in  "${_L_YAML_TESTS[@]}"; do
	echo ---
	echo "$i"
	echo ---
	_L_yaml_test "$i" || exit
	echo
done
exit


if [[ "${1:-}" == demo ]]; then
	_L_yaml_test "$_L_yaml"
	echo "---"
	echo "$_L_yaml"
	echo "---"
	declare -A obj
	L_yaml_to_obj obj "$_L_yaml"
	for k in "${!obj[@]}"; do printf '%q=%s\n' "$k" "${obj[$k]}"; done
fi
