#!/bin/sh
# The mechanical rules in ios/CONVENTIONS.md. Run from ios/ by `make lint`.
status=0

report() {
  if [ -n "$2" ]; then
    echo "$1"
    echo "$2"
    status=1
  fi
}

colors='red|orange|yellow|green|mint|teal|cyan|blue|indigo|purple|pink|brown|white|gray|black'
report "Color literal outside KiwiDesign; use a Palette token:" "$(
  grep -rnE --include='*.swift' \
    "Color\((red|hue|white|uiColor|\"|\.sRGB)|UIColor\(|Color\.($colors)\b|\((\.|Color\.)($colors)\)" \
    KiwiTracker KiwiKit/Sources KiwiKit/Tests |
    grep -v '^KiwiKit/Sources/KiwiDesign/'
)"

report "Only KiwiData imports Supabase:" "$(
  grep -rnE --include='*.swift' '^import Supabase' KiwiTracker KiwiKit/Sources KiwiKit/Tests |
    grep -vE '^KiwiKit/(Sources/KiwiData|Tests/KiwiDataTests)/'
)"

report "KiwiDomain imports only Foundation:" "$(
  grep -rnE --include='*.swift' '^import ' KiwiKit/Sources/KiwiDomain | grep -v 'import Foundation$'
)"

exit $status
