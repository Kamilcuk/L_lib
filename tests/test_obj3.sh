
_L_test_obj3() {
  obj_skip_test
  local paid cur tmp obj input='{"orders":[
  {"id":1,"user":"anna","total":120.5,"items":["pen","book"],"paid":true},
  {"id":2,"user":"piotr","total":15,"items":["pen"],"paid":false},
  {"id":3,"user":"anna","total":60,"items":["lamp"],"paid":true}
]}'
  L_obj_from_json obj <<<"$input"
  L_log "Extract ordersobj"
  local ordersobj pos
  L_obj_pos -v pos obj orders
  L_obj_copy obj+$pos ordersobj
  L_obj_to_json -c ordersobj

  L_log "Filter unpaid ordersobj."
  local unpaid_orders it="" tmp newpos index value type child
  L_obj_new unpaid_orders ARRAY
  while L_obj_iter ordersobj it index value type child; do
    L_obj_get -v paid ordersobj+$child paid
    if [[ "$paid" == false ]]; then
      L_obj_array_append_typed -v newpos unpaid_orders += MAP
      L_obj_copy ordersobj+$child unpaid_orders+$newpos
    fi
  done
  L_obj_to_json -c unpaid_orders

  L_log "Extract only ids and totals"
  local id="" index value type child id total extractobj
  L_obj_new extractobj ARRAY
  while L_obj_iter ordersobj it index value type child; do
    L_obj_array_append_typed -v newpos extractobj += MAP
    L_obj_get -v id ordersobj+$child id
    L_obj_set extractobj+$newpos id = "$id"
    L_obj_get -v total ordersobj+$child total
    L_obj_set extractobj+$newpos total = "$total"
  done
  L_obj_to_json -v tmp -c extractobj
  echo "$tmp"
  L_unittest_eq "$tmp" '[{"id":1,"total":120.5},{"id":2,"total":15},{"id":3,"total":60}]'

  L_log "Aggregate (total revenue)"
  local totalsum=0
  while L_obj_iter ordersobj it _ _ _ child; do
    L_obj_get -v paid ordersobj+$child paid
    if [[ "$paid" == true ]]; then
      L_obj_get -v total ordersobj+$child total
      L_float -v totalsum "$totalsum + $total"
    fi
  done
  echo "Total revenue: $totalsum"
  L_unittest_eq "$totalsum" 180.5

  L_log "Group by (spend per user)"
  local usersobj it="" child user user child total sum
  L_obj_new usersobj MAP
  while L_obj_iter ordersobj it _ _ _ child; do
    L_obj_get -v user ordersobj+$child user
    L_obj_get -v total ordersobj+$child total
    L_obj_get_or -v cur usersobj "$user" sum 0
    L_float -v sum "$cur + $total"
    L_obj_set usersobj "$user" sum = "$sum"
  done
  L_obj_to_json -c usersobj

  L_log "Flatten (all distinct items sold)"
  local itemsobj it="" items item child
  L_obj_new itemsobj MAP
  while L_obj_iter ordersobj it _ _ _ child; do
    L_obj_get_array -v items ordersobj+$child items
    for item in "${items[@]}"; do
      L_obj_set itemsobj "$item" = 1
    done
  done
  L_obj_keys -v items itemsobj
  L_sort items
  echo "Unique items sold: ${items[*]}"
  L_unittest_eq "${items[*]}" "book lamp pen"

  L_log "Update in place (mark order2 as paid)"
  local tmpobj
  L_obj_copy ordersobj tmpobj
  while L_obj_iter tmpobj it index _ _ child; do
    L_obj_get -v id tmpobj+$child id
    if [[ "$id" == 2 ]]; then
      L_obj_set tmpobj+$child paid = true
    fi
  done
  L_obj_to_json -c tmpobj

  L_log "Merge (defaults + user overrides, as with config files)"
  local defaultsobj overridesobj mergedobj
  L_obj_from_json defaultsobj <<<'{ "theme": "light", "fontSize": 14, "autoSave": true }'
  L_obj_from_json overridesobj <<<'{ "theme": "dark", "fontSize": 18 }'
  L_obj_new mergedobj MAP
  L_obj_merge defaultsobj mergedobj
  L_obj_merge overridesobj mergedobj
  L_obj_to_json -v tmp -c mergedobj
  echo "$tmp"
  L_unittest_eq "$tmp" '{"theme":"dark","fontSize":18,"autoSave":true}'

  # L_log "Diff (compare two API responses or configs)"
  # L_log "Converr id user total into csv"
}

