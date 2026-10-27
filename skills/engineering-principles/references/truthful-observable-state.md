# Truthful observable state — the record says what happened

## Definition

The property of a state store or an audit log that it reports what actually occurred: every
transition that happened is recorded, every gap is visible as a gap, and no summary claims more
than the evidence under it.

## The Principle in One Move

Separate the four things a status can mean, and never let one impersonate another: **attempted**,
**succeeded**, **failed**, and **not observed**. Most dishonest systems are not lying — they
collapsed "not observed" into "fine", and nobody noticed until the absence mattered.

The mechanics are small: a missing measurement stays missing rather than defaulting to zero; a
check that did not run reports as skipped, never as passed; a failure is a failure even when it was
fast; and a rendered status must be traceable to the event that caused it.

## The Sharp Test

> **Can every number or badge on this surface be traced back to a specific recorded event — and
> does a gap in the record show up as a gap, rather than as a good result?**

Apply it by picking the most reassuring thing the surface displays and asking what would have to
happen for it to be wrong. If nothing could make it show a problem, it is decoration.

## What This Isn't

- **Not "the system is bug-free."** Bugs happen. Truthful state is the reason you find out, and it
  is why a post-mortem has evidence instead of a narrative.
- **Not infinite retention.** This governs semantic integrity, not storage policy. A cache may be
  thrown away; a claim about what happened may not be quietly improved.
- **Not exhaustive logging.** Volume is not honesty. A log nobody can query is a log nobody can
  contradict, which is a different failure and not a better one.
- **Not "always be pessimistic."** A truthful green is as valuable as a truthful red. The rule is
  about the correspondence between claim and evidence, not about the mood.

## Failure Mode

**Theatrical compliance.** An audit reports "all checks passed" because a check exited zero when
it could not reach the service, or because a test skipped and the summary counted skips as passes.
The failure is worse than having no audit: a green light that cannot go red consumes the attention
that would have caught the problem.

Its second shape is **optimistic caching** — a status surface that renders from a stored value
written when things were fine, so the surface keeps reporting health for as long as nothing
refreshes it. The tell is that the display has no path to the thing it describes.

## Generic Example

```go
// Violation: an unreachable service is reported as a healthy 200.
func CheckHealth() Status {
    resp, err := http.Get(url)
    if err != nil {
        return Status{Label: "UNKNOWN", Code: 200}   // false green
    }
    return Status{Label: resp.Status, Code: resp.StatusCode}
}

// Compliance: the three outcomes stay distinguishable.
func CheckHealth() Status {
    resp, err := http.Get(url)
    if err != nil {
        return Status{Label: "UNREACHABLE", Err: err, Healthy: false}
    }
    return Status{Label: resp.Status, Code: resp.StatusCode, Healthy: resp.StatusCode == 200}
}
```

The same distinction in a test suite: "0 tests run, 0 failures" is not a pass. The summary has to
distinguish an empty selection from a clean one, or a broken test runner reads as a green build.
