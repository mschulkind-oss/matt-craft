# Lawyer Mode — definitions that survive substitution

## Definition

The writing discipline in which every term of art can be replaced by its own definition without
changing the meaning of the sentence it sits in, and every concept can be deleted without breaking
something named.

> [!NOTE]
> **What this card does not own.** How a definition is shaped, where its provenance goes, when a
> term graduates to a glossary, and why code is never a definition are all specified in
> **`vantage-docs`**, *Defined Terms*. Read that first. This card adds the two tests that
> discipline does not yet carry, and nothing else — a second copy of those rules would drift from
> the day it landed.

## The Principle in One Move

Apply two tests to every definition, in this order.

**The substitution test.** Take each defined term and put its definition in its place. The
sentence must still parse and must still claim exactly what it claimed before. If it does not, the
definition is incomplete, or the term was doing work the definition does not describe.

**The delete test.** Remove the concept — the page, the layer, the abstraction, the field — and
name what breaks. If nothing breaks, it had no consumer, and its presence was the cost of a
decision nobody made.

## The Sharp Test

> **Can this term be swapped for its definition and still read as the same claim — and can this
> concept be removed and break something you can name?**

Both halves must pass. A term that substitutes cleanly but has no consumer is decoration; a
concept with a real consumer but a definition that fails substitution is a trap, because it will
be implemented twice, differently.

## What This Isn't

- **Not legalism.** The point is not caveats, hedging or "for the avoidance of doubt" clauses. A
  definition that needs defending in three sentences is usually three terms.
- **Not a style preference.** This is not about shorter words or a house voice. A longer sentence
  that substitutes cleanly beats a shorter one that does not.
- **Not a licence to coin vocabulary.** The tests are a tax on new terms, not a subsidy. A term
  earns its place by being more precise than the plain phrase — never by sounding more rigorous.
- **Not a demand for formal notation.** Plain prose that passes both tests is the target; a
  formal grammar that nobody reads fails the delete test.

## Failure Mode

**Orphan jargon** — a term enters the tree without a definition, gets reused because it sounds
authoritative, and within a month several documents depend on a word whose meaning nobody can
state. It is worse than vagueness, because the reader assumes the precision exists somewhere and
blames their own reading.

Its twin is **definition drift**: the same concept defined twice, in two documents, slightly
differently. Neither copy is wrong on its own, and the difference is only discovered by whoever
implements the one that was not intended.

## Generic Example

```text
Before: "The engine processes messages. A message is an event payload. Messages can also
         be raw command strings."

Substitution test: "The engine processes an event payload." then "an event payload can
         also be a raw command string" — the second sentence now claims a payload can be
         a string, which contradicts the first. FAIL.

Delete test: delete "message" and write "payload" and "command" instead. Does anything
         break? No — the generic word was hiding two distinct things.

After: "A **payload** is a typed object with an id, a timestamp and an event name.
        A **command** is a command-line invocation. Payloads and commands are disjoint:
        a command never enters the payload queue."

Substitution test: holds — each definition is narrower than the word it replaces.
Delete test: deleting "payload" breaks the queue's contract; deleting "command" breaks
        the CLI's. Both earn their place.
```
