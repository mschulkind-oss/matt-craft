---
name: design-doc
description: Use when designing or revising a feature, system, or architecture that needs settled decisions.
---

# Design Docs

Write and maintain the document that captures a design being worked out together: what the thing is, how it's shaped, what it costs, and — most importantly — which decisions are still open and need the user's ruling. 

The doc serves two readers in sequence: the user *now*, deliberating the design and answering open questions in place; and anyone *later*, reading a settled record of what was decided and why. Once the design is actually built, that later reader is better served by a **`system-doc`** — and this doc graduates into one.

**Both readers are deciding, and what they are deciding is architecture** — the shape, the trade-offs, the things that will be expensive to change later. What gets built, in which file, in what order is a different document for a different reader: the companion sketch below. Keeping the two apart is what stops this doc from becoming a feature list.

**The objective is a document that is currently true and quickly readable** — not one that has lost nothing. Those two come apart the moment a question gets answered, and when they do, true-and-readable wins. Preserving the *decision* serves both readers; preserving the *deliberation* that produced it serves neither, and costs the next reader the time it takes to work out which of the four leanings on the page is the live one. Every rule below about compacting, overturning, and retracting is that one trade applied somewhere specific.

## Default Behavior (When run by itself or on an existing doc)

There are three operations on a design doc and they are different jobs: **drafting** it, **compacting** it as rulings land, and **auditing** its claims against the tree. Only drafting needs a prompt.

If this skill is invoked without specific drafting instructions (e.g. `/design-doc` or "run design-doc on docs/design/foo.md"), the default action is to **compact, audit, and reconcile the design doc**:

1. **Audit Open Questions:** Scan the doc for active questions (`💬`), answered questions (`✅`), and the Decision Ledger. An answered question still sitting in question form is a miss against [the compaction rule](#compaction-fires-on-answering-not-on-a-threshold), not a normal state — fix it here.
2. **Execute Compaction:** For all settled/answered questions, fold the ruling into the normative body text (§X) and compact the verbose question block into the **Decision Ledger** table.
3. **Audit the claims:** Run [the audit pass](#the-audit-pass--overturn-dont-annotate) over everything the doc asserts about the tree. Skippable only when the doc was written this session against code that has not moved since.
4. **Verify the header against the tree, not against itself.** The status line and the **Needs your ruling** line are claims like any other, and they are the two claims nobody re-checks. One repo's sweep found ~20 status lines false against the code in both directions; a later census of the same tree found three docs claiming *ALL PHASES SHIPPED* / *EXECUTED* / *SHIPPED IN FULL* while carrying live `💬` questions, one of them stating in its own body that a doc with a live question cannot graduate. **Re-spelling what the line says is what produced that drift.** Check the state against the code, and check **Needs your ruling** against the ids of the `💬` questions actually left in the file. [`references/status-lines.sh`](references/status-lines.sh) does both mechanically.
5. **Verify frontmatter status:** the second axis, in Vantage's closed set — `accepted` once zero unanswered `💬` questions remain, `in-review` or `draft` while any is open. See [the two axes](#frontmatter-is-a-second-axis-not-a-second-spelling).
6. **Name the graduation candidates.** A `BUILT` doc with zero live `💬` questions is ready for **`system-doc`** — [reaching built is the whole cue](#graduation-is-the-cue-and-there-is-no-second-one). List them by name; a candidate nobody names sits.
7. **Surface Live Decisions:** Report remaining `💬` questions needing user attention.

## When to use this skill

- "Write me a doc about this idea I've been considering"
- "Write up this feature" / "capture what we just discussed"
- "Compact this design doc" / "Clean up the OQs" / `/design-doc` standalone
- Any substantive design conversation that should end in a durable document

Not this skill:

- A design that is **built and merged** → `system-doc`: the doc graduates out of the planning tree into an evergreen reference of the system as built, and this one is deleted
- Persona-driven workflow narratives → `user-stories` (same Open Questions format, different body)
- The build hand-off — file map, what to reuse, traps, build order → `implementation-plan`. It opens as a **sketch** alongside this doc ([below](#the-companion-sketch--where-the-material-you-dont-want-goes)) and is completed against the tree once the design settles
- Task checklists and work queues → `roadmap.md` or `docs/tasks/`; a design doc *links* to them, it never contains them
- Cumulative research/domain knowledge → `docs/research/` domain docs

## Altitude — the rule that shapes everything

Write at the level of **systems, components, and algorithms** — the things the user needs to check against their mental model. Never at the level of a line-by-line implementation plan.

In scope: named components and their responsibilities; ownership and one-writer rules; data models; state machines, protocols, and message shapes; algorithms with their parameters and update rules; invariants; conflict and failure modes; what each alternative costs; sequencing.

Out of scope: per-file edit plans, function-by-function changes, code diffs — that material has its own home in an **`implementation-plan`**, open from the start of the design as a sketch ([below](#the-companion-sketch--where-the-material-you-dont-want-goes)) so there is somewhere to put it the moment it comes up. **Code is cited as evidence, not specified as work** — `file.go:123` references proving a claim about what exists are good; schema/config/CLI-surface sketches are good; implementations are not. Implementation-level material does not get a fenced section here as a compromise; it goes in the sketch, which is what the sketch is for.

Altitude is a ceiling, not an alibi. *Completeness* below is the floor.

## Completeness — altitude is not permission to leave holes

Altitude decides how high the doc flies; this decides that nothing is missing at that height. The two only look opposed. The rule that reconciles them: **specify behavior exhaustively, mechanism minimally.**

Write for an implementer who is a strong builder and a weak guesser — assume the doc will be handed to someone with less context and less appetite for reconstructing your intent than you had writing it. They do not need your code, your file paths, or your line numbers; they need your decisions. You are an expert PM writing for an excellent engineer: hand over every judgement call that has a right answer, and none of the ones that don't.

The dividing line, applied per claim: **could a reasonable implementer choose differently and still satisfy every behavior the doc states?** If yes it is theirs — data structures, decomposition, which file it lands in. If a different choice yields a system that *behaves* differently, it is yours, and a doc that doesn't say it is incomplete.

The failure this prevents is a quiet one. A hole does not produce a question or a stuck build; it produces a plausible guess, and the guess compiles, passes, and does something other than what the design intended. It surfaces later, as behavior nobody chose.

### The holes, by name

Walk these before handing the doc off. Each is a question the implementer must answer to write the code, and each one left unanswered gets answered anyway — by them, silently.

- **Degenerate inputs.** Zero, one, many, empty, absent, duplicate, oversized. If a list can be empty, the doc says what an empty one does.
- **A failure path for every happy path.** Each step that can fail says what happens when it does — retried (how many times, what backoff), abandoned, degraded to a named fallback, or left half-applied — and who finds out.
- **Concurrency and ordering.** Two at once; out of order; a second arriving while the first is in flight. Say serialized, idempotent, or last-writer-wins — or say concurrency cannot arise here, and why.
- **Defaults, with units.** Every knob names its default and its unit. "Configurable" with no default is a hole; `timeout: 5` with no unit is a smaller one.
- **The trigger, precisely.** On every write, on a 30s timer, on demand, once at startup. "Periodically" is not a trigger.
- **State that already exists.** What happens to the rows, files, and sessions already out there on the day this ships: migrated, ignored, or rejected.
- **One writer, named.** For each piece of state, who may write it — and if two components can, who wins.
- **Forbidden behavior.** What the thing must never do where a reasonable implementation might: never block the caller, never write outside the cache dir, never retry a non-idempotent call.
- **What done looks like.** The observable outcomes that mean it was built as designed — behavior a human could check, not test names and not coverage numbers.

### The gap test

Reread the finished doc as the implementer rather than the author. Every question you would have to answer to write the code must be in exactly one of three states:

1. **Answered in the doc.**
2. **Open, with a stable ID** (`OQ-N`) — a decision the user still owes you, and a legitimate reason for the implementer to stop.
3. **Delegated in as many words** — "any stable sort", "the implementer's choice of container", "error text is theirs to word".

Delegating is a complete specification. Silence is not. Those three are the only legal states, and the difference between an open decision and a hole is entirely whether the doc noticed.

## Where the doc lands

`docs/design/<topic>.md` by default; follow the local convention where the repo splits `docs/plans/` (in-flight RFCs) from `docs/design/`. Either way this is the *planning* tree — the built system's evergreen reference lands in `docs/reference/` (see `system-doc`). Filename is a content noun (`boundary-broker.md`, `adaptive-leveling.md`) — never a date, never prefixed with the tool that wrote it.

## The companion sketch — where the material you don't want goes

Altitude says implementation material belongs in an **`implementation-plan`**. The trap is timing: that plan is written later, so while the design is being argued the material has nowhere to go — and it lands here, in the doc that was supposed to stay at altitude. Fix the timing. **Open the plan as a sketch the moment the first piece of it exists.**

It lands beside the design, same basename plus `-plan` — `docs/design/<topic>-plan.md` — stamped `**Status:** SKETCH, 2026-09-05 — incomplete, and unstable while questions are open.` — the sketch sits in the planning tree and takes [a status line](#status--the-word-names-what-is-owed) like everything else there

**What to push into it.** Anything that surfaced during design, is worth keeping, and the user does not need to rule on: dependency and library notes, a schema or signature sketch, migration mechanics, packaging and rollout detail, sequencing below the design's altitude, "check whether `X` still exists before relying on it."

**What it is not.** It is **not a hand-off artifact**, and an agent must not build from it while it is stamped `SKETCH`. A real plan's product is codebase knowledge — the map, the reuse, the traps — and only an agent that has just read the tree can write it. The sketch is a parking lot that keeps this doc clean; **`implementation-plan`** owns what it must become first.

> [!IMPORTANT]
> **No design decision is ever made in the sketch.** If writing an entry means choosing behavior — something a reasonable implementer could do differently and get a system that behaves differently — it is not a sketch entry. It is an `OQ-N` here. The sketch holds settled-but-boring material; it is never where a decision hides.

**Open questions are the growth mechanic.** A sketch entry resting on an unruled question carries the link:

```markdown
Blocked on [OQ-4](rate-limiting.md#OQ-4) — the retry policy shapes this.
```

Answering a question is therefore two edits, not one: fold the ruling into the body here, then revisit every sketch entry that named it. An entry written under a guess the ruling contradicts is precisely what the marking exists to catch.

**Cross-reference both ways.** This doc's **Reads with:** names the sketch *and* says it is one. The sketch links back here and carries the precedence rule: the design wins on behavior.

## The header block

Everything before the closing `---` **orients the reader and nothing else.** It is a map to the doc, not a compressed copy of it. The design lives in the body; the header says what claim the body defends, why that matters, and where to start reading.

That is the job **In short** keeps failing, and the reason is in the old instruction: told only to fit the design into 2–4 sentences, an author writes until the design is in there, and the result is a paragraph nobody reads. **In short is a thesis, not a summary.** One or two sentences, stating a claim the reader can agree or disagree with.

**Architecture leads; the build does not appear here at all.** An inventory of the change — *"29 keys → 14, no compatibility aliases, family-prefixed names"* — is `implementation-plan` material even in summary form, and it is the most reliable way to turn this block into a wall. What the reader meets first is the idea, not the output list.

**The slots, in this order.** One sentence each; two only if the second earns it. Title, status, **In short** and the ruling line are always present. The rest appear only when they have something to say — drop an empty slot, never pad one.

| Slot | What it says |
| :--- | :--- |
| **Title** | A claim or a question, never a bare noun — "Where review state lives — and why it keeps biting us" beats "Review State" |
| **Status** | The vocabulary below, with an ISO date |
| **In short** | The design as a claim, set as a blockquote — the thesis the body spends its length earning |
| **Why it matters** | The concern that makes this worth doing; what the status quo costs |
| **The shape** | The named components and how they relate — the architecture in one line |
| **Cost** | What this breaks, deletes, or forecloses |
| **Start at** | The one section carrying the load, as a link; everything else falls out of it |
| **Needs your ruling** | Live `OQ-N` links, or **None** |
| **Reads with** | Sibling docs and the companion sketch, one parenthetical each saying why |

**Ceiling: one screen, call it 20 lines.** Past that the fix is cutting, never reflowing — anything that will not fit a slot is body material or sketch material, and both have somewhere to be.

**Status** is [its own section below](#status--the-word-names-what-is-owed) — it is the line most read and most often false, so it gets the space. Re-stamp it on amendment rather than silently editing it. A **Scope note** naming what was split into a sibling doc joins the header when there was a split.

```markdown
# Twenty-nine keys, and the three that lie

**Status:** DESIGN, 2026-09-05. Nothing built. Evidence verified at `62db92c`.

> **In short.** `config.toml`'s `engine` key welds together two independent
> axes — which model, and where its runtime runs. Splitting them is the whole
> design; six other keys turn out to be aliases for one axis or the other.

**Why it matters.** Three keys are wrong rather than merely confusing:
`gpu_layers` passes a flag `whisper-cli` rejects, so any non-zero value breaks
every transcription.

**The shape.** Two independent tables, `[model]` and `[runtime]`, where one
`engine` enum stands today.

**Cost.** Every existing config file breaks. Nothing has shipped, so no
migration path is written.

**Start at [§3](#3-two-axes-welded-into-one-enum)** — the split. The rest falls out of it.

**Needs your ruling:** [OQ-2](#oq-2), [OQ-5](#oq-5).

**Reads with:** [`configuration-surface-plan.md`](configuration-surface-plan.md)
(the implementation sketch — incomplete while OQ-2 is open),
[`model-benchmarks.md`](../reports/model-benchmarks.md) (every number quoted here).

---
```

## Status — the word names what is OWED

The status line is the first thing a reader looks at, and it is the line most likely to be false. Both of those come from the same mistake: treating it as a position on a lifecycle ladder. A reader opening a planning doc is asking one question — ***is there something here for me?*** — and the word answers it by naming **what the doc owes someone.**

| Word | What is owed | Stamp |
| :--- | :--- | :--- |
| `SKETCH` | Nothing yet — thinking out loud, and nobody should act on it | ISO date |
| `DESIGN` | A **ruling** from the user | ISO date |
| `DECIDED` | **Work.** Every ruling is in; nothing is built | ISO date |
| `BUILT` | Nothing. It is a [graduation candidate](#graduation-is-the-cue-and-there-is-no-second-one) | ISO date, commit, and a [measurement clause](#a-built-claim-carries-a-measurement-clause) |
| `GRADUATED` / `SUPERSEDED` | Terminal — this is no longer the live copy, and the line links to what is | ISO date |
| `CURRENT` | To be kept true | **No date** — see below |

**`BUILT`, not `IMPLEMENTED`.** In a census of 87 planning docs, `BUILT` and `SHIPPED` had each been independently coined as exact synonyms across six docs, by agents who had the defined word in front of them and reached past it. When a vocabulary is bypassed that consistently the vocabulary is wrong, not the authors. `BUILT` is what people write unprompted.

**`CURRENT` is the word for a doc that is not a proposal,** and the missing one costs more than it looks: 21 of those 87 docs had no status line at all, and most were evergreen — an index, a roadmap, a runbook, a living record. Nothing on the proposal ladder fits them, so their authors wrote nothing. It is also why `STORIES`, `INVENTORY` and `HANDOFF` turned up in the lifecycle slot.

**`CURRENT` takes no date.** An evergreen doc has no moment to stamp, and a date on a living record is a claim nobody re-checks — worse than none, because it reads as a verification that never happened.

> [!NOTE]
> A **`system-doc`**'s `CURRENT as of 2026-08-30, verified against a1b2c3d` is not a counterexample. That is a **verification stamp** — a claim about work someone actually did, bounded by the commit, and the most valuable line in a reference doc. Do not strip it. The rule here is about a *lifecycle* date on an evergreen planning doc, which claims nothing and expires anyway.

**No percentages.** `MOSTLY BUILT` and `LARGELY IMPLEMENTED` both existed in that corpus; both are `DECIDED`. How much shipped is prose, and prose is better at it — *"nine of ten rulings built; the macOS backend is the tenth"* tells a reader more than either word.

**Genre is not a status.** `STORIES`, `INVENTORY`, `HANDOFF` and `DESIGN + CATALOG` all appeared in the slot. What *kind* of document this is belongs in `tags:` or in the title. The status slot holds exactly one word from the table, and no document is exempt from having one — a missing status line is the same defect as a wrong one, arrived at by a different route.

### A built claim carries a measurement clause

"Built" and "built, and someone watched it run" are different facts, and in that corpus the synonym pair was quietly being used to smuggle the difference: three docs claimed built with **zero runtime observation recorded**, two of them describing a macOS backend no CI job has ever exercised — reading, on the page, identically to a design whose central claim had been measured against a control.

So any `BUILT` line says which it is:

```markdown
**Status:** BUILT 2026-09-12 (`a1b2c3d`). MEASURED: 40-question list, 171 ms → 0.3 ms
with the rule off, on the corpus in `docs/design/`.

**Status:** BUILT 2026-09-12 (`a1b2c3d`). UNMEASURED: the macOS backend ships and no
CI job has ever exercised it.
```

`UNMEASURED` is a legal, respectable state — the point is that it is *said*, not that it is avoided. The two words are deliberately shaped so one regex reads them apart: `\bMEASURED\b` does not match inside `UNMEASURED`, because `N` and `M` are both word characters and there is no boundary between them.

### Frontmatter is a second axis, not a second spelling

The prose line and frontmatter `status:` answer different questions, and squashing them into one value loses the more interesting half:

| | Question it answers | Vocabulary |
| :--- | :--- | :--- |
| `**Status:**` line | What does this doc owe someone? | The table above |
| `status:` frontmatter | Is the argument closed? | Vantage's closed four: `draft`, `in-review`, `accepted`, `deprecated` |

`BUILT` over `in-review` is then a legal and informative pair — in the tree, and still owing one ruling. Anything outside Vantage's four **silently renders no chip**, which is why 8 docs in that census were carrying frontmatter nobody could see. `decided` is not one of the four; `accepted` is the word.

### Graduation is the cue, and there is no second one

`BUILT` with zero live `💬` questions means hand off to **`system-doc`** — now, not at some later review. ~40 docs in that corpus qualified and sat, waiting for a cue that does not exist, until a whole restructure was needed to route them.

The fact that settles it took a census to notice and one line to state: **the evergreen tree has exactly one state.** 41 of 41 reference docs in that repo carried `status: current`. There is no "built but not yet current" for a doc to wait in, so reaching built *is* the cue, necessarily. Nothing else is coming.

That makes it checkable rather than cultural, which is the only version that survives: [the default audit](#default-behavior-when-run-by-itself-or-on-an-existing-doc) lists the candidates by name, and [`references/status-lines.sh`](references/status-lines.sh) finds them without an agent in the loop.

### Land the check in the repository

**A rule that lives only in a skill is a rule no repo can check.** This file is user-level, outside every repository it governs; for months nothing in that tree could enforce the vocabulary, and nothing did — 79 of 87 docs were off-vocabulary before anyone counted.

So the last step of applying this vocabulary to a corpus is to **write the rule into the repository, in a form that can be re-run.** Copy [`references/status-lines.sh`](references/status-lines.sh) in beside the repo's other corpus checks and wire it into whatever already runs them — a `just` recipe, a test file, CI. What worked was a numbered check with literal shell commands sitting next to the checks that were already there; a prose convention in a `CONTRIBUTING.md` would have rotted exactly the way the skill's copy did.

```console
$ sh references/status-lines.sh docs/design docs/plans
GRADUATE  docs/design/boundary-broker.md  (BUILT, zero live questions — hand off to system-doc)
NODATE    docs/design/glossary-plan.md  (CURRENT takes no date)
UNSTAMPED docs/design/mac-backend.md  (BUILT with no MEASURED:/UNMEASURED: clause)
RULING    docs/design/rate-limiting.md  (Needs your ruling says None, 2 live: OQ-4, OQ-7)
ok        docs/design/two-axes.md
BADWORD   docs/plans/agent-queue.md  (status "SHIPPED" is not in the vocabulary)
```

## Density — no walls of text

The header rule generalizes: **nothing in a design doc is a wall of text.** These docs are scanned before they are read — by the user hunting the decision, by an agent hunting the constraint — and a block of prose is where both go to fail.

The test is not length, it is *kind*. Prose is for **argument**: a claim being earned, a trade-off being weighed, reasoning that only works connected. Everything else is enumeration wearing prose as a disguise.

- **Enumerating → a list.** Three components, four failure modes, six keys. If you can count it, it is a list.
- **Comparing → a table.** Alternatives, risk against mitigation, before against after, who-writes-what.
- **A sequence → numbered steps**, or a Mermaid diagram where the shape matters more than the order.
- **A paragraph past ~6 lines** is a prompt to check which of those it actually was. Some survive the check. Most are a list that got typed as sentences.

Bold the load-bearing phrase in a long bullet so the scan lands on it, and split any section running past a screen into subsections whose headings say something — a heading is the cheapest navigation there is. The **`vantage-docs`** style guide treats an over-long section as a defect in its own right.

## Body — two shapes

Pick the shape that fits; don't force either. Number the sections (`## 1.`, `## 2.`) in long docs; short docs (<250 lines) go unnumbered. In prose, a section number is always a link to the heading it names — a bare one is an error (`ref/unlinked-section`), and it is the reference that quietly survives the renumbering that invalidated it:

```markdown
The sanitiser ordering in [§4.1](#41-the-anchor) is the one place this can be built wrong.
```

**Diagnosis → proposal** (redesigning or extending something that exists):

> verdict/principles up front → what exists today, stated precisely → the gap or diagnosis → the proposed shape → costs and what it deletes → risks → sequencing → **Open Questions** / **Decision Ledger** → prior art / appendices

**RFC** (adding a new capability):

> Goal → Non-Goals → Problem statement → Current state → Proposed solution → Alternatives considered → Impact on existing behavior → Risks → **Open Questions** / **Decision Ledger** → Success criteria

Signature moves, whichever shape:

- **Verdict up front.** Don't build suspense; state the recommendation in the first section and spend the rest earning it.
- **A negative-space section is near-obligatory**: `Non-Goals`, `What this does not license`, `What this proposal does NOT propose`. Scope creep dies here.
- **Alternatives end in explicit verdicts.** Each considered alternative gets a one-line disposition: "Rejected as overkill." "Rejected for v1; can migrate later if the pre-pass proves brittle."
- **Risks as a table** (`| Risk | Mitigation |`) or R-numbered bold bullets with consequences.
- **Costs, honestly.** What the design deletes, what it complicates, what it forecloses.
- **Sequencing as prose** ("What I would build, in order"), not tickets — task granularity lives elsewhere.
- **Load-bearing principles get numbered** (`P1.`, `P2.`) so later sections and sibling docs can cite them.

## The Two Lifecycle Phases of Decisions

Design documents evolve through two distinct phases:

```
┌─────────────────────────────────────────────────────────┐
│ Phase 1: Deliberating (In-Flight RFC / Proposal)        │
│ • Full OQ scaffolding (leanings, stakes, context)       │
│ • SKETCH / DESIGN  —  frontmatter: draft / in-review    │
│ • User rules on open questions in-doc                   │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼ Compaction Trigger
┌─────────────────────────────────────────────────────────┐
│ Phase 2: Settled (Durable System Description)           │
│ • Ruling woven into normative body text (§X)            │
│ • Refuted objections & traps preserved as warnings      │
│ • OQ scaffolding compacted into Decision Ledger table   │
│ • DECIDED — owes work  —  frontmatter: accepted         │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼ Implementation lands
┌─────────────────────────────────────────────────────────┐
│ Phase 3: BUILT → hand off to `system-doc`               │
│ • Reconciled against the code as actually built         │
│ • Alternatives, risks, sequencing, ledger stripped      │
│ • Rewritten at docs/reference/; THIS doc is deleted     │
└─────────────────────────────────────────────────────────┘
```

Phases 1 and 2 are this skill. Phase 3 is **`system-doc`** — a different reader
(a maintainer, not a decider) and a different genre, so it lives in its own
skill. Everything below covers phases 1 and 2.

---

## Phase 1: Open Questions (Deliberation)

During active design deliberation, end the document with an **Open Questions** section. These are **unresolved design decisions that need the user's ruling** — not TODOs, not bugs, not things you could decide yourself.

**Before opening a question, search the corpus for a ruling on it.** Decision Ledgers are per-document, which is exactly what makes a collision between two of them invisible: a subject settled last month in a sibling doc's ledger arrives here looking brand new, the design re-litigates it, and the second ruling can land flatly contradicting the first with nothing in either document admitting the other exists. So grep the docs tree for the subject before you write `OQ-N`. If a prior ruling turns up, the question is no longer the original question — it is **"does that ruling still hold?"**, asked with a link to the ledger row, the date it was made, and what has changed since. A ruling that holds costs one line and no user turn; one that doesn't gets overturned deliberately, in both documents, instead of by accident in one.

Use status emojis at the start of each question title for immediate scanning:
- 💬 **Open Question:** Active decision awaiting user ruling.
- 💬 🤷 **Deferred Question:** Pure subjective user preference where agent has no technical recommendation.
- ✅ **Answered / Resolved:** Decided question (awaiting compaction).
- 🔒 **Blocked:** Blocked on an upstream decision or external input before it can be answered.

Per-question format:

```markdown
## Open Questions

1. 💬 **OQ-1: Queue position on re-entry.** When a PR fails and the agent fixes
   it, does it go to the back of the queue or retain its position?

   <!-- vantage: oq id=OQ-1 leaning="Back of the queue — the fix might interact with what merged while it was out." -->

   _Leaning:_ Back of the queue — the fix might interact with things
   that merged while it was out.

   **Answer:**
   > _(empty — fill in when decided)_

2. 💬 🤷 **OQ-2: Default theme.** Dark mode default or match system?

   <!-- vantage: oq id=OQ-2 leaning="Match system — pure preference, and the OS already knows." -->

   _Leaning:_ Pure subjective preference.

   **Answer:**
   > _(empty — fill in when decided)_
```

Format rules:

- **Emoji prefix + stable ID + bold title** on the first line — status emoji (💬, 💬 🤷, ✅, 🔒), stable ID, and a bold sentence fragment or direct question.
- Context on the following lines, including **what the answer decides or blocks** ("this is the closure question"; "determines whether the daemon ever holds auth state"). A question with no stakes attached shouldn't be in the list.
- `_Leaning:_` — your current best guess with brief rationale. Always have one; "I genuinely don't know" or deferring to user preference (🤷) is itself a leaning worth stating. **A leaning is replaced, never versioned.** There is no "Leaning (second version)" and no "Leaning (fourth version, and it is review's)" — a leaning is what you think *now*, so when it changes it changes and the old one goes. If *why* it changed is load-bearing, that reason is a fact about the system: state it in the body as one. The leaning is not an autobiography of the design.
- `**Answer:**` on its own line, then a blockquote starting as `_(empty — fill in when decided)_`.
- **An `oq` directive on every 💬 question that states a leaning**, indented inside the list item with blank lines around it, carrying the question's id and the leaning restated in words. Without it the question renders with no button for the reviewer to click, and `vantage-check` reports it as an error. A 🔒 or ✅ question needs none.
- Stable IDs are mandatory so plans, sibling docs, and code comments can reference them as blockers — the id is also the question's anchor, so it is the letters `OQ`, a hyphen, an optional short uppercase prefix, then digits. Prefix the ids in both documents whenever two docs reference each other's questions; a bare number cannot say which document's fourth question you meant.
- **Cite a question as a link, never as bare prose** — to its own id while it is in flight, to the owning document's Decision Ledger once it is compacted. Same for `§` section numbers and for filenames. See the **`vantage-docs`** skill; `vantage-check`'s `ref/*` rules are errors.

### Answering Protocol
The user fills in the blockquote without erasing the question context. When the agent processes the answer — all of this in the same turn:
- Flip `💬` to `✅`, append `— RESOLVED (<date>)` to the title, and record the answer.
- Fold the ruling into the body section it governs, then compact the question into the Decision Ledger ([below](#compaction-fires-on-answering-not-on-a-threshold)). The `✅` state lives between these two bullets and nowhere else.
- If the answer rejects your leaning, the leaning goes — it was a guess and it was wrong. What survives is anything the user's reasoning established as a *fact about the system*, and that belongs in the body, in the present tense, framed as a fact rather than as the correction of one.

---

## Phase 2: Compaction & Decision Ledgers

Once questions are answered, preserving 300+ lines of discursive OQ scaffolding buries any remaining live questions and degrades the document's utility as a system reference.

**The Golden Rule of Compaction:** *Never lose a decision; always lose the deliberation.* A decision's durable form is a Decision Ledger row plus normative body text — never an ever-growing question scaffold. The leanings, the drafts and the argument that got you there are what compaction is **for**, and git already has them.

### Compaction fires on answering, not on a threshold

**Answering a question is two edits, not one: record the ruling, then compact it — same turn, every time.** An answered question never survives a single commit in question form.

Thresholds — "compact once answered outnumber open", "once the OQ section passes ~20–25% of the document" — read like rules and behave like nothing at all, because a threshold needs someone to be measuring and nobody is. A doc discovered sitting at 31% scaffolding is the *expected* outcome of a threshold rule, not a lapse in following one. The trigger has to be an event you cannot miss, and there is exactly one: **a ruling arrived.**

Two sweeps survive, and both are recovery rather than routine:

1. **Standalone invocation:** running `/design-doc` with no drafting prompt — compacts whatever the two-edit rule missed, and runs [the audit pass](#the-audit-pass--overturn-dont-annotate).
2. **Last question closed:** when the final `💬` is answered the doc changes genre, from a thing being decided into a description of a system. Compact, verify `status: accepted`, and update the roadmap in the same commit.

### The Decision Ledger Format
Replace verbose answered OQ blocks with a concise, greppable table:

```markdown
## Decision Ledger

| ID | Ruling / Decision | Date | Settled in | Built |
| :--- | :--- | :--- | :--- | :--- |
| OQ-1 | Server-side watcher; drop client-side state | 2026-08-16 | [§3.2 Review Daemon](#32-review-daemon) | ✅ |
| OQ-2 | Back of queue on re-entry to prevent race | 2026-08-16 | [§4.1 Merge Flow](#41-merge-flow) | ✅ |
| OQ-3 | 5s busy timeout on SQLite WAL writer | 2026-08-17 | [§5.4 Persistence](#54-persistence) | — |
```

**The `Built` column is filled from the tree, never from the commit messages.** It is the cheapest thing in this file and it earns its keep immediately: on a 31-row ledger it was the only reason a ruled-but-unbuilt decision was findable without walking every row by hand. It turns *"is this design partly fiction?"* into a table lookup, and it is what decides the [status line](#status--the-word-names-what-is-owed) — a `—` anywhere in the column means the doc is `DECIDED`, not `BUILT`.

> [!WARNING]
> Filling it from `git log` defeats the whole point. A commit message is the author's claim that they built the thing, which is the same optimism the ledger row already carries; checking it twice from one source is not checking it. Open the tree.

### Critical Rules for Compacting

1. **IDs are an API — Never renumber or re-spell:**
   An ID may be cited in code comments, PRs, task tickets, or sibling docs. Before compacting, grep the repo for it. The Decision Ledger must retain the exact ID and spelling so all cross-references resolve.

   Compaction also **deletes the question's `oq` directive, and with it the anchor its id provided.** Every inbound link that pointed at `#OQ-N` now points at nothing. Repoint them at the ledger (`…#decision-ledger`) in the same commit that compacts.

   **Grep the code, not just the docs** — this is the step that gets skipped, and the breakage it leaves is the kind no linter will ever report:

   ```console
   $ rg -n 'OQ-[A-Z]*[0-9]'          # the whole repo: code comments, tests, tickets
   $ uvx vantage-check docs/          # the doc half: link/dead-section-anchor
   ```

   `vantage-check` finds a dead `#OQ-N` in a sibling doc, and only if you remember to run it there. **A rule id cited from a source comment is invisible to every markdown tool there is.** One sprint deleted 49 `oq` directives; 28 of those ids resolved to nowhere afterwards and 9 inbound references were left stale. Separately, a graduation had to preserve seven ids in a `## Why it's this way` appendix precisely *because* source comments cited them — once the design doc is deleted that appendix is the only place they resolve at all.

2. **What compaction is allowed to DESTROY:**
   - Superseded agent leanings and deliberation drafts (git history preserves how you got there).
   - Verbose `**Answer:**` blockquote framing.

3. **What compaction MUST PRESERVE in the body text:**
   - **The ruling & reasoning chain:** Move the ruling into the normative text of the section it governs (§X).
   - **Refuted objections & known traps are DOCUMENTATION, not history.**
     If an objection was investigated and proved false (e.g. "No permanent lockout, verified at runtime.go:550"), or an alternative was rejected due to a subtle invariant ("Do not retry a1003b9 because X"), this is **load-bearing rationale**. Weave it directly into the relevant body section as a forward-facing statement or alert (`> [!WARNING]`).
     *A future reader who re-derives a refuted objection or hits a known trap costs far more than the lines saved.*

   **The test: a trap, or just a correction?** "Refuted objections are documentation" gets over-applied to every wrong claim the doc ever made, and that is one of the two ways a design doc turns into a changelog. Only a correction that would lead a reader to **re-derive a wrong conclusion, or build the wrong thing,** earns a line in the body. A stale line number, a wrong count, a commit SHA that never existed, a symbol that got renamed — these have **zero reader value once fixed.** Fix them silently.

   **Forward-facing, in practice.** "Weave it in as a forward-facing statement" is an instruction nobody can follow without a pattern, so here is the conversion. The reader needs to not-make-the-mistake; they do not need the minutes:

   ```markdown
   <!-- ❌ about the document -->
   §4 claimed the key was a gate. Corrected in review 2026-09-10: it is not,
   because the gate was deleted in OQ-TP9.

   <!-- ✅ about the system, and shorter -->
   The key discloses; it does not gate. (Gate is the intuitive reading and it
   is wrong — that gate was deleted in OQ-TP9.)
   ```

   The rejected version is *about the document*: it needs the reader to hold a
   history in their head to extract one fact. The kept version is about the
   system, names the wrong intuition so it cannot re-form, and is shorter.

4. **Fresh Agent Caution (Distinguish archaeology from load-bearing warnings):**
   - Compacting in the same session as the rulings is best.
   - If you are a fresh agent compacting a doc you didn't write: **read the git log and diffs first**. A refuted objection ("verified against code at file.go:123") looks like historical archaeology in a diff, but it is actually the reason the ruling is safe. Do not over-delete — and note that the trap test above cuts both ways: it is what tells you a refuted objection is load-bearing, and equally what tells you a corrected line number is not.

5. **Frontmatter Status Verification:**
   - `status: accepted` is load-bearing. Before stamping `status: accepted`, verify mechanically that zero unanswered `💬` questions remain.

---

## The audit pass — overturn, don't annotate

A third operation, and neither of the other two does any of it: **take every claim the doc makes about the tree and try to break it against evidence already in the tree.** Drafting adds claims and compaction reorganises rulings; nothing rechecks. On a doc that has been open more than a few days this is the highest-yield hour available, and it is worth running deliberately rather than noticing things in passing.

Run it adversarially. You are not proofreading your own doc, you are trying to catch it lying.

- **Negatives are the highest-yield category.** "`X` has no caller." "The class is empty." "Nothing reads this table." "That path is unreachable." A negative is precisely where a reader stops checking — it closes an avenue, so nobody walks down it — and it is the easiest kind of claim to get wrong, because it is only ever proved by an exhaustive search that probably wasn't. Re-run the search, and widen it past the obvious spelling: calls through an interface, reflection, generated bindings, a name assembled in a config string, a test.
- **Dated evidence expires.** Every `file.go:123` and every "verified 2026-08-12" gets re-read at the current commit, not assumed.
- **Then the load-bearing ones.** Claims a ruling was made on top of. If one of those falls, the ruling it justified is back open.

**Overturn; do not annotate.** The description of the design is [rewritten in place](#how-the-doc-evolves), so a broken claim is corrected and the page then reads as though it never said otherwise — no footnote, no strikethrough, no "(note: this turned out to be false)". Nobody needs a monument to a sentence that was never true; they need the page to be right. What survives an overturning is only what passes [the trap test](#critical-rules-for-compacting) — a correction a reader would otherwise re-derive — written forward-facing, as a statement about the system rather than about the doc's past.

**If a ruling falls out, say so out loud.** An overturned claim that a decision rested on does not quietly become a body edit: reopen the question as a live `💬` carrying the evidence that broke it, and put it back in front of the user.

## How the doc evolves

A design doc holds two kinds of content, and they take **opposite** editing rules:

| Content | Rule |
| :--- | :--- |
| **The description of the design** — what the thing is, how it is shaped, what it costs | **Rewritten in place to be currently true.** No stratum, no postscript, no "corrected in review". |
| **The record of decisions** — which rulings were made, when, and where each one landed | **Append-only.** That record is the [Decision Ledger](#the-decision-ledger-format), and it is the only append-only thing in the document. |

**"Nothing is deleted" is a rule about the second row only** — and it has to say so, because unscoped it reads as covering both, and then it wins. It wins on frequency: compaction waits for a ruling to arrive, while "annotate, never edit" applies to every keystroke in between. Every correction becomes a permanent stratum, and the doc turns into a transcript of its own review. The end state is observable and it is not subtle — a 2,000-line document carrying fifty-odd ⚠ markers and 640 lines of Open Questions for three live questions, where finding out what is true *now* means date-sorting the page.

### When the doc itself is overtaken

These mechanisms are for a change of **status**, not a correction of a claim: the world moved, the body now describes a system that no longer exists, and rewriting in place would mean rewriting all of it. Once the design is built the doc stops accreting these and graduates via `system-doc` instead.

- Add a **dated postscript blockquote at the top** saying what changed and where the current story lives — and preserve the body's original tense, saying so explicitly ("the body below describes the architecture as it was before that work").
- Append **`## Follow-up:`** sections rather than rewriting settled ones.
- **Inside a body you have deliberately frozen that way**, a claim that is now false gets a **`### ⚠ Retracted:`** heading — you gave up the right to edit in place, so marking is all that is left. Outside a frozen body there is no such thing as a retraction; the claim is simply corrected. **⚠ markers accumulating in a doc that is still being actively edited means this rule is being misapplied** — they belong to frozen text, and frozen text is rare.
- When one use case grows its own blockers, **split it into a sibling doc** and announce the split in a Scope note.

## Roadmap sync — this doc is not the index

A design doc is read by whoever already knows it exists. The **roadmap** is how everyone else finds out, and it is the thing that goes stale silently: a doc that moved from three open questions to zero, sitting under a roadmap line that still says *blocked on the user*, costs the user a whole turn to discover.

So a change here is a change there, **in the same commit** — whenever the project keeps a roadmap (`roadmap.md` at the root, or the local equivalent). The states and the archiving rules are **`roadmap`**'s; don't create a roadmap as a side effect of a doc task, and if the project has none, say so once rather than inventing one.

| What happened here | What changes in the roadmap |
| --- | --- |
| New design doc | A thread exists for it, linking the doc |
| A new `💬` question opened | An **Attention Required** item carrying the same stakes and leaning — the roadmap is where the user looks for questions, not the bottom of this file |
| A question answered and compacted | That item leaves Attention Required |
| Last `💬` closed, `status: accepted` | The thread moves to **Up Next** (📦), linking this doc and its plan |
| Doc split, renamed, or superseded | Every roadmap link re-pointed |

**A `📦` claim is a claim about this doc.** *Ready* means an agent with no memory of the conversation could build the item from what is written down. If an answer the implementer needs lives only in your head or in this session, the roadmap item is `💬` — see [the gap test](#the-gap-test).

## Style & Formatting

Follow the **`vantage-docs`** style guide for core Markdown formatting (YAML frontmatter, callout alerts, Mermaid diagrams, KaTeX math, tables, line anchors), for its **Defined Terms** rules, and for its **Open Questions & Decision Ledgers** section — which owns the `oq` directive, the id grammar, and the rule that a reference is a link.

- **Design docs are where terms get coined**, so the defining discipline binds hardest here. Naming a new component, mode, or state *is* coining a term: define it at first use, mark it `*(coined here)*`, and say what it is **not**. A name that enters the tree undefined is quoted back by every later doc as though it were standard vocabulary, and by then nobody can say where it came from. When a coined term outlives this doc — a sibling doc picks it up — it graduates to the glossary and both link there.
- **First person, opinions owned.** "My read", "the thing that surprised me — and my first reading of it was wrong." A design doc with no author viewpoint is a spec, and worse for it.
- **Present tense, concrete nouns, real numbers.**
- **Evidence is dated.** "Verified against the code 2026-08-12" — claims about what exists carry file:line anchors and a check date, not vibes.
- **Diagrams:** Use Mermaid (`flowchart`, `sequenceDiagram`, `stateDiagram-v2`) for architecture, lifecycle flows, and protocols.
- **Tables** for comparisons: alternatives, risk/mitigation, responsibility maps, rule contrasts, and Decision Ledgers.
- **Alerts:** Use GitHub/Vantage callouts (`> [!NOTE]`, `> [!WARNING]`, etc.) for critical asides and preserved traps.
- Relative markdown links with backticked filenames. Internal references — a section number, an open-question id, a filename — are links, never bare prose.

## Quality checklist

- [ ] The header orients rather than contains: **In short** is one or two sentences stating a claim, architecture leads, no build inventory, whole block inside one screen
- [ ] No walls of text: enumerations are lists, comparisons are tables, no paragraph past ~6 lines that should have been either
- [ ] Implementation material lives in the companion sketch, not here; sketch entries resting on open questions name them, and the sketch is linked in **Reads with:**
- [ ] The status line is one word from [the owed vocabulary](#status--the-word-names-what-is-owed), stamped as that row requires, and **checked against the tree** rather than re-spelled — no genre words, no percentages, and no doc without one
- [ ] A `BUILT` line carries `MEASURED:` or `UNMEASURED:`, and says which honestly
- [ ] **Needs your ruling** names exactly the live `💬` ids, or **None** with none live
- [ ] Frontmatter `status:` is one of Vantage's four and answers the other question; `accepted` verified to have zero open `💬` questions
- [ ] `BUILT` with zero live questions was named as a graduation candidate, not left to a later review
- [ ] Altitude holds: components/algorithms/invariants, no per-file edit plans outside a fenced section
- [ ] Completeness holds: degenerate inputs, failure paths, ordering, defaults with units, triggers, pre-existing state, one-writer rules, and observable done-conditions are all stated
- [ ] Every question an implementer must answer is answered, opened as an `OQ-N`, or explicitly delegated — none left silent
- [ ] Claims about existing code carry file:line evidence
- [ ] A negative-space section says what this does NOT cover
- [ ] Alternatives considered, each with an explicit verdict
- [ ] Live Open Questions have status emoji (💬), stable ID, bold title, stakes, leaning, empty Answer blockquote, and an `oq` directive carrying the id and the leaning text
- [ ] `uvx vantage-check <doc>` is clean — in particular every section number, question id and filename in prose is a link (`ref/*`)
- [ ] Settled decisions are compacted into the Decision Ledger + normative body text (with refuted objections preserved as warnings)
- [ ] The ledger's `Built` column was filled by opening the tree, not by reading commit messages
- [ ] Before any compaction, `rg -n 'OQ-[A-Z]*[0-9]'` was run over the **whole repo** — source comments cite these ids and no markdown tool can see them
- [ ] No `✅` question survived the turn it was answered in — every ruling is a ledger row plus body text, and no leaning is versioned
- [ ] Every question was checked against sibling docs' Decision Ledgers before it was opened
- [ ] The audit pass has run since the last substantive edit: negatives re-searched, dated evidence re-read at the current commit
- [ ] The description reads as currently true — corrections are edits, not strata; the only append-only thing is the Decision Ledger, and ⚠ markers appear only inside a deliberately frozen body
- [ ] Every preserved correction passes the trap test and is written forward-facing, about the system rather than about the document
- [ ] Nothing framed as a task list the user has to maintain
- [ ] The roadmap reflects this doc — its link, its status, and every question newly opened or answered — updated in the same commit
- [ ] Where this vocabulary now governs a corpus, [the check is in the repository](#land-the-check-in-the-repository) and re-runnable — not only in this skill
