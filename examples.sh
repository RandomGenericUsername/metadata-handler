#!/bin/bash

# Comprehensive examples of the independent JSON metadata system
# This script demonstrates all available operations

# Set the metadata file path
export METADATA_JSON="./example_metadata.json"

# Source the JSON metadata system
source "./metadata-handler"

# Set up print_debug for examples
export print_debug="echo"

echo "=========================================="
echo "JSON Metadata System - Comprehensive Examples"
echo "=========================================="

# Clean start
rm -f "$METADATA_JSON"

echo
echo "=== BASIC VARIABLE OPERATIONS ==="

# Set simple variables
echo "Setting simple variables..."
set_json_var "system.screen_size" "1920x1080"
set_json_var "system.font_family" "FiraCode Nerd Font"
set_json_var "app.status" "enabled"

# Get variables
echo "Getting variables:"
echo "  screen_size: $(get_json_var "system.screen_size")"
echo "  font_family: $(get_json_var "system.font_family")"
echo "  app.status: $(get_json_var "app.status")"

# Check if variable exists
if has_json_var "system.screen_size"; then
    echo "  ✓ system.screen_size exists"
else
    echo "  ✗ system.screen_size does not exist"
fi

echo
echo "=== NESTED OBJECT OPERATIONS ==="

# Set nested variables individually
echo "Setting nested variables individually..."
set_json_var "wallpaper.current.path" "/home/user/wallpapers/mountain.jpg"
set_json_var "wallpaper.current.name" "mountain"
set_json_var "wallpaper.current.effect" "blur"

# Set entire object at once
echo "Setting entire object..."
set_json_object "wallpaper.selected" '{
    "path": "/home/user/wallpapers/ocean.jpg",
    "name": "ocean",
    "effect": "brightness"
}'

# Get nested values
echo "Getting nested values:"
echo "  current wallpaper: $(get_json_var "wallpaper.current.name")"
echo "  current effect: $(get_json_var "wallpaper.current.effect")"
echo "  selected wallpaper: $(get_json_var "wallpaper.selected.name")"

# Get entire object
echo "Getting entire object:"
echo "  wallpaper.current: $(get_json_object "wallpaper.current")"

# Get object keys
echo "Object keys for wallpaper.current:"
get_json_object_keys "wallpaper.current" | while read -r key; do
    echo "  - $key"
done

# Merge object (add/update fields)
echo "Merging object (adding timestamp)..."
merge_json_object "wallpaper.current" '{"timestamp": "2024-01-01T12:00:00Z", "effect": "new_blur"}'
echo "  After merge: $(get_json_object "wallpaper.current")"

# Check if object has key
if has_json_object_key "wallpaper.current" "timestamp"; then
    echo "  ✓ wallpaper.current has timestamp key"
fi

# Remove object key
echo "Removing timestamp key..."
remove_json_object_key "wallpaper.current" "timestamp"
echo "  After removal: $(get_json_object "wallpaper.current")"

echo
echo "=== ARRAY OPERATIONS ==="

# Set entire array
echo "Setting entire array..."
set_json_array "cache.wallpapers" \
    "/home/user/wallpapers/mountain.jpg" \
    "/home/user/wallpapers/ocean.jpg" \
    "/home/user/wallpapers/forest.jpg"

# Get array
echo "Array contents:"
get_json_array "cache.wallpapers" | while read -r item; do
    echo "  - $item"
done

# Get array length
echo "Array length: $(get_json_array_length "cache.wallpapers")"

# Get specific element
echo "Element at index 1: $(get_json_array_element "cache.wallpapers" 1)"

# Set element at specific index
echo "Setting element at index 1..."
set_json_array_element "cache.wallpapers" 1 "/home/user/wallpapers/desert.jpg"
echo "New element at index 1: $(get_json_array_element "cache.wallpapers" 1)"

echo
echo "=== ARRAY STACK OPERATIONS (Push/Pop) ==="

# Push to end
echo "Pushing to end..."
push_json_array "cache.wallpapers" "/home/user/wallpapers/city.jpg"
echo "Array after push:"
get_json_array "cache.wallpapers" | nl -v0 -s": "

# Pop from end
echo "Popping from end..."
popped=$(pop_json_array "cache.wallpapers")
echo "Popped element: $popped"
echo "Array after pop:"
get_json_array "cache.wallpapers" | nl -v0 -s": "

echo
echo "=== ARRAY QUEUE OPERATIONS (Unshift/Shift) ==="

# Unshift to beginning
echo "Unshifting to beginning..."
unshift_json_array "cache.wallpapers" "/home/user/wallpapers/sunrise.jpg"
echo "Array after unshift:"
get_json_array "cache.wallpapers" | nl -v0 -s": "

# Shift from beginning
echo "Shifting from beginning..."
shifted=$(shift_json_array "cache.wallpapers")
echo "Shifted element: $shifted"
echo "Array after shift:"
get_json_array "cache.wallpapers" | nl -v0 -s": "

echo
echo "=== ARRAY SEARCH AND MANIPULATION ==="

# Check if array contains element
if contains_json_array_element "cache.wallpapers" "/home/user/wallpapers/forest.jpg"; then
    echo "✓ Array contains forest.jpg"
else
    echo "✗ Array does not contain forest.jpg"
fi

# Remove element by value
echo "Removing forest.jpg from array..."
remove_json_array_element "cache.wallpapers" "/home/user/wallpapers/forest.jpg"
echo "Array after removal:"
get_json_array "cache.wallpapers" | nl -v0 -s": "

# Verify removal
if contains_json_array_element "cache.wallpapers" "/home/user/wallpapers/forest.jpg"; then
    echo "✗ forest.jpg still in array"
else
    echo "✓ forest.jpg successfully removed"
fi

echo
echo "=== ATOMIC OPERATIONS ==="

# Set multiple variables atomically
echo "Setting multiple variables atomically..."
set_json_vars \
    "app.theme.name=dark" \
    "app.theme.path=/themes/dark" \
    "app.launch_command=myapp --theme dark"

echo "Atomic update results:"
echo "  theme name: $(get_json_var "app.theme.name")"
echo "  theme path: $(get_json_var "app.theme.path")"
echo "  launch command: $(get_json_var "app.launch_command")"

echo
echo "=== UTILITY OPERATIONS ==="

# List all variables
echo "All variables:"
list_json_vars | head -10 | while read -r var; do
    echo "  - $var"
done

# List variables with prefix
echo "Variables starting with 'wallpaper':"
list_json_vars "wallpaper" | while read -r var; do
    echo "  - $var"
done

# Dump all as key=value pairs
echo "All variables as key=value (first 5):"
dump_json_vars | head -5

echo
echo "=== BACKUP AND RESTORE ==="

# Backup metadata
backup_path="./metadata_backup.json"
echo "Backing up metadata to $backup_path..."
backup_json_metadata "$backup_path"

# Modify something
set_json_var "test.backup" "modified"
echo "Added test variable: $(get_json_var "test.backup")"

# Restore from backup
echo "Restoring from backup..."
restore_json_metadata "$backup_path"

# Check if test variable is gone
if has_json_var "test.backup"; then
    echo "✗ Restore failed - test variable still exists"
else
    echo "✓ Restore successful - test variable removed"
fi

# Clean up
rm -f "$backup_path"

echo
echo "=== FINAL METADATA STATE ==="
echo "Pretty printed metadata:"
pretty_print_json_metadata

echo
echo "=== PERFORMANCE TEST ==="
echo "Testing performance (1000 operations)..."

# Time the JSON system
start_time=$(date +%s%N)
for i in {1..1000}; do
    set_json_var "test.performance" "value_$i" >/dev/null 2>&1
done
end_time=$(date +%s%N)
json_time=$(( (end_time - start_time) / 1000000 ))

echo "JSON system: ${json_time}ms for 1000 operations"
echo "Average: $((json_time / 10))ms per 100 operations"

# Clean up test variable
unset_json_var "test.performance"

echo
echo "=========================================="
echo "All examples completed successfully!"
echo "Metadata file: $METADATA_JSON"
echo "=========================================="
