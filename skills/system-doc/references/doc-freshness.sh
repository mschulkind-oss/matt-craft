#!/usr/bin/env sh
#
# doc-freshness — report which system docs may have rotted.
#
# For every Markdown file carrying `verified_commit:` and a `covers:` list in
# its YAML frontmatter, diff the covered paths between that commit and HEAD.
# An empty diff proves the doc is still current; a non-empty one names exactly
# which files to re-check.
#
#   sh doc-freshness.sh [path ...]        # default: docs/reference
#
# Exit 0 = everything current, 1 = at least one doc is stale or unverifiable.
# Suitable for CI or a pre-commit hook. POSIX sh + git + awk; no other deps.

set -eu

# Frontmatter shape this reads:
#
#   ---
#   verified_commit: a1b2c3d
#   covers:
#     - internal/broker/
#     - internal/proto/broker.go
#   ---
#
# Inline `covers: [a, b]` is also accepted.
parse_field() {
    # $1 = file, $2 = "commit" | "covers"
    awk -v want="$2" '
        BEGIN { sq = sprintf("%c", 39); trim = "^[[:space:]\"`" sq "]+|[[:space:]\"`" sq "]+$" }
        NR == 1 && $0 != "---" { exit }
        NR > 1 && $0 == "---"  { exit }
        {
            if (in_covers) {
                # A list item continues the covers block; anything else ends it.
                if ($0 ~ /^[ \t]*-[ \t]+/) {
                    sub(/^[ \t]*-[ \t]+/, "")
                    gsub(trim, "")
                    if (want == "covers" && length($0)) print
                    next
                }
                in_covers = 0
            }
            if ($0 ~ /^verified_commit:[ \t]*/) {
                sub(/^verified_commit:[ \t]*/, "")
                gsub(trim, "")
                if (want == "commit" && length($0)) print
                next
            }
            if ($0 ~ /^covers:[ \t]*$/)  { in_covers = 1; next }
            if ($0 ~ /^covers:[ \t]*\[/) {
                sub(/^covers:[ \t]*\[/, ""); sub(/\].*$/, "")
                n = split($0, parts, ",")
                for (i = 1; i <= n; i++) {
                    gsub(trim, "", parts[i])
                    if (want == "covers" && length(parts[i])) print parts[i]
                }
                next
            }
        }
    ' "$1"
}

git rev-parse --git-dir >/dev/null 2>&1 || {
    echo "doc-freshness: not inside a git repository" >&2
    exit 1
}

[ "$#" -gt 0 ] || set -- docs/reference

# git ls-files rather than find: git is already a hard requirement here, and
# some environments shim or block find. Only tracked files are considered,
# which is the right perimeter for a freshness check anyway.
docs=$(mktemp)
trap 'rm -f "$docs"' EXIT
for root in "$@"; do
    git ls-files -- "$root"
done | sort -u >"$docs"

FAIL=0
STAMPED=0

# Fed by redirection, not a pipe: a pipeline would run this loop in a subshell
# and the FAIL assignments below would be discarded.
while IFS= read -r doc; do
    case "$doc" in *.md) ;; *) continue ;; esac
    [ -f "$doc" ] || continue

    commit=$(parse_field "$doc" commit)
    [ -n "$commit" ] || continue          # not a stamped system doc
    STAMPED=$((STAMPED + 1))

    covers=$(parse_field "$doc" covers)
    if [ -z "$covers" ]; then
        echo "NOCOVER  $doc  (verified_commit but no covers: perimeter)"
        FAIL=1
        continue
    fi

    if ! git cat-file -e "${commit}^{commit}" 2>/dev/null; then
        echo "UNKNOWN  $doc  (verified_commit $commit not in this repo)"
        FAIL=1
        continue
    fi

    # shellcheck disable=SC2086 # covers is an intentional list of pathspecs
    changed=$(git diff --name-only "$commit" HEAD -- $covers)
    if [ -n "$changed" ]; then
        count=$(printf '%s\n' "$changed" | wc -l | tr -d ' ')
        echo "STALE    $doc  (verified $commit, $count file(s) changed since)"
        printf '%s\n' "$changed" | sed 's/^/  /'
        FAIL=1
    else
        echo "ok       $doc"
    fi
done <"$docs"

[ "$STAMPED" -gt 0 ] || echo "doc-freshness: no docs with a verified_commit: stamp under $*" >&2

exit "$FAIL"
