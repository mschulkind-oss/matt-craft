---
name: roadmap
description: Use when creating, updating, reconciling, or compacting a project's living roadmap.
---

# Roadmap

A roadmap owns **priority and the reasons for that order**. Source documents own the work's
state, next action, dependencies, decisions, and evidence. Write each fact once, where it
belongs; the roadmap links to it rather than maintaining a second planning database.

Default location: **`roadmap.md`** at the project root, unless the repo has an established one.
A project may keep multiple roadmaps by area or team. Reconcile the one being worked on;
new committed work needs a link from at least one existing roadmap. Do not create one as
a side effect of an unrelated doc task. See *Vantage integration* for discovery and pinning.

A reader must learn in under a minute **what matters next, why it comes first, and where to
act**. This must work in plain Markdown, on GitHub, in a static export, and in a Vantage 0.7 viewer, none of which draws planning badges — not only in Vantage 0.8.
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
facts there and leave the priority reason here. Keep open questions out of the roadmap itself:
its links to itself route nothing, so they cannot place those questions in its own order. A question that needs a ruling earns a small source document, linked bare.

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
5. **Boundaries:** name candidate work not yet committed to. A bare document or question
   link here still routes its questions, at the end of the order; heading links do not.
   There is no "outside the queue" state for an open question. Mark a genuine wait 🔒
   in its source with what it waits on, and give it its question directive (see **`vantage-docs`**), rather than parking an answerable question.

Prefer **one ordered list**. Use sections only when they add navigational value, such as a
separate external-wait list; document order is priority order, including across sections.
Do not recreate a status dashboard with mandatory Actionable / Needs you tables: where Vantage
runs, its planning page (`g p`, at `/.vantage/planning`) derives *Needs you* and *Not on a roadmap* from these links (*Blocked* from 🔒 markers and `depends-on`), and each planning document's Referenced by line says whether the
roadmap routes it and how many of its open questions it does not. Put the
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

- **`status`** answers whether the argument is closed, using the repo's convention. Vantage
  reads only `draft`, `in-review`, `accepted` and `deprecated`, lowercase: any other value
  shows no chip or badge, although the key still makes the file a planning document.
- **`stage`** answers what the document owes someone, using the repository's own vocabulary.
  Keep it here, not repeated in a prose status line. Prose carries dates, reasons, and evidence.
- **`next`** holds one concrete next step as a line of plain text, including the first stop
  when useful. Research, experiments, design, implementation, and verification all count.
- **`depends-on`** holds actual document dependencies as doc-relative paths, optionally ending
  in `#OQ-…`. An entry naming a question waits only while it is 💬 open; a bare path waits
  only while its document has a 💬 open question. A 🔒 or ✅ target, or one with a
  `done`-role stage, never waits: say in prose what a blocked dependency waits on. A path that does not exist, leaves the repository, or does not contain the id fails
  `planning/depends-on-missing`, on even with no `.vantage.toml`. Hardware or host conditions
  need prose in the source; do not invent a missing file to encode them. A question needing an
  answer eventually is not necessarily blocking useful agent work now.
- **No `priority` key:** relative order belongs only in the roadmap.

Do not guess past an owner-only decision. If an agent can narrow a choice, investigate a
blocker, or verify a claim now, make that the source's next step instead of manufacturing a
user bottleneck. Uncertainty about completion is not completion; keep verification work visible.

## Vantage integration — optional tooling, not a content dependency

This section describes Vantage 0.8.0: a 0.7 viewer has no badges, planning page or
`[planning]`, and drops `question` directives. Follow **`vantage-docs`** and the
`style-guide` of the checker you run, whose first line names its release from 0.8.0. A Vantage planning index
is its derived model of the repository's planning documents, not a separate editable queue.

- A **bare document link** in the roadmap reaches all questions in that document.
- A **live question-anchor link** reaches only that question.
- A **heading link** reaches no questions, even though its badge shows the document's state.
  Link a heading for detail, but add a bare document or question link when prioritizing rulings.
- The first link reaching a question establishes its position. Check incidental preface and
  boundary links: a bare preface link gives background work first priority, and a bare
  or question-anchor link under Boundaries still queues its questions.
- A roadmap's links to itself, and links to `done`-role documents, route nothing.
- Questions exist to the index only through an attached question directive, in every
  state. **`vantage-docs`**, *Open Questions & Decision Ledgers*, owns its name, syntax and
  checks; **`design-doc`** owns answering and compaction.
  Missing directives on 🔒, ✅ or leaning-less questions silently disappear. Read the
  sources too: an empty *Needs you* does not prove there are no questions. Nor does a 💬 question listed there prove it still needs the user: `index` reads no review comments, so one answered by comment stays 💬 until its document records the ruling (**`design-doc`**, *Answering Protocol*).
- Compaction removes the directive and its anchor. Repoint inbound Markdown links to
  the Decision Ledger and reconsider priority: a ledger link routes nothing. Keep
  question fragments in `depends-on` unchanged when the id survives in a ledger row;
  they stop waiting. A heading fragment instead waits on the whole document.

### Checker, discovery, and selection

Read `.vantage.toml` first: its `[planning]` table (below) decides which files are roadmaps
and what each stage word means. Then run `index` with the checker **`vantage-docs`**, *Getting
the binary*, names. Vantage 0.8.0 added `index`, `--roadmap` and the `planning/*` rules
together, so there is nothing to probe:

```bash
uvx vantage-check index                                   # the default roadmap
uvx vantage-check index --roadmap docs/plans/roadmap.md   # another roadmap
```

Only a checker before 0.8.0, such as an older pin or a stale install, lacks them: it treats `index`
as a path (`no such file or directory: index`, exit 2), rejects a config naming `planning/*`
rules, and reports `question`/`fallback` as `vantage/unknown-name`. Those are limits of that
checker, not document defects. Never delete valid config or directives, rename `question` to
`oq`, or change `target` to satisfy it; if no 0.8.0 or later checker can run, read sources by
hand and say so.

Vantage discovers every file named `roadmap.md`, in any directory and case, subject to hidden-directory
rules, `.vantageignore`, and `[planning] include`/`exclude`. No config is needed. An explicit
`[planning] roadmap` string or list pins exactly those paths and turns discovery off. The
planning page has a picker; `index --roadmap <path>` chooses one, and the default is nearest
the root. First-link order is per roadmap; *Not on a roadmap* means **no roadmap** reaches the question,
not that the selected roadmap lacks it. Do not add pins unless that restriction is intended.

The optional `[planning]` table also controls the scan perimeter and limits.
`[planning.stages]` maps exact, case-sensitive words to `open` (still being decided),
`ready` (decided, not built), `built` (built), or `done` (no longer a live proposal).
**`design-doc`** owns the vocabulary and complete seven-word mapping, not this skill.
A `done` document contributes nothing: links route nothing, its questions disappear without
warning, and dependencies naming it never wait. Rule or move unfinished questions first.
Without declared stages, questions, routing and *Blocked* still work, but *Ready to build*, *Ready to graduate*,
and *Stage conflict* are absent; vocabulary and disagreement checks report nothing.

An open question under a ready/built role goes under *Stage conflict*; 🔒 and ✅ do not trigger
that warning. A built document reaches
*Ready to graduate* only with **no questions in any state**, including ✅ awaiting compaction.

`index` takes no paths and scans the project root (nearest `.git` or `.vantage.toml`, or
working directory if neither exists). `--config` chooses config, not the project. It prints
*Needs you*, *Not on a roadmap*, *Blocked*, *Ready to build*, *Ready to graduate*, *Stage conflict* and scan omissions (*Too large*, *Unreadable*), each with a line saying what it holds and who acts, then the chosen roadmap with each link's badge. Exit 0 means it ran, never that the plan is clean; it never exits 1.
Exit 3 means the candidate limit prevented scanning. Skipped/unreadable files are unknown,
not zero questions. Inspect the sections even when `planning/unrouted` is off (the default). *Needs you*
includes ✅ questions awaiting compaction.

For checks, pass the actual planning sources and roadmap paths, not assumed directories:
missing paths exit 2. Run document checks where the repository follows **`vantage-docs`**;
elsewhere its `ref/*` rules can report unrelated prose, which is not roadmap work. Checks
report against question owners, so checking a roadmap alone does not verify coverage.
`planning/stage-vocabulary` and `planning/depends-on-missing` are errors;
`planning/stage-disagrees` is a warning (`--strict` fails it).

## Reconciling — the default action

**Reconciling** *(coined here)* means rebuilding the roadmap from its sources' current state and diffing it against the page, not checking each claim against code as **`system-doc`** does.

Invoked by itself (`/roadmap`, "update the roadmap", "where are we at"): **derive, then diff**.
Use the old roadmap as an index of sources to inspect, not evidence of their current state.
Derive from `vantage-check index` first (`--roadmap <path>` for the roadmap being reconciled): *Not on a roadmap* lists open questions no
roadmap reaches (step 3), *Stage conflict* a ready or built stage over open questions and *Ready to graduate* a
built document with no questions left (step 2), and a `[✅ ruled]` or `[⚠ not found]` badge in
its roadmap echo marks a link to a question that was compacted or removed (step 6). It reports
the documents' own claims; checking them against the tree is still step 1.

A pasted planning-page request (**Copy agent request**, the same text `vantage-check index --request [unrouted|ready|graduate|disagrees]` prints) is that pass's instruction, and its limits win over the steps below: for *Not on a roadmap* it says to propose each question's place with a one-clause reason and edit a roadmap only once the human confirms the order, so step 3 proposes rather than places. End with its `Verify` command, exactly as written.

1. Read source docs and recent commits; check claims of build/completion against the tree.
   Inspect working changes too. Zero open questions does not mean work is done.
2. Reconcile each source's stage, next step, dependencies, and gates. Look for useful agent
   actions buried behind apparent owner gates or external waits; split independent steps.
3. Find committed work and live questions with no priority link. Add their source or specific
   question at its intended position. Mark a genuine wait 🔒 in its source with its
   unblock condition and its question directive (see **`vantage-docs`**); do not park answerable questions outside the queue. Do not commit speculative
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
| Design built | Keep graduation or target verification if still owed; compact its ✅ questions, since Vantage lists it under *Ready to graduate* only once it has none |
| Doc split, renamed, or superseded | Move directives rather than copy them; repair every roadmap and inbound anchor link, keeping unfinished work visible |
| Work closes and graduates | Remove the closed entry; give absent or unverified work its own next step |

When asked to **take action on everything**, read all prioritized sources and advance every
useful agent step, including research and verification. A priority list is not permission to
make subjective owner decisions or take destructive/external actions without confirmation.
Report what advanced, what closed, and what now needs the user or an external condition.
