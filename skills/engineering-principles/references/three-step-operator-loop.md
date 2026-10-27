# Three-step operator loop — correct before drift compounds

## Definition

The control loop that keeps automated work aimed at what the operator actually wants: see what the
work is doing, hold the goal it should be doing it for, and correct the difference while the
correction is still cheap.

## The Principle in One Move

Make the loop fast enough that a wrong direction is caught while it is still one decision, not a
body of work. That means three things, all of them the operator's side of the interface:

- **See.** The work states its current direction in a form readable at a glance — what it is about
  to do and why, not a transcript of what it has typed.
- **Compare.** The operator holds the goal and can say, in one sentence, where the direction
  diverges from it.
- **Correct.** The nudge is a steering vector, not a rewrite: "keep the config in TOML", "use the
  existing parser", "that error text is user-facing".

Frequency is the whole point. A correction after two hours of unattended work is not a correction,
it is a restart.

## The Sharp Test

> **Is the operator's inspection-and-correction cycle shorter than the time it takes the work to
> commit to a direction?**

If the loop period is longer than the drift period, the loop does not exist — you are reviewing
finished work and calling it steering.

## What This Isn't

- **Not micromanagement.** A nudge supplies the vector; it does not dictate keystrokes. An operator
  reading every line is a bottleneck wearing the loop's clothes.
- **Not code review.** Review happens after the work is shaped. The loop runs while the work is
  still being shaped, which is why it can prevent a rewrite rather than request one.
- **Not a claim that more turns are better.** Ten turns spent re-explaining a goal that could have
  been stated once is a failure of the loop, not evidence of it.
- **Not only for agents.** The same loop governs a human pair, a contractor, or a long-running
  process whose state someone has to check.

## Failure Mode

**Compound drift.** Work runs unattended against an ambiguous goal, resolves the ambiguity the
plausible way, and builds on that resolution. Two hours later the architecture is coherent,
tested, and wrong — and the correction now costs the whole body of work, so the operator discards
it and the effort is a total loss. The loop's absence does not look like a mistake at any point
along the way; every individual step was reasonable.

## Generic Example

```text
Turn 1  Work states: "I'll put the retry policy in the config file and read it at startup."
Nudge:  "Config is TOML, use the existing loader — don't add a new parser."

Turn 2  Work: writes the failing test for the retry policy, loading from TOML.
Nudge:  "Include the zero-retries case in the table."

Turn 3  Work: implements it; the table now covers zero, one and many. Tests green.

Result: two nudges, no discarded code, and the operator never read a line of implementation.
```

Contrast the batch version of the same work: a 2,000-line pull request, reviewed once, in which the
config decision and the zero-retries case are two comments among forty — and the rework is measured
in days.

> [!NOTE]
> **An open edge this card does not close.** The source doctrine behind this loop forbids
> proceeding on a guess, and also hints that a parked question may proceed on a default once the
> operator stays silent. Those two statements contradict each other. The safe reading ships here —
> silence parks the work, never authorizes it — and the contradiction is recorded rather than
> resolved, because resolving it would grant a permission this library has no authority to grant.
