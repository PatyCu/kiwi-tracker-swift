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

report "A View's name ends in a suffix from ios/CONVENTIONS.md (UI):" "$(
  find KiwiKit/Sources/KiwiFeatures KiwiKit/Sources/KiwiDesign -name '*.swift' -print0 |
    xargs -0 perl -0777 -ne '
      while (/^[ \t]*(?:(?:@[\w.]+(?:\([^)]*\))?|\w+)[ \t]+)*(?:struct|class|enum|actor|extension)[ \t]+([\w.]+)((?:<(?:[^<>]++|(?2))*>)?)[ \t]*:([^{]*)\{/mg) {
        my ($name, $conformances, $at) = ($1, $3, $-[0]);
        $conformances =~ s/\bwhere\b.*//s;
        next unless $conformances =~ /(?:^|,)\s*(?:SwiftUI\.)?View\s*(?:,|$)/;
        $name =~ s/.*\.//;
        next if $name =~ /(Screen|Sheet|Section|Header|Card|Row|Field|Picker|Button|Label|Image|View)$/;
        my $line = 1 + (substr($_, 0, $at) =~ tr/\n//);
        print "$ARGV:$line: $name\n";
      }
    '
)"

exit $status
