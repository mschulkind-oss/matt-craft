#!/bin/sh
# The engineering-principles skill's local contract.
#
# `scripts/check-skills` holds the corpus-wide invariants: frontmatter, naming, link
# containment, no symlinks. It knows nothing about what a *principle card* is. That
# shape is this one skill's contract, so it is asserted here rather than in the shared
# validator — and it is asserted mechanically, because a card that silently loses a
# section is a card that reads as authoritative while saying less than it claims.
#
# Run with `just test`. Read-only; POSIX tools only.
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
skill="$repo/skills/engineering-principles"

fails=0
ok()  { printf '  ok    %s\n' "$1"; }
bad() { printf '  FAIL  %s\n' "$1"; fails=$((fails + 1)); }

[ -f "$skill/SKILL.md" ] || { bad "missing skills/engineering-principles/SKILL.md"; exit 1; }
ok "the skill index exists"

# Every shipped reference link in the index resolves. `check-skills` checks the same
# thing, but it checks it for every skill; this names the failure in this skill's terms.
links=$(sed -n 's/.*](\(references\/[^)#]*\)).*/\1/p' "$skill/SKILL.md")
[ -n "$links" ] || bad "the index links no reference cards"
for target in $links; do
    if [ -f "$skill/$target" ]; then
        ok "index link resolves: $target"
    else
        bad "index link does not resolve: $target"
    fi
done

# Every card carries the six-part shape, in order, and nothing else at that level.
# Uniformity is the point: a reader who knows one card knows where the sharp test is.
expected=$(printf '%s\n' \
    "Definition" \
    "The Principle in One Move" \
    "The Sharp Test" \
    "What This Isn't" \
    "Failure Mode" \
    "Generic Example")

cards=0
for card in "$skill"/references/*.md; do
    [ -f "$card" ] || continue
    cards=$((cards + 1))
    name=$(basename "$card")
    got=$(sed -n 's/^## //p' "$card")
    if [ "$got" = "$expected" ]; then
        ok "$name carries the six-part shape"
    else
        bad "$name does not carry the six-part shape in order (got: $(printf '%s' "$got" | tr '\n' ',' ))"
    fi
done
[ "$cards" -gt 0 ] || bad "no reference cards ship"

[ "$fails" -eq 0 ] || { printf '\n%s check(s) failed\n' "$fails" >&2; exit 1; }
printf '\nall checks passed\n'
