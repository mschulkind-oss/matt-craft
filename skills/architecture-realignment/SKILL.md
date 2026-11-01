---
name: architecture-realignment
description: Use when recovering a codebase or design from agentic divergence, realigning a drifted architecture across sessions, documents, and code, adopting a legacy codebase not born under matt-craft, or establishing a document-first target architecture when a system was built without a design doc.
---

# Architecture Realignment: Document-First Recovery and Legacy Adoption

Design and implementation have two entry points:
- **Forward Design (`design-doc`):** When building a new feature or revising a clean baseline, start directly in `design-doc` $\rightarrow$ `implementation-plan` $\rightarrow$ `system-doc` (or `doc-constellation`).
- **Recovery & Realignment (`architecture-realignment`):** When a system has escaped the normal process — because an agent diverged across turns and dropped earlier decisions, because an existing legacy project is being brought under `matt-craft` for the first time, because code was built without a design doc, or because docs and code have drifted into mutual contradiction — you cannot start with an incremental `design-doc` or trust the code as ground truth.

In an agentic divergence or legacy adoption, **the code is the crime scene**. Agents default to treating existing code as sacred authority and updating docs to rationalize whatever the code currently does. That cements the divergence.

`architecture-realignment` is the five-step campaign that resets the foundation: cleaning the shelf (`doc-janitor`), excavating true intent through three-way archaeology, converging the ideal target architecture **strictly in documents first** (`design-doc` and its review iteration discipline), running an unsentimental `DELETE` / `KEEP` / `BUILD` gap analysis against the codebase, and generating a hard-railed `implementation-plan` before touching production code.

```
doc-janitor (Step 1) → Three-Way Archaeology (Step 2) → Target design-doc (Step 3)
                                                               │
  system-doc / doc-constellation (Step 5) ← Phased Build ← Code Gap Analysis & implementation-plan (Step 4)
```

## 1. Foundational Principles

### 1.1 Principle 1: Code is NOT King (Code is the Crime Scene)

Never treat existing implementation code as automatic architectural authority. The code shows *what currently runs*, including every shortcut, hallucinated abstraction, and dropped requirement introduced during agent drift or legacy development. You must be prepared to cut away diverged code without hesitation — even if it is already wired in and passing its own self-justifying tests.

### 1.2 Principle 2: The Current Design Doc is NOT King

Existing design and reference documents may also be corrupted by agent drift, defensive rationalizations, or stale legacy assumptions. The true baseline requires **three-way archaeology** across:
1. **Past sessions and transcripts:** Where the owner's original vision, rulings, and rejected alternatives live.
2. **Existing documents:** Which hold a mix of valid architecture and drifted claims.
3. **Current code:** Which serves as forensic evidence of what was built and where divergence occurred.

### 1.3 Principle 3: Work STRICTLY in Documents First

**Freeze all implementation code edits during Steps 1 through 4.** Do not fix bugs, refactor structs, or touch production files while realigning the architecture. Half-written code beside half-written documents guarantees neither converges. Work purely in documents until the target architecture is reviewed, settled, and approved by the owner.

### 1.4 Principle 4: Four Distinct Roles and Seat Capability Gates

Mixing roles causes campaigns to drift. Enforce strict boundaries:

| Seat | Owns | Never does |
| :--- | :--- | :--- |
| **Owner** | Architectural vision, rulings on open questions (`OQ-…`), approval of code deletions and file dispositions | Write boilerplate recon or reference tables |
| **Designer** (expensive seat) | Target architecture (`design-doc`), contradiction triage, gap analysis against code, high-skill `implementation-plan` | Dig through raw transcripts or write implementation code |
| **Scouts / Workers** (cheap, parallel) | `doc-janitor` inventory, session archaeology packets, forensic code fact-sheets | Make architectural rulings or silently pick between contradictions |
| **Coordinator** | Brief assembly, seat capability checks, applying `design-doc` editorial passes, running linters, landing approved commits | Invent architectural compromises on the fly |

**Verify seat capabilities before dispatching (`no-read` / `no-write` gates):**
- Record whether a dispatched design seat can read workspace files, write files, or suffers output truncation.
- Never pass file paths to a `no-read` seat; embed the research packets directly in the brief with explicit line counts and terminators, and require the seat to restate headings and item counts to prove nothing was truncated.
- A `no-write` seat returns documents in its final message; the coordinator writes them **unstaged** to disk so the owner can inspect real files before committing.

---

## 2. Step 1 — Deep Clean the Shelf (`doc-janitor`)

Before excavating architecture, stop the bleeding in the `docs/` directory by running `doc-janitor`:

1. **Inventory every document in scope:** Produce the complete `doc-janitor` inventory table (path, status, last commit, genre, cluster, fate, survivor path, and inbound link count).
2. **Fix lying status lines immediately:** Repair frontmatter `status:` and `stage:` lies (`draft` on shipped code, `accepted` on unbuilt proposals, `current` on superseded docs) in one standalone mechanical commit.
3. **Hold destructive file moves until Step 4:** Do **not** delete or archive drifted docs yet; Step 2 archaeology needs to read them to see what was lost or distorted.

---

## 3. Step 2 — Grounding & Three-Way Archaeology

Pause all worker implementation lanes. Dispatch parallel read-only scouts to produce three forensic packets:

### 3.1 Packet 1: Session Archaeology (Original Intent & Dropped Rulings)

Search past conversation transcripts, review threads, and commit history for the owner's actual instructions and rulings:
- Extract every explicit owner decision, constraint, and rejected design direction, with timestamps or session IDs.
- **Flag dropped rulings loudly:** Highlight every ruling the owner made in a session that never reached the tracked documents or was quietly disobeyed by subsequent code turns.

### 3.2 Packet 2: Document Claim & Contradiction Inventory

From the existing documents identified in Step 1, extract:
- The **Normative Claim List**: every stated invariant, state transition, formula, and scope boundary.
- Every internal contradiction between documents, and every place where an existing document rationalizes a complex workaround.

### 3.3 Packet 3: Forensic Code Fact-Sheet ("Inspecting the Crime Scene")

Inspect the current codebase at mechanism altitude — not to bless it, but to map what is actually there and where it diverged:
1. **Execution spine and state ownership:** What mutates state, in what order, and where state lives.
2. **Divergence markers (the four forensic defect classes):**
   - **Layering violations:** Upstream decisions reading values produced downstream.
   - **Unpublished or dead state:** State written in one place that no consumer reads, or declared config levers that nothing applies.
   - **Intent vs. observed state confusion:** Code recording intended inputs while claiming to report physical or runtime state.
   - **Hallucinated abstractions:** Unrequested wrappers, fallback branches, or compatibility shims that violate the owner's stated model.

### 3.4 Divergence & Contradiction Triage

Compare Packets 1, 2, and 3 side by side in a **Divergence Ledger**:

| Conflict Type | Resolution Rule |
| :--- | :--- |
| **Code vs. Owner Ruling (Packet 3 vs. Packet 1)** | **Owner ruling wins.** Mark the code path as `DIVERGED — SLATED FOR DELETION/REWRITE`. Never bend the target architecture to preserve diverged code. |
| **Doc vs. Owner Ruling (Packet 2 vs. Packet 1)** | **Owner ruling wins.** Mark the doc section for overwrite in Step 3. |
| **True Ambiguity / Unruled Trade-off** | File as a structured Open Question (`OQ-…`) in the target `design-doc` for the owner to rule on in Step 3. Never let a scout or coordinator guess. |

If a factual claim about the current tree remains unverified at the end of Step 2, mark it with the exact machine-checkable token:
`UNVERIFIED: <claim> — not established by <packet>, checked at <commit>`

---

## 4. Step 3 — Document-First Target Architecture & Review Loop (`design-doc`)

Author the **ideal target state** strictly in documents following **`design-doc`**. Depending on scope, this is a single `design-doc` (`docs/design/<topic>.md`) or a coordinated multi-document set pairing a `design-doc` with an enduring reference `doc-constellation` (`docs/reference/<topic>/`).

### 4.1 Split by genre before writing prose

Never mix genres in one file:
- **Target `design-doc`:** What the target architecture is, the governing invariants, settled trade-offs, open questions (`OQ-…`), and the bottom Decision Ledger (`D1`, `D2`, …). Zero build-order tasks.
- **Reference (`system-doc` or `doc-constellation`):** How already-correct, enduring machinery works in the present tense. Do not put unbuilt target proposals into `docs/reference/` until Step 5 graduation.
- **Tactics card / Runbook (when applicable):** Command-by-command operational playbook. If a design doc grows terminal commands and expected outputs for every step, split that operational material into a runbook.

### 4.2 Converge through `design-doc`'s Review Iteration & Vantage Thread Protocol

Deliver the draft documents **unstaged** (or on the working branch for Vantage review) and iterate with the owner using **`design-doc`** (*Review iteration — narrative forward logic, the Vantage thread protocol, and the first-time state*) until every `OQ-…` is answered and compacted:

1. **Follow the Vantage Thread Protocol (`design-doc`):**
   When the owner asks a question or challenges a section in a Vantage thread:
   - Reply directly to the owner in the **Vantage thread** with the reasoning.
   - Ask *"What was missing or unclear in the prose that caused a smart reader to ask this?"* and **rewrite the document section on disk before replying** so a fresh reader reading the page from the top would never have the question in the first place.
   - Keep ongoing debate in the Vantage thread — never paste defensive justifications into the document body.
2. **Enforce the First-Time State Principle (`design-doc`):**
   After every review round, scrub the document so it reads as if written fresh that morning with zero process scarring. Fold answered `OQ-…` blocks directly into normative prose and compact the ruling into the bottom Decision Ledger (`D1`, `D2`, …).
3. **Enforce Topological Forward-Telling Narrative (`design-doc`):**
   Ensure every concept, domain term (with its explicit exclusion), and state input is defined *before* the first section that uses it. Eliminate circular forward-reference logic puzzles across sections.
4. **Propagate rulings across the document set:**
   When a ruling changes a state machine, invariant, or scope boundary, sweep every companion document in the same round so the decision is updated everywhere it is enforced. Run `uvx vantage-check` on all touched files before concluding each round.

---

## 5. Step 4 — Gap Analysis Against Code & High-Skill Implementation Planning

Only after the owner approves the settled target architecture (`status: accepted`, zero open `OQ-…`) do you turn back to the codebase.

### 5.1 The Unsentimental Code Gap Analysis

Compare the approved target architecture (`design-doc`) against the forensic code fact-sheet from Step 2. Classify every affected package, file, and symbol into three explicit buckets:

| Bucket | Meaning & Action |
| :--- | :--- |
| **1. DELETE (Excise Divergence)** | Code that implements a hallucinated abstraction, a dropped approach, an unrequested fallback, or a layering violation. **Must be explicitly scheduled for deletion** — not left behind as dead or "deprecated" code. |
| **2. KEEP / ADAPT** | Code whose core mechanism matches the target architecture and only needs signature, wiring, or invariant alignment. |
| **3. BUILD (Missing Target Behavior)** | New mechanisms, state transitions, or verification harnesses required by the settled `design-doc` that do not exist yet. |

### 5.2 Complete `doc-janitor` Disposition

Now that the target documents exist and the gap analysis has read every legacy source document:
- Run the `doc-janitor` **absorption check** across all superseded or duplicate documents identified in Step 1.
- Archive or delete superseded docs and rewrite all inbound links in one clean commit.

### 5.3 Author the High-Skill `implementation-plan`

Use a planning or design seat following **`implementation-plan`** to turn the Gap Analysis into a concrete, phased build plan (`docs/plans/<topic>-plan.md` or `docs/design/<topic>-plan.md`):
- **Put deletions first or atomically alongside replacements:** Never let a plan layer new target code on top of diverged code without removing the diverged path.
- **Hard rails per phase:** Every task in the plan must state:
  - `Settled`: Quoted ruling IDs (`D1`, `D2`) from the `design-doc`.
  - `Preconditions`: What must be true in the tree before starting (and when to stop and escalate).
  - `Tests first`: The exact red test to write or update before touching implementation code.
  - `Change`: Exact files/symbols to **delete**, **modify**, and **create**.
  - `Fences`: Explicit out-of-scope files and forbidden shortcuts so the implementer cannot re-introduce divergence.
  - `Gates`: Exact test and lint commands that must pass before committing the phase.

---

## 6. Step 5 — Mechanical Phased Execution & Graduation

With the target `design-doc` settled and the `implementation-plan` providing hard rails:

1. **Execute phase by phase:** Dispatch lower-cost implementation turns strictly bound to one phase of the `implementation-plan` at a time. The implementer does not re-litigate architecture; if a precondition fails, it stops and escalates.
2. **Verify deletion completeness:** At the end of implementation, verify with `rg` and `git diff --stat` that every diverged struct, flag, and workaround slated for deletion in [§5.1](#51-the-unsentimental-code-gap-analysis) is completely gone from the tree.
3. **Graduate to evergreen reference:** Once the code is built and verified against all gates, graduate the settled `design-doc` into `docs/reference/` using **`system-doc`** (for a single-file system) or **`doc-constellation`** (for a 4–8 file subsystem), and delete the completed `design-doc` and `implementation-plan` in the graduation commit.

---

## 7. Quality Checklist

- [ ] **Code freeze honored during Steps 1–4:** Zero production code files modified before the target `design-doc` and `implementation-plan` are approved ([§1.3](#13-principle-3-work-strictly-in-documents-first)).
- [ ] **Shelf cleaned (`doc-janitor`):** Inventory completed and lying frontmatter status lines repaired in an initial commit ([§2](#2-step-1--deep-clean-the-shelf-doc-janitor)).
- [ ] **Three-way archaeology completed:** Past sessions, existing docs, and current code inspected; dropped owner rulings and diverged code paths isolated in the Divergence Ledger ([§3](#3-step-2--grounding--three-way-archaeology)).
- [ ] **Target documents converged cleanly (`design-doc`):** All open questions (`OQ-…`) answered and compacted into `D1..Dn`; zero process scarring; strict topological forward narrative; Vantage Thread Protocol followed ([§4](#4-step-3--document-first-target-architecture--review-loop-design-doc)).
- [ ] **Unsentimental Gap Analysis completed:** Every diverged code path explicitly listed in the **DELETE** bucket rather than worked around ([§5.1](#51-the-unsentimental-code-gap-analysis)).
- [ ] **Superseded docs safely retired (`doc-janitor`):** Section-by-section absorption verified and inbound links rewritten ([§5.2](#52-complete-doc-janitor-disposition)).
- [ ] **High-skill `implementation-plan` authored:** Phased tasks carry `Settled`, `Preconditions`, `Tests first`, `Change` (including explicit deletions), `Fences`, and `Gates` ([§5.3](#53-author-the-high-skill-implementation-plan)).
- [ ] **`uvx vantage-check` passes clean** across every new and modified document.
