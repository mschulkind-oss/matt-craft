---
name: system-doc
description: Use when documenting how an implemented system works, graduating a shipped design, or re-verifying a system reference.
---

# System Docs

The last stage of a design's life. A design doc argued for a shape; once that shape exists in code, the argument is over and the doc's remaining job is different: **tell someone who has never seen this system how it works, and stop them breaking it.**

That is not the same document with the Open Questions deleted. It is a different genre with a different reader, and it lives somewhere else.

```
brainstorming → research → design-doc → implementation-plan → (build it) → system-doc
                            ↑                                                   │
                            └── a substantial change ───────────────────────────┘
                                starts a new design doc
```

## When to use this skill

- A design doc's feature is built and merged — "this is done, clean up the doc"
- "Write up how X actually works" / "I want a doc that just describes the final design"
- Running the skill on an existing system doc → **re-verify it against the code** and re-stamp (see *Staying current*)
- Any point where a doc in the planning tree has stopped being a proposal

### `BUILT` is the cue, and no second one is coming

**`design-doc`** says reaching the built state hands off to here, and that reads like the *start* of a wait — for a review, a soak, some later moment when the doc is ready. There is no such moment. In one census ~40 design docs qualified for graduation and sat, until a whole restructure was needed to route them.

The fact that settles it took a census to find and one line to state: **the evergreen tree has exactly one state.** 41 of 41 reference docs in that repo carried `status: current`. There is no "built but not yet current" for a doc to wait in, so reaching built *is* the cue, necessarily.

So the trigger is mechanical, and it is worth running as one: **a doc stamped `BUILT` with zero live `💬` questions is a graduation candidate.** `design-doc` ships a check that lists them.

> [!WARNING]
> A built claim carries a measurement clause — `MEASURED:` or `UNMEASURED:` — and an `UNMEASURED:` design doc graduates like any other, **carrying that fact with it.** Three docs in that census claimed built with zero runtime observation recorded, two of them describing a macOS backend no CI job has ever exercised. Reconciling against the code ([step 1](#step-1--reconcile-against-the-code)) proves the code exists; it proves nothing about whether anyone watched it run. Say which in the header, and say it in the roadmap.

Not this skill:

- A design still being decided, or with live `💬` questions → `design-doc`
- Knowledge about the *world* — libraries, protocols, prior art → `docs/research/` via `research`. System docs are evergreen knowledge about **what we built**; research docs are evergreen knowledge about everything else.
- A user-facing guide, tutorial, or README → those have a different reader again (someone *using* the thing, not maintaining it)

## The move

`docs/design/<topic>.md` → `docs/reference/<topic>.md`; the design doc and, when present, `docs/design/<topic>-plan.md` are **deleted**. The completed plan is a hand-off artifact, not an evergreen record: move its real traps into the system doc, then retire it with the other planning material. Git keeps both histories.

Out of the planning tree, into a reference tree. Follow the local convention if the repo already has one (`docs/architecture/`, `docs/system/`); create `docs/reference/` if it doesn't. Keep the same content-noun filename — `boundary-broker.md` stays `boundary-broker.md` — so the move reads as a move.

## The three failure modes this exists to prevent

**1. The doc that describes the design instead of the system.** The most dangerous doc in a tree, because it reads authoritative and is wrong. Implementations always drift: a parameter got tuned, a component got merged into another, a subsystem never got built. Someone will trust this doc over the code and lose an afternoon.

**2. The design doc with the Open Questions deleted.** Still opens with the diagnosis of a problem that no longer exists, still weighs three alternatives, still has a build-order section for work that's finished. The genre never changed — only the length. This one wastes the reader's time rather than lying to them, which is the better failure, but not by much.

**3. The doc that was true once.** Failure 1, arrived at slowly. The code moved and the doc didn't, because nothing about changing the code forced anyone to look at the doc. This is the default outcome and the one the whole rest of this skill is arranged against: *Altitude* below decides how much of the doc is even capable of rotting, and *Staying current* decides how the rest gets caught.

## Altitude — the doc has to outlive the code

A system doc is read months after it's written, by someone who will trust it. So the governing question at every sentence is not "is this true?" but **"how long will this stay true, and what happens to the reader when it stops?"**

### The one test

> **Would this sentence still be true after a refactor that changed no behavior?**

If no, it describes the *code*, not the *system*, and it will be wrong by winter. Rewrite it one level up — at the mechanism — or move it to the Current values table (below), which is the one place perishable facts are allowed to live.

"The queue evicts the oldest *pending* entry when full, never an approved one" survives any rename, any file split, any language port. "`queue.go:88` calls `ring.PopOldest()` when `len(q.pending) > maxPending`" is wrong the first time someone adds an import.

### Claims sorted by how fast they rot

| Claim | Rots when | Write it? |
| :--- | :--- | :--- |
| Line numbers | anything above them is edited | **Never** — see *self-healing anchors* |
| Exact constants, timeouts, sizes | anyone tunes anything | Only in the Current values table |
| Function and method names | any refactor | Only for a genuine public entry point |
| File paths | a reorganization | Prefer the package or directory |
| Type, error, and package names | a rename — which is greppable | **Yes.** These are the good anchors |
| Component names and responsibilities | a redesign | **Yes** — the doc's spine |
| Protocols, wire formats, data shapes | a version bump, and loudly | **Yes** |
| Invariants and one-writer rules | a redesign, never a refactor | **Yes** — the most valuable lines in the doc |
| Principles and known traps | close to never | **Yes** — these outlive the implementation |

The top of that table is where docs go to die. The bottom is the reason to write one at all.

### Self-healing anchors beat precise ones

Evidence in a system doc is a **symbol plus a package** — `ErrStaleEpoch` in `internal/proto` — not `proto/errors.go:41`. The symbol is greppable *after it moves*; the line number is a dangling pointer the moment anyone breathes on the file.

> [!NOTE]
> This deliberately inverts the `file:line` convention `design-doc` uses, and the reason is lifespan. A design doc's evidence has to be checkable *this week*, by a reader deciding something, and the doc is superseded within a month. A system doc outlives its own line numbers by years. Same word, "evidence"; different job.

### Numbers: magnitude and reason in the prose, exact value in one table

An exact constant in prose is the worst kind of claim — authoritative-looking, trivially checkable, never checked. In the body, write what the number *is for*: "single-digit seconds — long enough to ride out a checkpoint, short enough that a wedged writer surfaces as a failed request rather than a hang." That reasoning stays true across every retuning.

The exact value goes in the **Current values** table with where it's defined. State an exact number in prose only when the exact number is the contract: a protocol version byte, a well-known port, a limit external consumers must match.

### Never restate a machine-readable source

If it exists in a schema, a proto file, an enum, a `--help` output, or a config struct, that copy is the one people edit and yours is the one that drifts. Document the *shape and the reason*; link to the enumeration.

**Any exhaustive list is a rot machine** — config keys, error codes, subcommands, event types. Name the two or three that carry meaning and say where the full set lives.

For the same reason: **no code blocks that are copies of code.** A snippet in a doc is an unmaintained fork. Wire-format and payload examples are fine — that's protocol, not implementation — as is pseudocode that was never a copy of anything.

### Nothing with a date-shaped truth

Performance measurements, current scale, "known issues", "recently added", team ownership. These rot on a schedule the doc can't track and don't survive their first quarter. They belong in a roadmap, a dashboard, or nowhere.

### Structure the doc by half-life

Order the doc so rot arrives from the bottom:

1. **What it is, and why it's shaped this way** — principles, invariants. Near-immortal.
2. **How it works** — components, mechanisms, protocols, failure modes. Refactor-invariant.
3. **Where it lives** — packages and key types. Moves occasionally; greppable when it does.
4. **Current values** — constants, ports, env vars, paths. Perishable, and *quarantined here*.

This matters more than it looks, because **a doc loses trust as a whole.** One stale line number teaches the reader that nothing in the file can be relied on — including the invariants, which were the expensive part and were still perfectly true. Concentrating the perishable into one table protects everything above it, and makes re-verification a single bounded pass instead of a re-read.

## The loop

1. **Reconcile** the doc against the code. The expensive step, and the reason this skill exists.
2. **Rewrite** it in the new genre, at the new path.
3. **Re-point** every inbound reference in the repo.
4. **Retire** the design doc and completed implementation plan, in the same commit.

---

## Step 1 — Reconcile against the code

Read the design doc, then read the code. Every normative claim the doc makes gets one of four verdicts:

| Verdict | What it means | What to do |
| :--- | :--- | :--- |
| **Confirmed** | The code does this | Keep it, anchored to a symbol and package — never a line number (see *Altitude*) |
| **Drifted** | The code does something else | **The code wins.** Describe what's there. If the divergence looks deliberate, say why in one line; if it looks accidental, say so and flag it to the user — it might be a bug, not a doc update |
| **Not built** | Specified, absent | It does not appear in the system doc in present tense. Either it's dropped, or it's a roadmap item — say which, out loud, rather than letting it evaporate |
| **Undocumented** | Built, never designed | **Write it up.** Implementations grow things the design never mentioned — a cache, a retry, an env var, a migration path. The design doc is not the outline; the code is |

> [!IMPORTANT]
> The code is the source of truth for *what happens*. The design doc is the source of truth for *why* — for principles, invariants, and the traps that were found the hard way. Neither substitutes for the other, and this step is where they get reconciled rather than one silently winning.

Parameter values come out of the code, not out of the design's proposals — but they land in the **Current values** table, not scattered through the prose. A design doc that said "roughly a 5s timeout" against code that says `3 * time.Second` gives you two separate outputs: a table row with the real value and where it's set, and a body sentence about what the timeout is *for*, which is the half that stays true after the next retuning.

### Check adjacent reference docs

The new system doc is not the only reference that can become stale. Before changing prose, list existing reference docs whose stated scope, components, routes, states, or protocol vocabulary overlap the implementation. Read the claims that use absolutes or enumerate behavior — especially "only", "all", "never", and "always" — and update each claim that the implementation made false or incomplete.

- [ ] Search the reference tree for the component names, public routes or commands, state names, and protocol terms the implementation changed.
- [ ] Read every matching doc's scope and behavioral claims; do not treat a still-valid link as proof that its explanation remains valid.
- [ ] Update the affected docs in the landing commit, or explicitly record why the apparent overlap does not change their claims.

This is a bounded sweep, not an order to edit every consumer: inspect documents that make claims about the changed behavior, then leave unrelated references alone.

## Step 2 — Change the genre

### What survives

| Material | Fate |
| :--- | :--- |
| **Principles** (`P1.`, `P2.`) | **Keep verbatim, IDs intact** — sibling docs and code comments cite them |
| **Invariants, ownership, one-writer rules** | **Keep**, promoted to their own section — these are what a maintainer breaks by accident |
| **Data models, state machines, protocols, wire formats** | **Keep**, corrected to what the code actually emits |
| **Algorithms and their update rules** | **Keep** — the rule and what it trades off. Exact constants go to the Current values table, not here |
| **Failure modes** and what happens on each | **Keep** — a reference that covers only the happy path is half a doc |
| **Known traps and refuted objections** | **Keep** as `> [!WARNING]`, phrased forward: "Do not retry on a 409 — the writer is idempotent only within a WAL epoch," never "we considered retrying" |
| **The negative-space section** (Non-Goals, what this does not license) | **Keep** — still the cheapest scope defense in the tree |
| **Operational surface**: config keys, CLI flags, env vars, ports, paths | **Keep** — usually under-specified in the design, and the most-grepped part of a reference doc. Goes in the **Current values** table, and never as an exhaustive list that duplicates a schema or `--help` |

### What goes

| Material | Fate |
| :--- | :--- |
| Alternatives considered | **Cut** — except where an alternative is the obvious thing a maintainer would reach for. Then it's one `> [!WARNING]` line about why not, not a comparison table |
| Risk / mitigation table | **Cut** the risks the build resolved. A risk that is *still live* isn't history — move it into the section it threatens |
| Sequencing, "what I'd build in order" | **Cut.** It's built |
| The before-and-after framing: "what exists today", the gap, the diagnosis | **Cut** — it describes a world that no longer exists |
| Open Questions, leanings, answer blockquotes | **Cut** |
| Decision Ledger | **Cut**, minus the rows that pass the test below |
| Postscripts, `⚠ Retracted:` headings, status archaeology | **Cut** — resolve them. The claim is either true, in which case state it plainly in the body, or it's gone |

### The one test for keeping a ruling

> **Would a maintainer, reading only the normative text, undo this on purpose?**

If yes, the ruling keeps a one-line row in a short `## Why it's this way` appendix — **with its original `OQ-N` ID**, because those IDs are cited in code comments, tickets, and sibling docs, and after step 4 this doc is the only place they resolve. If no, it dies; git has it.

This appendix is not a history section. Every row is forward-facing: it exists to stop a future change, not to record a past conversation. If it grows past a dozen rows, the rulings weren't absorbed into the body properly.

### Tense, voice, orientation

- **Future → present.** "The broker will hold the request" becomes "the broker holds the request." Grep the draft for `will `, `would `, `proposed`, `planned`, `we should` — each hit is either a leftover or a thing that isn't built.
- **Third person about the system.** Design docs are first-person and opinionated by design ("my read"; "the thing that surprised me"). A reference doc is about the system, not about its author's reading of it. **The exception is principles**, which keep their rationale — a principle stripped to a bare rule reads as arbitrary and gets ignored.
- **Delete every sentence that was arguing.** A design doc earns its recommendation over several pages. Nothing is being recommended anymore. If a paragraph's job was to convince, cut it; if it explains a mechanism, keep it.
- **Orientation flips.** A design doc is read front to back, once, and is structured with the verdict up front. A reference doc is *landed in* — from a link, a grep hit, a search. So: headings are nouns someone would actually search for, sections are independently readable, and anything a section depends on is linked rather than assumed from earlier reading.
- **Don't inherit `§N` numbering.** Sections got cut and reordered; a stale number pointing at the wrong section is worse than no number. Prefer named sections and anchor links. If the doc is long enough to want numbers, number it fresh — and then step 3 has to fix every inbound `§N`.

### The header block

````markdown
---
status: current
verified: 2026-08-30
verified_commit: a1b2c3d
covers:
  - internal/broker/
  - internal/proto/broker.go
tags: [broker, jail, approvals]
---

# The boundary broker — approvals for what crosses the jail wall

**Status:** CURRENT as of 2026-08-30, verified against `a1b2c3d`.

The broker is a long-lived daemon on the host side of the jail boundary. It
holds requests that outlive the connection that made them, and routes the ones
needing a human to a notification channel — answering from cache when the same
request was approved inside the TTL.

| Component | Lives in |
| :--- | :--- |
| Request queue and TTL cache | `internal/broker` |
| Wire protocol | `internal/proto` (`BrokerFrame`, `ErrStaleEpoch`) |
| Human-approval channel | `internal/notify` |

**Reads with:** [`loophole-protocol.md`](loophole-protocol.md) (the wire format
this extends).

---
````

Five things, all load-bearing:

1. **The title names the thing.** Inverts the design-doc rule: no claims, no questions. Someone arriving from a grep hit needs to know what they've landed in.
2. **A verification date and a commit.** The most valuable line in the doc, because it tells the reader how far to trust it — and because it makes re-verification a bounded diff instead of a re-read. Never restate it without redoing step 1.

   `CURRENT` is the same word **`design-doc`** uses for an evergreen doc, where it deliberately takes **no date**. This is the exception and the reason is worth keeping straight: a lifecycle date on a living record claims nothing and expires on its own, while *this* date is a **verification stamp** — a claim about work someone actually did, bounded by the commit beside it. Do not let a vocabulary sweep strip it.
3. **`covers:` — the doc's declared perimeter.** The paths this doc claims to describe. This is what turns "is this doc stale?" from a judgement call into a command; see *Staying current*. Get it right: too narrow and real drift goes unnoticed, too broad and every unrelated commit cries wolf.
4. **What it is, in one paragraph, present tense.**
5. **Where the code lives** — component → *package*, with the key types named. The thing a design doc structurally cannot have (it predates the code) and the thing that makes a reference doc worth opening.

Keep the repo's other frontmatter conventions (`tags`, `summary`, `freshness_days` where it's used).

### The Current values table

One table, near the end, holding every perishable fact in the doc: constants, timeouts, ports, env vars, config keys, paths.

```markdown
## Current values

Verified at `a1b2c3d`. The prose above explains what each of these is for;
this table is the only place the numbers themselves are stated.

| Value | Setting | Defined in |
| :--- | :--- | :--- |
| Write timeout | 3s | `broker.Defaults` |
| Approval TTL | 15m | `broker.Defaults` |
| Control socket | `$XDG_RUNTIME_DIR/broker.sock` | `internal/broker/socket.go` |
```

It earns its place three ways: the body above it stays refactor-invariant, a reader knows exactly which lines are dated, and re-verification is one focused pass over one table rather than a hunt through prose.

## Step 3 — Re-point every inbound reference

The design doc is about to stop existing. Before it does:

```console
$ rg -n 'design/<topic>|<topic>\.md'    # path links
$ rg -n 'OQ-[A-Z]*[0-9]'                # ID citations — deliberately NOT scoped to docs/
$ rg -n '§[0-9]'  docs/                 # section references from siblings
```

Every hit gets rewritten to the new path **and a valid anchor**. A corrected path with a dead `#anchor` is the same broken link with extra steps.

> [!IMPORTANT]
> **The `OQ-` grep is unscoped on purpose: rule ids are cited from source comments, and no markdown tool can see them.** One sprint's compaction deleted 49 `oq` directives; 28 of those ids resolved to nowhere afterwards. A graduation in the same tree had to preserve seven ids in its [`## Why it's this way` appendix](#the-one-test-for-keeping-a-ruling) precisely *because* Go comments cited them — after step 4 that appendix is the only place they resolve at all. Run the grep before you decide which rulings survive step 2, not after.

Inbound references are links now, not bare prose, so the last step of this one is mechanical: run `uvx vantage-check` over the referring documents. A path that no longer exists is `link/missing-target`, and an anchor that survived the rewrite by accident is `link/dead-section-anchor`. Two caveats the grep still covers — an id cited in a code comment is invisible to the checker, and so is a doc you forgot to pass it.

If an inbound link points at material that got cut, the linking doc is asking for something the system doc no longer says. That's a finding, not a formatting problem: either the material was load-bearing and belongs back in, or the link was to deliberation and the *sentence* needs rewriting, not just the URL.

> [!NOTE]
> **A link from a design doc that is still in flight** gets re-pointed like any other. If that in-flight doc genuinely needed the deliberation — the alternatives, the ledger's reasoning — treat it as a signal: either this design wasn't as implemented as it looked, or that material was load-bearing and should have survived step 2.

### The roadmap is an inbound reference too

A grep scoped to `docs/` misses it — the roadmap sits at the repo root (`roadmap.md`, or the local equivalent), and its link to the design doc you are about to delete is the one most likely to be left dangling. It also needs more than a re-pointed URL, because this move is the moment the work stopped being planned. Finish it there, in the same commit; the states and the archiving rules are **`roadmap`**'s:

- **The shipped thread leaves the roadmap.** Done work does not linger as a checked box — the commit history is the record. A thread that stays behind reads as unfinished work forever.
- **Anything specified-but-absent becomes a roadmap item, by name.** Step 1 surfaces it and this is where it lands; a subsystem that quietly never got built must not evaporate with the design doc that proposed it.
- **A ruling that was retired rather than implemented** goes to the Retired Decisions doc the roadmap keeps, so nobody re-proposes it next quarter.
- **An `UNMEASURED:` claim becomes a roadmap item too.** Built-and-never-observed is a real state and it survives graduation intact; what it must not do is disappear into a reference doc that reads like every other one.

## Step 4 — Delete and commit

`git rm` the design doc and its completed `-plan` companion (if it exists), and add the system doc **in the same commit**, so the change reviews as one move and the trail is intact. Content rewriting usually defeats git's rename detection, so name the old paths in the commit body — that's what makes the origin greppable later.

```
docs(broker): boundary broker as-built reference

Replaces docs/design/boundary-broker.md and retires
docs/design/boundary-broker-plan.md; verified against a1b2c3d.
```

---

## Staying current

A system doc rots more dangerously than a design doc, because a design doc announces itself as a proposal and this one doesn't. *Altitude* above limits how much of the doc **can** rot. This section is about catching the rest.

The rule that governs the whole section: **a defense that depends on someone remembering to check the doc is not a defense.** Nothing about editing code naturally leads anyone to the doc, which is exactly why the default outcome is rot. Every mechanism below either removes the need to remember or makes the staleness visible without anyone looking for it.

### The perimeter diff — what makes re-verification cheap

This is what `covers:` and `verified_commit:` are *for*. Together they turn an unbounded question ("is any of this still true?") into a mechanical one:

```console
$ git diff --stat <verified_commit>..HEAD -- <covers paths>
```

- **Empty diff → the doc is provably current.** Re-stamp it for free. No reading required.
- **Non-empty → you have the exact list of what to re-check**, usually a handful of files rather than a subsystem.

Without the stamp, re-verifying a doc costs a full re-read, so nobody does it and the doc silently decays. With it, the common case costs one command. That asymmetry is the point.

[`references/doc-freshness.sh`](references/doc-freshness.sh) runs this across a whole reference tree and exits non-zero if anything is stale:

```console
$ sh references/doc-freshness.sh docs/reference
STALE  docs/reference/boundary-broker.md  (verified a1b2c3d, 4 files changed since)
  internal/broker/queue.go
  internal/broker/socket.go
ok     docs/reference/loophole-protocol.md
```

Wire it into CI or a pre-commit hook in any repo that has more than a couple of these. A warning fired *at the moment someone commits inside a documented perimeter* is worth more than every prose rule in this file — it catches the drift while the person who caused it still has the context to fix it.

### Point the code at the doc

A one-line comment at the entry point of every package that **owns** behavior documented by this reference:

```go
// Architecture and invariants: docs/reference/boundary-broker.md
```

This is mandatory when the package has a natural entry point and its behavior is inside `covers:`: without it, the person changing the owning code has no reason to find the reference. It is recommended, not required, for cross-cutting contributors that merely call, adapt, or consume the feature. Do not scatter pointers through unrelated callers just because a cross-cutting change touched them; add one where it makes the doc discoverable to the next person who can change the documented behavior.

The single highest-leverage thing on this page, because it inverts the direction of discovery. Docs rot because the person changing the code never sees them; this puts the pointer in the file they already have open.

### Repair at the point of use

Any agent or person who reads a system doc, uses it, and finds it wrong **fixes it before continuing.** Not a ticket, not a note — the fix, then the work. This is where the information is freshest and the cost is lowest: you have just done the investigation that proves the doc wrong, and that investigation is exactly what the correction needs. Walking away from it means someone pays for it again.

### Drift is a question, not just an edit

When the code and the doc disagree, decide which one is wrong before touching either:

- The doc describes an **implementation detail** that changed → the doc is wrong. Update it, and ask why that detail was in the doc at all — it probably failed the refactor test.
- The doc describes an **invariant or a principle** the code now violates → **the code may be the bug.** Say so rather than quietly editing the doc to match. A doc that gets silently rewritten to agree with whatever the code does is not a reference, it's a mirror, and it can never tell you anything you didn't already know.

That second case is the whole return on writing these docs. Preserve the ability to have it.

### Rewritten, never annotated

The sharp break from `design-doc`, where nothing is deleted and everything is annotated with dated postscripts. A system doc has no "how we got here" to preserve — it describes what is true now. Edit it into its new truth and let git hold the old one. A change big enough to need deliberation starts a **new design doc**, not a postscript here; when that design ships, it comes back through this skill and folds in.

### Re-verification is this skill's default mode

Invoked on an existing system doc with no other instruction: run the perimeter diff, redo step 1 over whatever it surfaced, correct the drift, re-stamp `verified` and `verified_commit`. The date is a claim about work you did — never advance it without doing the check.

## Style

Follow the **`vantage-docs`** style guide for core Markdown formatting (frontmatter, callouts, Mermaid, tables, anchors) and for its **Defined Terms** rules.

> [!IMPORTANT]
> **A symbol is an anchor, never a definition.** This skill has you point at packages and types constantly, which makes it the doc kind most likely to confuse *where a thing lives* with *what a word means*. "The **epoch** is `broker.Epoch`" defines nothing — it hands the reader the reverse-engineering job the doc existed to spare them. Define the term in prose, then anchor it. A system doc is often the last surviving definition of its own vocabulary, because the design doc that coined the term was deleted in step 4.

- **Every claim about behavior is anchored to a greppable symbol**, and the doc's authority rests on the verification stamp rather than on per-sentence citation.
- **Diagrams earn their place more than in a design doc.** A `stateDiagram-v2` of the real state machine or a `sequenceDiagram` of the real protocol is often the highest-value thing on the page, because the reader is trying to build a mental model, not evaluate a proposal.
- **Real names, real paths.** No "some sort of", no placeholder component names that lost an argument with the code. Real *numbers* live in the Current values table; the prose gets the magnitude and the reason.

## Quality checklist

**Accurate**

- [ ] Status line carries a verification date **and** a commit; step 1 was actually done
- [ ] Every claim about behavior was checked against the code
- [ ] The design doc was `BUILT` with zero live `💬` questions before this started — not held back waiting for a cue that was never coming
- [ ] An `UNMEASURED:` built claim came across with the doc rather than evaporating into a header that implies observation nobody made
- [ ] Nothing unbuilt is described in present tense; anything specified-but-absent was called out, not dropped silently
- [ ] Things the implementation added but the design never mentioned are written up

**Built to last**

- [ ] Every sentence passes the refactor test — no line numbers anywhere, symbols and packages instead of files and functions
- [ ] Every exact constant, port, env var and path is in the Current values table and nowhere else; the prose has the magnitude and the reason
- [ ] Nothing restates a schema, enum, proto, or `--help`; no exhaustive lists; no code blocks copied from code
- [ ] No performance numbers, scale figures, or "known issues"
- [ ] Sections run in half-life order: principles and invariants first, Current values last
- [ ] Every term of art is defined in prose or linked to a definition; no term is "defined" by pointing at a symbol
- [ ] Terms coined in the deleted design doc survived the move — into this doc, or into the glossary
- [ ] `covers:` names a perimeter that is neither too narrow to catch drift nor so broad it cries wolf; `sh references/doc-freshness.sh` passes
- [ ] Every owning package in `covers:` with a natural entry point carries a one-line comment pointing back at this doc; cross-cutting contributors were considered without adding noise to unrelated callers

**The right genre**

- [ ] A "where the code lives" table maps components to packages
- [ ] Principles kept their IDs and their rationale; invariants have their own section
- [ ] Known traps and refuted objections survive as forward-facing `> [!WARNING]`s, not as history
- [ ] The negative-space section survived
- [ ] Zero alternatives tables, zero sequencing, zero Open Questions, zero postscripts
- [ ] Rulings kept only where a maintainer would otherwise undo them, in a `## Why it's this way` appendix with original `OQ-N` IDs

**Landed**

- [ ] Every inbound reference in the repo re-points to the new path with a live anchor
- [ ] Existing reference docs with overlapping scope were checked for stale or incomplete behavioral claims, and updated where needed
- [ ] `rg -n 'OQ-[A-Z]*[0-9]'` was run over the **whole repo**, not just `docs/`, before deciding which rulings survive
- [ ] The roadmap's thread for this work is closed out, and everything specified-but-not-built is a roadmap item by name
- [ ] The design doc and completed `-plan` companion (if present) are deleted in the same commit, with their old paths named in the message
