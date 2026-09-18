#!/usr/bin/env sh
#
# status-lines — check a planning tree's status lines against the vocabulary.
#
# The status line is the first thing a reader looks at and the line most likely
# to be false. This makes the vocabulary enforceable inside the repository that
# holds the docs, rather than only inside the skill that defines it.
#
#   sh status-lines.sh [path ...]      # default: docs/design docs/plans
#
# For every tracked Markdown file under the given paths it checks:
#
#   NOSTATUS   no `**Status:**` line at all
#   BADWORD    the first word is not one of the seven
#   NEEDDATE   a dated word carries no ISO date
#   NODATE     CURRENT carries a date (an evergreen doc has no moment)
#   UNSTAMPED  BUILT with no MEASURED:/UNMEASURED: clause
#   FMSTATUS   frontmatter `status:` outside Vantage's four (renders no chip)
#   RULING     the "Needs your ruling" line disagrees with the live questions
#   GRADUATE   BUILT, zero live questions — hand off to system-doc
#
# Exit 0 = clean, 1 = at least one finding, 2 = bad invocation. GRADUATE is a
# notice rather than a finding: it reports work that is ready to hand off, not
# a document that is wrong.
#
# POSIX sh + git + awk; no other deps. Read-only.

set -eu

VOCAB="SKETCH DESIGN DECIDED BUILT GRADUATED SUPERSEDED CURRENT"
FM_VOCAB="draft in-review accepted deprecated"

git rev-parse --git-dir >/dev/null 2>&1 || {
    echo "status-lines: not inside a git repository" >&2
    exit 2
}

if [ "$#" -eq 0 ]; then
    for d in docs/design docs/plans; do
        [ -d "$d" ] && set -- "$@" "$d"
    done
    [ "$#" -gt 0 ] || {
        echo "status-lines: no docs/design or docs/plans here; name a path" >&2
        exit 2
    }
fi

# git ls-files rather than find: git is already required, and some
# environments shim or block find. Tracked files are the right perimeter.
docs=$(mktemp)
trap 'rm -f "$docs"' EXIT
for root in "$@"; do
    git ls-files -- "$root"
done | sort -u >"$docs"

FAIL=0
SEEN=0

# Fed by redirection, not a pipe: a pipeline runs the loop in a subshell and
# the FAIL assignments below would be discarded.
while IFS= read -r doc; do
    case "$doc" in *.md) ;; *) continue ;; esac
    [ -f "$doc" ] || continue
    SEEN=$((SEEN + 1))

    out=$(awk -v vocab="$VOCAB" -v fmvocab="$FM_VOCAB" '
        BEGIN {
            chat = "\360\237\222\254"; done = "\342\234\205"; lock = "\360\237\224\222"
            split(vocab, v, " ");   for (i in v) ok_word[v[i]] = 1
            split(fmvocab, f, " "); for (i in f) ok_fm[f[i]]   = 1
        }
        NR == 1 && $0 == "---" { fm = 1; next }
        fm && $0 == "---"      { fm = 0; next }
        fm && /^status:[ \t]*/ {
            fmstatus = $0
            sub(/^status:[ \t]*/, "", fmstatus)
            gsub(/^[ \t"'"'"']+|[ \t"'"'"']+$/, "", fmstatus)
            next
        }
        fm { next }

        # Fences hold specimens, never claims: a doc that quotes this
        # vocabulary in an example is not stamped with it.
        /^[ \t]*(```|~~~)/ { fence = !fence; next }
        fence { next }

        /^\*\*Status:\*\*/ && status_line == ""  { status_line = $0; next }
        /^\*\*Needs your ruling/ && ruling == "" { ruling = $0; next }

        # A live question carries both the emoji and an id. A bare emoji in
        # prose ("answer the remaining questions") is not a question.
        index($0, chat) && $0 ~ /OQ-[A-Z]*[0-9]+/ {
            if (index($0, done) || index($0, lock)) next
            line = $0
            while (match(line, /OQ-[A-Z]*[0-9]+/)) {
                id = substr(line, RSTART, RLENGTH)
                if (!(id in live)) { live[id] = 1; order[++nlive] = id }
                line = substr(line, RSTART + RLENGTH)
            }
        }

        END {
            if (fmstatus != "" && !(fmstatus in ok_fm))
                print "FMSTATUS|frontmatter status \"" fmstatus "\" is outside Vantage'"'"'s four, so it renders no chip"

            if (status_line == "") { print "NOSTATUS|no **Status:** line"; exit }

            rest = status_line
            sub(/^\*\*Status:\*\*[ \t]*/, "", rest)
            word = rest
            sub(/[ \t].*$/, "", word)
            gsub(/[^A-Za-z]/, "", word)

            if (!(word in ok_word)) {
                print "BADWORD|status \"" word "\" is not in the vocabulary"
                exit
            }

            dated = (rest ~ /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)
            if (word == "CURRENT" && dated)  print "NODATE|CURRENT takes no date"
            if (word != "CURRENT" && !dated) print "NEEDDATE|" word " needs an ISO date"

            if (word == "BUILT") {
                bare = rest
                gsub(/UNMEASURED/, "", bare)
                if (index(bare, "MEASURED") == 0 && index(rest, "UNMEASURED") == 0)
                    print "UNSTAMPED|BUILT with no MEASURED:/UNMEASURED: clause"
            }

            ids = ""
            for (i = 1; i <= nlive; i++) ids = ids (ids == "" ? "" : ", ") order[i]

            if (ruling != "") {
                claimed = 0
                line = ruling
                while (match(line, /OQ-[A-Z]*[0-9]+/)) {
                    id = substr(line, RSTART, RLENGTH)
                    if (!(id in live))
                        print "RULING|Needs your ruling names " id ", which is not a live question"
                    named[id] = 1; claimed++
                    line = substr(line, RSTART + RLENGTH)
                }
                if (claimed == 0 && nlive > 0)
                    print "RULING|Needs your ruling says None, " nlive " live: " ids
                else
                    for (i = 1; i <= nlive; i++)
                        if (!(order[i] in named))
                            print "RULING|" order[i] " is live and missing from Needs your ruling"
            } else if (nlive > 0) {
                print "RULING|no Needs your ruling line, " nlive " live: " ids
            }

            if (word == "BUILT" && nlive == 0)
                print "GRADUATE|BUILT, zero live questions — hand off to system-doc"
            if (word == "BUILT" && nlive > 0)
                print "RULING|BUILT while " nlive " question(s) are still live: " ids
        }
    ' "$doc")

    if [ -z "$out" ]; then
        printf 'ok        %s\n' "$doc"
        continue
    fi

    printf '%s\n' "$out" | while IFS='|' read -r code msg; do
        printf '%-9s %s  (%s)\n' "$code" "$doc" "$msg"
    done

    # A lone GRADUATE is a notice; anything else fails the run.
    case "$out" in
        GRADUATE*) [ "$(printf '%s\n' "$out" | wc -l)" -eq 1 ] || FAIL=1 ;;
        *) FAIL=1 ;;
    esac
done <"$docs"

[ "$SEEN" -gt 0 ] || echo "status-lines: no tracked Markdown under $*" >&2

exit "$FAIL"
