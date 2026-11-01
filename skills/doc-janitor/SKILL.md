---
name: doc-janitor
description: Use when a repository has a cluttered, drifted, or duplicated set of documents that needs shelf-level cleanup — inventorying files, fixing lying frontmatter status lines, merging or archiving superseded docs with section-by-section absorption checks, and rewriting inbound links.
---

# Document Janitor: Shelf Cleanup and Safe Disposition

An inherited or agent-sprawled document tree is a liability that reads like an asset: dozens of files, mixed genres, duplicates that disagree, and status lines that stopped being true. `doc-janitor` is the shelf-level procedure for classifying what each document *is*, repairing lying metadata, and verifying the claim that makes archiving or deleting safe: that the surviving document actually contains every section it claims to absorb.

This skill owns **corpus-level file hygiene** (the shelf). For line-level review iteration and prose cleanup inside an active design document, use `design-doc`. For recovering an architecture from agentic divergence across sessions, docs, and code, use `architecture-realignment`.

## 1. When to run it — and when to hold destructive moves

Run `doc-janitor` standalone whenever a documentation directory has accumulated duplicates, stale plans, or lying statuses. Run [§2](#2-the-inventory--data-not-opinion) and [§3](#3-correct-lying-status-lines-first) as Step 1 of an `architecture-realignment` campaign so the campaign starts with an honest map.

**Never archive or delete a source document before the gap analysis or absorption check that reads it.** A drifted document slated for retirement is often the only place an edge case or historical constraint was written down. Fixing lying status lines ([§3](#3-correct-lying-status-lines-first)) is safe immediately; moving, archiving, and deleting wait until the surviving documents are written and verified ([§4](#4-the-absorption-check)).

## 2. The inventory — data, not opinion

Classify **every** document in the target scope before moving a single file. Produce one row per file with no blank cells:

| Field | Required content |
| :--- | :--- |
| `path`, `title` | Exact path and title as written |
| `frontmatter status` | Verbatim frontmatter `status:` and `stage:` (plus any conflicting bold **Status:** line in the header) |
| `last commit` | Output of `git log -1 --format='%h %ad' --date=short -- <path>` |
| `genre as written` | `design` · `reference` · `ruling` · `plan` · `advice/log` · `research` · `postmortem` |
| `what it documents` | One concise clause |
| `cluster` | Which other documents in the tree overlap its subject |
| `fate` | Exactly one value from [§2.1](#21-the-fate-vocabulary) |
| `why` | One clause justifying the fate |
| `confidence` | `high` / `medium` / `low`, naming any sections or backing files not yet inspected |

### 2.1 The fate vocabulary

Every document receives one of eight canonical fates:

- `keep as design`
- `keep as ruling in force`
- `graduate to docs/reference`
- `graduate after re-verification against a named authority`
- `split, with each half's new home named`
- `merge into a named survivor`
- `archive as superseded by a named survivor`
- `delete as duplicate of a named survivor`

**Every non-keep fate carries three mandatory fields**:
1. The **survivor's exact path**.
2. **What the survivor absorbs** (specific sections or claims).
3. The **inbound link count** (`rg -l -F <filename>` across the repository) that the move must rewrite.

### 2.2 Four required summary outputs from the inventory

Below the inventory table, list:

1. **Duplication clusters:** Each cluster names **one** canonical survivor and the exact list of files it absorbs.
2. **Lying status lines:** Every document whose status contradicts reality — for example, `draft` or `proposed` for behavior already shipped, `accepted` or `current` for work never built or superseded, a multi-word sentence stuffed into a `status:` token, or a `built` claim lacking a verification anchor.
3. **Inbound citation counts:** The exact output count of `rg -l -F <filename>` for every file slated to move, archive, or delete. A file with inbound links cannot be moved or retired without rewriting those links in the same commit.
4. **Cross-document contradictions:** Pairs of documents that make incompatible claims about the same mechanism or decision, flagged for triage.

### 2.3 Evidence rules

- **Verify existence before citing:** Confirm every file path, symbol, or command mentioned in the inventory actually exists in the working tree. Inventories are where stale names propagate furthest.
- **Disclose skim depth:** If a document was classified from its headings without reading every section body, record `confidence: medium` or `low` and state what was not read. Never run an archive or delete on a non-`high` confidence row.

## 3. Correct lying status lines first

Status frontmatter is the cheapest repair and the most disorienting lie when left broken. Fix lying status lines **before** moving or rewriting any files, in one standalone mechanical commit:

- Justify each status change in the commit message with the specific evidence that proved the old status false (e.g., the commit SHA or package that shipped the feature, or the successor doc that superseded it).
- Never silently flip a `draft` document to `accepted` or `current` if its body still contains unresolved open questions (`OQ-…`). Either resolve and compact the questions first, or keep the status honest.

## 4. The absorption check

"Absorbed by `X.md`" is a testable claim, not a label. Before archiving or deleting any source document:

1. **Enumerate every section heading** (and any unheaded tables or invariants) in the source document.
2. **Map each section to the exact section heading in the survivor** that carries the equivalent content.
3. **Resolve every orphan section explicitly:** Where the survivor does not yet carry the content, choose one of three actions before touching the source file:
   - Copy/synthesize the missing content into the survivor now.
   - Keep the source document alive and narrow its scope.
   - Record an explicit owner-approved drop note explaining why the section is obsolete (e.g., belongs to a deleted diverged code path).
4. **Gate:** Only a source document with **zero unaccounted sections** may be archived or deleted.

## 5. Safe execution mechanics

Execute file dispositions in this exact order:

1. **Create or update destination pages first:** Write the new or merged survivor pages before removing any source file. Graduating a design into `docs/reference/` is a genre change (`system-doc` or `doc-constellation`), never a bare `git mv`.
2. **Move in clusters, one commit per cluster:** Group each survivor with the files it absorbs and all inbound link rewrites across the repository into a single atomic commit. Never leave a commit where inbound links dangle.
3. **Archive with a tombstone header:** When archiving a file rather than deleting it, place it in the repository's designated archive path and prepend a one-line banner at the top of the body stating what superseded it and on what date.
4. **Delete only verified duplicates or fully absorbed docs:** Delete a file only after [§4](#4-the-absorption-check) passes for 100% of its sections.
5. **Re-verify citation counts and link integrity:** Re-run `rg -l -F <old-filename>` to confirm zero dangling references remain, and run `uvx vantage-check <changed-paths>` (or the repository's link checker) to verify all headings and anchors resolve.

## 6. Quality checklist

- [ ] Every document in scope has a complete row in the [§2](#2-the-inventory--data-not-opinion) inventory table with no blank cells.
- [ ] Every assigned fate comes from the canonical [§2.1](#21-the-fate-vocabulary) list.
- [ ] Every non-keep fate names its survivor path, what it absorbs, and its pre-move inbound link count.
- [ ] Duplication clusters each designate exactly one survivor.
- [ ] Lying status lines are listed with contradicting evidence and repaired first in an isolated commit ([§3](#3-correct-lying-status-lines-first)).
- [ ] Section-by-section absorption check ([§4](#4-the-absorption-check)) is complete with zero unaccounted sections for every archived or deleted file.
- [ ] Destination survivor pages exist on disk before any source file is archived or removed ([§5](#5-safe-execution-mechanics)).
- [ ] Each cluster move rewrites all inbound links in the same commit.
- [ ] Post-move `rg -l -F <old-filename>` returns zero unintended hits, and `uvx vantage-check` passes clean.
