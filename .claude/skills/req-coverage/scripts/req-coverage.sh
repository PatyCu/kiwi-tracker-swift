#!/usr/bin/env bash
# Checks requirements/*.md against the tests that cite their IDs.
#   req-coverage.sh          integrity check: fails on malformed requirements, orphan or dropped IDs in tests
#   req-coverage.sh strict   also fails while an active requirement has no test
#   req-coverage.sh report   prints everything, never fails
# Tests are *.swift files under a path containing "Tests" and supabase/tests/*.sql.
set -euo pipefail

mode="${1:-check}"
case "$mode" in check | strict | report) ;; *)
  echo "usage: $0 [strict|report]" >&2
  exit 2
  ;;
esac

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$root"
req_dir="${REQ_DIR:-requirements}"
test_root="${TEST_ROOT:-.}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Prefixes registered in the README's table.
awk -F'|' '/^\| *[A-Z]{2,6} *\|/ { gsub(/ /, "", $2); print $2 }' "$req_dir/README.md" | sort -u >"$tmp/prefixes"

# Requirements: "ID<TAB>status", plus malformed headings and statuses.
: >"$tmp/reqs"
: >"$tmp/bad"
for file in "$req_dir"/*.md; do
  [ "$(basename "$file")" = README.md ] && continue
  awk -v file="$file" -v reqs="$tmp/reqs" -v bad="$tmp/bad" '
    function finish() {
      if (id != "" && status == "") print "BAD STATUS  " file ": " id " has no Status line" >> bad
      if (id != "") print id "\t" status >> reqs
      id = ""; status = ""
    }
    /^### / {
      finish()
      if (match($0, /^### [A-Z][A-Z]+-[0-9][0-9][0-9]: ./) && RLENGTH > 0) {
        id = substr($0, 5); sub(/:.*/, "", id)
        prefix = id; sub(/-.*/, "", prefix)
        if (length(prefix) > 6) { print "BAD ID      " file ": " $0 >> bad; id = "" }
      } else {
        print "BAD ID      " file ": " $0 >> bad
      }
      next
    }
    id != "" && status == "" && /^Status:/ {
      status = $2
      if (status != "draft" && status != "active" && status != "dropped")
        print "BAD STATUS  " file ": " id " is \"" status "\"" >> bad
    }
    END { finish() }
  ' "$file"
done
cut -f1 "$tmp/reqs" | sort | uniq -d | sed 's/^/DUPLICATE ID  /' >>"$tmp/bad"
cut -f1 "$tmp/reqs" | sed 's/-.*//' | sort -u | comm -23 - "$tmp/prefixes" |
  sed 's/^/BAD ID      unregistered prefix /' >>"$tmp/bad"

# IDs cited by tests: "ID<TAB>file".
{
  find "$test_root" -type f -name '*.swift' -path '*Tests*' \
    -not -path '*/.build/*' -not -path '*/DerivedData/*' -not -path '*/.reference/*'
  find "$test_root" -type f -path '*/supabase/tests/*.sql' \
    -not -path '*/.build/*' -not -path '*/DerivedData/*' -not -path '*/.reference/*'
} | sort >"$tmp/test_files"
: >"$tmp/refs"
while IFS= read -r file; do
  { grep -oE '[A-Z]{2,6}[-_][0-9]{3}' "$file" || true; } | tr '_' '-' | sort -u |
    while IFS= read -r id; do printf '%s\t%s\n' "$id" "${file#./}"; done >>"$tmp/refs"
done <"$tmp/test_files"
# Keep only registered prefixes, so unrelated codes in tests aren't read as IDs.
awk -F'\t' 'NR == FNR { p[$1] = 1; next } { x = $1; sub(/-.*/, "", x); if (x in p) print }' \
  "$tmp/prefixes" "$tmp/refs" | sort -u >"$tmp/refs_known"

cut -f1 "$tmp/refs_known" | sort -u >"$tmp/cited"
cut -f1 "$tmp/reqs" | sort -u >"$tmp/defined"
awk -F'\t' '$2 == "active" { print $1 }' "$tmp/reqs" | sort -u >"$tmp/active"
awk -F'\t' '$2 == "dropped" { print $1 }' "$tmp/reqs" | sort -u >"$tmp/dropped"

comm -23 "$tmp/cited" "$tmp/defined" >"$tmp/orphan"
comm -12 "$tmp/cited" "$tmp/dropped" >"$tmp/dropped_tested"
comm -23 "$tmp/active" "$tmp/cited" >"$tmp/uncovered"

section() { # title, file, show where it's cited
  [ -s "$2" ] || return 0
  echo "$1"
  while IFS= read -r id; do
    if [ "${3:-}" = cited ]; then
      echo "  $id  ($(awk -F'\t' -v id="$id" '$1 == id { print $2 }' "$tmp/refs_known" | paste -sd, -))"
    else
      echo "  $id"
    fi
  done <"$2"
}

[ -s "$tmp/bad" ] && sort -u "$tmp/bad"
section "ORPHAN (tests cite an ID that doesn't exist)" "$tmp/orphan" cited
section "DROPPED BUT TESTED" "$tmp/dropped_tested" cited
section "UNCOVERED (active, no test)" "$tmp/uncovered"

active=$(wc -l <"$tmp/active" | tr -d ' ')
uncovered=$(wc -l <"$tmp/uncovered" | tr -d ' ')
drafts=$(awk -F'\t' '$2 == "draft"' "$tmp/reqs" | wc -l | tr -d ' ')
echo "Coverage: $((active - uncovered))/$active active ($drafts draft)"

[ "$mode" = report ] && exit 0
if [ -s "$tmp/bad" ] || [ -s "$tmp/orphan" ] || [ -s "$tmp/dropped_tested" ]; then exit 1; fi
if [ "$mode" = strict ] && [ "$uncovered" -gt 0 ]; then exit 1; fi
exit 0
