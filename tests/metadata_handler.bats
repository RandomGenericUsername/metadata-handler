#!/usr/bin/env bats

setup() {
  export METADATA_JSON="./test_metadata.json"
  rm -f "$METADATA_JSON"
  source "./metadata-handler"
  # Use a no-op debug function to avoid interfering with test output
  export print_debug=":"
}

teardown() {
  rm -f "$METADATA_JSON"
}

@test "set/get nested scalar" {
  run set_json_var "a.b.c" "val"
  [ "$status" -eq 0 ]

  run get_json_var "a.b.c"
  [ "$status" -eq 0 ]
  [ "$output" = "val" ]
}

@test "has and unset nested scalar" {
  run set_json_var "x.y" "1"
  [ "$status" -eq 0 ]
  run has_json_var "x.y"
  [ "$status" -eq 0 ]

  run unset_json_var "x.y"
  [ "$status" -eq 0 ]
  run has_json_var "x.y"
  [ "$status" -ne 0 ]
}

@test "typed setter preserves types" {
  run set_json_var_json "t.obj" '{"n":123,"flag":true}'
  [ "$status" -eq 0 ]
  run get_json_object "t.obj"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.n==123 and .flag==true' >/dev/null
}

@test "array push/pop and contains" {
  run set_json_array "arr.items" "a" "b"
  [ "$status" -eq 0 ]
  run push_json_array "arr.items" "c"
  [ "$status" -eq 0 ]
  run contains_json_array_element "arr.items" "b"
  [ "$status" -eq 0 ]
  run pop_json_array "arr.items"
  [ "$status" -eq 0 ]
  [ "$output" = "c" ]
}

@test "object merge and keys" {
  run set_json_object "obj.one" '{"k1":"v1"}'
  [ "$status" -eq 0 ]
  run merge_json_object "obj.one" '{"k2":"v2"}'
  [ "$status" -eq 0 ]
  run get_json_object_keys "obj.one"
  [ "$status" -eq 0 ]
  echo "$output" | tr '\n' ' ' | grep -q "k1" && echo "$output" | tr '\n' ' ' | grep -q "k2"
}



@test "prefix list and dump" {
  run set_json_var "app.name" "MyApp"
  [ "$status" -eq 0 ]
  run set_json_var_json "app.cfg" '{"debug":true,"level":3}'
  [ "$status" -eq 0 ]

  run list_json_vars "app"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qx "app.name"
  echo "$output" | grep -qx "app.cfg.debug"
  echo "$output" | grep -qx "app.cfg.level"

  run dump_json_vars
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '^app.name=MyApp$'
}

@test "backup and restore" {
  backup_path="./test_backup.json"
  run set_json_var "t.back" "orig"
  [ "$status" -eq 0 ]
  run backup_json_metadata "$backup_path"
  [ "$status" -eq 0 ]
  run set_json_var "t.back" "changed"
  [ "$status" -eq 0 ]
  run restore_json_metadata "$backup_path"
  [ "$status" -eq 0 ]
  run get_json_var "t.back"
  [ "$status" -eq 0 ]
  [ "$output" = "orig" ]
  rm -f "$backup_path"
}

@test "set_json_vars atomic multi" {
  run set_json_vars "p.q=1" "p.r=2"
  [ "$status" -eq 0 ]
  run get_json_var "p.q"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
  run get_json_var "p.r"
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
}

@test "object has/remove key" {
  run set_json_object "o.k" '{"a":"A","b":"B"}'
  [ "$status" -eq 0 ]
  run has_json_object_key "o.k" "a"
  [ "$status" -eq 0 ]
  run remove_json_object_key "o.k" "a"
  [ "$status" -eq 0 ]
  run has_json_object_key "o.k" "a"
  [ "$status" -ne 0 ]
}

@test "array unshift/shift/remove/length" {
  run set_json_array "ar.v" "x" "y"
  [ "$status" -eq 0 ]
  run unshift_json_array "ar.v" "w"
  [ "$status" -eq 0 ]
  run shift_json_array "ar.v"
  [ "$status" -eq 0 ]
  [ "$output" = "w" ]
  run get_json_array_length "ar.v"
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
  run remove_json_array_element "ar.v" "y"
  [ "$status" -eq 0 ]
  run contains_json_array_element "ar.v" "y"
  [ "$status" -ne 0 ]
  run contains_json_array_element "ar.v" "x"
  [ "$status" -eq 0 ]
}

@test "flat dotted key fallback (read-only) and migration on write" {
  # Create a flat dotted key directly
  echo '{}' > "$METADATA_JSON"
  run jq -c '."flat.key"="v"' "$METADATA_JSON"
  echo "$output" > "$METADATA_JSON"
  run get_json_var "flat.key"
  [ "$status" -eq 0 ]
  [ "$output" = "v" ]

  # Now write via API; this should migrate to nested and remove legacy flat key
  run set_json_var "flat.key" "v2"
  [ "$status" -eq 0 ]
  run get_json_var "flat.key"
  [ "$status" -eq 0 ]
  [ "$output" = "v2" ]
  # Ensure the legacy flat key is gone
  run jq -r '."flat.key" // empty' "$METADATA_JSON"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
