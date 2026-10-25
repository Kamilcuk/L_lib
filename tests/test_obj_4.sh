###############################################################################
# @section obj4
# Tests for L_obj on empty containers (foreach, walk, clear) and L_obj_value_pos.

# ---------------------------------------------------------------------------
# L_obj_foreach on an empty MAP container — callback never invoked, rc=0
# ---------------------------------------------------------------------------
_L_test_obj_4_foreach_empty_map() {
	obj_skip_test
	local obj pos out=""
	cb() { out+="$1:$2:$3:$4"$'\n'; }
	L_obj_set_typed obj = MAP ""
	L_obj_set_map obj em =
	L_obj_pos -v pos obj em
	# The 'em' child is an empty MAP; iterating its children visits none.
	L_obj_foreach "obj+${pos}" cb
	L_unittest_vareq out ""
	# Return code is success (0) even though nothing was iterated.
	L_unittest_checkexit 0 L_obj_foreach "obj+${pos}" cb
}

# ---------------------------------------------------------------------------
# L_obj_foreach on an empty ARRAY container — callback never invoked, rc=0
# ---------------------------------------------------------------------------
_L_test_obj_4_foreach_empty_array() {
	obj_skip_test
	local obj pos out=""
	cb() { out+="$1:$2:$3:$4"$'\n'; }
	L_obj_set_typed obj = MAP ""
	L_obj_set_array obj ea =
	L_obj_pos -v pos obj ea
	L_obj_foreach "obj+${pos}" cb
	L_unittest_vareq out ""
	L_unittest_checkexit 0 L_obj_foreach "obj+${pos}" cb
}

# ---------------------------------------------------------------------------
# L_obj_foreach on a root MAP that has no children — rc=0, no callback
# ---------------------------------------------------------------------------
_L_test_obj_4_foreach_empty_root_map() {
	obj_skip_test
	local obj out=""
	cb() { out+="$1:$2:$3:$4"$'\n'; }
	L_obj_set_typed obj = MAP ""
	# Root is an empty MAP: foreach over the root visits no children.
	L_obj_foreach obj cb
	L_unittest_vareq out ""
	L_unittest_checkexit 0 L_obj_foreach obj cb
}

# ---------------------------------------------------------------------------
# L_obj_foreach on an uninitialized object — not a container, rc=1
# ---------------------------------------------------------------------------
_L_test_obj_4_foreach_uninitialized() {
	obj_skip_test
	local obj out=""
	cb() { out+="$1:$2:$3:$4"$'\n'; }
	obj=()
	L_unittest_checkexit 1 L_obj_foreach obj cb
	L_unittest_vareq out ""
}

# ---------------------------------------------------------------------------
# L_obj_walk on an empty MAP child — START/END emitted for it, no VALUE, rc=0
# ---------------------------------------------------------------------------
_L_test_obj_4_walk_empty_map() {
	obj_skip_test
	local obj out=""
	walkcb() { out+="$*"$'\n'; }
	L_obj_set_typed obj = MAP ""
	L_obj_set_map obj em =
	# Walking the whole object visits the empty 'em' MAP child: START/END only.
	L_obj_walk obj walkcb
	L_unittest_cmd L_regex_match "$out" 'START MAP -- em'
	L_unittest_cmd L_regex_match "$out" 'END MAP -- em'
	L_unittest_cmd ! L_regex_match "$out" 'VALUE '
}

# ---------------------------------------------------------------------------
# L_obj_walk on an empty ARRAY child — START/END emitted for it, no VALUE, rc=0
# ---------------------------------------------------------------------------
_L_test_obj_4_walk_empty_array() {
	obj_skip_test
	local obj out=""
	walkcb() { out+="$*"$'\n'; }
	L_obj_set_typed obj = MAP ""
	L_obj_set_array obj ea =
	L_obj_walk obj walkcb
	L_unittest_cmd L_regex_match "$out" 'START ARRAY -- ea'
	L_unittest_cmd L_regex_match "$out" 'END ARRAY -- ea'
	L_unittest_cmd ! L_regex_match "$out" 'VALUE '
}

# ---------------------------------------------------------------------------
# L_obj_walk on a root empty MAP — START/END for root, no VALUE, rc=0
# ---------------------------------------------------------------------------
_L_test_obj_4_walk_empty_root_map() {
	obj_skip_test
	local obj out=""
	walkcb() { out+="$*"$'\n'; }
	L_obj_set_typed obj = MAP ""
	L_obj_walk obj walkcb
	L_unittest_cmd L_regex_match "$out" 'START MAP --'
	L_unittest_cmd L_regex_match "$out" 'END MAP --'
	L_unittest_cmd ! L_regex_match "$out" 'VALUE '
}

# ---------------------------------------------------------------------------
# L_obj_clear on an empty MAP child — rc=0, stays empty (len=0)
# ---------------------------------------------------------------------------
_L_test_obj_4_clear_empty_map() {
	obj_skip_test
	local obj v pos
	L_obj_set_typed obj = MAP ""
	L_obj_set_map obj em =
	# Clearing an already-empty container must succeed and keep it empty.
	L_obj_clear obj em
	L_obj_len -v v obj em
	L_unittest_vareq v 0
	# Verify it is still usable as a MAP container.
	L_obj_type -v v obj em
	L_unittest_vareq v MAP
	L_obj_set obj em child = "added-after-clear"
	L_obj_get -v v obj em child
	L_unittest_vareq v "added-after-clear"
}

# ---------------------------------------------------------------------------
# L_obj_clear on an empty ARRAY child — rc=0, stays empty (len=0)
# ---------------------------------------------------------------------------
_L_test_obj_4_clear_empty_array() {
	obj_skip_test
	local obj v
	L_obj_set_typed obj = MAP ""
	L_obj_set_array obj ea =
	L_obj_clear obj ea
	L_obj_len -v v obj ea
	L_unittest_vareq v 0
	L_obj_type -v v obj ea
	L_unittest_vareq v ARRAY
	# Still usable as an ARRAY after clearing the empty container.
	L_obj_array_append obj ea += "first"
	L_obj_len -v v obj ea
	L_unittest_vareq v 1
	L_obj_get -v v obj ea 0
	L_unittest_vareq v "first"
}

# ---------------------------------------------------------------------------
# L_obj_clear on a root empty MAP — rc=0, stays empty
# ---------------------------------------------------------------------------
_L_test_obj_4_clear_empty_root_map() {
	obj_skip_test
	local obj v
	L_obj_set_typed obj = MAP ""
	L_obj_clear obj
	L_unittest_checkexit 0 L_obj_len -v v obj
	L_unittest_vareq v 0
	# Re-use the cleared root.
	L_obj_set obj k = "v"
	L_obj_len -v v obj
	L_unittest_vareq v 1
	L_obj_get -v v obj k
	L_unittest_vareq v "v"
}

# ---------------------------------------------------------------------------
# L_obj_clear on an uninitialized object — rc=0 (no-op)
# ---------------------------------------------------------------------------
_L_test_obj_4_clear_uninitialized() {
	obj_skip_test
	local obj
	obj=()
	# Clearing an object that was never given a type is a successful no-op.
	L_unittest_checkexit 0 L_obj_clear obj
}

# ---------------------------------------------------------------------------
# L_obj_value_pos — get value position of a scalar, read obj[pos]
# ---------------------------------------------------------------------------
_L_test_obj_4_value_pos_get_scalar() {
	obj_skip_test
	local obj pos
	L_obj_set obj leaf = "Hello"
	L_obj_value_pos -v pos obj leaf
	# pos points at the value slot; reading obj[pos] yields the scalar value.
	L_unittest_eq "${obj[pos]}" "Hello"
	L_obj_set obj num = 42
	L_obj_value_pos -v pos obj num
	L_unittest_eq "${obj[pos]}" "42"
}

# ---------------------------------------------------------------------------
# L_obj_value_pos — nested path a.b.c
# ---------------------------------------------------------------------------
_L_test_obj_4_value_pos_nested() {
	obj_skip_test
	local obj pos
	L_obj_set obj a b c = "deepval"
	L_obj_value_pos -v pos obj a b c
	L_unittest_eq "${obj[pos]}" "deepval"
}

# ---------------------------------------------------------------------------
# L_obj_value_pos — root scalar value position
# ---------------------------------------------------------------------------
_L_test_obj_4_value_pos_root_scalar() {
	obj_skip_test
	local obj pos v
	L_obj_set obj = "roottest"
	L_obj_value_pos -v pos obj
	L_unittest_eq "${obj[pos]}" "roottest"
}

# ---------------------------------------------------------------------------
# L_obj_value_pos — modify the value in place through the returned position
# ---------------------------------------------------------------------------
_L_test_obj_4_value_pos_modify() {
	obj_skip_test
	local obj pos v
	L_obj_set obj a b c = "Hello"
	L_obj_value_pos -v pos obj a b c
	# Mutate the value directly through the position, then read it back via L_obj_get.
	obj[pos]="world"
	L_obj_get -v v obj a b c
	L_unittest_vareq v "world"
}

# ---------------------------------------------------------------------------
# L_obj_value_pos — non-existent path returns failure
# ---------------------------------------------------------------------------
_L_test_obj_4_value_pos_missing() {
	obj_skip_test
	local obj pos
	L_obj_set obj a = 1
	L_unittest_cmd ! L_obj_value_pos -v pos obj missing nested path
	# pos should be left untouched (or empty) on failure.
}

# ---------------------------------------------------------------------------
# L_obj_copy with the same object as both source and destination.
# The implementation takes a snapshot when the variable name matches, so
# self-copy must be a safe, idempotent operation (result == source).
# ---------------------------------------------------------------------------
_L_test_obj_4_copy_self_root() {
	obj_skip_test
	local obj v a b
	L_obj_set obj a = 1
	L_obj_set obj b = 2
	# Copy the whole object into itself.
	L_obj_copy obj obj
	# Nothing should change: both children still present with original values.
	L_obj_len -v v obj;        L_unittest_vareq v 2
	L_obj_get -v a obj a;      L_unittest_vareq a 1
	L_obj_get -v b obj b;      L_unittest_vareq b 2
}

# Copying a subtree into the very same position of the same object.
_L_test_obj_4_copy_self_same_position() {
	obj_skip_test
	local obj v pos
	L_obj_set obj a b = "val"
	L_obj_pos -v pos obj a
	L_obj_copy "obj+${pos}" "obj+${pos}"
	# The subtree must be untouched.
	L_obj_len -v v obj;      L_unittest_vareq v 1
	L_obj_len -v v obj a;    L_unittest_vareq v 1
	L_obj_get -v v obj a b;  L_unittest_vareq v "val"
}

# Copying one subtree into another subtree of the *same* object.
_L_test_obj_4_copy_self_different_positions() {
	obj_skip_test
	local obj v pa pb
	L_obj_set obj src key = "sourceval"
	L_obj_set obj dst key = "old"
	L_obj_pos -v pa obj src
	L_obj_pos -v pb obj dst
	# src == dst variable name, but different positions -> snapshot protects source.
	L_obj_copy "obj+${pa}" "obj+${pb}"
	# 'dst' now holds a copy of 'src'.
	L_obj_get -v v obj dst key; L_unittest_vareq v "sourceval"
	# 'src' is untouched.
	L_obj_get -v v obj src key; L_unittest_vareq v "sourceval"
	# Root still has exactly two children.
	L_obj_len -v v obj;         L_unittest_vareq v 2
}

# Copying the whole object into its OWN child position. The snapshot must
# preserve the destination path arguments, so the child receives a clean copy
# of the source while the original root is left intact: obj == {a:1, b:{a:1}}.
_L_test_obj_4_copy_self_into_own_child() {
	obj_skip_test
	local obj v
	L_obj_set obj a = 1
	L_obj_copy obj obj b
	# Root now has two children (a and b); b is a copy of the original root.
	L_obj_len -v v obj;      L_unittest_vareq v 2
	L_obj_get -v v obj a;    L_unittest_vareq v 1
	L_obj_len -v v obj b;    L_unittest_vareq v 1
	L_obj_get -v v obj b a;  L_unittest_vareq v 1
}

# ---------------------------------------------------------------------------
# L_obj_merge with the same object as source and destination.
# Merging an object into itself should be idempotent for scalar and nested
# MAP content (every source key is also a destination key -> deep merge).
# ---------------------------------------------------------------------------
_L_test_obj_4_merge_self_scalars() {
	obj_skip_test
	local obj v a b
	L_obj_set obj a = 1
	L_obj_set obj b = 2
	# Self-merge of scalar-valued map: each key merges with itself.
	L_obj_merge obj obj
	L_obj_len -v v obj; L_unittest_vareq v 2
	L_obj_get -v a obj a; L_unittest_vareq a 1
	L_obj_get -v b obj b; L_unittest_vareq b 2
}

_L_test_obj_4_merge_self_nested_maps() {
	obj_skip_test
	local obj v
	L_obj_set obj a b = 1
	L_obj_set obj c d = 2
	# Self-merge with nested MAP children: idempotent recursion.
	L_obj_merge obj obj
	L_obj_len -v v obj;        L_unittest_vareq v 2
	L_obj_len -v v obj a;      L_unittest_vareq v 1
	L_obj_len -v v obj c;      L_unittest_vareq v 1
	L_obj_get -v v obj a b;    L_unittest_vareq v 1
	L_obj_get -v v obj c d;    L_unittest_vareq v 2
}

# ---------------------------------------------------------------------------
# L_obj_merge with the same object as source and destination, ARRAY child.
# ARRAY:ARRAY merge appends the source's children to the destination array.
# When source and destination are the same array, each child is appended to
# itself, so the array doubles to [x, y, x, y]. This is the expected
# (append-based) behavior for a self-merge of an ARRAY.
# ---------------------------------------------------------------------------
_L_test_obj_4_merge_self_array() {
	obj_skip_test
	local obj v
	L_obj_array_append obj arr += x
	L_obj_array_append obj arr += y
	# Self-merge doubles the array: append source children to the same array.
	L_obj_merge obj obj
	L_obj_len -v v obj arr; L_unittest_vareq v 4
	L_obj_get -v v obj arr 0; L_unittest_vareq v x
	L_obj_get -v v obj arr 1; L_unittest_vareq v y
	L_obj_get -v v obj arr 2; L_unittest_vareq v x
	L_obj_get -v v obj arr 3; L_unittest_vareq v y
}

# ---------------------------------------------------------------------------
# L_obj_set_obj — "destination first" wrapper around L_obj_copy.
# Syntax: L_obj_set_obj <dst> [parts...] = <src>  ('=' is a literal separator,
# src is the LAST argument). Still exercises L_obj_copy under the hood.
# ---------------------------------------------------------------------------
_L_test_obj_4_set_obj_basic() {
	obj_skip_test
	local src dst v
	L_obj_set src a = 1
	dst=()
	# dst becomes a deep copy of src.
	L_obj_set_obj dst = src
	L_obj_len -v v dst;   L_unittest_vareq v 1
	L_obj_get -v v dst a; L_unittest_vareq v 1
	# source is untouched.
	L_obj_len -v v src;   L_unittest_vareq v 1
}

# Setting a nested path of the destination.
_L_test_obj_4_set_obj_with_path() {
	obj_skip_test
	local src dst v
	L_obj_set src a = 1
	dst=()
	L_obj_set_obj dst child = src
	# dst.child is a copy of src.
	L_obj_len -v v dst;        L_unittest_vareq v 1
	L_obj_len -v v dst child;  L_unittest_vareq v 1
	L_obj_get -v v dst child a; L_unittest_vareq v 1
}

# Self case: set a child of an object to a copy of itself. The snapshot guard
# must prevent infinite recursion: obj == {a:1, b:{a:1}}.
_L_test_obj_4_set_obj_self_into_own_child() {
	obj_skip_test
	local obj v
	L_obj_set obj a = 1
	L_obj_set_obj obj b = obj
	L_obj_len -v v obj;      L_unittest_vareq v 2
	L_obj_get -v v obj a;    L_unittest_vareq v 1
	L_obj_len -v v obj b;    L_unittest_vareq v 1
	L_obj_get -v v obj b a;  L_unittest_vareq v 1
}

# The '=' separator is required.
_L_test_obj_4_set_obj_missing_equals() {
	obj_skip_test
	local src dst
	L_obj_set src a = 1
	dst=()
	# No '=' separator -> usage error.
	L_unittest_cmd ! L_obj_set_obj dst child src
}

# -v stores the position of the newly created destination node.
_L_test_obj_4_set_obj_v_option() {
	obj_skip_test
	local src dst v pos check
	L_obj_set src a = 1
	dst=()
	L_obj_set_obj -v pos dst child = src
	# -v must capture the position of dst.child.
	L_obj_pos -v check dst child
	L_unittest_vareq pos "$check"
	L_obj_len -v v dst child;  L_unittest_vareq v 1
	L_obj_get -v v dst child a; L_unittest_vareq v 1
}

# ---------------------------------------------------------------------------
# L_obj_path — the inverse of L_obj_pos. Climbs parent links from "obj+<pos>"
# to the root, collecting MAP keys and ARRAY indexes (from 0) into the -v
# array. The root has an empty path. Optional [parts...] descend further from
# the positioned node before climbing. See bin/L_lib.sh L_obj_path / example:
#   L_obj_pos -v pos obj a b 0 ; L_obj_path -v parts "obj+$pos"  # parts=(a b 0)
# ---------------------------------------------------------------------------
_L_test_obj_4_path_root_empty() {
	obj_skip_test
	local -a parts
	obj=()
	L_obj_set obj a = 1
	# The root node has an empty path.
	L_obj_path -v parts obj
	L_unittest_eq "${parts[*]+${parts[*]}}" ""
}

_L_test_obj_4_path_map_keys() {
	obj_skip_test
	local -a parts pos v
	obj=()
	L_obj_set obj a b = 1
	L_obj_pos -v pos obj a b
	L_obj_path -v parts "obj+$pos"
	# Path from root to obj.a.b: (a b).
	L_unittest_eq "${parts[*]}" "a b"
	# Round-trip: recomposing the path reaches the same scalar.
	L_obj_get -v v obj "${parts[@]}"; L_unittest_vareq v 1
}

_L_test_obj_4_path_array_index() {
	obj_skip_test
	local -a parts p0 p1 v
	obj=()
	L_obj_array_append obj arr += x
	L_obj_array_append obj arr += y
	# ARRAY indexes are counted from 0.
	L_obj_pos -v p0 obj arr 0
	L_obj_pos -v p1 obj arr 1
	L_obj_path -v parts "obj+$p0"
	L_unittest_eq "${parts[*]}" "arr 0"
	L_obj_get -v v obj "${parts[@]}"; L_unittest_vareq v x
	L_obj_path -v parts "obj+$p1"
	L_unittest_eq "${parts[*]}" "arr 1"
	L_obj_get -v v obj "${parts[@]}"; L_unittest_vareq v y
}

# A path mixing a MAP key and an ARRAY index.
_L_test_obj_4_path_mixed_map_array() {
	obj_skip_test
	local -a parts pos v
	obj=()
	L_obj_array_append obj list += m
	L_obj_array_append obj list += n
	L_obj_pos -v pos obj list 1
	L_obj_path -v parts "obj+$pos"
	L_unittest_eq "${parts[*]}" "list 1"
	L_obj_get -v v obj "${parts[@]}"; L_unittest_vareq v n
}

# [parts...] descend from the positioned node before the path is decomposed.
_L_test_obj_4_path_extra_parts_descend() {
	obj_skip_test
	local -a parts pos v
	obj=()
	L_obj_set obj a b c = 1
	L_obj_pos -v pos obj a b
	# Path to obj.a.b is (a b) ...
	L_obj_path -v parts "obj+$pos"
	L_unittest_eq "${parts[*]}" "a b"
	# ... descending one more level ("c") yields (a b c).
	L_obj_path -v parts "obj+$pos" c
	L_unittest_eq "${parts[*]}" "a b c"
	L_obj_get -v v obj "${parts[@]}"; L_unittest_vareq v 1
}
