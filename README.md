# JSON Metadata Handler

A robust, independent JSON-based metadata system for bash scripts that provides atomic operations for variables, arrays, and objects. Uses true nested dot-path semantics (e.g., "a.b.c") via jq getpath/setpath and supports typed values.

## Features

- **Atomic Operations**: All writes use temporary files with atomic moves
- **Zero Dependencies**: Only requires `jq` (JSON processor)
- **Rich Data Types**: Native support for strings, arrays, and nested objects
- **Error Handling**: Comprehensive validation and fallbacks
- **Performance**: Direct `jq` operations for speed
- **Debugging**: Easy to inspect JSON files and operations

## Requirements

- `bash` (4.0+)
- `jq` (JSON processor)

## Quick Start

```bash
# Set the metadata file path (optional, defaults to ./metadata.json)
export METADATA_JSON="/path/to/your/metadata.json"

# Source the system
source "./metadata-handler"

# Set a variable
set_json_var "app.name" "MyApp"

# Get a variable
app_name=$(get_json_var "app.name")
echo "App name: $app_name"
```

## API Reference

### Basic Variables

```bash
# Set a variable
set_json_var "key.nested.path" "value"

# Get a variable
value=$(get_json_var "key.nested.path")

# Check if variable exists
if has_json_var "key.nested.path"; then
    echo "Variable exists"
fi

# Delete a variable
unset_json_var "key.nested.path"

# Set multiple variables atomically
set_json_vars "key1=value1" "key2=value2" "key3=value3"
```

### Arrays

```bash
# Set entire array
set_json_array "my.array" "item1" "item2" "item3"

# Get array (one item per line)
get_json_array "my.array" | while read -r item; do
    echo "Item: $item"
done

# Get array length
length=$(get_json_array_length "my.array")

# Get/set specific element
element=$(get_json_array_element "my.array" 0)
set_json_array_element "my.array" 0 "new_value"

# Stack operations (end of array)
push_json_array "my.array" "new_item"
popped=$(pop_json_array "my.array")

# Queue operations (beginning of array)
unshift_json_array "my.array" "first_item"
shifted=$(shift_json_array "my.array")

# Search and manipulation
if contains_json_array_element "my.array" "search_item"; then
    echo "Array contains item"
fi
remove_json_array_element "my.array" "item_to_remove"
```

### Objects

```bash
# Set entire object
set_json_object "my.object" '{"key1": "value1", "key2": "value2"}'

# Get object as JSON
object_json=$(get_json_object "my.object")

# Get object keys
get_json_object_keys "my.object" | while read -r key; do
    echo "Key: $key"
done

# Merge objects (deep merge)
merge_json_object "my.object" '{"key3": "value3", "key1": "updated_value1"}'

# Object key operations
if has_json_object_key "my.object" "key1"; then
    echo "Object has key1"
fi
remove_json_object_key "my.object" "key2"
```

### Utilities

```bash
# List all variables
list_json_vars

# List variables with prefix
list_json_vars "app"

# Dump all as key=value pairs
dump_json_vars

# Pretty print for debugging
pretty_print_json_metadata

# Backup and restore
backup_json_metadata "/path/to/backup.json"
restore_json_metadata "/path/to/backup.json"
```

## Configuration

### Custom Metadata File

```bash
# Set custom path before sourcing
export METADATA_JSON="/custom/path/metadata.json"
source "./metadata-handler"
```

### Custom Debug Function

```bash
# Set custom debug function before sourcing
export print_debug="my_debug_function"
source "./metadata-handler"
```

## Examples

### Basic Usage

```bash
#!/bin/bash
source "./metadata-handler"

# Application configuration
set_json_vars \
    "app.name=MyApp" \
    "app.version=1.0.0" \
    "app.debug=true"

# User preferences
set_json_object "user.preferences" '{
    "theme": "dark",
    "language": "en",
    "notifications": true
}'

# Recent files array
set_json_array "user.recent_files" \
    "/path/to/file1.txt" \
    "/path/to/file2.txt"

# Add new recent file
push_json_array "user.recent_files" "/path/to/file3.txt"

# Get configuration
app_name=$(get_json_var "app.name")
theme=$(get_json_var "user.preferences.theme")
echo "$app_name using $theme theme"
```

### Complex Data Structures

```bash
# Nested configuration
set_json_var "database.host" "localhost"
set_json_var "database.port" "5432"
set_json_var "database.credentials.username" "admin"
set_json_var "database.credentials.password" "secret"

# Multiple environments
set_json_object "environments.development" '{
    "api_url": "http://localhost:3000",
    "debug": true
}'

set_json_object "environments.production" '{
    "api_url": "https://api.example.com",
    "debug": false
}'

# Feature flags array
set_json_array "features.enabled" "feature_a" "feature_b"
if contains_json_array_element "features.enabled" "feature_a"; then
    echo "Feature A is enabled"
fi
```

## Error Handling

The system provides comprehensive error handling:

- All functions return appropriate exit codes (0 for success, 1 for failure)
- Atomic operations ensure data consistency
- Temporary files are cleaned up on failure
- Debug messages help with troubleshooting

## Performance

- **Atomic writes**: Uses `mv` for atomic file operations
- **Efficient JSON processing**: Direct `jq` operations
- **Minimal overhead**: No Python dependencies or complex parsing
- **Scalable**: Handles large JSON structures efficiently

## Testing

Run the comprehensive examples:

```bash
chmod +x examples.sh
./examples.sh
```

This will demonstrate all features and create an `example_metadata.json` file.

## License

This is an independent utility that can be used in any project. No specific license restrictions.
