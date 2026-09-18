---
name: roadmap
description: Use when creating, updating, reconciling, or compacting a project's living roadmap.
---

# Roadmap

The roadmap is a **routing table with a priority order**: each open decision, the doc that holds it,
and what ruling it releases. It is not where the thinking lives, and it is not a record of what
happened.

Default location: **`roadmap.md`** at the project root, unless the repo has an established one.

A reader must get two things from it in under a minute:

1. **What is outstanding.**
2. **Where to spend the next hour.**

Everything below serves those two. A roadmap that has to be *read* rather than *scanned* has
already failed, however accurate it is.

## The hard rules

These are the ones a long-lived roadmap breaks first, and they break silently.

1. **One table line per item.** No paragraphs, no sub-bullets, no per-item callouts. If an item
   needs a paragraph, the paragraph belongs in its doc and the row links it.
2. **Never restate what the doc says** — not the question, the stakes, the options, or your
   leaning. The row names the decision and links it; a reader who wants the argument clicks.
3. **No history.** Not what a row used to say, not why it changed, not what a previous count was,
   not a correction of an earlier correction. `git log -p -- <roadmap>` is the record. A sentence
   beginning *"this row used to say"* is always a deletion.
4. **No done items.** There is no ✅. Work that closes leaves the file the day it closes.
5. **Counts are derived, never carried forward.** Re-derive every number from the docs each run.
   A count copied from the previous version of the file is how the file starts lying.
6. **Budget: under ~200 lines.** Past 300 the file is the problem, not the project. If the rows
   genuinely do not fit, the project needs triage — say so in one line at the top rather than
   growing the file.

> [!IMPORTANT]
> The failure these prevent is not ugliness, it is **staleness**. A file nobody can scan is a file
> nobody reconciles, and its rows go on describing questions that were answered weeks ago. Expect
> to find, on any roadmap that has grown past its budget, at least one row whose own doc says in as
> many words that it is resolved.

## The shape

### 1. Header

A **counted** status line and the date — tally the actual rows, never assert. Then three sentences
stating what the file is and is not, so the next agent editing it inherits the rules above.

### 2. Rule these first

The prioritization answer, and the reason the file exists. Five to eight lines, each worth one
sitting.

**State the ordering basis in the file** so the order is checkable rather than asserted. The
default basis, which fits most projects:

> a defect live in shipped code outranks blocked build work, which outranks a ruling that only
> closes a doc; ties break toward the smallest sitting.

```markdown
| | Rule | Releases | Cost |
|---|---|---|---|
| **1** | [`OQ-ID`](doc.md#anchor) — the decision, in six words | **Defect, live today.** `file.go:168` keeps X, so Y | one ruling |
```

> [!WARNING]
> **Verify before you rank.** Call a row a *defect* only if you found it in the tree — name the
> `file:line`. The previous roadmap's prose is not evidence; it is the thing most likely to be
> stale, and ranking off it puts a closed question at the top of the list.

### 3. Needs you (💬)

```markdown
| # | Decides | Doc | Live | Gate | Releases |
|---|---|---|---|---|---|
| **26** | The decision in one clause, not its background | [`doc-name`](path.md) · *in-review* | 4 | [`OQ-ID`](path.md#anchor) | **defect** — shipped, reproducible |
```

- **Decides** — what ruling this is. One clause.
- **Doc** — the link, plus the doc's own status (`draft` / `in-review` / `accepted` /
  `sketch, nothing built`), read off the doc rather than remembered.
- **Live** — that doc's live open-question count, derived.
- **Gate** — the single id to rule if the user rules only one thing. **This is the column that
  turns a pile of questions into a next action**; a row without one has not been thought about.
- **Releases** — exactly one of **defect** (something is wrong in shipped code today), **build**
  (designed code is waiting on this ruling), or **doc** (nothing waits; the ruling closes
  questions) — plus a short object.

Follow the table with at most two short lists: **rule-together sets** (decisions that are
unanswerable apart) and **small calls** that do not deserve a row.

- Where a decision is genuinely subjective, mark the row 🤷 rather than manufacturing a
  recommendation. The leaning still lives in the doc, not here.
- **No artificial "pick one" bottlenecks.** Never ask the user to sequence approved work — that is
  yours. Ask only what you cannot decide.

### 4. Ready (📦)

Ruled, unblocked, nobody waiting on the user.

**Ready means implementable cold** — an agent with no memory of any conversation could pick it up.
Apply the gap test to the item and everything it links: every question the implementer must answer
is answered there, open with a stable id, or explicitly delegated. An answer that exists only in
this session's context makes the item 💬, not 📦.

> [!WARNING]
> **Ready work hides inside 💬 rows.** A design with thirteen open questions routinely has three
> build steps blocked by none of them. Go looking every run — an empty 📦 beside a large 💬 section
> is usually wrong, and it is the most useful thing a reconcile finds after a stale row.

### 5. Waiting (🔒) and Icebox (🧊)

Two columns: what it is blocked on, and what would clear it. 🔒 is an environment, hardware, or a
measurement. 🧊 is genuine uncertainty about whether we want the thing — never a long cycle time,
and never a queue that got too big.

### 6. What this file does not cover

One short section, with links: candidate work nobody has committed to, and live questions that
block nothing. Close it with the rule that keeps the file small without losing anything — *a
question is promoted to a row the day it starts blocking something, and leaves the day it stops.*

## The emoji system

Distinct metaphors, not a colour ramp, so the file stays scannable in greyscale.

- 💬 **Needs you** — a decision only the user can make. (🤷 beside it: genuinely their preference.)
- 📦 **Ready** — designed, ruled, no blockers.
- 🏗️ **In progress** in the active session.
- 🔒 **Waiting** on hardware, a host, or a measurement.
- 🛑 **Broken** — actively failing.
- 🧊 **Icebox** — unsure we want it.

**Failsafe ambiguity:** when a state is genuinely unclear — built on Linux, unverified on the
target platform — pick the state that fails safe (🔒 over 📦), so nothing is assumed complete.

**Vocabulary migrations:** substitute longest-match-first. A `🟡 ❓` → `💬 🤷` rule must run before
a bare `🟡` → `💬` rule, or the compound splits and strands the old glyph on the most important
rows.

## Reconciling — the default action

Invoked by itself (`/roadmap`, "update the roadmap", "where are we at"): reconcile against the docs
and the tree. **Derive, then diff** — reading the existing rows first is how their staleness gets
inherited.

1. **Count live questions per doc, mechanically.** Find the project's greppable open-question
   marker and count with it; put the command in the file so the number is re-runnable. ⚠ Check the
   pattern catches *every* spelling in use — a heading style or directive form it misses reads as
   zero, which is indistinguishable from a closed doc.
2. **Read each doc's status** from the doc.
3. **Drop every row whose doc shows no live questions**, then open that doc to confirm. This is the
   highest-yield step in the whole procedure; expect it to fire.
4. **Check recent commits and the working tree** for work that shipped, and for build orders whose
   steps are now done.
5. **Hunt the 💬 rows for ready work** (see 📦 above) and promote it.
6. **Re-verify every blocker.** "Blocked on a measurement / hardware / another ruling" is a claim
   with a date on it; confirm it still holds.
7. **Find unrouted questions** — docs carrying live questions that no row names. Give them a row,
   or name them under *does not cover*.
8. **Re-derive the counted header** from the rows you ended up with, and check every link and
   anchor resolves.

## Compacting a sprawling roadmap

When the file has grown narrative, do not trim it row by row — **rewrite it into the shape above,
from the docs**, using the old file only as an index of which docs to read. What is lost is
history, which is what `git log` is for.

Then tell the user what the rewrite found: rows already answered in their own docs, counts that
were wrong, ready work that was buried, questions nothing routed. Those findings are the argument
that the compaction was needed, and they are invisible from inside the old file.

## Doc changes are roadmap changes

The roadmap is the index of the planning tree, and it is the half that goes stale silently: nobody
re-reads a design doc to discover that the question blocking them was answered last week. **The
roadmap edit belongs in the same commit as the doc change.**

| The doc did this | The roadmap does this |
| --- | --- |
| A design doc is created (`design-doc`) | A row exists for it, linking the doc |
| A `💬` question opened | A **Needs you** row, or a new `Live` count on an existing one |
| A question answered and compacted | `Live` drops; at zero the row leaves |
| A design settles — zero `💬`, `status: accepted` | The row moves to **Ready** (📦) |
| An implementation plan opens as a `SKETCH` (`implementation-plan`) | Nothing becomes 📦 — a sketch is not a hand-off |
| That plan is promoted against the tree | 📦, linking the plan and the design |
| A brainstorm idea is promoted (`brainstorming`) | It arrives as a row; ideas still being costed do not |
| A user story records a gap accepted as work (`user-stories`) | Its own row, linking the story |
| A research round rules an option out or opens a decision (`research`) | The affected row updated, or a new 💬 row |
| A design ships and graduates (`system-doc`) | The row leaves; anything specified-but-not-built stays as its own row |

Two failure modes this exists to prevent, both of which look fine locally: **the answered question
that still reads blocked**, which costs the user a turn to discover, and **the shipped design whose
row never left**, which makes the counts lie.

## Format

- Follow the **`vantage-docs`** style guide, and run its checker on the result — tables, links,
  anchors, and the open-question reference rules (every question id is a link *with a fragment*).
- **Link aggressively.** Every row links its doc; every id links the question.
- Tables over bullets, bullets over prose, and nothing over a paragraph.

## Archiving Protocol

Completed work leaves immediately. How it leaves depends on what it was:

- **Features and fixes:** delete the row. The commit history is the record.
- **Retired decisions:** when we decide explicitly *not* to build something, or reject an
  architecture, move it to a "Retired Decisions" doc under `docs/`. Deleting it is dangerous — it
  will be re-proposed, and the reasoning is what stops that.
