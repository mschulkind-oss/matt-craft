---
name: implementation-plan
description: Use when a settled design needs a build hand-off grounded in the current repository tree.
---

# Implementation Plans

The design doc says what to build, and is written for the person deciding. This says what the builder would otherwise have to rediscover, and is written for the agent that builds it.

Assume the **implementer** role: a cheaper model that executes well, has a small search budget, and must not diagnose. The **smart** role — the one that just read the tree and settled the design — writes this plan, and the implementer builds from this plan alone; the design is the author's and the reviewer's, not the implementer's. Name the roles, never the models: which model fills each is configuration, and it changes between sessions. You just spent a session in the tree. **The plan is the transfer of what you know and they would otherwise pay for.**

The file has a life before that, though. It **opens as a sketch** while the design is still being argued, holding the implementation material that would otherwise clutter the design doc — see [Lifecycle](#lifecycle). A sketch is not a hand-off, and nothing is built from one.

## The economics — one test per line

> **Expensive to discover, cheap to state.**

That is the whole filter. Before a line goes in, say what it saves. "One obvious grep" — cut it; the implementer is good at greps. "An hour, or a wrong turn that compiles" — keep it.

The corollaries are what keep the doc short:

- **Never restate the design's argument.** Link the design. A plan that re-explains the feature is pure cost. But *do* quote the settled behavior a task needs, marked **do not re-open**: the implementer does not read the design, and a fact it has to re-derive is a fact it can get wrong.
- **Never write the production code.** No function bodies. Signatures only where the shape is a contract someone else must match — an interface, a wire message, a CLI surface.
- **Do write the failing test in full**, with exact literals — config values, strings, JSON, and the red command. That is the one place a pasted block outruns a description.
- **Name production code, don't quote it.** `store.WithTx(ctx, fn)` beats a pasted snippet, costs a tenth as much, and cannot go stale in place.
- **If you can't say what a line saves, it is not advice, it is throat-clearing.**

Aim for ~120 lines of prose per task. Test code, commands, and the commit message do not count toward that — they are exact by design, and the briefs that worked spent most of their length there. Past ~200 lines of prose per task you are writing the implementation with extra steps, and the implementer reads less of it, not more.

## Binding vs. advisory — mark which

A cold implementer cannot tell your requirement from your suggestion, and guesses badly in both directions: it will fight the compiler to obey a stray preference, or quietly drop a real constraint that read as taste. So every line is one of two kinds, and the plan says which.

- **Constraint (must).** A fact about the repo or the world: "`api.pb.go` is generated — run `just gen`, never hand-edit it."
- **Advice (default, with its reason).** "Walk the tree iteratively — the recursive version overflows on the real corpus (~40k nodes)." **The reason is the point:** given the reason, any deviation that still satisfies it is fine.

Advice stripped of its reason degrades into an order, and that is the failure this distinction prevents.

> [!IMPORTANT]
> **Behavior is never advisory.** A *must* about what the system does, rather than how it is built, belongs in the design doc. Put it there instead — see **`design-doc`**, *Completeness*.

## Precedence — what wins when things disagree

Put this in the plan, near the top. It is the rule the implementer most needs and the one nobody writes down.

1. **The design doc wins on behavior.** If the plan implies different behavior, the plan is wrong.
2. **The tree wins on fact — cosmetic drift only.** A moved line, a renamed helper with the same role: follow the tree and say so in the report and the commit.
3. **The plan is advice, and is the first thing to be wrong.** It is one agent's understanding at one commit.

The instruction that follows: **never twist the code to match the plan.** An overtaken plan is a note to correct, not a spec to satisfy.

**Stop and report; do not commit** when the disagreement is not cosmetic:

- the test does not fail the way the task predicted;
- a file the task names is dirty with someone else's work;
- a symbol the task names is gone;
- the fix needs a file outside the task's fence;
- a gate fails outside the task's scope.

Those are not the tree being right and the plan wrong. They are the plan's assumptions breaking, and the implementer's job is to stop, not to diagnose a way through. State the conditions in each task's preconditions, and repeat the rule here.

## Ready to hand off

A plan is safe to hand to the implementer only when all of these hold. This is the smart role's check before spawning, not something the implementer fixes.

- The author reproduced the problem or confirmed the gap, and recorded how — the command, the run id, the file read.
- Every behavior a task needs is answered, or marked **cheap** and explicitly left to the implementer.
- The failing test and the command that shows it red are given in full.
- Every path and symbol named was read at the commit the plan is stamped against.
- Fences, stop conditions, gates, and the commit message are present.

Then reread each task as the implementer and search the text for **investigate**, **figure out**, **decide**, and **choose**. Every hit is either diagnosis the author should do now, or a choice to mark cheap. Those four words are the readiness test failing out loud.

A design question left open in the plan is not a precondition — it is the design's, open until the user rules. See **`design-doc`**, *Completeness*.

## What goes in

In this order. Drop any section that would be empty rather than padding it.

**Header.** The design doc link, top-level `status`, `stage`, `next`, and actual `depends-on` paths, plus the commit the plan was written against — `Written against a1b2c3d, 2026-09-01`. That stamp is the entire staleness defense: an implementer arriving 200 commits later knows exactly how far to trust the map.

**The map.** One table, one row per file that changes: path → what changes there, new files marked new. This is the material `design-doc` deliberately refuses, and this is where it lives. A map, not a diff.

**Reuse before you write.** The highest-value section, and the only one you alone can write. Existing helpers by symbol and path; the fixture that already builds the test state; the sibling to copy the shape from — "mirror `internal/sync/pull.go`: same retry shape, same error wrapping." Every line here is a small reimplementation that will otherwise happen.

**House style that isn't obvious.** Only where the repo departs from what a competent agent writes by default — error wrapping, logging, config plumbing, test layout, naming. If the repo does the obvious thing, spend nothing here.

**Traps.** What looks right and isn't, one line each, with the symptom, so it is recognizable from the inside: "config is loaded twice; the second load silently wins and has no CLI flags in it." Ordering constraints, late-initialized globals, generated files, a test that is flaky for a known reason.

**Tasks.** The shared header above — header, map, reuse, traps — is written once. Below it, each unit of work is a task, and the task is what the implementer is handed. Give each the fields it needs, and drop any that would be empty:

- **Settled** — the behavior it must produce, quoted from the ruling, marked **do not re-open**.
- **Preconditions** — the commands that must hold, and what to do if one fails (usually the stop-and-report list under *Precedence*).
- **Tests first** — the failing test, in full, and the command that shows it red.
- **Change** — file, symbol, `~line`. The shape, not the body.
- **Gates** — the exact commands that prove it green, including any to run by hand because the hook is not installed here.
- **Fences** — files and hunks that are out of scope, naming another agent's work when it shares the tree.
- **Commit message** — the exact message to write.
- **Report** — what to paste back: the red command and its output, the green gates, and anything the tree forced.

**Build order** is then a property of the tasks, not a separate list: mark each **independent** or **after N**. A task is sized as one commit and one worktree; parallel tasks get disjoint files, or the order they land in is named. Say what unblocks the rest, and what gets expensive if it lands late.

**Everything else that ships** (`## Ships with`)**.** Tests by level and by case; the docs that now describe the old behavior; the surfaces that are neither — config defaults, CLI help, error text, generated files, migrations, examples. One line each, named by path. This is the section a cold implementer will not write for itself; see *Attention* below for why, and for what belongs in it.

**Don't.** Out of scope, files not to touch, and — most valuable — the plausible wrong turn pre-empted with its reason: "you will want to put a cache in front of this; don't, invalidation is the live question `[OQ-N](rate-limiting.md#OQ-N)`."

**Blockers.** Only what stops work. Live design questions stay in the design doc as `OQ-N` and are cited here as a link to the question's own anchor — or to the design doc's Decision Ledger once it has been compacted, which destroys that anchor. Never fork the question list across two documents.

## Attention — the failure is misallocation, not absence

A cold implementer does not think too little. It thinks hard about the wrong things: it will deliberate over a map type or the factoring of a helper, then ship the feature with no integration test, a README describing the old flag, and three pages of docs still narrating the behavior it just replaced. Nothing in the diff looks wrong, so nothing prompts it. **The plan spends its reader's attention for it.** Two moves, both cheap.

### 1. Name what ships besides code

"Obvious" is a property of your context, not theirs. Name these *for this change*, not in general:

- **Tests, by level and by case.** Never "add tests". Which unit cases — the degenerate inputs and failure paths the design already enumerated — and which **integration** test, the one that would actually catch this breaking end to end. Name the suite it joins and the fixture that already builds the state. For a bug, the failing test is step 1 of the build order.
- **Tests that will break, and should.** A behavior change invalidates whatever asserted the old behavior. Say which, and say they are to be **rewritten to the new behavior, not repaired until green** — that reflex is how a design change gets silently reverted inside the test suite.
- **Docs that now describe the old thing.** By path: README section, reference doc, CLI help, changelog, the example that no longer runs. For each existing reference doc whose stated scope overlaps the change, check its behavioral claims as well as its links: a new route, state, or mode can make an old "only" or "always" claim false without changing that doc's path. A doc confidently describing superseded behavior is worse than no doc.
- **Surfaces that are neither code nor docs.** Config keys and their defaults, migrations, error text, log and metric names, generated files (and the command that regenerates them), fixtures and examples.
- **The norms this change actually touches** — not the style guide. Where a norm is mechanically enforced, name the command instead of the rule: a check that fails beats a paragraph that gets skipped. `just check` before each commit outranks a page on formatting.

### 2. Say where the judgement is — and where it isn't

An unmarked choice reads as consequential, and that is exactly where the deliberation goes. Both halves are worth a line:

- **Cheap, and theirs.** "Any map type — read once at startup." Marking a choice unimportant stops the spiral before it starts, and costs six words.
- **Expensive, and not theirs.** The one or two places where a wrong guess is costly and the answer isn't yours to give: it changes behavior the design fixed, it touches data already on disk, it is externally visible. Name them as **stop and ask**, and list them under blockers rather than leaving them to be decided alone.

## Example (abridged)

```markdown
---
status: accepted
stage: DECIDED
next: "Build the bucket and unit tests; stop at the targeted test gate"
---

# Plan: token bucket for the poller

**Status:** 2026-09-01. Completed against the tree, written against `a1b2c3d`.
**Design:** [`rate-limiting.md`](rate-limiting.md).
Precedence: the design wins on behavior, the tree wins on fact, this file
is advice and is the first thing to be wrong.

## Map
| Path | Change |
| :--- | :--- |
| `internal/rate/bucket.go` | new — the bucket |
| `internal/poll/loop.go` | acquire before each fetch (~`loop.go:88`) |

## Reuse
- `internal/clock.Clock` — inject it; never call `time.Now` directly.
  (Advice: every timing test in the repo fakes time through it.)
- Option struct: mirror `internal/poll/opts.go` — functional options, no config struct.

## Traps
- One goroutine per host, but a single shared HTTP client — a per-client
  bucket is not a per-host bucket. **Constraint:** the design's limit is per host.

## Tasks
**Task 1 — the bucket.**
- **Settled:** the limit is per host, refilled on the injected clock. Do not re-open.
- **Tests first:** `internal/rate/bucket_test.go` — burst exhaustion, refill across a
  fake-clock jump, zero-rate config. → `just test ./internal/rate` (red).
- **Change:** `internal/rate/bucket.go` (new); acquire in `internal/poll/loop.go` (~`:88`).
- **Gates:** `just test ./internal/rate`.
- **Fences:** nothing under `internal/http`.
- **Commit:** `feat(rate): per-host token bucket`.
- **Report:** the red run, the green run, and whether `internal/clock` already had a fake.

**Task 2 — wire the loop** (after 1): behind a default-on flag. → `just test ./internal/poll`.
**Task 3 — drop the flag** (after 2, soak clean): → `just check`.

## Ships with
- Unit: burst exhaustion, refill across a fake-clock jump, zero-rate config.
  Integration: `test/poll_ratelimit_test.go` — two hosts, one client, asserts
  per-host pacing. That one catches a per-client regression; the unit tests don't.
- `poll/loop_test.go:TestFetchAll` asserts unthrottled timing — rewrite it to the
  new behavior; do not relax the assertion until it passes.
- Docs: `README.md` "Polling", `docs/reference/poller.md` "Rate limits", and the `--interval`
  help text (it now interacts with the limit).
- Config: `rate.per_host`, default 5/s, into `config.example.toml`.
- Cheap and yours: bucket internals (advice: float tokens, not a timer).
  **Stop and ask** if the limit must be per-host *and* global — the design fixes
  one, and [OQ-4](rate-limiting.md#OQ-4) is unruled.

## Don't
- Don't reach for `golang.org/x/time/rate` — it cannot be driven by the fake
  clock (tried at `d4e5f6a`).
```

## Lifecycle

Lands beside the design it serves, same basename plus `-plan`: `docs/design/<topic>-plan.md`.

### It opens as a sketch

The file exists from early in the design, not from hand-off. While the design is still being argued it is a **sketch** — `stage: SKETCH` in frontmatter, with a dated prose status line saying it is incomplete and unstable while questions are open — and it has exactly one job: hold the implementation material that would otherwise clutter the design doc. Dependency and library notes, schema and signature sketches, migration mechanics, packaging, sequencing below the design's altitude.

Two rules govern it, and **`design-doc`** owns both:

- **No design decision is made in the sketch.** Behavior that could reasonably go two ways is an `OQ-N` in the design doc, never a line here. The sketch holds settled-but-boring material; it is not a place for a decision to hide.
- **An entry resting on an unruled question names it,** and is revisited when that question is answered. A line written under a guess the ruling contradicts is what the marking exists to catch.

  ```markdown
  Blocked on [OQ-4](rate-limiting.md#OQ-4) — the retry policy shapes this.
  ```

### It is completed against the tree

**A sketch is not a hand-off, and nothing is built from one.** The promotion happens after the design settles and **after reading the code**, and it is what adds the sections carrying this genre's whole value: the map, the reuse, the traps, the build order, `Ships with`. A plan written from the design alone contains no codebase knowledge, which was the entire product.

Do it **close to hand-off**, because it rots at the speed of the tree. Promoting means: stamp the written-against commit, drop the `SKETCH` status, and re-check every line that has been sitting in the sketch since the design was open — those are the stalest lines in the file, and they were written before the rulings.

**Deleted at graduation**, in the same commit that adds the system doc (see **`system-doc`**, Step 4), not at landing. Keep the plan and roadmap links while graduation or verification is owed; stamp it with the repository's built stage (`BUILT` with **`design-doc`**'s mapping). Git keeps it afterward. Two things move out first:

- **Traps that turned out to be real** → the system doc's warnings (see **`system-doc`**). They are now permanent knowledge about the system.
- **What the plan got wrong** → the retro below.

### The source owns state; the roadmap owns order

Keep `stage`, `next`, and actual `depends-on` paths in this file's frontmatter. Review the
roadmap in the **same commit** whenever links, sequencing rationale, or remaining scope
change; do not copy plan state or blockers into a second table. See **`roadmap`** for `vantage-check index` and `--roadmap <path>`.

- **Opened as a sketch:** set `stage: SKETCH`, name refinement as the next action, and link
  the design gates. This is not a build hand-off, even if it has a priority position.
- **Promoted against the tree:** set the repository's ready stage (default `DECIDED`),
  record the written-against commit, and name the first build step in `next`. Review the
  roadmap link to this hand-off and its order, not a duplicated ready label.
- **Work landed:** set the built stage and retain the plan and roadmap links while graduation
  or verification is owed. **Graduated, plan deleted:** remove closed entries and give
  specified-but-absent or unverified work its own live source and next step.

## Whether this is working

This genre is an experiment. The claim — context transferred from an author who has the tree loaded to an implementer who doesn't pays for its own tokens — is plausible and unproven. Measure it cheaply. Each task's **Report** is where the first list arrives: read it, and fold what it reveals into the next plan. When the work lands, note two things in the landing commit:

- **What the implementer had to ask or rediscover.** A hole the plan should have closed.
- **What the plan said that nobody needed.** Dead tokens; that category comes out of the next plan.

If the first list stays empty while the second grows, the plans are too long. If the reverse, too thin.

## Style

Follow **`vantage-docs`** for Markdown formatting. Otherwise this genre inverts `design-doc`'s voice deliberately:

- **Impersonal and terse.** No first person, no narrative, no conclusion earned over paragraphs. It is scanned, not read.
- **One line per item.** Tables over prose; fragments are fine.
- **Perishable anchors are welcome.** `file.go:412` is right here — the doc lives days, and precision beats durability. (`system-doc` bans them for exactly the opposite reason.)
- **No hedging.** "Probably", "consider", "you may want to" — either it is advice with a reason, or it is cut.

## Quality checklist

- [ ] Status is honest: `SKETCH` while the design has open questions, promoted only after reading the tree
- [ ] No design decision is made here — behavior that could go two ways is an `OQ-N` in the design doc
- [ ] Every entry resting on an open question links it; on promotion, each was re-checked against its ruling
- [ ] Ready to hand off: the problem was reproduced, every behavior is answered or cheap, the red test and its command are given, paths were read at the stamped commit, and fences, stop conditions, gates and the commit message are present
- [ ] Reread as the implementer: no "investigate", "figure out", "decide" or "choose" is left unmarked
- [ ] Each task carries its Settled, Preconditions, Tests first, Change, Gates, Fences, Commit message and Report fields; empty fields were dropped
- [ ] Settled behavior is quoted to be self-contained, not merely linked
- [ ] Stop-and-report conditions are named (test not red as predicted, dirty file, missing symbol, a file outside the fence, a gate failure out of scope)
- [ ] Links the design doc and does not restate its argument; the settled behavior a task needs is quoted instead
- [ ] Written-against commit named, and dated
- [ ] Precedence stated: design → tree → plan, with the stop-and-report cases
- [ ] Every advice line carries its reason; every constraint is a fact, not a preference
- [ ] No function bodies; signatures only where the shape is a contract
- [ ] The map covers every file that changes, new ones marked
- [ ] Reuse names symbols and paths, not descriptions of them
- [ ] Each task ends green and names the command that proves it
- [ ] Tasks are marked independent or after N; each is one commit and one worktree, and parallel tasks have disjoint files or a stated landing order
- [ ] Tests named by level and by case, including the integration test that would catch this breaking
- [ ] Tests that must change with the behavior are marked as rewrites, not repairs
- [ ] Docs, config keys, CLI help and generated files describing the old behavior are named by path
- [ ] Existing reference docs with overlapping scope were checked for now-false or incomplete behavioral claims, not merely broken links
- [ ] Norms named only where this change touches them, by enforcing command where one exists
- [ ] Cheap choices marked cheap; expensive ones marked stop-and-ask
- [ ] No behavior claims that belong in the design doc
- [ ] Source metadata matches the plan's actual readiness; roadmap links and sequencing were reviewed in the same commit, without copied state
- [ ] Under ~120 lines of prose per task (test code, commands and the commit message excluded)
