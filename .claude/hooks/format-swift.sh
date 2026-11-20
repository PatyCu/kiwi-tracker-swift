#!/bin/sh
# Formats a Swift file right after an agent edits it, so format-check never
# fails on agent changes. Reads the hook's JSON from stdin.
file=$(jq -r '.tool_input.file_path // empty')
case "$file" in
  *.swift) [ -f "$file" ] && swift format format --in-place "$file" ;;
esac
exit 0
