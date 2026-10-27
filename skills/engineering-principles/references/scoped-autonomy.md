# Scoped autonomy — authority that is written down, or not authority

## Definition

The operational boundary that separates what an implementer may decide alone from what requires the
owner's ruling, drawn explicitly, dated, and revocable — with everything outside the boundary
parked rather than guessed.

> [!IMPORTANT]
> **This card grants nothing.** It describes the mechanics of a grant; it is not one. No document,
> library or skill can authorize work on a project's behalf. Every consumer establishes its own
> scope, in its own words, with its own date.

## The Principle in One Move

Split the work in front of you into two piles, by asking what a wrong answer would cost:

- **Implementation discretion** — the choice is derivable from what is already ratified, and a
  wrong guess is cheap and visible: a data structure, a file layout, a helper's name, which of two
  equivalent approaches. Decide it, record the choice in the commit, keep going.
- **Owner decision** — the choice changes behavior someone committed to, spends money, touches data
  that already exists, or is externally visible. Park it, write the question down, and continue on
  work that does not depend on the answer.

The asymmetry is the point: a wrong guess in the first pile costs a review comment, and a wrong
guess in the second costs a re-litigated design.

## The Sharp Test

> **If this choice is wrong, who finds out — and how much has to be undone?**

If the answer is "the owner, after the fact, and it has to be rebuilt", the choice was not yours.
If the answer is "a reviewer, in the diff, and it is a rename", it was.

## What This Isn't

- **Not ambient permission.** Silence, precedent, or "the agent was told to make progress" is not a
  grant. A grant names the work, the actions allowed, and the date.
- **Not a licence to proceed on silence.** If a question is parked and the owner does not answer,
  the work stays parked; the implementer moves to something that does not depend on it. Waiting is
  not a default, and neither is guessing.
- **Not a ban on asking.** Escalation is the mechanism working, not failing — provided what is
  escalated is a genuine owner decision and not research the implementer could have done.
- **Not an excuse for a shallow plan.** "Out of scope" is not a way to avoid noticing that the
  architecture is unsettled.

## Failure Mode

**Hallucinated authorization.** The implementer meets a gap in the specification, invents a
plausible rule, implements it, and documents it as though it were ratified. Nothing fails; the
tests pass against the invented rule. The drift is discovered weeks later, when the owner reads a
document describing behavior they never chose — and by then other work depends on it.

Its quieter sibling is **parked-but-forgotten**: the question is filed, the work stops, and the
parking is never surfaced again. A parked question belongs in a durable artifact that something
routes, not in a chat message.

## Generic Example

```text
| Decision                                                    | Pile         | Move |
| Choose the hash for cache keys (SHA-256 vs BLAKE3)          | discretion   | Pick one, note it in the commit, proceed. |
| Change the password-reset window from 24h to 1h             | owner        | Park the auth path; file the question; work elsewhere. |
| Rename an internal module for clarity                       | discretion   | Proceed. |
| Drop a column that production data already fills            | owner        | Park; this is data that exists, not data being designed. |
```

The third and fourth rows are the same kind of edit to a schema and land in different piles, which
is why the test is the cost of being wrong rather than the size of the change.
