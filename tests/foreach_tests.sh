
_L_test_foreach_1_all() {
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
  L_unittest_cmd -o '3,a b c:1,d:' \
    eval 'while L_foreach -n 3 a : array1; do echo -n ${#a[@]},${a[*]}:; done'

  L_log "Test pairs of arrays"
  L_unittest_cmd -o 'a,e:b,f:c,g:d,h:' \
    eval 'while L_foreach -s -k _ a b : array1 array2; do echo -n $a,$b:; done'
  L_unittest_cmd -o '0,a,e:1,b,f:2,c,g:3,d,h:' \
    eval 'while L_foreach -s -k k a b : array1 array2; do echo -n $k,$a,$b:; done'
  L_unittest_cmd -o '3,d,h:2,c,g:1,b,f:0,a,e:' \
    eval 'while L_foreach -r -k k a b : array1 array2; do echo -n $k,$a,$b:; done'

  L_log "Test associative arrays"
  local -A dict1=([a]=b [c]=d) dict2=([a]=e [c]=f)
  L_unittest_cmd -o '2,d b:' \
    eval 'while L_foreach -n 3 a : dict1; do echo -n ${#a[@]},${a[*]}:; done'
  L_unittest_cmd -o 'a,b,e:c,d,f:' \
    eval 'while L_foreach -s -k k a b : dict1 dict2; do echo -n $k,$a,$b:; done'
  L_unittest_cmd -o 'a,b,e:c,d,f:' \
    eval 'while L_foreach -s -k k a b : dict1 dict2; do echo -n $k,$a,$b:; done'
 }

_L_test_foreach_2_all_index_first_last() {
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
  L_unittest_cmd -o '010,3,a b c:101,1,d:' \
    eval 'while L_foreach -ii -ff -ll -n 3 a : array1; do echo -n $i$f$l,${#a[@]},${a[*]}:; done'

  L_log "Test pairs of arrays"
  L_unittest_cmd -o '010,a,e:100,b,f:200,c,g:301,d,h:' \
    eval 'while L_foreach -ii -ff -ll -s -k _ a b : array1 array2; do echo -n $i$f$l,$a,$b:; done'
  L_unittest_cmd -o '010,0,a,e:100,1,b,f:200,2,c,g:301,3,d,h:' \
    eval 'while L_foreach -ii -ff -ll -s -k k a b : array1 array2; do echo -n $i$f$l,$k,$a,$b:; done'
  L_unittest_cmd -o '010,3,d,h:100,2,c,g:200,1,b,f:301,0,a,e:' \
    eval 'while L_foreach -ii -ff -ll -r -k k a b : array1 array2; do echo -n $i$f$l,$k,$a,$b:; done'

  L_log "Test associative arrays"
  local -A dict1=([a]=b [c]=d) dict2=([a]=e [c]=f)
  L_unittest_cmd -o '011,2,d b:' \
    eval 'while L_foreach -ii -ff -ll -n 3 a : dict1; do echo -n $i$f$l,${#a[@]},${a[*]}:; done'
  L_unittest_cmd -o '010,a,b,e:101,c,d,f:' \
    eval 'while L_foreach -ii -ff -ll -s -k k a b : dict1 dict2; do echo -n $i$f$l,$k,$a,$b:; done'
  L_unittest_cmd -o '010,a,b,e:101,c,d,f:' \
    eval 'while L_foreach -ii -ff -ll -s -k k a b : dict1 dict2; do echo -n $i$f$l,$k,$a,$b:; done'
 }


_L_test_foreach_3_normal() {
  local arr=(a b c d e) i a k acc=() acc1=() acc2=()
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

_L_test_foreach_4_k_normal() {
  local arr=(a b c d e) i a k acc=() acc1=() acc2=()
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

_L_test_foreach_5_first() {
  {
    L_log "test sorted array L_foreach"
    local arr=(a b c d e) i a k acc=()
    while L_foreach -i i -k k a : arr; do
      acc+=("$i" "$k" "$a")
    done
    L_unittest_arreq acc 0 0 a 1 1 b 2 2 c 3 3 d 4 4 e
  }
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
}

_L_test_foreach_6_last() {
  {
    local arr=(a b c d e) other=(1 2 3 4) i a k acc=()
    while L_foreach -i i -k k a : arr; do
      acc+=("$i" "$k" "$a")
    done
    L_unittest_arreq acc 0 0 a 1 1 b 2 2 c 3 3 d 4 4 e
  }
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
}
