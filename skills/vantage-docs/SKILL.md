---
name: vantage-docs
description: Use when authoring, formatting, reviewing, or render-verifying Markdown documentation for Vantage and GitHub.
---

# Vantage Documentation Style Guide

Formatting rules and standards for writing Markdown documentation rendered in **Vantage** (and GitHub).

Vantage renders Markdown with full GitHub Flavored Markdown (GFM) fidelity, KaTeX math, client-side Mermaid diagrams, frontmatter metadata cards, and live reload. Writing docs to this standard ensures they are scannable, beautifully rendered, and semantically structured.

[§1](#1-formatting) points at the formatting conventions — it does not restate them. [§2](#2-open-questions--decision-ledgers) and [§3](#3-defined-terms) are the substantive conventions every doc in the tree follows regardless of kind: how decisions are recorded, and how terms are defined. [§4](#4-vantage-check--read-it-first-run-it-last) is the tool, and it bookends the work:

> [!IMPORTANT]
> **Before writing** — run `uvx vantage-check style-guide` and read what it prints. It is the canonical formatting conventions, straight from the renderer's own source. This skill deliberately does not restate them ([§1](#1-formatting)); if the command cannot run, read [`references/style-guide.md`](references/style-guide.md).
>
> **After writing** — run `uvx vantage-check <file>` and fix what it reports.

## When to use this skill
- Formatting or authoring any documentation (`docs/design/`, `docs/research/`, `user-stories/`, `roadmap.md`, RFCs).
- Referencing rules for relative links, line anchors, math delimiters, frontmatter, diagrams, and callouts.
- Reviewing or cleaning up existing Markdown files for readability.
- Starting a document: read `uvx vantage-check style-guide` first ([§4](#4-vantage-check--read-it-first-run-it-last)).
- Verifying that a document actually renders before delivering it ([§4](#4-vantage-check--read-it-first-run-it-last)).

---

## 1. Formatting

**The formatting conventions are not restated here.** They live in one place that moves with the renderer:

| Source | When |
| :--- | :--- |
| `uvx vantage-check style-guide` | Always, when it runs. Generated from the viewer's own module, so it is correct for the Vantage in front of you. |
| [`references/style-guide.md`](references/style-guide.md) | Only when the command cannot run — no `uvx`, no network, no binary on `PATH`. A dated snapshot of the same text. |

That covers document structure, relative links and line anchors, frontmatter, Mermaid, code and diff fences, callouts, tables, task lists, the `$$...$$` math rule, Vantage's `<!-- vantage: … -->` directives, and the reserved `vantage:` frontmatter key.

> [!NOTE]
> This section used to restate the whole guide, and the restatement had already
> drifted: it was missing the rule that nothing may sit above the opening `---`,
> the entire `<!-- vantage: … -->` directive vocabulary was absent, and the
> Mermaid paragraph still advertised a feature the renderer had replaced. Two
> statements of one convention is the failure [§3](#3-defined-terms) is about. Do not restore it —
> if something here is missing, the fix is upstream in the guide the command
> prints, and this file picks it up for free.

### The two rules that are ours, not Vantage's

The printed guide is about what the renderer can do. These two are about how we write, and the checker has no opinion on either:

- **Vertical space over density:** Do not crunch explanations into dense blocks. Give context room to breathe with line breaks and formatted lists.
- **Section size limits:** If an inline section or sub-point exceeds several formatted paragraphs, split it into a dedicated document and link it.
- **Frontmatter `status:` is an axis, not a second spelling of the prose `**Status:**` line.** They answer different questions and both are worth having: the frontmatter one answers *is the argument closed?* in Vantage's closed four; the prose line answers *what does this doc owe someone?* in the vocabulary **`design-doc`** defines. So `BUILT` over `in-review` is a legal and informative pair — in the tree, and still owing one ruling — and squashing them into one value loses that. Two rules follow: a lifecycle word never goes in the frontmatter slot, where anything outside the four **silently renders no chip**; and the document's *genre* — `STORIES`, `INVENTORY`, `HANDOFF` — goes in `tags:` or the title and never in either.

> [!NOTE]
> **Wrap release-note prose like the rest of the file.** GitHub turns each newline in a release body into a line break, so `publish.yml` runs `changelog-section.sh --unwrap` to join each paragraph and list item onto one line. Do not write long lines to compensate, and do not use a bare newline to force a break — that gets joined too. A break that must survive needs two trailing spaces or a `\`.

---

## 2. Open Questions & Decision Ledgers
When surfacing and recording design decisions:
- **Phase 1 (Deliberating):** In-flight questions use status emojis and full scaffolding:
  - 💬 **Open Question:** Active decision awaiting ruling.
  - 💬 🤷 **Deferred Question:** Pure subjective user preference where agent has no technical leaning.
  - ✅ **Answered / Resolved:** Decided question awaiting compaction.
  - 🔒 **Blocked:** Blocked on upstream decisions or experiments.
  Format: stable ID (`OQ-N`), bold title + stakes, `_Leaning:_`, fill-in blockquote `**Answer:**`, and an `oq` directive carrying the id and the leaning text.

  > [!IMPORTANT]
  > **Three parts of that scaffolding are checked, all at error severity** (Vantage 0.5.9). The printed style guide ([§1](#1-formatting)) states them in full; what they cost you here:
  >
  > - **The `oq` directive is not optional.** A 💬 question with a `_Leaning:_` and no `oq` directive renders with nothing for the reviewer to click — `vantage/oq-missing`. Its `leaning` value restates the leaning in words and is never `"Yes"`: that text *is* the review comment the next agent reads, and nobody remembers which button was pressed.
  > - **The id is the question's anchor now**, so its shape is checked (`vantage/oq-id-format`) and so is uniqueness within the document (`vantage/oq-id-duplicate`). A malformed or duplicated one silently goes nowhere.
  > - **Every reference to a question, a section or a file is a link** — `ref/unlinked-oq`, `ref/unlinked-section`, `ref/unlinked-file`. See below.

  ```markdown
  1. 💬 **OQ-9: Queue position on re-entry.** Does a fixed PR go to the back?

     <!-- vantage: oq id=OQ-9 leaning="Back of the queue — the fix might interact with what merged while it was out." -->

     _Leaning:_ Back of the queue.

     **Answer:**
     > _(empty — fill in when decided)_
  ```

  The id is `OQ`, a hyphen, an optional short uppercase prefix, then digits:

  ```text
  OQ-9      valid        OQ-foo   no — the prefix is uppercase
  OQ-TP6    valid        OQ-tp6   no
  OQ-A03    valid        OQ6      not a reference at all — the hyphen is the convention
  ```

  The prefix is what keeps ids distinct once two documents reference each other's questions; use one in both whenever they do.
- **Phase 2 (Compacted):** *Never delete a decision* — but a decision's durable form is a **Decision Ledger row plus normative body text**, not an ever-growing question scaffold. When questions are settled:
  - Fold the ruling directly into the normative text of the body section it governs (§X).
  - Preserve refuted objections and known traps as warnings (`> [!WARNING]`) in the body text (refuted objections are documentation, not history).
  - Compact answered questions into a clean table: `| ID | Ruling / Decision | Date | Settled in |`.
  - **Compaction destroys the `oq` directive** — that is what compaction is — and with it the question's anchor. Inbound references stay links; they repoint at the ledger (below).

  > [!WARNING]
  > **The worst breakage here is invisible to every checker, including this one.** `vantage-check` reports a dead `#OQ-N` in a sibling document — and only if you run it there. **Rule ids are also cited from source comments,** which no markdown tool parses at all. One sprint's compaction deleted 49 directives; 28 of those ids resolved to nowhere afterwards and 9 inbound references were left stale. So the grep is unscoped, and it runs *before* the compaction, not after:
  >
  > ```console
  > $ rg -n 'OQ-[A-Z]*[0-9]'    # the whole repo: code comments, tests, tickets
  > ```

### A reference is a link, or it is a lie

An `OQ-` id, a `§N` section number and a filename all read like pointers. Written as bare prose none of them can be followed, and none can be checked — which is exactly why a stale one is never caught. The 💬 ids in particular outlive the questions they name.

```markdown
[OQ-4](#OQ-4)                              a question in flight — the directive's id
                                           is the anchor, verbatim and case-sensitive
[OQ-TP4](../design/trust-paths.md#OQ-TP4)  a question in another document — prefix the
                                           ids in BOTH, so a bare number can't be ambiguous
[OQ-4](./api.md#decision-ledger)           a question after compaction — the directive is
                                           gone, so the ledger is the honest target
[§4.1](#41-the-anchor)                     a section — checked against the heading the
                                           number names, not merely that it resolves
[agent-cli.md](./agent-cli.md)             a file beside the document — resolved
                                           doc-relative, against the file the token names
```

Two consequences worth knowing before the checker tells you:

- **A specimen is not a reference.** An id in a template, a filename in a command, a `§N` in an example — put it in a fenced block, which these rules never read. Prose and inline code are read; fences are not.
- **The link is checked against what the reference *names*,** not merely that it resolves. A section number linked to a different heading, or a filename linked to a different file, is a finding.

---

## 3. Defined Terms

Aspire to the standard a contract is held to: **a reader must never have to guess what a word means, and must never have to accept a word on authority.** Every term of art in a doc is either defined where it is used or linked to where it is defined.

### The failure this prevents

**Orphan jargon** *(coined here)* — a term that entered the tree without a definition, got reused because it sounded authoritative, and now several documents depend on a word whose meaning nobody can state and whose origin nobody can name. It is worse than vagueness, because it is vagueness wearing a lab coat: the reader assumes the precision exists somewhere and that the gap is in their own knowledge.

### The rule

Every term of art has exactly one of three provenances, and the doc says which:

1. **Standard in the field** → link a stable external reference the reader can actually open. Not "as is well known," not a bare name-drop.
2. **Ours, defined elsewhere** → link the glossary, or the doc that owns the term.
3. **Coined here** → say so, in as many words: **Term** *(coined here)*.

Coining is entirely legitimate — a project that names its own concepts is thinking clearly. **Silent** coining is the failure. An invented term that is never marked as invented reads to every later reader as standard vocabulary they are expected to already know, and that is exactly how a word ends up in five documents with no origin.

### The "when pressed" test

Before using a term of art, be able to answer three questions **without opening the code**:

- What does it mean, in one sentence?
- Where did it come from — field-standard, our glossary, or coined right here?
- What is the nearest thing it is *not*?

Fail any of the three and you do not have a term, you have a placeholder. Define it now, or write the plain words instead.

### Code is never the definition

> [!IMPORTANT]
> Never answer "what does this term mean?" with a pointer to an implementation — not a function, not a type, not a file, and never a line number.

Three reasons. It **answers the wrong question**: a symbol tells you where an implementation lives, not what the concept means or why it exists, so the reader has to reverse-engineer the definition out of the behavior — the exact labor the doc existed to save. It is **circular**: the doc's job is to explain the code, so pointing back at the code closes a loop with no meaning inside it. And it **rots**: implementations move, and a definition that moved is a definition that is gone.

Naming a package or type as *where the thing lives* remains good practice. That is an anchor, not a definition. A doc may do both; it must not mistake one for the other.

### One term, one meaning

The other half of the standard, and the more commonly broken half:

- **One concept, one word, every time.** A contract never alternates "the Buyer" and "the Purchaser"; docs routinely write "the broker," "the daemon," and "the approval service" for one thing and leave the reader to work out whether three things exist. Synonym variation is a virtue in prose and a defect in reference writing. Consistency beats elegance.
- **One word, one concept.** If *session* means both the transport connection and the user's login, one of them needs a different word — and the doc picks which.

### Prefer the plain word

The goal is **less undefined jargon, not more defined jargon.** A term of art earns its place only by being *more precise* than the plain phrase — never by being shorter, and never by sounding more serious.

The definition requirement is a deliberate tax: if writing the definition feels like more work than the term is worth, that is the answer, and the plain words were always available.

### The shape of a definition

Say what it is, say what it excludes, name its origin. A definition without an exclusion is half a definition — it is the "for the avoidance of doubt" clause, and it is where the reader's actual confusion lives.

```markdown
**Loophole** — a host capability deliberately exposed into a jail through a
mediated, audited channel. Not a sandbox escape (that is a bug, and undeclared)
and not a plain network route (that carries no policy). From the `yolo-jail`
tool, which coined it 2026-04-18 (`11689cef`) replacing its own earlier
"modules"/"host_services"; adopted here 2026-05-13.
```

> [!NOTE]
> That example is real, and it was wrong the first time this section was
> written: the origin line said *"Coined here."* An audit traced the term to
> `yolo-jail`, a month earlier. The plausible-sounding provenance is the exact
> failure this section exists to prevent, and it is easy to commit while
> writing the rule against it. Run the archaeology; do not reconstruct it from
> memory.

### The glossary

`docs/glossary.md`, one per repo, alphabetical, one entry per term: the definition, the exclusion, and an **Origin** line.

**When a term graduates into it:** define a term inline at first use; the moment a *second* document needs it, move it to the glossary and have both docs link there. That trigger keeps single-use terms out of the glossary and stops one term acquiring two slightly different definitions in two places — which is the failure mode a glossary exists to prevent.

Two housekeeping rules:

- **The Origin line is mandatory**, and it is the point of the whole entry. A term whose provenance nobody knows is then *visibly* missing its origin — the gap sits in the artifact where the next reader trips over it, instead of in someone's memory where it never surfaces.
- **An entry nothing links to is dead.** Delete it; the term left the vocabulary.

> [!NOTE]
> Only half of this is mechanically checkable. Whether a glossary link resolves, and whether an entry carries an Origin line, are exact checks worth wiring into CI. Whether a word *is* a term of art is judgment, and the "when pressed" test above is the prompt for exercising it.

---

## 4. `vantage-check` — read it first, run it last

`vantage-check` ships with Vantage (new in v0.5.4) and does two things, one at each end of writing a document. It runs entirely offline against files on disk — no Vantage server, no port, no network — and it never rewrites your documents.

```bash
uvx vantage-check style-guide             # BEFORE writing: the canonical conventions
uvx vantage-check docs/design/api.md      # AFTER writing: does this actually render?
uvx vantage-check docs/ userguide/        # directories, walked for .md and .markdown
uvx vantage-check help                    # commands, options, and every rule id
```

`check` is the default command, so a bare path list runs it. With **no arguments at all it prints help rather than checking anything** — always pass a path.

### Before writing: `style-guide`

**Run `uvx vantage-check style-guide` and read the output before you write or edit a Vantage document.** It is not a summary of this skill and not an optional extra: it is the conventions as the renderer itself states them, generated from the same source the viewer uses, so it is correct for the Vantage version actually in front of you.

Two reasons it is a step and not a formality:

- **This skill is a copy, and copies lag.** Where the two disagree, the printed guide wins — it moves with the renderer, this file moves when someone remembers to edit it.
- **Some of it you cannot check by eye.** Vantage's `<!-- vantage: … -->` directives (`section`, `block`, `oq`, and their closed vocabulary of tones and badges) and the reserved `vantage:` frontmatter key are *silently inert* when wrong — nothing breaks, and nothing styles either. Reading the vocabulary first is the cheap way to get them right; `check`'s `vantage/*` rules are the only way to find out afterwards.

If the command is unavailable, read [`references/style-guide.md`](references/style-guide.md) — the same text, snapshotted, shipped inside this skill so it is there when the network is not. Say in your hand-off that you worked from the snapshot.

### After writing: `check`

Run it on every document you write or edit, before handing the work back. The style guide tells you how to write; `check` verifies the result against the real render pipeline. They are the two halves of one contract.

### Getting the binary

| If | Then |
| :--- | :--- |
| `uvx` is available (the usual case) | `uvx vantage-check <path>` — fetches a wheel carrying the binary, caches it, runs it |
| `vantage-check` is already on `PATH` | run it directly; it is the same binary |
| Neither | Skip the check and **say so in your hand-off**, naming the files you could not verify |

It is a quality gate, not a delivery dependency: a missing checker never blocks delivery. A *silent* skip is the thing that is not acceptable.

### Reading the result

| Exit | Meaning | What to do |
| :--- | :--- | :--- |
| `0` | Nothing to fix | Done. |
| `1` | Findings that fail the run | Fix them. |
| `2` | Bad arguments, a path that is not there, or a `.vantage.toml` that cannot be trusted | Fix the invocation or the config, then re-run. |
| `3` | **A check could not run** | The documents were not fully checked, so the result is *unknown*, not clean. Re-run, or report the files as unverified. |

> [!WARNING]
> A `3` is never a pass. It means the checker's own environment broke — a file it
> could not read, a validator it could not start — so it says so on stderr rather
> than blaming your document, and it outranks `1`. An incomplete run reported as a
> clean one is the one outcome worth guarding against.

Findings are sorted by file, then line and column, so two runs over the same tree print the same bytes and one report diffs against the last.

```console
$ uvx vantage-check docs/standards/distribution.md
docs/standards/distribution.md
  38:103  error  link/missing-target  `../projects/waykeeper.md` does not exist (looked for `docs/projects/waykeeper.md`).

✖ 1 error in 1 file checked
```

### Options

| Option | Effect |
| :--- | :--- |
| `--format text\|json` | Output format. Default `text`. JSON keeps `failures` (could-not-check) as a sibling of `findings` (broken), so a consumer cannot confuse the two. |
| `--strict` | Warnings fail the run as well as errors. |
| `-q`, `--quiet` | Drop the summary line. |
| `--color` / `--no-color` | Force colour on or off (default: on when stdout is a terminal). |
| `--config <path>` | Use this `.vantage.toml`. A path that is not there is an error. |
| `--no-config` | Ignore `.vantage.toml`; use the built-in defaults. |
| `--` | Everything after it is a path, not an option. |

> [!NOTE]
> **Paths come first, or name the command.** `vantage-check --format json docs/` exits `2` with *unknown option* — the bare form takes a path list, and an option before the first path is read as the command name. Either put the options after the paths, or say `check` explicitly: `vantage-check check --format json docs/`.

Configuration is optional. A `.vantage.toml` at the **repository root** (never in `.vantage/`, which is transient state) can set `check.strict`, `check.exit-code`, and per-rule severities of `"error"`, `"warning"` or `"off"`. A config file that is present but wrong — unknown key, misspelled rule name, a severity that is not one — exits `2` rather than warning.

### What it checks

Four families, and the split is the point:

| Family | The question it answers |
| :--- | :--- |
| `link/*` | Does this relative link, line anchor or section anchor resolve *in this repo*? Leading slashes, `file://` and drive letters, missing targets, `#L42` past end-of-file, and `#section` anchors matching no heading — the last with a `Did you mean …?` suggestion, computed with the renderer's own slugger. |
| `frontmatter/*`, `mermaid/*`, `katex/*`, `render/*` | Do the viewer's own parsers accept this? The checker imports Vantage's render pipeline rather than reimplementing it, so a block fails for exactly the reason the browser would, in that parser's words. `render/pipeline` is the end-to-end backstop. |
| `ref/*` | *Should this have been a link at all?* An `OQ-` id, a `§N` number or a doc-relative filename written as prose ([§2](#2-open-questions--decision-ledgers)). A reference that is not a link cannot go dead, so no other rule can ever notice it went stale — which is the whole point of the family. |
| `vantage/*` | Is Vantage's own `<!-- vantage: … -->` markup, and the reserved `vantage:` frontmatter key, well-formed? Wrong ones are **silently inert** — no error anywhere — so these rules are the only thing that will ever tell you a directive styled nothing. |

Links and directives come from the *parsed* document, never a text search, so `[Doc](/docs/x.md)` inside a code fence is a code sample rather than a finding. A link to a directory is fine: Vantage routes those to a listing.

`uvx vantage-check help` prints every rule id with a one-line summary. Read that list from the version you are running rather than any copy of it — the rules grow.

### Fix the document, not the rule

The temptation on a red run is to switch the rule off in `.vantage.toml`. Don't. Every default-on rule reports something genuinely broken in the rendered page — a link that goes nowhere, a directive that styles nothing, a frontmatter block that rendered as a horizontal rule and a heading of raw keys. Silencing the rule hides the breakage, not just the message. Change severities only when the human asks, and say why in the commit.

The one exception the tool documents for itself is performance: `vantage/block-split` re-parses the enclosing block per directive, which is quadratic on a long Open Questions list (a 40-question list measures ~171 ms against ~0.3 ms with the rule off). If that ever matters, turning *that* rule off is a considered trade, not a silencing.

### Checking a tree that predates the checker

A repo with a backlog will report dozens of findings that are not yours. **Check the files you touched**, not the whole tree, so the run's output is about your work. Clearing the backlog is its own task — propose it, don't fold it into an unrelated change.

### What it does *not* check

The checker reports what breaks rendering. It has no opinion on:

- prose, structure, or section size ([§1](#1-formatting));
- whether Open Questions have been compacted into a Decision Ledger ([§2](#2-open-questions--decision-ledgers));
- whether a term of art is defined, or whether glossary entries carry Origin lines ([§3](#3-defined-terms));
- external `https://` links — it never touches the network;
- Mermaid **layout** — diagrams are validated headless, grammar only, so one that parses can still lay out badly;
- general Markdown hygiene — the `markdown/hygiene` family is off by default, because its rules are opinions about Markdown rather than statements about whether Vantage can render the page.

A clean run means the page renders. Everything above in this guide is still yours to get right.
