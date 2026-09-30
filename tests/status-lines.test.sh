#!/bin/sh
# The design-doc skill ships references/status-lines.sh so a repo can enforce
# the status vocabulary without the skill. This exercises every finding it
# claims to produce, against a throwaway git repo of fixture docs.
#
# Run with `just test`. Read-only against this repo; needs git and awk.
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
script="$repo/skills/design-doc/references/status-lines.sh"
fails=0
ok()  { printf '  ok    %s\n' "$1"; }
bad() { printf '  FAIL  %s\n' "$1"; fails=$((fails + 1)); }

[ -f "$script" ] || { bad "status-lines.sh is missing"; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/docs/design"
cd "$tmp"
git init -q .
git config user.email t@example.com
git config user.name test

w() { cat >"docs/design/$1"; }

w clean.md <<'EOF'
---
status: in-review
---
# A clean design

**Status:** DESIGN, 2026-09-05. Nothing built.

**Needs your ruling:** [OQ-1](#OQ-1).

1. 💬 **OQ-1: A live question.** Stakes.
EOF

w badword.md <<'EOF'
# Shipped, allegedly

**Status:** ALL PHASES SHIPPED, 2026-09-01.
EOF

w nostatus.md <<'EOF'
# An index nobody stamped

Links to things.
EOF

w dated-current.md <<'EOF'
# A living record

**Status:** CURRENT, 2026-08-02.
EOF

w evergreen.md <<'EOF'
# A living record, done right

**Status:** CURRENT. The runbook for the nightly job.
EOF

w unstamped.md <<'EOF'
# Built, and nobody said whether it ran

**Status:** BUILT 2026-09-12 (`a1b2c3d`).
EOF

w measured.md <<'EOF'
# Built and watched

**Status:** BUILT 2026-09-12 (`a1b2c3d`). MEASURED: 171 ms → 0.3 ms on the real corpus.
EOF

w unmeasured.md <<'EOF'
# Built, honestly unobserved

**Status:** BUILT 2026-09-12 (`a1b2c3d`). UNMEASURED: no CI job exercises the macOS backend.
EOF

w ruling-lies.md <<'EOF'
# Claims nothing is owed

**Status:** DESIGN, 2026-09-05.

**Needs your ruling:** None.

1. 💬 **OQ-4: One.** Stakes.
2. 💬 **OQ-7: Two.** Stakes.
EOF

w ruling-partial.md <<'EOF'
# Names one of two

**Status:** DESIGN, 2026-09-05.

**Needs your ruling:** [OQ-4](#OQ-4).

1. 💬 **OQ-4: One.** Stakes.
2. 💬 **OQ-7: Two.** Stakes.
EOF

w ruling-stale.md <<'EOF'
# Names a question that was compacted

**Status:** DESIGN, 2026-09-05.

**Needs your ruling:** [OQ-4](#OQ-4), [OQ-9](#OQ-9).

1. 💬 **OQ-4: One.** Stakes.
EOF

w built-with-questions.md <<'EOF'
# Executed, allegedly

**Status:** BUILT 2026-09-12 (`a1b2c3d`). MEASURED: against a control.

**Needs your ruling:** [OQ-2](#OQ-2).

1. 💬 **OQ-2: Still live.** Stakes.
EOF

w fm-offvocab.md <<'EOF'
---
status: decided
---
# Chip-less

**Status:** DECIDED, 2026-09-05.
EOF

w specimen.md <<'EOF'
# A doc that quotes the vocabulary

**Status:** DECIDED, 2026-09-05.

An example of what a bad line looks like:

```markdown
**Status:** ALL PHASES SHIPPED, 2026-09-01.

1. 💬 **OQ-9: A specimen.** Not a live question.
```
EOF

w answered.md <<'EOF'
# Everything ruled

**Status:** DECIDED, 2026-09-05.

1. ✅ **OQ-1: Answered.** — RESOLVED (2026-09-05)
2. 🔒 **OQ-3: Blocked upstream.** Stakes.
EOF

# Source-owned stages must work without a second lifecycle word in prose.
w stage-design.md <<'EOF'
---
status: in-review
stage: DESIGN
next: "Rule OQ-1"
---
# A design
**Status:** 2026-09-29. Nothing built.
**Needs your ruling:** [OQ-1](#OQ-1).
1. 💬 **OQ-1: Choose.** Stakes.
EOF

w stage-built.md <<'EOF'
---
status: accepted
stage: "BUILT"
---
# Built
**Status:** 2026-09-29 (`a1b2c3d`). UNMEASURED: target unavailable.
EOF

w stage-duplicate.md <<'EOF'
---
stage: DESIGN
---
# Conflicting copies
**Status:** DECIDED, 2026-09-29.
EOF

w stage-bad.md <<'EOF'
---
stage: SHIPPED
---
# Wrong stage
**Status:** 2026-09-29.
EOF

w stage-current.md <<'EOF'
---
status: accepted
stage: CURRENT
---
# Evergreen
**Status:** Maintained reference.
EOF

w stage-unstamped.md <<'EOF'
---
stage: BUILT
---
# Missing observation
**Status:** 2026-09-29 (`a1b2c3d`).
EOF

w stage-undated.md <<'EOF'
---
stage: DECIDED
---
# Missing date
**Status:** Work remains.
EOF

w stage-blocked.md <<'EOF'
---
stage: BUILT
---
# Built with a pending decision
**Status:** 2026-09-29 (`a1b2c3d`). MEASURED: tests passed.
1. 🔒 **OQ-3: Await target evidence.** Still undecided.
   <!-- vantage: oq id=OQ-3 -->
EOF

# Regression fixtures for stage-first validation, comments, and compaction.
w current-only.md <<'EOF'
---
stage: CURRENT
---
# Maintained
EOF
w bad-only.md <<'EOF'
---
stage: SHIPPED
---
# Invalid even without prose
EOF
w dated-only.md <<'EOF'
---
stage: DESIGN
---
# A stage is not its evidence
EOF
w stage-comment.md <<'EOF'
---
stage: DESIGN  # still being argued
---
**Status:** 2026-09-29.
EOF
w stage-quoted-comment.md <<'EOF'
---
stage: 'DESIGN' # still being argued
---
**Status:** 2026-09-29.
EOF
w stage-hash.md <<'EOF'
---
stage: "DESIGN # not a comment"
---
**Status:** 2026-09-29.
EOF
w built-answered.md <<'EOF'
---
stage: BUILT
---
**Status:** 2026-09-29. MEASURED: test.
1. ✅ **OQ-A1: Ruled.** Awaiting compaction.

   <!-- vantage: oq id=OQ-A1 -->

   **Answer:**
   > Agreed.
EOF
w built-ledger.md <<'EOF'
---
stage: BUILT
---
**Status:** 2026-09-29. MEASURED: test.
| ID | Ruling | Built |
| :--- | :--- | :--- |
| OQ-A1 | Agreed | ✅ |
EOF
w built-answered-specimen.md <<'EOF'
---
stage: BUILT
---
**Status:** 2026-09-29. MEASURED: test.
~~~markdown
1. ✅ **OQ-A1: Example.** Not a question here.
~~~
EOF

git add -A && git commit -qm fixtures

run() { sh "$script" "docs/design/$1" 2>&1 || true; }
code() { sh "$script" "docs/design/$1" >/dev/null 2>&1 && echo 0 || echo $?; }

expect() { # file, code, description
    got=$(run "$1")
    case "$got" in
        *"$2"*) ok "$3" ;;
        *)      bad "$3 — got: $got" ;;
    esac
}
reject() { # file, code, description
    got=$(run "$1")
    case "$got" in
        *"$2"*) bad "$3 — got: $got" ;;
        *)      ok "$3" ;;
    esac
}

expect clean.md                "ok        docs/design/clean.md" "a clean doc passes"
[ "$(code clean.md)" = 0 ] && ok "clean doc exits 0" || bad "clean doc should exit 0"

expect badword.md              BADWORD   "an off-vocabulary word is BADWORD"
[ "$(code badword.md)" = 1 ] && ok "a finding exits 1" || bad "a finding should exit 1"

expect nostatus.md             NOSTATUS  "a missing status line is NOSTATUS"
expect dated-current.md        NODATE    "CURRENT with a date is NODATE"
expect evergreen.md            "ok  "    "CURRENT without a date passes"
expect unstamped.md            UNSTAMPED "BUILT with no clause is UNSTAMPED"
reject measured.md             UNSTAMPED "MEASURED: satisfies the clause"
reject unmeasured.md           UNSTAMPED "UNMEASURED: satisfies the clause"
reject unmeasured.md           NEEDDATE  "a stamped BUILT line is dated"
expect ruling-lies.md          "says None, 2 live: OQ-4, OQ-7" "None against live questions is RULING"
expect ruling-partial.md       "OQ-7 is live and missing" "a live id absent from the ruling line is RULING"
reject ruling-partial.md       "OQ-4 is live"            "an id the ruling line does name is not reported"
expect ruling-stale.md         "OQ-9, which is not a live question" "a stale id on the ruling line is RULING"
expect built-with-questions.md "BUILT while 1 question" "BUILT with a live question is RULING"
expect fm-offvocab.md          FMSTATUS  "off-vocabulary frontmatter is FMSTATUS"
expect specimen.md             "ok  "    "a fenced specimen is not a claim"
expect answered.md             "ok  "    "answered and blocked questions are not live"

expect measured.md             GRADUATE  "BUILT with no live questions is a graduation candidate"
[ "$(code measured.md)" = 0 ] && ok "a lone GRADUATE is a notice, not a failure" \
                              || bad "a lone GRADUATE should exit 0"

expect stage-design.md "ok  " "frontmatter stage with date-only prose passes"
expect stage-built.md GRADUATE "frontmatter BUILT is a graduation candidate"
[ "$(code stage-built.md)" = 0 ] && ok "frontmatter BUILT with evidence exits 0" || bad "stage BUILT should pass"
expect stage-duplicate.md DUPSTAGE "a copied lifecycle word in prose is reported"
expect stage-bad.md BADWORD "an off-vocabulary frontmatter stage is BADWORD"
expect stage-current.md "ok  " "frontmatter CURRENT needs no lifecycle date"
expect stage-unstamped.md UNSTAMPED "frontmatter BUILT still requires observation evidence"
expect stage-undated.md NEEDDATE "frontmatter DECIDED still needs a prose date"

reject stage-blocked.md GRADUATE "blocked decisions prevent graduation"
expect stage-blocked.md RULING "BUILT with a blocked question is reported"

expect current-only.md "ok  " "CURRENT needs neither prose nor a date"
[ "$(code current-only.md)" = 0 ] && ok "CURRENT-only exits 0" || bad "CURRENT-only must pass"
expect bad-only.md BADWORD "invalid stage is checked before missing prose"
reject bad-only.md NOSTATUS "invalid stage does not hide behind NOSTATUS"
expect dated-only.md NEEDDATE "a dated stage without prose still needs evidence"
expect stage-comment.md "ok  " "plain stage accepts a YAML comment"
expect stage-quoted-comment.md "ok  " "quoted stage accepts an outside YAML comment"
expect stage-hash.md BADWORD "a hash inside quotes remains part of the stage"
reject built-answered.md GRADUATE "an answered question prevents graduation"
expect built-answered.md "1 answered question(s) await compaction" "answered question reports compaction owed"
[ "$(code built-answered.md)" = 1 ] && ok "compaction owed exits 1" || bad "compaction owed must fail"
expect built-ledger.md GRADUATE "ledger checkmarks do not prevent graduation"
expect built-answered-specimen.md GRADUATE "fenced answered examples do not prevent graduation"
expect stage-built.md "BUILT, no questions left" "graduation notice includes every question state"
stale_count=$(run ruling-stale.md | awk '/names OQ-9, which/ { n++ } END { print n+0 }')
[ "$stale_count" = 1 ] && ok "linked stale id reports once, not label plus anchor" || bad "linked stale id reported $stale_count times"

exit $((fails > 0))
