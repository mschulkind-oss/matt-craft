# Visibility with behavior — ship the window with the mechanism

## Definition

The rule that a new mechanism ships in the same change as the surface that lets an operator observe
it working, and observe it failing, without reading the source.

## The Principle in One Move

Treat the observation surface as part of the feature, not as follow-up work. When you add a
mechanism that can decide something an operator will later have to explain — a rate limiter, a
retry policy, a cache, a queue, a scheduler — add the thing that shows what it is doing *in the same
commit*: a counter, a status verb, a structured log line with a stable name, a metric.

The test of sufficiency is not "can I tell it ran". It is "when this misbehaves at 3 a.m., can
whoever is on call find out why without attaching a debugger".

## The Sharp Test

> **Can the operator watch this mechanism work, and watch it fail, from outside the program — in
> the change that introduces it?**

If the only answer is a stack trace after the fact, the feature is not finished.

## What This Isn't

- **Not a dashboard requirement.** A CLI verb that prints the current limits, a log line, a metric
  and a status field are all first-class. Mandating a browser UI for every service is one project's
  application of this rule, not the rule.
- **Not "log everything".** A surface nobody can interpret is noise. What is required is the state
  an operator would ask for first: what is the limit, what was dropped, what is queued, what did
  the last run decide.
- **Not deferred to a follow-up ticket.** Deferral is how the mechanism ends up permanently opaque;
  the ticket closes when the pressure is off.
- **Not unit-test output.** A passing test proves the code can run. Visibility proves an operator
  can see it running.

## Failure Mode

**Operator blindness.** A cache-eviction policy ships. Six weeks later a user reports stale data.
Nobody can answer whether the entry was evicted, never written, or written and overwritten, because
the only evidence is the absence of the value — and the absence is indistinguishable from all three
causes. The team's options are now guesswork or a reproduction that takes days, both of which cost
more than the metric would have.

Its quieter version: the mechanism *does* emit data, but under a name nobody knows and into a stream
nobody reads, which is a surface in form and not in function.

## Generic Example

```text
Pull request: add a token-bucket rate limiter to the outbound client.

  [x] pkg/ratelimit: the bucket, refilled on the injected clock.
  [x] /metrics: tokens_available{client}, tokens_dropped_total{client}
  [x] cli: `client ratelimit status --client=NAME` prints limit, tokens, and drops
  [x] log: one line per refusal, naming the client and the retry-after it computed
  [x] tests: burst, refill, zero-rate config

Without the middle three, the first incident question — "are we dropping requests, or are they
slow?" — has no answer that is not a guess.
```

The same rule applied to a migration: shipping the `--plan` output alongside `--apply` is not two
features. The plan view is how the operator sees the mechanism before it runs, and it is the reason
the run is explainable afterwards (see `pure-planning-separate-effects`).
