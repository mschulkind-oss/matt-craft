# Practices now mandatory — cheaper to write, still not free to skip

## Definition

The economic argument that disciplines once rationed for their authoring cost — explicit contracts,
property tests, exhaustive interfaces, strict types — are now cheap enough to be the default, while
the need to verify them mechanically has gone up rather than down.

## The Principle in One Move

Re-price the discipline, not the standard. The old calculus was "a property test costs an afternoon,
so we write one where the risk is highest". The authoring cost of the test has collapsed; the cost
of a missed edge case has not. So the practice stops being a luxury good and becomes ordinary work.

Then add the second half, which is the part people skip: because the work is now produced by
something that drifts, the practice has to be **enforced by a mechanism** rather than trusted to
the producer's care. The type checker, the schema, the invariant test in CI — the enforcement is
what makes the practice real, not the intention to follow it.

## The Sharp Test

> **Is this discipline enforced by something that can fail, or is it a convention everyone believes
> they follow?**

If the only thing holding it up is that people mean well, it is not in force. If a build goes red
when it is skipped, it is.

## What This Isn't

- **Not "agents never slip."** They slip constantly, in the same way people do and at higher volume.
  That is the premise, not an objection to it. Any claim that the tooling makes mistakes impossible
  is the failure mode below, stated as a feature.
- **Not "cognition is free."** Review, verification and understanding still cost real attention.
  What got cheaper is authoring; what got more valuable is the check.
- **Not language dogmatism.** The argument is about cost, so it applies wherever the cost fell:
  types in one language, schemas and contract tests in another, property tests in a third.
- **Not a mandate for every practice everywhere.** A throwaway script does not need a property
  suite. The claim is that the *default* moved — the burden is now on skipping a practice, not on
  adopting one.

## Failure Mode

**The false economy.** A high-discipline artifact is skipped to save time that no longer exists to
save — the property test, the exhaustive enum handling, the schema — and the saving is spent
immediately, while the defect it would have caught arrives weeks later, in production, with
interest. The tell is a justification phrased as effort: "we didn't have time to write the
invariant tests" when writing them was minutes.

The opposite failure is just as real: **ceremony without enforcement**. The practices are adopted as
vocabulary — types that are `any`, tests that assert nothing, contracts nothing validates — and the
team believes it has the discipline because it has the nouns.

## Generic Example

```python
# The old calculus: "a property test is overkill for an internal transfer function."
# The new one: the test is four lines, so the question is only what invariant holds.

class Transfer(BaseModel):
    sender: str = Field(min_length=1)
    receiver: str = Field(min_length=1)
    cents: int = Field(gt=0)

@given(st.integers(min_value=1, max_value=100_000))
def test_balance_is_conserved(cents):
    ledger = Ledger(balance=100_000)
    ledger.transfer("a", "b", cents)
    assert ledger.total() == 100_000          # the invariant, not an example
```

The enforcement half, in the same change: the schema is what validates the payload at the boundary,
and the test is what runs in CI. Neither depends on anyone remembering to be careful — which is the
only version of this that survives a bad week.
