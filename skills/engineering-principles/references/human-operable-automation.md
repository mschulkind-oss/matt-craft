# Human-operable automation — one interface, two kinds of operator

## Definition

The rule that an automated system is operated, inspected and repaired through the same supported
interfaces a human uses, with the automation adapting to those interfaces rather than growing a
private path of its own.

## The Principle in One Move

For every operation the automation performs, ask what a human would type to do it. If the answer
is "they can't", the automation is not finished — it is operating a channel that no one can
inspect, reproduce or repair. Build the interface first, then have the agent use it.

The practical form is unglamorous: a CLI verb with a stable exit code, an API endpoint, a status
file in a documented format. What makes it compliant is not that it is pretty but that the same
call serves both callers, so a bug found by an agent is reproducible by a person, and a permission
a person holds is not silently exceeded by a script.

## The Sharp Test

> **Delete the agent. Can a human still perform this exact operation, and inspect the result,
> through a documented interface?**

If the answer requires reading source code, opening a database, or knowing which internal function
the agent calls, the automation has a dark path. That is the defect, not the inconvenience.

## What This Isn't

- **Not "build a GUI."** A POSIX command, a clean HTTP endpoint or a structured log is a
  first-class human interface. A dashboard that no human can operate from a terminal is not
  required, and mandating one for every project is the application, not the principle.
- **Not anti-automation.** Agents should do the work at full speed. The rule is about *which*
  interface they use, not how often.
- **Not "humans must approve everything."** Autonomy is a separate question (see
  `scoped-autonomy`). This card is about the channel, not the authority.
- **Not a ban on internal code paths.** Code may call code. The rule bites where an operation
  crosses a boundary a human might need to cross — state that persists, an effect on the outside
  world, a decision someone will later have to explain.

## Failure Mode

**Dark state.** The automation keeps its progress in a sidecar file, a hidden database or a magic
token that only it understands. It works, for months. Then it half-fails, and the operator
discovering it has no verb to inspect the state, no way to resume, and no way to reproduce the
condition — so the recovery is manual surgery on a file whose schema exists only in the agent's
head. The work is not lost because it was hard; it is lost because it was unobservable.

## Generic Example

```text
Violation:
  The agent writes its checkpoint to .project/agent-state.bin and resumes by reading it.
  A human can see that the file exists and nothing else.

Compliance:
  The agent runs:  project task checkpoint --id T-102 --state validated
  A human runs:    project task checkpoint --id T-102          (inspect)
                   project task checkpoint --id T-102 --clear   (repair)
  Same verb, same exit codes, same output format — the agent is simply one more caller.
```

The same test applied to a migration: a script that mutates the database directly has a dark path
even if it is idempotent, because the operator cannot see what it would do before it does it. A
`--plan` verb that prints the intended changes, and an `--apply` that executes exactly that plan,
gives both callers one interface (see `pure-planning-separate-effects`).
