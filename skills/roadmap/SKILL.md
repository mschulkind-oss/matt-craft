---
name: roadmap
description: Use when creating, updating, reconciling, or compacting a project's living roadmap.
---

# Roadmap

The roadmap is a **routing table with a priority order**: each committed piece of unfinished work,
its next actor and action, and the doc that holds the details. It is not where the thinking lives,
and it is not a record of what happened.

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
   leaning. The row names the next action or decision and links it; a reader who wants the
   argument clicks.
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

### 2. Actionable (▶️)

**The primary agent queue.** If an agent can make useful progress now without a new user ruling,
put the next step here — including investigation, research, experiments, writing or revising a
design, planning, implementation, and verification. **Actionable does not mean ready to implement.**
A missing answer is often the work: research it, test it, or prepare a recommendation before asking
for a ruling. Do not invent a ruling or implement past a genuine owner gate.

```markdown
| # | Next agent action | Doc | Stops at |
|---|---|---|---|
| **1** | Research the two options and recommend one | [Design](doc.md) | User rules [the choice](doc.md#question) |
| **2** | Implement the agreed slice | [Plan](plan.md) | Run tests and verify on target |
```

Each row names a **concrete next action**, not just a project or a status. Link the work's source;
name the first actual stop in **Stops at** (a user ruling, external dependency, or verifiable done
condition). An item can need the user *eventually* and still be ▶️ now. Keep it here while an agent
can advance it, and move it to 💬 only when the next step truly belongs to the user. Split independent
steps into separate rows so an owner-gated decision does not hide unrelated agent work. A build
step must be implementable cold from its linked docs: resolve or explicitly delegate every
necessary question. Otherwise the ▶️ action is to research or design, not to guess and build.

**State the ordering basis in the file** so the order is checkable. Default: fix a verified live
defect, then work that unblocks the most other work, then smaller independent steps. Call a row a
defect only after finding it in the tree; cite `file:line`, not the previous roadmap's claim.

When asked to **“take action on everything”**, work through every ▶️ row, not just build tasks.
Advance each as far as evidence and delegated authority allow; update its doc and row as the next
step changes. Do not silently skip research, and do not treat this as permission to make subjective
owner decisions or perform destructive/external actions without the required confirmation. Report
what advanced, what closed, and what now needs the user or an external condition.

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
  yours. Ask only what you cannot decide. If an agent can still narrow the question, put that step
  in ▶️ instead; 💬 is for the *next* action that only the user can take.

### 4. Waiting (🔒) and Icebox (🧊)

Two columns: what it is blocked on, and what would clear it. 🔒 is an environment, hardware, or a
measurement that an agent cannot obtain or work around now. 🧊 is genuine uncertainty about whether
we want the thing — never a long cycle time, and never a queue that got too big. If an agent can
investigate the blocker or clarify the proposal now, that next step is ▶️, not parked here.

### 5. What this file does not cover

One short section, with links: candidate work nobody has committed to, and live questions that
block nothing. Close it with the rule that keeps the file small without losing anything — *committed
work gets a row when there is a next action; a question gets a row when it blocks that work; both
leave when the work closes.*

## The emoji system

Distinct metaphors, not a colour ramp, so the file stays scannable in greyscale.

- ▶️ **Actionable** — a concrete next agent action, whether research, design, build, or verification.
- 💬 **Needs you** — the next step is a decision only the user can make. (🤷 beside it: genuinely their preference.)
- 🏗️ **In progress** in the active session.
- 🔒 **Waiting** on hardware, a host, or a measurement.
- 🛑 **Broken** — actively failing; if an agent can investigate or fix it, that work goes in ▶️.
- 🧊 **Icebox** — unsure we want it.

**Failsafe ambiguity:** uncertainty about completion is not completion. If an agent can verify on
the target, verification is ▶️; if only the owner or unavailable hardware can, route it to 💬 or
🔒 respectively. Never label unverified work done.

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
3. **Check rows whose doc shows no live questions** against the doc and tree. Remove closed work,
   but keep unfinished research, build, or verification steps in ▶️; zero questions is not done.
4. **Check recent commits and the working tree** for work that shipped, and for build orders whose
   steps are now done.
5. **Hunt 💬, 🔒, and 🧊 for agent actions** — research, narrowing a choice, experiments, partial
   implementation, verification — and route each independent next step to ▶️. A remaining owner
   gate belongs in 💬 only once the agent step is exhausted.
6. **Re-verify every blocker.** "Blocked on a measurement / hardware / another ruling" is a claim
   with a date on it; confirm it still holds.
7. **Find unrouted work and questions** — committed work with no row, or docs carrying live
   questions that no row names. Route the next action, or name out-of-scope questions under
   *does not cover*.
8. **Re-derive the counted header** from the rows you ended up with, and check every link and
   anchor resolves.

## Compacting a sprawling roadmap

When the file has grown narrative, do not trim it row by row — **rewrite it into the shape above,
from the docs**, using the old file only as an index of which docs to read. What is lost is
history, which is what `git log` is for.

Then tell the user what the rewrite found: rows already answered in their own docs, counts that
were wrong, agent work that was buried, questions nothing routed. Those findings are the argument
that the compaction was needed, and they are invisible from inside the old file.

## Doc changes are roadmap changes

The roadmap is the index of the planning tree, and it is the half that goes stale silently: nobody
re-reads a design doc to discover that the question blocking them was answered last week. **The
roadmap edit belongs in the same commit as the doc change.**

| The doc did this | The roadmap does this |
| --- | --- |
| A design doc is created (`design-doc`) | Route its next agent action to ▶️, or its genuinely owner-only ruling to 💬 |
| A `💬` question opened | Researchable next step goes to ▶️; only an owner-only next step goes to 💬 |
| A question answered and compacted | `Live` drops; remove the row only if the underlying work is done |
| A design settles — zero `💬`, `status: accepted` | Unfinished implementation or verification goes to ▶️ |
| An implementation plan opens as a `SKETCH` (`implementation-plan`) | Refining the sketch may be ▶️; it is not a build hand-off |
| That plan is promoted against the tree | Build step goes to ▶️, linking the plan and design |
| A brainstorm idea is promoted (`brainstorming`) | Route the next agent step or owner ruling; ideas still being costed do not enter the queue |
| A user story records a gap accepted as work (`user-stories`) | Its own row, linking the story and naming the next actor |
| A research round rules an option out or opens a decision (`research`) | Update the next action; move to 💬 only if agent work is exhausted |
| A design ships and graduates (`system-doc`) | The row leaves; anything specified-but-not-built stays as its own ▶️ row |

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
