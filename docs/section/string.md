# String Utilities

A comprehensive collection of string manipulation functions for Bash scripting.

## Common String Operations

### L_strip - Trim Whitespace

Remove leading and trailing whitespace:

```bash
str="  hello world  "
result=$(L_strip "$str")
echo "$result"  # Output: "hello world"

# Or store in variable
L_strip -v result "$str"
echo "$result"  # Output: "hello world"
```

### L_strupper / L_strlower - Case Conversion

```bash
L_strupper "hello"  # Output: HELLO
L_strlower "WORLD"  # Output: world

# With -v option
L_strupper -v upper "bash scripting"
echo "$upper"  # Output: BASH SCRIPTING
```

### L_strstr - Substring Search

Check if string contains substring:

```bash
if L_strstr "hello world" "world"; then
	echo "Found!"
fi

# Returns 0 (success) if found, 1 if not found
```

## URL and HTML Encoding

### L_urlencode / L_urldecode

```bash
# Encode special characters for URLs
L_urlencode "hello world & stuff"
# Output: hello%20world%20%26%20stuff

# Decode URL-encoded strings
L_urldecode "hello%20world"
# Output: hello world

# Use with variables
url="my file.txt"
L_urlencode -v encoded "$url"
echo "$encoded"  # Output: my%20file.txt
```

### L_html_escape

Escape HTML special characters:

```bash
L_html_escape "<script>alert('xss')</script>"
# Output: &lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;

# Prevent XSS in web output
user_input="<b>bold</b>"
L_html_escape -v safe "$user_input"
echo "<div>$safe</div>"
```

## String Manipulation

### L_string_replace - Find and Replace

```bash
str="hello world world"
L_string_replace "$str" "world" "bash"
# Output: hello bash bash

# Replace first occurrence only
L_string_replace -n 1 "$str" "world" "bash"
# Output: hello bash world
```

### L_string_count - Count Occurrences

```bash
str="the quick brown fox jumps over the lazy dog"
L_string_count "$str" "the"
# Output: 2

# Count lines
text=$'line1\nline2\nline3'
L_string_count_lines "$text"
# Output: 3
```

## JSON Escaping

### L_json_escape

Properly escape strings for JSON:

```bash
L_json_escape 'Hello "World"'
# Output: "Hello \"World\""

L_json_escape $'Line1\nLine2'
# Output: "Line1\nLine2"

# Escape multiple values (creates JSON array)
L_json_escape "value1" "value2" "with\"quotes"
# Output: ["value1","value2","with\"quotes"]
```

## Hash Functions

### L_strhash - String Hashing

Generate hash from string (platform-dependent):

```bash
L_strhash "mystring"
# Output: hash value (implementation specific)

# Bash-only hash (portable across platforms)
L_strhash_bash "mystring"
```

## Practical Examples

### Build URL with Parameters

```bash
base_url="https://api.example.com/search"
query="hello world"
category="blog posts"

L_urlencode -v encoded_query "$query"
L_urlencode -v encoded_cat "$category"

full_url="${base_url}?q=${encoded_query}&cat=${encoded_cat}"
echo "$full_url"
# Output: https://api.example.com/search?q=hello%20world&cat=blog%20posts
```

### Safe HTML Output

```bash
display_user_content() {
	local content=$1

	L_html_escape -v safe_content "$content"

	cat <<EOF
<div class="user-content">
	${safe_content}
</div>
EOF
}

# Safe from XSS
display_user_content "<script>alert('hack')</script>"
```

### Generate JSON API Response

```bash
create_json_response() {
	local name=$1
	local message=$2
	local status=$3

	L_json_escape -v json_name "$name"
	L_json_escape -v json_msg "$message"

	cat <<EOF
{
	"user": $json_name,
	"message": $json_msg,
	"status": "$status"
}
EOF
}

create_json_response "John Doe" "Hello \"World\"" "success"
```

### String Processing Pipeline

```bash
process_string() {
	local input=$1

	# Strip whitespace
	L_strip -v cleaned "$input"

	# Convert to lowercase
	L_strlower -v lower "$cleaned"

	# Replace spaces with dashes
	L_string_replace -v result "$lower" " " "-"

	echo "$result"
}

process_string "  My Document Title  "
# Output: my-document-title
```

## Using the `-v` Option

All string functions support the `-v` option to store results in variables instead of printing:

```bash
# Without -v: prints to stdout
result=$(L_strip "  text  ")

# With -v: stores in variable (more efficient)
L_strip -v result "  text  "
```

The `-v` option is more efficient as it avoids subshells and command substitution.

::: bin/L_lib.sh string
