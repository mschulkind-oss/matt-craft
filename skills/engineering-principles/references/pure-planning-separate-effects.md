# Pure planning, separate effects — decide, then do

## Definition

The split between computing a plan — a value that says what should happen, derived from inputs with
no side effects — and applying it, at one explicit boundary that performs the I/O.

## The Principle in One Move

Make the decision a value. Given the current state and the desired state, compute a plan: the list
of things that will be created, changed and removed, with enough detail to execute it. Print it,
diff it, test it, store it. Then hand that plan to one function that performs the effects, and only
that function.

Two properties follow, and they are the whole benefit. The plan is inspectable before anything
happens, so a wrong decision costs a review rather than a rollback. And the plan is testable
without a filesystem, a network or a database, so the interesting logic runs at unit-test speed.

## The Sharp Test

> **Can the plan be printed, inspected and executed against a different target without recomputing
> the decision?**

If applying the change re-derives what to do as it goes, the split is not there — a `--dry-run` flag
threading booleans through effectful code is not this pattern, it is the same code with a branch.

## What This Isn't

- **Not the Builder pattern.** A builder assembles one object. A plan is a description of multiple
  actions against external state, executed later by someone else.
- **Not event sourcing or a command bus.** Those are architectures for recording and replaying
  history. This is a local separation inside one operation, available without any framework.
- **Not "everything must be pure".** Effects have to happen. The rule is that they happen in one
  place, after the decision, not interleaved with it.
- **Not only for infrastructure.** The same split applies to a data migration, a file sync, a bulk
  email, a schema change, or a release script.

## Failure Mode

**Interleaved planning and execution.** A script walks a directory, deletes as it goes, and hits a
permission error on the fourth entry. Now the filesystem is in a state that exists in neither the
before nor the after picture, and nothing recorded what the intended end state was. Recovery is
archaeology.

The subtler version is **plan/apply divergence**: a `--dry-run` that computes the plan by a
different code path than the real run, so the preview and the execution disagree. A plan that is
not the thing executed is worse than no preview, because it is trusted.

## Generic Example

```typescript
interface Plan {
  create: Array<{ path: string; content: string }>;
  delete: string[];
}

// Pure: no filesystem, no clock, no network. Unit-testable in microseconds.
function planSync(current: Manifest, target: Manifest): Plan {
  return {
    create: target.files.filter(f => !current.files.some(c => c.path === f.path)),
    delete: current.files.filter(c => !target.files.some(f => f.path === c.path)).map(c => c.path),
  };
}

// One effectful boundary. It executes the plan it was given; it does not re-decide.
async function applySync(plan: Plan, fs: Fs): Promise<void> {
  for (const f of plan.create) await fs.write(f.path, f.content);
  for (const p of plan.delete) await fs.remove(p);
}
```

The operator-facing form is the same value printed: `sync --plan` renders the plan, `sync --apply`
executes exactly it, and the exit code says whether the plan is empty. `--plan` and `--apply` share
the computation, so the preview cannot lie about what will run.
