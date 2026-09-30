---
name: roadmap
description: Use when creating, updating, reconciling, or compacting a project's living roadmap.
---

# Roadmap

A roadmap owns **priority and the reasons for that order**. Source documents own the work's
state, next action, dependencies, decisions, and evidence. Write each fact once, where it
belongs; the roadmap links to it rather than maintaining a second planning database.

Default location: **`roadmap.md`** at the project root, unless the repo has an established one.
Do not create one as a side effect of an unrelated doc task.

A reader must learn in under a minute **what matters next, why it comes first, and where to
act**. This must work in plain Markdown, on GitHub, and in a static export — not only in Vantage.
Badges are a convenience, never the content that makes the page useful.

## Ownership — one home per fact

| Fact | Home |
| :--- | :--- |
| Relative priority, sequencing rationale, cross-project trade-offs | Roadmap |
| Lifecycle stage, next action, dependencies, verification stops | Source design, plan, or work document |
| Questions, stakes, options, leaning, ruling | Question's owning document |
| What shipped and how the roadmap changed | Git history |

**No copied status chips, stage words, question counts, or counted status header.** A date
records the reconciliation; it is not evidence that every linked proposal is ready or built.
A roadmap link is not permission to implement: read the source's next step and gates first.

For work too small to justify a separate document, the roadmap may be its **only home**:
write its concrete action, first stop, and evidence directly beneath the entry. Do not create
an empty source doc just to have a link. If that work grows into a design or plan, move those
facts there and leave the priority reason here.

## The shape — an annotated priority list

1. **Header:** title, last reconciled date, and a short scope statement.
2. **Ordering basis:** explain what takes precedence. Default: verified live defects,
   work that unblocks other work, then smaller independent steps. Call something a defect
   only after finding it in the tree; link the evidence, not an earlier roadmap claim.
3. **Ordered entries:** a descriptive link identifying the work or decision, plus a
   one-clause reason for its place. A filename alone is not a useful label.
4. **Optional context beneath an entry:** one short paragraph or a few bullets holding
   only roadmap-owned material — why these efforts are sequenced together, what is being
   traded off, or an external unblock condition with no other home. Move detailed thinking
   to its source, but do not ban all prose or reduce the page to bare links.
5. **Boundaries:** briefly identify candidate work not yet committed to and questions
   intentionally outside this queue, with links where useful.

Prefer **one ordered list**. Use sections only when they add navigational value, such as a
separate external-wait list; document order is priority order, including across sections.
Do not recreate a status dashboard with mandatory Actionable / Needs you tables. Put the
links that actually set priority before background links: their order matters to Vantage too.

```markdown
# Roadmap

**Reconciled:** 2026-09-29

Prioritize the live data-loss defect, then the shared contract that unblocks both clients.
This page owns ordering; each linked document owns its next action and stopping conditions.

1. [Prevent duplicate imports](docs/design/imports-plan.md) — first because retries can
   overwrite a user's edits.

2. [Choose the storage contract](docs/design/storage.md#OQ-S2) — before either client,
   because changing it after both land doubles the migration work.

   Keep the two client efforts behind this choice rather than optimizing each separately.

3. [Build the offline client](docs/design/offline-plan.md) — ahead of sync polish because
   local recovery is useful even when the server is unreachable.

## External waits

4. [Compiler upgrade](docs/plans/compiler.md) — after the compatibility release, since the
   lint gate cannot run against the new compiler yet.
```

**Plain-Markdown acceptance test:** hide all badges and HTML comments. The page must still
identify the work, explain its order and trade-offs, and offer a clear place to act. A reader
may click for current state and next action; they must not click just to learn why an item
matters. More copied state is not the fallback for a missing renderer.

**Budget: under ~200 lines.** Past 300, triage scope or move detail to its owner; do not keep
history or expand a second set of question scaffolds. No done items or checked-off archive.

## Source planning metadata

For planning documents, use top-level frontmatter (ordinary YAML, readable outside Vantage):

```yaml
---
status: in-review
stage: DESIGN
next: "Rule OQ-S2 — the storage contract gates both clients"
depends-on:
  - ../research/storage.md
---
```

- **`status`** answers whether the argument is closed, using the repo's convention; Vantage
  recognizes `draft`, `in-review`, `accepted`, and `deprecated`.
- **`stage`** answers what the document owes someone, using the repository's own vocabulary.
  Keep it here, not repeated in a prose status line. Prose carries dates, reasons, and evidence.
- **`next`** holds one concrete next step as a line of plain text, including the first stop
  when useful. Research, experiments, design, implementation, and verification all count.
- **`depends-on`** holds actual document dependencies as doc-relative paths, optionally to
  a live question anchor. Hardware or host conditions need prose in the source; do not invent
  a missing file to encode them. A question needing an answer eventually is not necessarily
  blocking useful agent work now.
- **No `priority` key:** relative order belongs only in the roadmap.

Do not guess past an owner-only decision. If an agent can narrow a choice, investigate a
blocker, or verify a claim now, make that the source's next step instead of manufacturing a
user bottleneck. Uncertainty about completion is not completion; keep verification work visible.

## Vantage integration — optional tooling, not a content dependency

Follow **`vantage-docs`** for the installed version's conventions. A Vantage planning index
is its derived model of the repository's planning documents, not a separate editable queue.

- A **bare document link** in the roadmap reaches all questions in that document.
- A **live question-anchor link** reaches only that question.
- A **heading link** reaches no questions, even though its badge shows the document's state.
  Link a heading for detail, but add a bare document or question link when prioritizing rulings.
- The first link reaching a question establishes its position. Check incidental preface and
  boundary links so they do not accidentally give background work first priority.
- Every question needs an `oq` directive, including 🔒 blocked and ✅ answered questions.
  Keep it until compaction; a blocked question need not carry a leaning. The visible prose
  must still describe its state and stakes without that Vantage-only comment.
- Compaction removes the directive and its anchor. Repoint inbound links to the Decision
  Ledger, then reconsider priority; a ledger link does not reach other live questions.

Where Vantage is used, inspect the existing `.vantage.toml` before changing configuration.
Its optional `[planning]` table names the roadmap and scan perimeter; `[planning.stages]`
maps exact, case-sensitive repository words to `open` (still being decided), `ready`
(decided, not built), `built` (built), or `done` (no longer a live proposal). Do not mark
unfinished work `done` to hide it: that role excludes its questions from the planning queue.
Without declared stages, question/link reporting works, but stage-derived lists do not.

```bash
uvx vantage-check index                 # derived state, unrouted questions, roadmap order
uvx vantage-check roadmap.md docs/      # links, metadata, and planning rules
```

Use a version supporting `index`; if unavailable, reconcile manually and disclose that limit.
An `index` exit of 0 means the report ran, not that its disagreements or unrouted questions
are resolved; read the sections. Run it from the target repository: `--config` chooses the
configuration, not the project to scan. Do not treat skipped/unreadable files or scan-limit
failures as zero questions. The
`planning/unrouted` check is opt-in; inspect the index even when a normal check passes.

## Reconciling — the default action

Invoked by itself (`/roadmap`, "update the roadmap", "where are we at"): **derive, then diff**.
Use the old roadmap as an index of sources to inspect, not evidence of their current state.

1. Read source docs and recent commits; check claims of build/completion against the tree.
   Inspect working changes too. Zero open questions does not mean work is done.
2. Reconcile each source's stage, next step, dependencies, and gates. Look for useful agent
   actions buried behind apparent owner gates or external waits; split independent steps.
3. Find committed work and live questions with no priority link. Add their source or specific
   question, or explicitly record why they are outside this queue. Do not commit speculative
   catalog entries to the build queue merely because they exist.
4. Re-verify blockers and priority reasons. Order useful next efforts by the stated basis,
   without asking the user to sequence already-approved work.
5. Remove closed work; preserve unfinished implementation, verification, or graduation as
   work with an owner and a next step. Explicitly rejected proposals keep their reasoning
   in their owning doc or a Retired Decisions doc, not an active roadmap row.
6. Check link targets and anchors, question coverage, first-link order, and the plain-Markdown
   acceptance test. Update the reconciliation date only after doing the pass.

When compacting a sprawling roadmap, rebuild from these sources rather than trimming stale
rows. Report answered questions still labeled blocked, wrong copied counts, buried agent work,
and missing priority links; those discoveries matter more than the reduction in lines.

## Doc changes and roadmap review belong together

In the **same commit**, update source metadata and review the roadmap's links, order, rationale,
and remaining scope. Edit the roadmap only when one of those changes; a question count changing
alone is not a reason to copy it here or churn the file.

| Source changed | Review here |
| :--- | :--- |
| Design or accepted story gap created | Add a priority link with a reason |
| Question opened | Link its owner or its anchor; leave stakes and leaning there |
| Question compacted | Repair dead anchors; keep unfinished work prioritized |
| Design settled / plan promoted against the tree | Link the build hand-off; revisit sequencing, not copied state |
| Research changes a dependency or rejects an option | Reconsider priority and any roadmap-only unblock condition |
| Design built | Keep graduation or target verification if still owed |
| Work closes and graduates | Remove the closed entry; give absent or unverified work its own next step |

When asked to **take action on everything**, read all prioritized sources and advance every
useful agent step, including research and verification. A priority list is not permission to
make subjective owner decisions or take destructive/external actions without confirmation.
Report what advanced, what closed, and what now needs the user or an external condition.
