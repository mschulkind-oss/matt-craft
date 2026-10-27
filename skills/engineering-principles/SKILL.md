---
name: engineering-principles
description: Use when specifying a system's structure, its failure handling, its verification, or how an operator will observe and correct it — the engineering disciplines that hold regardless of language, framework, or project.
---

# Engineering principles

A card library of engineering doctrine: how to fix a recurring failure, how to write a definition
that survives substitution, and how to build systems whose state, tests, and observation surfaces
tell the truth. The cards are the substance; this file is the index and the routing rule.

## How to use this

**Load the card you need, not the library.** Each card is one page: a definition, the operational
move, a sharp test you can apply to an artifact in front of you, the near-misses it is *not*, the
failure it prevents, and one generic example. The sharp test is the working part — quote it into a
review, or apply it to the thing you are about to ship.

**Cite the card, don't restate it.** When a rule belongs in another skill's checklist, that skill
carries the sharp test in short form and names the card. Two copies of a rule drift; one copy and a
citation do not.

**Some principles are already specified elsewhere**, and deliberately get no card here — see
*Specified by sibling skills* below. Adding a card for those would create the second copy this
library exists to prevent.

## Tier 0 — the governing rule

| Card | The rule in one line |
| :--- | :--- |
| [`principle-zero`](references/principle-zero.md) | When a rule is repeatedly violated, the fix is never "remember next time" — it is a structural change that makes the violation impossible, or visible at the moment it happens. |

## Tier 1 — foundational method

| Card | The rule in one line |
| :--- | :--- |
| [`lawyer-mode`](references/lawyer-mode.md) | A defined term must survive substitution: replace it with its definition and the text still means the same thing. A concept must survive deletion: remove it and something named breaks. |

## Tier 2 — engineering and verification

| Card | The rule in one line |
| :--- | :--- |
| [`human-operable-automation`](references/human-operable-automation.md) | Automation uses the same supported interfaces a human does. There is no agent-only side channel. |
| [`truthful-observable-state`](references/truthful-observable-state.md) | State and audits report what happened. Missing data is not zero, and a check that did not run is not a pass. |
| [`visibility-with-behavior`](references/visibility-with-behavior.md) | A mechanism ships in the same change as the surface that lets an operator watch it work and watch it fail. |
| [`tests-use-consumer-interfaces`](references/tests-use-consumer-interfaces.md) | Tests drive the boundary real callers use, not a private seam invented for the test. |
| [`pure-planning-separate-effects`](references/pure-planning-separate-effects.md) | Compute an inspectable plan; execute it at one explicit effectful boundary. |
| [`scoped-autonomy`](references/scoped-autonomy.md) | Authority is explicit, dated, and bounded. An unanswered question parks the work; silence is never a default. |

## Tier 3 — feedback and economics

| Card | The rule in one line |
| :--- | :--- |
| [`three-step-operator-loop`](references/three-step-operator-loop.md) | See what the agent is doing, hold the goal, correct early enough that drift never compounds. |
| [`practices-now-mandatory`](references/practices-now-mandatory.md) | Authoring labor is now cheap enough that strict contracts and invariant tests are affordable — and agent drift makes mechanical verification more necessary, not less. |

## Specified by sibling skills — pointers, not cards

These four are already fully specified in the tree. Read them where they live.

| Principle | Where it is specified |
| :--- | :--- |
| Human-reviewable design | `design-doc` — *Altitude*, *Completeness*, *The holes, by name*, *The gap test* |
| Explain why the operator is needed | `design-doc` — *Phase 1: Open Questions* (what is a ruling, and what is work you owe) |
| Decisions belong in durable documents | `design-doc` — *Phase 2* and the *Decision Ledger*; `roadmap` for ordering |
| Concepts earn their place | `vantage-docs`, *Defined Terms* (the delete test also appears in `lawyer-mode`) |

## Deferred — named, not yet written

The roster is complete and visible; these rows are unlinked until their cards land. They are
listed so that "is this covered?" has an answer that is not a guess.

| Deferred principle | Covers |
| :--- | :--- |
| A model includes its rules | Contracts carry their invariants and validation, not just their fields; derived representations are checked against the source. |
| Opt-in, composable capability | Zero ambient capability; permissions and tools composed per consumer. |
| Intent and executable scenarios stay connected | A scenario description and its executable setup are derived from one another, so neither drifts. |
| Runtime evidence is human-reviewable | Traces are inspectable and causally linked; a narrative never invents a fact. |
| Missing measurements are not zero | Absent data stays absent; failed work is not throughput. |
| Tests own their effects | A test that spawns processes or writes state allocates, isolates, and cleans up its own. |
| Validate before mutation | Preconditions are checked before the first irreversible effect. |
| Incremental complete demonstrations | Grow capability in working, observable slices that keep earlier verification. |
| Proportional justification | A non-standard mechanism or an exception to an invariant carries a written warrant: what it prevents, what it costs, what it retains. |
| Scale-invariant loops | The same observe–compare–correct loop applies at a turn, a task, a feature, and a roadmap. |
