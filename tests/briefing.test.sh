#!/bin/sh
# The pack ships a briefing beside the skills. A skill the briefing never names
# is a skill an agent is never told to load: the frontmatter description is the
# catalog entry an agent can notice, but the briefing is where a situation names
# its skill in the imperative.
#
# Run with `just test`. Read-only; needs only POSIX tools.
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
briefing_dir="$repo/briefing"

fails=0
ok()  { printf '  ok    %s\n' "$1"; }
bad() { printf '  FAIL  %s\n' "$1"; fails=$((fails + 1)); }

[ -d "$briefing_dir" ] || { bad "no briefing/ directory — the pack ships no briefing"; exit 1; }

set -- "$briefing_dir"/*.md
[ -f "$1" ] || { bad "briefing/ contains no Markdown"; exit 1; }

# Every skill is named; the naming is checked against the tree, so adding a
# skill without routing to it fails here.
for dir in "$repo"/skills/*; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    if grep -F -q -- "\`$name\`" "$briefing_dir"/*.md; then
        ok "briefing names $name"
    else
        bad "briefing does not name the $name skill"
    fi
done

# It is always-on prose, so it has to stay small.
lines=$(cat "$briefing_dir"/*.md | wc -l | tr -d ' ')
if [ "$lines" -le 40 ]; then
    ok "briefing is $lines lines (ceiling 40)"
else
    bad "briefing is $lines lines, over the 40-line ceiling — something has accreted"
fi

[ "$fails" -eq 0 ] || { printf '\n%s check(s) failed\n' "$fails" >&2; exit 1; }
printf '\nall checks passed\n'
