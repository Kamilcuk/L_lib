#!/bin/bash
# Test URL and HTML encoding from string.md

. "$(dirname "$0")/../../../bin/L_lib.sh"

echo "=== Testing L_urlencode ==="
result=$(L_urlencode "hello world & stuff")
echo "Encoded: $result"
[[ "$result" == "hello%20world%20%26%20stuff" ]] || { echo "FAIL: URL encode"; exit 1; }

url="my file.txt"
L_urlencode -v encoded "$url"
echo "Encoded file: $encoded"
[[ "$encoded" == "my%20file.txt" ]] || { echo "FAIL: URL encode with -v"; exit 1; }

echo ""
echo "=== Testing L_urldecode ==="
result=$(L_urldecode "hello%20world")
echo "Decoded: $result"
[[ "$result" == "hello world" ]] || { echo "FAIL: URL decode"; exit 1; }

echo ""
echo "=== Testing L_html_escape ==="
result=$(L_html_escape "<script>alert('xss')</script>")
echo "HTML escaped: $result"
[[ "$result" == *"&lt;"* ]] || { echo "FAIL: HTML escape should convert <"; exit 1; }
[[ "$result" == *"&gt;"* ]] || { echo "FAIL: HTML escape should convert >"; exit 1; }

user_input="<b>bold</b>"
L_html_escape -v safe "$user_input"
echo "Safe HTML: $safe"
[[ "$safe" != *"<b>"* ]] || { echo "FAIL: Should have escaped tags"; exit 1; }

echo ""
echo "All encoding tests passed!"
