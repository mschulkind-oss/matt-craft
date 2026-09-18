---
name: brainstorming
description: Use when a user wants to explore, compare, or rank ideas before choosing a direction.
---

# Brainstorming

Maintain the document where a design space gets worked out over many sessions: the ideas, what each one costs, which ones survive, and what is still undecided.

**The failure mode this skill exists to prevent:** a pleasant, agreeable, ever-growing list of undifferentiated ideas that never converges on anything. Every entry sounds good, nothing is ranked, nothing is ruled out, no idea is checked against what is actually buildable, and the list is longer every session and no closer to a decision. That document is worse than no document, because it *looks* like progress.

A brainstorming doc's job is to make ideas **decidable**. Generating them is the easy half.

## When to use this skill

- "Let's brainstorm X" / "kick around some ideas for X" / "here's another idea —"
- Adding a concept to an existing catalog or roster of ideas
- Any substantive idea-development conversation that should outlive the chat
- Revisiting a stale idea doc to sharpen it

Not this skill:

- A settled design being specified → `design-doc`
- Filling gaps in domain knowledge → `research` (though a brainstorm often *sends* you there)
- A one-off lookup, or a decision the user has already made

## The loop

1. **Read the existing doc first.** Brainstorming is cumulative. Never answer a "what about X?" without knowing what the doc already says — you will re-derive, contradict, or duplicate an idea that is already there under another name.
2. **Engage properly.** Push on the idea, cost it, connect it to what exists, say what is wrong with it. See *The three obligations* below.
3. **Mirror it back into the doc.** Expand and synthesize, don't transcribe. A round that produces only chat output is a lost round.

## The three obligations

These are what separate brainstorming from listing. Every idea gets all three.

**1. Cost it against a real constraint.** Before an idea is elaborated, find the number that governs whether it can exist — the code budget, the hardware ceiling, the schedule, the headcount, the attention span of the user it is for — and cost the idea against it. If no such constraint is written down anywhere, **finding and documenting it is the highest-value thing you can do**, higher than any individual idea. An idea catalog with no cost column is a wish list.

> [!IMPORTANT]
> **A constraint that forces shipping is an asset, not an obstacle.** When an idea does not fit the budget, the reflex is to propose a bigger platform. Resist it. Usually the design is too big, not the platform too small — and removing the guardrail does not fix that, it just removes the thing that would have forced the design to get finished. Propose the larger platform only for a design that has been costed and genuinely does not fit, and say plainly what discipline is being given up.

**2. Name what it displaces.** A new idea that is strictly better than an existing one should say so, by name: *"this likely displaces #9 — same mechanism, but with the specific local detail, and it doesn't need the extra platform. Keeping both pays twice for one slot."* If it genuinely adds rather than replaces, say that too. Catalogs that only grow are catalogs nobody can act on.

**3. Say what won't work, and why.** Load-bearing. Name the thing that is unimplementable, self-contradictory, or magical thinking — including in ideas already in the doc, including ones you wrote yourself last session. Two patterns worth hunting specifically:

- **Mechanisms with no mechanism.** A rule the system has no way to enforce or even detect. Either give it a real implementation or cut it.
- **Two provisions that fight.** A rule that hard-blocks progress and a rule that promises progress is never blocked cannot both hold. Write down the conflict even if you cannot resolve it.

Deliver these as a plain sentence and move on — not an apology, not a lecture, not a hedge. Then keep building the rest.

## Anatomy of an entry

The shape that works, top to bottom. Not every entry needs every part, but the order is load-bearing — the reader must be able to stop after the first two lines and still know what the thing is.

1. **The hook** — one or two sentences, in the concrete terms of the actual situation, not genre abstractions.
2. **The turn** — the specific inversion or constraint that makes this *this idea* rather than a clone of its inspiration. If you cannot name the turn, the idea is not ready.
3. **The moving parts** — a table. Each component, what it does, what it serves or counters.
4. **Why it fits the hard structural requirement.** Every project has a requirement most candidate ideas fail. Show how this one satisfies it *structurally* — by construction, not by good intentions or by asking people to behave well.
5. **Failure handling.** What happens when it goes wrong. Strong designs make failure escalate into a new and more interesting problem rather than ending.
6. **Guardrails** — a `> [!IMPORTANT]` naming the way this idea goes bad and the line not to cross.
7. **The cost**, as a table against the governing constraint, with a total and a verdict.
8. **Displacement** — a `> [!NOTE]` naming what this makes redundant.

## Doc structure

- **An overview table up front**, one row per idea, with stable numbers. Columns should include whatever the ranking axis is — cost, fit, status. A reader must be able to see the whole space in one screen before any detail.
- **Stable IDs.** Ideas are referenced across sessions and sibling docs by number. Never renumber; retire an entry in place rather than compacting the list and shifting everything.
- **Detailed entries below**, in the overview's order.
- **An axioms or principles section** — the standing rules every idea is checked against, numbered so entries can cite them. These accumulate as the space gets understood; adding one is a real result.
- **An Open Threads section.** See below.
- **Scaling rule:** past ~a dozen entries, or when entries pass ~200 lines, split into **one file per idea plus an index** — the index keeps the overview table and one-line hooks, the files carry the full entries. The per-idea files are linked everywhere else by path; inbound anchor links must be rewritten at split time, not left dangling. A duplicate-content window (old monolith + new files) is fine mid-migration, but end the task with the monolith rewritten as the index.

## Exploratory mode: the browsable catalog

The loop above converges — it exists to make ideas decidable. Some catalogs have a second job: **being a library the user browses to get ideas, give ideas, and tweak ideas**, across many sessions, without any entry needing to be chosen. When that is the product:

- **Every entry carries Options & Variants** — two to four explicitly open design decisions, each a genuinely distinct, pickable direction with named tradeoffs, written so a human can answer them. Cosmetic variations don't count; an option with no downside isn't an option.
- **Every entry carries an Idea Parking Lot** — sparks not yet integrated, one line each. The parking lot is where half-formed ideas wait without polluting the design; it is the browse-and-steal shelf.
- **Hooks and tables up front; density over bloat.** A browsed doc is skimmed first and read second. If the hook doesn't tell you what the thing is in two sentences, the entry fails even if the body is brilliant.
- **Composition is a finding.** When ideas are categorized — by platform, type, audience — check the distribution. A category with zero entries is an open thread, not an accident. And user rules about composition ("no educational games on the TV target; math and reading on the other three") constrain the *catalog*, not just each entry; audit the mix, not only the members.
- **The tweak channel is part of the design.** Entries should say which decisions are whose — an open question marked "the user's call" stays open no matter how many passes polish around it.

## Open threads stay open

Unresolved things get written down as unresolved, in their own section, each with enough context to be picked up cold. What belongs there:

- Decisions not yet made, with the leaning and what it hinges on
- Known-broken items you found but could not fix
- Untested assumptions the whole plan rests on — flag these hardest; an unverified dependency that gates everything is the most valuable line in the doc
- Whole dimensions nobody has considered yet

The two things never to do: silently drop a thread because it was awkward, and write a thread up as settled when the user has not actually ruled on it. If a question genuinely needs the user's decision, use the Open Questions format from the **`design-doc`** skill (💬 status emoji, stable ID, stakes, `_Leaning:_`, empty `**Answer:**` blockquote, and the `oq` directive that makes it answerable in one click).

## Reference works

Referencing existing work is encouraged and the point is never to clone it. For each reference, extract:

- **The mechanism** — what it actually does, mechanically, not what it feels like
- **Why it is good** — the specific problem that mechanism solves
- **What is portable** — which part survives translation to this project's constraints, and which part depends on resources this project does not have

Name the source explicitly; the lineage is useful to a later reader deciding whether to go play the thing. "*X* does this, and the reason it works is Y, and Y survives here because Z" is worth ten paragraphs of original-sounding invention.

Where the reference is a product people use, prefer evidence about *what its audience actually responds to* over critical reception.

## Voice

- **Opinionated and ranked.** End with a recommendation — "if you want my pick" — not a balanced survey. A comparison table with no verdict pushes the decision back onto the reader.
- **Specific beats general, always.** The concrete detail from the actual situation — the real incident, the real name, the real number, the thing actually said out loud — is what makes an idea good rather than plausible. Generic content is the tell of a brainstorm that has not touched reality.
- **Real numbers, not adjectives.** "~4,400 of 8,192" beats "should fit comfortably."
- **No false balance and no hedging filler.** If one option is clearly better, say so.
- **Commit to a view.** The doc should assert, not present. "This is the strongest of the three, because X" — not "each has merits." A brainstorm with no viewpoint is a catalog, and worse for it.
- **Untangle messy input without fuss.** Dictated or duplicated input, half-finished thoughts, three ideas in one sentence — sort it out silently and get on with the substance. Do not make the user feel bad about how the input arrived.

## How it evolves

Living document, revisited often. Each pass should leave it **better, not just longer**:

- **Sharpen, don't append.** New understanding rewrites the entry it affects. Endless appending is how these docs die.
- **Re-cost when the constraints change.** A discovered budget means every existing entry needs a number it did not have before. Do that pass; do not leave half the catalog uncosted.
- **Prune.** Displaced and dead ideas get marked as such in place, with the reason. Retire them, don't delete them — the reason an idea failed stops it coming back.
- **Promote what is ready.** When an idea is chosen and is going to be built, it graduates to a design doc (`design-doc`) and the brainstorm entry becomes a stub pointing at it — **and it appears on the roadmap** in the same commit, wherever the project keeps one (`roadmap.md` at the root, or the local equivalent; see **`roadmap`**). A promotion invisible from the roadmap is an idea that got a document and no queue position. The rule runs both ways: an idea still being costed here does *not* belong on the roadmap, and an open thread waiting on the user's ruling belongs there as a `💬` item rather than at the bottom of this file where nobody is looking for it.

## Fan-out production

When the ask is volume — "flesh out the whole catalog," five per category — parallel agents earn their cost, and their failure modes are predictable. The recipe that works:

1. **Template first, agents second.** Write the full entry anatomy (every section, in order, with the voice exemplar named) *before* launching anything. Fast models fill templates well and invent structure badly.
2. **One owner per file.** Split by category/slot with explicit file lists. Two agents with overlapping write sets is the #1 way to lose work. Files nobody owns are the coordinator's to carry forward.
3. **Fast models draft, capable models enrich, commit between.** The draft wave lands as a checkpoint commit; the enrichment wave edits in place. This preserves the "before" state, makes the enrichment diff reviewable, and means an enrichment failure never loses the drafts.
4. **Forbid sub-agent spawning in the briefs.** Research agents that fan out on their own initiative multiply concurrent streams and hit rate limits; the kills lose everything. If you need more parallelism, you add it deliberately, staggered.
5. **Steer mid-flight when the constraints change.** A queued message to a running agent beats silently redoing its output afterward — but follow the original channel: refine the constraint, don't reverse it (a mid-flight reversal produces a doc at war with itself).
6. **The coordinator does the integration:** inbound links, the index, count claims ("twelve concepts"), cross-links between siblings, and the commit split so each wave is its own readable change.

Follow the **`vantage-docs`** style guide for Markdown conventions (frontmatter, callouts, Mermaid, tables) and for its **Defined Terms** rules.

Brainstorms invent vocabulary faster than any other doc — naming the turn is half of having the idea. Two consequences. A coined name is marked as coined and given its one-line meaning *in the entry that invents it*, because an idea whose central term is undefined cannot be costed or displaced by anything, which is the whole job. And a name that sounds evocative but that you cannot define is a tell — the idea underneath it is usually not there yet.

## Quality checklist

- [ ] Overview table up front; whole space visible before any detail
- [ ] Stable IDs that have never been renumbered
- [ ] Every entry costed against the governing constraint, with a number
- [ ] The governing constraint is itself written down somewhere
- [ ] Every entry names its turn — what makes it not a clone
- [ ] New entries say what they displace, or say explicitly that they add
- [ ] At least one thing in the doc says what will *not* work, and why
- [ ] Open Threads section exists and includes the untested assumptions
- [ ] Promoted ideas and user-blocking threads are on the roadmap; nothing still being costed here is
- [ ] References name the mechanism and what is portable, not just the title
- [ ] A recommendation exists — the doc picks something
- [ ] *Exploratory mode:* every entry has pickable Options & Variants and a living parking lot; the category mix is audited, not just the entries
- [ ] *After a fan-out:* the index rewritten, count claims updated, inbound links off the old anchors, sibling designs cross-linked
