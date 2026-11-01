---
name: doc-constellation
description: Use when a shipped or graduated subsystem is too large for a single system-doc (> 250 lines or ≥ 3 coupled mechanisms) and needs a coordinated 4–8 file reference directory in docs/reference/<topic>/ so a designer or model can reason about the architecture without opening source code.
---

# Doc Constellations: Multi-File Reference Architecture

A **constellation** is a bounded set of small reference documents (4–8 files in `docs/reference/<topic>/`) that together describe an implemented, verified subsystem at mechanism altitude: what the parts are, how state advances, what each mechanism models, what levers exist, and what is explicitly excluded. Its goal is to let a designer or model hold the whole machine in head and reason about changes **without opening source code**.

Use `doc-constellation` when graduating or documenting a verified system that exceeds a single **`system-doc`**.
- **If the system is still being designed or has diverged from owner intent:** Run **`architecture-realignment`** and **`design-doc`** first. Never use `doc-constellation` to rubber-stamp diverged code as "the reference architecture."
- **If the document shelf is cluttered with duplicates:** Run **`doc-janitor`** first.
- **While drafting and reviewing prose:** Apply **`design-doc`**'s review iteration rules (*First-Time State Principle*, *Vantage Thread Protocol*, and *Topological Forward-Telling Narrative*) and **`system-doc`**'s altitude rules so every page reads fresh, moves strictly forward, and carries zero process scarring.

## 1. When to use a constellation (and how to size it)

| Scope of the verified system | Right artifact |
| :--- | :--- |
| Still being decided, recovering from divergence, or has open questions (`OQ-…`) | `design-doc` (`docs/design/`) via `design-doc` or `architecture-realignment` |
| Verified system with ≤ 2 coupled mechanisms, fitting comfortably in ≤ 250 lines | One `system-doc` (`docs/reference/<topic>.md`) |
| Verified system with ≥ 3 coupled mechanisms, distinct state, equations, or levers (> 250 lines if combined) | **A `doc-constellation` (`docs/reference/<topic>/`)** |

### Sizing rules

- **4 to 8 documents in `docs/reference/<topic>/`, 100 to 220 lines each**, plus one optional companion open-questions document outside the reference tree when live tuning or research questions exist (`docs/plans/<topic>-open-questions.md`).
- **Fewer than 4 files** means one file is a monolith hiding multiple mechanisms; either use a single `system-doc` or split the monolith by reader question.
- **More than 8 files** means you split by source file or struct rather than by reader question, forcing the reader to keep six tabs open to follow one mechanism.

---

## 2. Six-Inventory Code Reconnaissance

Before freezing the file split, verify the implemented subsystem across six structured inventories:

1. **Public and host surface:** Every exported type, method, event, error, and constant, separating *inputs/setters* (levers) from *getters/diagnostics* (observables).
2. **Module and type doc comments:** Architectural invariants and explicitly excluded mechanisms recorded in code comments.
3. **Authored tables and static laws:** Every constant array, lookup table, scaling formula, piecewise anchor table, and preset vector, with **exact math and anchor coordinates** verified by arithmetic.
4. **The execution spine:** The single function or loop that advances state for one unit of work (one tick, one sample, one frame, one request):
   - Exact execution order.
   - What mutates state vs. what only observes state.
   - Exact branch conditions where work is skipped (idle/sleep/bypass) and **which exact branch flips that condition back**.
5. **Experimentation seams and feature flags:** Every testing, debug, or tuning entry point, its **exact validation guard** (e.g., `0.02..=0.50`), whether it resets state or applies live, and any default differences between test and production builds.
6. **Persistence, wrappers, and presentation layers:** Saved/loaded state formats, version migrations, and what outer wrappers add to the core (smoothing, clamping, framing, preset overrides).

### Reconciling Recon Against Predecessor Docs

| Recon Verdict | Action |
| :--- | :--- |
| **Confirmed** | Keep claim, anchored to package and symbol |
| **Harmless implementation drift** | Update the reference table and fix or retire the predecessor doc in the same commit |
| **Diverged from owner ruling / Suspected bug** | **Stop reference authoring for that mechanism.** Escalate to the owner or route into `architecture-realignment`. Never document a bug or agent divergence as a normative reference invariant. |
| **Unbuilt** | Exclude from present-tense reference prose; route to `docs/plans/<topic>-open-questions.md` or the roadmap |

---

## 3. Freeze the Constellation Spine (Split by Reader Question)

Split child documents by the questions a designer asks, never by source directory layout:

| Archetype file | The single question it answers | Owns `Current values` for |
| :--- | :--- | :--- |
| `README.md` | What is this subsystem, how do the pieces connect in one diagram, what do the shared terms mean, and which file answers which question? | None (links to children) |
| `signal-path.md` (or `lifecycle.md`) | What happens, in what exact order, between intake and output, and what does the loop guarantee? | Global capacities, rates, step counts, seeds |
| `1..N` mechanism docs (noun names: `scheduler.md`, `cache.md`) | What does this part model or enforce, by what equation/algorithm, what does it *not* do, and what levers touch it? | That mechanism's constants, formulas, and anchor tables |
| `observations.md` (or `telemetry.md`) | How is internal state turned into outputs or diagnostics, what are the units/headroom, and what can an output *not* tell you? | Output gains, observer weights, diagnostic scales |
| `control-surface.md` | What are all production parameters (with ranges **and defaults**), presets, state formats, and testing seams (with exact bounds)? | Parameter counts, defaults, preset vectors, state headers |
| `docs/plans/<topic>-open-questions.md` *(outside `reference/`)* | What tuning or research questions remain open, and what experiment closes each item? | Measured experimental deltas still in flight |

### Five authoring rules that prevent internal rot

1. **Freeze `README.md` first, and cap composition passes at two files:** Author and verify `README.md` (shared vocabulary, spine diagram, file map, and `verified_commit`) before drafting child mechanism docs. When delegating to a design/writing seat, cap each pass at **at most 2 files (100–220 lines each)** so outputs never truncate.
2. **Disjoint constant ownership:** Every tunable constant or formula belongs to **exactly one** document's `Current values` table. Other documents link to that owner instead of repeating the digits.
3. **The Two-Tier Number Rule:**
   - **Tier 1 — Structural counts and orders of magnitude** (e.g., "64 channels", "2 substeps") may appear in body prose when needed to explain *why* a mechanism behaves as it does, provided the backing constant is also listed in `Current values`.
   - **Tier 2 — Tunable constants, coefficients, piecewise tables, and validation ranges** appear **only** in `Current values` (or `control-surface.md` tables) with package and symbol citations. Body prose states the functional shape and reason, never a second copy of the digits.
   - **Define every variable in a formula** in the same table where the formula appears.
4. **Topological vocabulary before prose (`design-doc` / `vantage-docs`):** Define every domain term in one plain sentence before its first use, state its exclusion ("Not X, which does Y"), and never define a concept solely by naming a code symbol.
5. **Quarantine date-shaped truth:** Never write *"in the current pass"*, *"recently changed"*, or *"awaiting review"* inside `docs/reference/`. Reference describes what is verified at `verified_commit`; live evaluations live in `docs/plans/<topic>-open-questions.md`.

---

## 4. Standard Reference Page Template

Order every child document in `docs/reference/<topic>/` by half-life (immortal invariants at the top, perishable numbers quarantined at the bottom), using the same frontmatter vocabulary as **`system-doc`**:

```markdown
---
title: "<Subsystem>: <what this part is>"
status: accepted
stage: CURRENT
verified: YYYY-MM-DD
verified_commit: <short-sha>
covers:
  - <exact repo-relative paths whose edits can stale this file>
tags: [...]
summary: "<one sentence>"
---

# <Subsystem>: <what this part is>

**Status:** Verified YYYY-MM-DD against `<short-sha>`.

One paragraph, present tense: what this part is, what it physically or logically does, and why it is shaped this way.

## <Mechanism sections — noun headings in forward causal order>

## What <this part> is not
## What a designer can change here
## Current values
## Where the code lives
```

If any factual detail could not be verified from the code recon, mark it explicitly:
`UNVERIFIED: <claim> — not established by <inventory>, checked at <commit>`

---

## 5. Wire, Verify, and Land

1. **Run the editorial scrub pass (`design-doc`):** Verify strict topological forward narrative, zero process scarring, and clean formatting across all 4–8 files.
2. **Verify link and anchor integrity:** Run `uvx vantage-check docs/reference/<topic>/` (and any updated companion docs) to confirm every cross-file link and `[§N](#anchor)` reference resolves cleanly.
3. **Retire superseded docs safely (`doc-janitor`):** Run `doc-janitor`'s section-by-section absorption check before archiving or deleting the predecessor `design-doc` or old reference files, rewriting all inbound links in the same commit.
4. **Add code back-pointers:** At the entry point of each package listed in `covers:`, add a one-line comment pointing to the constellation root (`// Architecture and invariants: docs/reference/<topic>/README.md`).

---

## 6. How to Brief a Designer Using the Constellation

A finished constellation lets you brief an expensive design seat in **500–800 lines of Markdown (< 10k tokens)** without reading source code:

1. **Assemble the minimal context packet:**
   - Always include `README.md`, `control-surface.md`, and (if present) `docs/plans/<topic>-open-questions.md`.
   - Include `observations.md` when the question touches telemetry or outputs.
   - Include **only** the 1–2 mechanism files touched by the problem.
2. **State the briefing contract:**
   - The constellation is verified against `<verified_commit>` at mechanism altitude.
   - Require the design response to name which control in `control-surface.md` tests the change, which invariants in `What ... is not` it preserves, and which observable in `observations.md` would falsify it.

---

## 7. Quality Checklist

- [ ] **4–8 files in `docs/reference/<topic>/`, 100–220 lines each**, split by reader question ([§1](#1-when-to-use-a-constellation-and-how-to-size-it), [§3](#3-freeze-the-constellation-spine-split-by-reader-question)).
- [ ] **`README.md` frozen first** with shared vocabulary, system diagram, file map, and `verified_commit` ([§3](#3-freeze-the-constellation-spine-split-by-reader-question)).
- [ ] **Six code recon inventories verified:** Every sleep/bypass branch, state mutation, experimentation seam guard, and preset default checked against code ([§2](#2-six-inventory-code-reconnaissance)).
- [ ] **No rubber-stamped divergence:** Any suspected code bug or violation of owner rulings was escalated rather than documented as invariant truth ([§2](#2-six-inventory-code-reconnaissance)).
- [ ] **Disjoint `Current values` tables & Two-Tier Number Rule:** Every constant owned by one file; Tier 2 digits quarantined in tables; all formula variables defined ([§3](#3-freeze-the-constellation-spine-split-by-reader-question)).
- [ ] **First-time state & topological forward narrative (`design-doc`):** Zero process scarring, inputs defined before consumers, and zero date-shaped prose in `docs/reference/` ([§3](#3-freeze-the-constellation-spine-split-by-reader-question), [§5](#5-wire-verify-and-land)).
- [ ] **Complete `covers:` perimeters and code back-pointers** added ([§4](#4-standard-reference-page-template), [§5](#5-wire-verify-and-land)).
- [ ] **Predecessor docs safely retired via `doc-janitor`** with absorption checks and inbound link rewrites, and `uvx vantage-check` passes clean ([§5](#5-wire-verify-and-land)).
- [ ] **Cold-Reader Design Test passes:** A designer can specify a concrete change or experiment using only the constellation pages without opening source code ([§6](#6-how-to-brief-a-designer-using-the-constellation)).
