# Principle Zero — procedures over promises

## Definition

When a rule is repeatedly violated, the fix is never "remember next time": it is a change to the
system that makes the violation impossible, or that makes it visible at the exact moment it
happens.

## The Principle in One Move

Remove the decision point. Take the failure you have now seen twice, and walk a strict ladder —
stop at the first rung that is achievable:

1. **Make it impossible.** The invalid state cannot be produced: the type will not hold it, the
   schema rejects it, the permission is denied, the hook refuses the commit, the command exits
   before writing. No one has to notice anything.
2. **Make it visible where it happens.** If it cannot be prevented, it is surfaced at the moment
   of the mistake, in the path of the person making it — not in a log nobody opens, not in a
   document read last week.
3. **Document the procedure.** Prose is the weakest rung. It is what you accept when the first two
   are genuinely out of reach, and it is where a fix goes to die quietly.

## The Sharp Test

> **Does this fix remove a decision someone has to remember, or does it add one?**

Apply it to the fix, not the failure. A second checklist, a louder reminder, a paragraph in the
style guide, "be more careful" — each of those adds a decision point and fails the test, whatever
it does to the tone of the document.

## What This Isn't

- **Not "never write documentation."** Prose procedures are legitimate; they are just the last
  rung, and they are honest only while the structural fix is still being designed. Documentation
  that explains *why* is not the same thing as documentation that asks someone to remember *when*.
- **Not a demand for root-cause analysis on every bug.** A novel defect is a bug. Principle Zero
  is about the *second* occurrence: the failure that has now proven it can happen to you twice.
- **Not an argument for more process.** The output of a fix is usually *less* ceremony — one
  atomic command replacing two steps, a schema replacing a convention, a hook replacing a habit.
- **Not a claim that people are the problem.** The person who forgot is the messenger. The defect
  is a process that depended on a human noticing at the right moment.

## Failure Mode

The same failure, wearing the fix as a disguise. You respond to a skipped step by adding a step
that reminds the coordinator to perform the original one — which requires the coordinator to
remember, which is the bug. The defence looks heavier, the failure rate is unchanged, and the
blame is now attached to a document. Its five recurring shapes, named so they can be recognized:

1. **State in head.** Progress, decisions or intent held in prose or memory, invisible to the next
   session, person or tool. Put it in the artifact.
2. **Step two by the coordinator.** Any workflow where step two is "now also do X" after a tool
   call will eventually skip it. Fuse the steps, or trigger the second on completion of the first.
3. **Lifecycle coupling.** Work that dies when its starter dies loses everything at once.
   Long-running work is independent of whatever launched it.
4. **Narrative versus reality.** "The tests pass" is not "the database holds the right rows", and
   neither is "the user sees the right thing". Inspect the artifact at the layer the claim is
   about.
5. **Coordinator-dependent defence in depth.** When the failure mode is "the coordinator forgets",
   any mitigation that requires the coordinator to remember is the same bug with a bigger
   footprint.

## Generic Example

A team keeps committing unformatted code. The fix ladder, applied honestly:

```text
Rung 3 (what they did first): add "run the formatter before committing" to CONTRIBUTING.md.
  → The same three people still forget. The document grew; the failure did not move.

Rung 2 (if rung 1 is out of reach): the CI check fails the build and names the files.
  → Visible, but at the wrong moment: the commit is already pushed and the branch is red.

Rung 1 (the fix): a pre-commit hook formats or refuses.
  → The unformatted commit cannot be created. Nobody has to remember anything.
```

The same ladder applied to a plan rather than a rule: a decision recorded only in a chat thread
fails the same way as the reminder did. "The plan is not the commitment" — a described intention
is not a queued, tracked artifact, and treating it as one is a tier-3 fix pretending to be a
tier-1 one.
