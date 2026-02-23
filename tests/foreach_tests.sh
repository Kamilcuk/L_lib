_L_test_foreach_01_all() {
  local array1=(a b c d) array2=(e f g h)
  L_log "Test simple one or two vars in array"
  L_unittest_cmd -o 'a:b:c:d:' \
    eval 'while L_foreach a : array1; do echo -n $a:; done'
  L_unittest_cmd -o 'a,b:c,d:' \
    eval 'while L_foreach a b : array1; do echo -n $a,$b:; done'
  L_unittest_cmd -o 'a,b:c,d:e,f:g,h:' \
    eval 'while L_foreach a b : array1 array2; do echo -n $a,$b:; done'
  L_unittest_cmd -o 'a,b,c:d,e,f:g,h,unset:' \
    eval 'while L_foreach a b c : array1 array2; do echo -n $a,$b,${c:-unset}:; done'
  L_unittest_cmd -o '3,a b c:3,d :' \
    eval 'while L_foreach -R 3 a : array1; do echo -n ${#a[@]},${a[*]}:; done'

  L_log "Test pairs of arrays"
  L_unittest_cmd -o 'a,e:b,f:c,g:d,h:' \
    eval 'while L_foreach -s -k _ a b : array1 array2; do echo -n $a,$b:; done'
  L_unittest_cmd -o '0,a,e:1,b,f:2,c,g:3,d,h:' \
    eval 'while L_foreach -s -k k a b : array1 array2; do echo -n $k,$a,$b:; done'
  L_unittest_cmd -o '3,d,h:2,c,g:1,b,f:0,a,e:' \
    eval 'while L_foreach -r -k k a b : array1 array2; do echo -n $k,$a,$b:; done'

  if (( L_HAS_ASSOCIATIVE_ARRAY )); then
    L_log "Test associative arrays"
    local -A dict1=([a]=b [c]=d) dict2=([a]=e [c]=f)
    L_unittest_cmd -r '3,[bd] [bd] :' \
      eval 'while L_foreach -R 3 a : dict1; do echo -n ${#a[@]},${a[*]}:; done'
    L_unittest_cmd -o 'a,b,e:c,d,f:' \
      eval 'while L_foreach -s -k k a b : dict1 dict2; do echo -n $k,$a,$b:; done'
    L_unittest_cmd -o 'a,b,e:c,d,f:' \
      eval 'while L_foreach -s -k k a b : dict1 dict2; do echo -n $k,$a,$b:; done'
  fi
}

_L_test_foreach_02_all_index_first_last() {
  local array1=(a b c d) array2=(e f g h)
  L_log "Test simple one or two vars in array"
  L_unittest_cmd -o '010,a:100,b:200,c:301,d:' \
    eval 'while L_foreach -ii -ff -ll a : array1; do echo -n $i$f$l,$a:; done'
  L_unittest_cmd -o '010,a,b:101,c,d:' \
    eval 'while L_foreach -ii -ff -ll a b : array1; do echo -n $i$f$l,$a,$b:; done'
  L_unittest_cmd -o '010,a,b:100,c,d:200,e,f:301,g,h:' \
    eval 'while L_foreach -ii -ff -ll a b : array1 array2; do echo -n $i$f$l,$a,$b:; done'
  L_unittest_cmd -o '010,a,b,c:100,d,e,f:201,g,h,unset:' \
    eval 'while L_foreach -ii -ff -ll a b c : array1 array2; do echo -n $i$f$l,$a,$b,${c:-unset}:; done'
  L_unittest_cmd -o '010,3,a b c:101,3,d :' \
    eval 'while L_foreach -ii -ff -ll -R 3 a : array1; do echo -n $i$f$l,${#a[@]},${a[*]}:; done'

  L_log "Test pairs of arrays"
  L_unittest_cmd -o '010,a,e:100,b,f:200,c,g:301,d,h:' \
    eval 'while L_foreach -ii -ff -ll -s -k _ a b : array1 array2; do echo -n $i$f$l,$a,$b:; done'
  L_unittest_cmd -o '010,0,a,e:100,1,b,f:200,2,c,g:301,3,d,h:' \
    eval 'while L_foreach -ii -ff -ll -s -k k a b : array1 array2; do echo -n $i$f$l,$k,$a,$b:; done'
  L_unittest_cmd -o '010,3,d,h:100,2,c,g:200,1,b,f:301,0,a,e:' \
    eval 'while L_foreach -ii -ff -ll -r -k k a b : array1 array2; do echo -n $i$f$l,$k,$a,$b:; done'

  if (( L_HAS_ASSOCIATIVE_ARRAY )); then
    L_log "Test associative arrays"
    local -A dict1=([a]=b [c]=d) dict2=([a]=e [c]=f)
    L_unittest_cmd -r '011,3,[bd] [bd] :' \
      eval 'while L_foreach -ii -ff -ll -n 3 a : dict1; do echo -n $i$f$l,${#a[@]},${a[*]}:; done'
    L_unittest_cmd -o '010,a,b,e:101,c,d,f:' \
      eval 'while L_foreach -ii -ff -ll -s -k k a b : dict1 dict2; do echo -n $i$f$l,$k,$a,$b:; done'
    L_unittest_cmd -o '010,a,b,e:101,c,d,f:' \
      eval 'while L_foreach -ii -ff -ll -s -k k a b : dict1 dict2; do echo -n $i$f$l,$k,$a,$b:; done'
  else
    L_log "SKIP: Test associative arrays"
  fi
}


_L_test_foreach_03_normal() {
  local arr=(a b c d e) i a b k acc=() acc1=() acc2=()
  {
    L_log "test simple"
    while L_foreach a : arr; do
      acc+=("$a")
    done
    L_unittest_arreq acc a b c d e
  }
  {
    L_log "test simple two"
    while L_foreach a b : arr; do
      acc1+=("$a")
      acc2+=("${b:-unset}")
    done
    L_unittest_arreq acc1 a c e
    L_unittest_arreq acc2 b d unset
  }
}

_L_test_foreach_04_k_normal() {
  local arr=(a b c d e) i a b k acc=() acc1=() acc2=()
  {
    L_log "test simple"
    while L_foreach -k k a : arr; do
      acc+=("$k" "$a")
    done
    L_unittest_arreq acc 0 a 1 b 2 c 3 d 4 e
  }
  {
    L_log "test simple two"
    while L_foreach a b : arr; do
      acc1+=("$a")
      acc2+=("${b:-unset}")
    done
    L_unittest_arreq acc1 a c e
    L_unittest_arreq acc2 b d unset
  }
}

_L_test_foreach_05_first() {
  {
    L_log "test sorted array L_foreach"
    local arr=(a b c d e) i a k acc=() b
    while L_foreach -i i -k k a : arr; do
      acc+=("$i" "$k" "$a")
    done
    L_unittest_arreq acc 0 0 a 1 1 b 2 2 c 3 3 d 4 4 e
  }
  if (( L_HAS_ASSOCIATIVE_ARRAY )); then
    {
      L_log "test dict L_foreach"
      local -A dict=(a b c d e)
      local i k a acc=() j=0
      while L_foreach -i i -k k a : dict; do
        L_unittest_eq "${dict[$k]}" "$a"
        L_unittest_vareq j "$i"
        j=$(( j + 1 ))
      done
    }
    {
      L_log "test sorted dict L_foreach"
      local -A dict=(a b c d e)
      local i k a acc=()
      while L_foreach -s -i i -k j a : dict; do
        acc+=("$i" "$j" "$a")
      done
      L_unittest_arreq acc 0 a b 1 c d 2 e ''
    }
  else
    L_log "SKIP associative arrays"
  fi
}

_L_test_foreach_06_last() {
  local arr=(a b c d e) other=(1 2 3 4) i a b k acc=()
  {
    while L_foreach -i i -k k a : arr; do
      acc+=("$i" "$k" "$a")
    done
    L_unittest_arreq acc 0 0 a 1 1 b 2 2 c 3 3 d 4 4 e
  }
  if (( L_HAS_ASSOCIATIVE_ARRAY )); then
    {
      L_log "test dict L_foreach"
      local -A dict=(a b c d e)
      local i k a acc=() j=0
      while L_foreach -i i -k k a : dict; do
        L_unittest_eq "${dict[$k]}" "$a"
        L_unittest_vareq j "$i"
        j=$(( j + 1 ))
      done
    }
    {
      L_log "test sorted dict L_foreach"
      local -A dict=(a b c d e)
      local i k a acc=()
      while L_foreach -s -i i -k j a : dict; do
        acc+=("$i" "$j" "$a")
      done
      L_unittest_arreq acc 0 a b 1 c d 2 e ''
    }
  fi
}

_L_test_foreach_07_nested() {
  local array1=(a b) array2=(1 2)
  L_log "Test basic nested loops"
  L_unittest_cmd -o 'a,1:a,2:b,1:b,2:' \
    eval 'while L_foreach x : array1; do while L_foreach y : array2; do echo -n $x,$y:; done; done'

  L_log "Test nested loops with indices"
  L_unittest_cmd -o '0,a,0,1:0,a,1,2:1,b,0,1:1,b,1,2:' \
    eval 'while L_foreach -ii x : array1; do while L_foreach -i j y : array2; do echo -n $i,$x,$j,$y:; done; done'

  L_log "Test nested loops with multiple variables"
   local array3=(A B C D)
  L_unittest_cmd -o 'a,A,B:a,C,D:b,A,B:b,C,D:' \
    eval 'while L_foreach x : array1; do while L_foreach y z : array3; do echo -n $x,$y,$z:; done; done'
}

_L_test_foreach_08_sparse_array() {
  local array1=([2]=a [8]=b) array2=([4]=c [6]=d) i k a b acc=() l f c e acc2=()
  {
    L_log "test sparse array iteration key is ok"
    while L_foreach -i i -k k a : array1; do
      acc+=("$i" "$k" "$a")
    done
    L_unittest_arreq acc \
      0 2 a \
      1 8 b
  }
  {
    L_log "test sparse two arrays iteration in order"
    acc=()
    while L_foreach -c c -e e -l l -f f -i i -k k a b : array1 array2; do
      # echo "$i" "$f" "$l" "$k" "${a:-X}" "${b:-X}"
      declare -p e
      acc+=("$i" "$f" "$l" "$k" "$c" "${e[0]:-0}" "${e[1]:-0}" "${a:-X}" "${b:-X}")
    done
    L_unittest_arreq acc \
      0 1 0 2 1 1 0 a X \
      1 0 0 8 1 1 0 b X \
      2 0 0 4 1 0 1 X c \
      3 0 1 6 1 0 1 X d
    # i f l k c m m a b
  }
  {
    L_log "test sparse two arrays iteration in sorted keys order"
    acc=() acc2=()
    while L_foreach -c c -e e -s -l l -f f -i i -k k a b : array1 array2; do
      # echo "$i" "$f" "$l" "$k" "${a:-X}" "${b:-X}"
      acc+=("$i" "$f" "$l" "$k" "${a:-X}" "${b:-X}")
      acc2+=("$c" "${e[0]:-0}" "${e[1]:-0}")
    done
    L_unittest_arreq acc \
      0 1 0 2 a X \
      1 0 0 4 X c \
      2 0 0 6 X d \
      3 0 1 8 b X
    L_unittest_arreq acc2 \
      1 1 0 \
      1 0 1 \
      1 0 1 \
      1 1 0
  }
}

_L_test_foreach_09_empty() {
  local array1=() array2=() i k a b acc=() l f e
  {
    L_log "test empty array"
    L_unittest_cmd -e 4 L_foreach a : array1
  }
  {
    L_log "test two empty arrays"
    L_unittest_cmd -e 4 L_foreach a : array1 array2
  }
  local arr1=(a b c) arr2=(d) e c acc=()
  {
    L_log "diff len"
    L_unittest_cmd -o "0,2,1,1,a d|1,1,1,,b |2,1,1,,c |" \
      eval 'while L_foreach -s -k k -c c -e e -- a : arr1 arr2; do echo -n "$k,$c,${e[0]},${e[1]},${a[@]}|" ; done'
  }
}

_L_test_foreach_10_exists() {
  local arr1=([0]=a [1]=b) arr2=([0]=c [2]=d)
  L_unittest_cmd -o "\
arr1[0]=a,arr2[0]=c|\
arr1[1]=b,arr2[1]=NO|\
arr1[2]=NO,arr2[2]=d|\
" -- \
    eval '
      while L_foreach -k k -e e -- a b : arr1 arr2; do
        if ((e[0])); then
          echo -n "arr1[$k]=$a"
        else
          echo -n "arr1[$k]=NO"
        fi
        echo -n ","
        if ((e[1])); then
          echo -n "arr2[$k]=$b"
        else
          echo -n "arr2[$k]=NO"
        fi
        echo -n "|"
      done
    '
}

_L_test_foreach_11_v_sort_values() {
  if (( L_HAS_ASSOCIATIVE_ARRAY )); then
    local -A dict=([a]=z [b]=y [c]=x)
    L_log "Test sorting by values"
    L_unittest_cmd -o 'c,x:b,y:a,z:' \
      eval 'while L_foreach -V -k k v : dict; do echo -n $k,$v:; done'
    
    local -A dict2=([a]=10 [b]=2 [c]=1)
    L_log "Test sorting by values numerically"
    # Note: L_sort (which I assume L_foreach -V uses) might not do numeric sort by default.
    # Let's see what it does.
    L_unittest_cmd -o 'c,1:a,10:b,2:' \
      eval 'while L_foreach -V -k k v : dict2; do echo -n $k,$v:; done'
    L_unittest_cmd -o 'c,1:b,2:a,10:' \
      eval 'while L_foreach -V -n -k k v : dict2; do echo -n $k,$v:; done'
  fi

  local array=(z y x)
  L_log "Test sorting indexed array by values"
  L_unittest_cmd -o '2,x:1,y:0,z:' \
    eval 'while L_foreach -V -k k v : array; do echo -n $k,$v:; done'
}
