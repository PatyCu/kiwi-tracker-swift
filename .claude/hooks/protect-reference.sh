#!/bin/sh
# Blocks agent edits to the Expo app: its pinned copy in .reference/ and its own
# checkout next to this repo (AGENTS.md#the-expo-app). Reads the hook's JSON from stdin.
file=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')
[ -n "$file" ] || exit 0
# Resolve `..` and symlinks through the nearest existing folder, since a new file has none yet.
dir=$(dirname "$file")
while [ ! -d "$dir" ]; do dir=$(dirname "$dir"); done
file="$(cd "$dir" && pwd -P)/${file#"$dir"/}"
root=$(cd "$CLAUDE_PROJECT_DIR" && pwd -P)
expo=$(cd "$root/.." && pwd -P)/kiwi-tracker
case "$file" in
  "$root"/.reference/* | "$expo"/*)
    echo "The Expo app is read-only: copy what this repo needs out of .reference/kiwi-tracker and edit the copy here." >&2
    exit 2
    ;;
esac
exit 0
