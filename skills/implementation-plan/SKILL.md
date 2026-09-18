---
name: implementation-plan
description: Use when a settled design needs a build hand-off grounded in the current repository tree.
---

# Implementation Plans

The design doc says what to build, and is written for the person deciding. This says what the builder would otherwise have to rediscover, and is written for the agent that builds it.

Assume that agent is a capable coder starting cold: no repo in context, a limited search budget, and no way to know which of its plausible first moves is the one this codebase already regrets. You just spent a session in the tree. **The plan is the transfer of what you know and they would otherwise pay for.**

The file has a life before that, though. It **opens as a sketch** while the design is still being argued, holding the implementation material that would otherwise clutter the design doc — see [Lifecycle](#lifecycle). A sketch is not a hand-off, and nothing is built from one.

## The economics — one test per line

> **Expensive to discover, cheap to state.**

That is the whole filter. Before a line goes in, say what it saves. "One obvious grep" — cut it; the implementer is good at greps. "An hour, or a wrong turn that compiles" — keep it.

The corollaries are what keep the doc short:

- **Never restate the design.** Link it. A plan that re-explains the feature is pure cost: the implementer reads both.
- **Never write the code.** No function bodies. Signatures only where the shape is a contract someone else must match — an interface, a wire message, a CLI surface.
- **Name, don't quote.** `store.WithTx(ctx, fn)` beats a pasted snippet, costs a tenth as much, and cannot go stale in place.
- **If you can't say what a line saves, it is not advice, it is throat-clearing.**

Aim for one screen — call it 120 lines. Past ~200 you are writing the implementation with extra steps, and the implementer reads less of it, not more.

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
2. **The tree wins on fact.** File moved, helper gone, map stale → follow the tree and say so in the commit.
3. **The plan is advice, and is the first thing to be wrong.** It is one agent's understanding at one commit.

The instruction that follows: **never twist the code to match the plan.** An overtaken plan is a note to correct, not a spec to satisfy.

## What goes in

In this order. Drop any section that would be empty rather than padding it.

**Header.** The design doc link, a status, and the commit the plan was written against — `Written against a1b2c3d, 2026-09-01`. That stamp is the entire staleness defense: an implementer arriving 200 commits later knows exactly how far to trust the map.

**The map.** One table, one row per file that changes: path → what changes there, new files marked new. This is the material `design-doc` deliberately refuses, and this is where it lives. A map, not a diff.

**Reuse before you write.** The highest-value section, and the only one you alone can write. Existing helpers by symbol and path; the fixture that already builds the test state; the sibling to copy the shape from — "mirror `internal/sync/pull.go`: same retry shape, same error wrapping." Every line here is a small reimplementation that will otherwise happen.

**House style that isn't obvious.** Only where the repo departs from what a competent agent writes by default — error wrapping, logging, config plumbing, test layout, naming. If the repo does the obvious thing, spend nothing here.

**Traps.** What looks right and isn't, one line each, with the symptom, so it is recognizable from the inside: "config is loaded twice; the second load silently wins and has no CLI flags in it." Ordering constraints, late-initialized globals, generated files, a test that is flaky for a known reason.

**Build order.** Numbered steps, each a vertical slice that ends green and committable, each naming the command that proves it: `just test ./internal/store`. For a bug, step 1 is the failing test. Say what unblocks the rest, and what gets expensive if it lands late.

**Everything else that ships** (`## Ships with`)**.** Tests by level and by case; the docs that now describe the old behavior; the surfaces that are neither — config defaults, CLI help, error text, generated files, migrations, examples. One line each, named by path. This is the section a cold implementer will not write for itself; see *Attention* below for why, and for what belongs in it.

**Don't.** Out of scope, files not to touch, and — most valuable — the plausible wrong turn pre-empted with its reason: "you will want to put a cache in front of this; don't, invalidation is the live question in `OQ-N`."

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
# Plan: token bucket for the poller

**Design:** [`rate-limiting.md`](rate-limiting.md) · **Status:** ready ·
Written against `a1b2c3d`, 2026-09-01.
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

## Build order
1. Bucket + unit tests, no wiring. → `just test ./internal/rate`
2. Wire into the loop behind a default-on flag. → `just test ./internal/poll`
3. Drop the flag once the soak is clean. → `just check`

## Ships with
- Unit: burst exhaustion, refill across a fake-clock jump, zero-rate config.
  Integration: `test/poll_ratelimit_test.go` — two hosts, one client, asserts
  per-host pacing. That one catches a per-client regression; the unit tests don't.
- `poll/loop_test.go:TestFetchAll` asserts unthrottled timing — rewrite it to the
  new behavior; do not relax the assertion until it passes.
- Docs: `README.md` "Polling", `docs/reference/poller.md` §3, and the `--interval`
  help text (it now interacts with the limit).
- Config: `rate.per_host`, default 5/s, into `config.example.toml`.
- Cheap and yours: bucket internals (advice: float tokens, not a timer).
  **Stop and ask** if the limit must be per-host *and* global — the design fixes
  one, and `OQ-4` is unruled.

## Don't
- Don't reach for `golang.org/x/time/rate` — it cannot be driven by the fake
  clock (tried at `d4e5f6a`).
```

## Lifecycle

Lands beside the design it serves, same basename plus `-plan`: `docs/design/<topic>-plan.md`.

### It opens as a sketch

The file exists from early in the design, not from hand-off. While the design is still being argued it is a **sketch** — `**Status:** SKETCH — incomplete, and unstable while questions are open.` — and it has exactly one job: hold the implementation material that would otherwise clutter the design doc. Dependency and library notes, schema and signature sketches, migration mechanics, packaging, sequencing below the design's altitude.

Two rules govern it, and **`design-doc`** owns both:

- **No design decision is made in the sketch.** Behavior that could reasonably go two ways is an `OQ-N` in the design doc, never a line here. The sketch holds settled-but-boring material; it is not a place for a decision to hide.
- **An entry resting on an unruled question names it,** and is revisited when that question is answered. A line written under a guess the ruling contradicts is what the marking exists to catch.

  ```markdown
  Blocked on [OQ-4](rate-limiting.md#OQ-4) — the retry policy shapes this.
  ```

### It is completed against the tree

**A sketch is not a hand-off, and nothing is built from one.** The promotion happens after the design settles and **after reading the code**, and it is what adds the sections carrying this genre's whole value: the map, the reuse, the traps, the build order, `Ships with`. A plan written from the design alone contains no codebase knowledge, which was the entire product.

Do it **close to hand-off**, because it rots at the speed of the tree. Promoting means: stamp the written-against commit, drop the `SKETCH` status, and re-check every line that has been sitting in the sketch since the design was open — those are the stalest lines in the file, and they were written before the rulings.

**Deleted when the work lands.** Git keeps it; a stale plan sitting next to a shipped feature is a trap for the next reader. Two things graduate out of it first:

- **Traps that turned out to be real** → the system doc's warnings (see **`system-doc`**). They are now permanent knowledge about the system.
- **What the plan got wrong** → the retro below.

### The roadmap tracks which of the three it is

Those three states are exactly what the roadmap reports, and the roadmap is what the user reads. Move the item in the **same commit** as the plan change, whenever the project keeps one (`roadmap.md` at the root, or the local equivalent) — states and archiving belong to **`roadmap`**:

- **Opened as a sketch** → the item is *not* `📦`, however much the file already contains. A sketch is not a hand-off; it stays `💬` or `🏗️` until the design settles.
- **Promoted against the tree** → `📦`, linking this plan and the design. This is the transition that makes an item buildable cold, and the one most often left unwritten.
- **Work landed, plan deleted** → the item leaves the roadmap (archiving protocol), and anything the plan named but nobody built becomes its own item rather than evaporating with the file.

## Whether this is working

This genre is an experiment. The claim — context transferred from an author who has the tree loaded to an implementer who doesn't pays for its own tokens — is plausible and unproven. Measure it cheaply. When the work lands, note two things in the landing commit:

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
- [ ] Links the design doc and does not restate it
- [ ] Written-against commit named, and dated
- [ ] Precedence stated: design → tree → plan
- [ ] Every advice line carries its reason; every constraint is a fact, not a preference
- [ ] No function bodies; signatures only where the shape is a contract
- [ ] The map covers every file that changes, new ones marked
- [ ] Reuse names symbols and paths, not descriptions of them
- [ ] Each build step ends green and names the command that proves it
- [ ] Tests named by level and by case, including the integration test that would catch this breaking
- [ ] Tests that must change with the behavior are marked as rewrites, not repairs
- [ ] Docs, config keys, CLI help and generated files describing the old behavior are named by path
- [ ] Existing reference docs with overlapping scope were checked for now-false or incomplete behavioral claims, not merely broken links
- [ ] Norms named only where this change touches them, by enforcing command where one exists
- [ ] Cheap choices marked cheap; expensive ones marked stop-and-ask
- [ ] No behavior claims that belong in the design doc
- [ ] The roadmap item matches this file's state — never `📦` while the status line says `SKETCH` — moved in the same commit
- [ ] Under ~120 lines
