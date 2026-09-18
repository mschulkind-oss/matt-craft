---
name: user-stories
description: Use when exploring a product or feature through realistic narrative workflows and the gaps they expose.
---
# Narrative User Stories Skill

Write user stories as **concrete narratives** — not abstract cards. Each story follows a named persona through a real workflow, step by step, with actual CLI commands, real output, and honest gap analysis. The goal is to discover what works, what breaks, and what's missing by *telling the story of someone using the thing*.

## When to Use This Skill

- Exploring a new feature or system design
- Validating workflows before implementation
- Discovering gaps, friction, and edge cases
- Communicating intent to a team (human or agent)
- Designing progressive feature layers

## Where the doc lands

**The planning tree, always** — `docs/planning/<topic>.md` where the repo has
one, otherwise `docs/design/user-stories-<topic>.md` beside the design work it
feeds. Never in a reference or guides tree.

A user story is a **design instrument, not a record of the system**. It walks a
workflow that may not exist yet, and its most valuable output — the inline gaps —
describes things that are *missing*. Filed next to evergreen documentation, all
of that reads as a description of how the thing works, and a reader has no way to
tell the built behavior from the intended one. Filed in the planning tree, the
speculation is legible as speculation.

The corollary: when the stories have been built, they do not graduate into
reference docs. `system-doc` writes what the system actually does, from the code;
the story stays in planning as the record of what was being aimed at, or is
deleted with the rest of the planning artifacts for that feature.

Filename is a content noun (`inbox-triage.md`, `worktree-handoff.md`) — never a
date, never prefixed with the tool that wrote it.

## The roadmap is where the gaps become work

Gaps are this document's most valuable output and its most easily stranded:
findings buried inline in a narrative that nobody re-reads once it is written.
Close the loop on the roadmap in the same commit, wherever the project keeps one
(`roadmap.md` at the root, or the local equivalent) — the states and the
archiving rules belong to **`roadmap`**:

- **A gap accepted as work** becomes its own roadmap item, linking the story that
  found it. Not every gap — a gap is a finding, and only some findings are work.
- **An open question here** is a `💬` **Attention Required** item there, carrying
  the same stakes and leaning. The user answers questions from the roadmap.
- **The story doc itself** gets a thread while it is feeding an active design, so
  the work it implies is visible without reading the narrative.

## Document Structure

Every user story document follows this structure:

```markdown
# User Stories: [Topic]

[1-3 sentences framing what this document explores. Not a spec —
a statement of the territory. End with the lens you're using.]

---

## 1. Persona — Role, Situation

**Context:** [Who they are, what they need, why they're here.
Concrete: project type, team size, tools they use, pain they feel.
Not "a developer" — "Maya has a Rust CLI with 40 GitHub issues and
no formal tracking."]

**[Phase label]:**

1. [Step with exact command or action]
   ```
   [Actual CLI output, JSON payload, or UI state they see]
   ```

2. [Next step — what they do with the result]

   **Gap:** [Something missing or broken, discovered by telling
   the story. Inline, right where the friction occurs.]

3. [Continue the workflow...]

**What would trip them up:**
- [Friction point — not a bug, but a "wait, how do I...?" moment]
- [Missing connection between steps]
- [Assumption that won't hold for all users]

**What makes this work:**
- [Why this flow succeeds when it does]
- [Key design property that enables the experience]

---
```

### Phase Labels

Use whatever label fits the story's arc. Common ones:

| Label | When to use |
|-------|-------------|
| **First 10 minutes:** | Onboarding, discovery, first-time experience |
| **What happens:** | Standard workflow, normal path |
| **What happens today:** / **What happens with [X]:** | Before/after contrast |
| **The first agent run:** | When agents enter the picture |
| **The QA moment:** | Human review, approval, quality gates |
| **The next morning:** | Async results, overnight processing |

## Personas

### Rules

1. **Always named.** Not "a user" or "the developer." Maya, Sam, Kenji, Val, Lisa, Derek, Priya.
2. **Always situated.** Role + context: "Sam — Solo Developer, Side Project with Agents"
3. **Persistent across documents.** If Maya appeared in a previous doc, she's the same Maya. Her context accumulates.
4. **Mix human and agent personas.** Agents are users too — they have workflows, friction points, and needs.
5. **Include non-technical personas.** Lisa doesn't read code. Derek wants the simplest possible version. These personas stress-test your design.
6. **Cover the spectrum.** At minimum: power user, new user, non-technical stakeholder, and agent.

### Persona Header Format

```markdown
## 3. Lisa — Product Owner, Only Touches the UI
```

The number is sequential within the document. The dash separates name from role/situation.

## Story Content

### Technical Realism

- **Exact CLI commands** — copy-paste ready, not pseudocode
- **Actual output** — what the terminal or UI really shows, including formatting
- **Real numbers** — "38 features" not "several features"; "12 seconds" not "quickly"
- **Real file paths** — `.tillr/worktrees/global-inbox/` not "the workspace directory"
- **Error messages** — show what failure actually looks like
- **Code snippets** — SQL schemas, JSON payloads, Go/TypeScript when relevant

### Gap Discovery

Gaps are the most valuable output. They surface **inline**, right where the friction occurs — not in a separate section at the end.

```markdown
3. Sam opens the workstream page. He sees "1 item needs QA." He clicks
   through to the feature. He sees... the feature name, description, and
   status.

   **Gap:** There's no test plan. No "here's what to check." No screenshots.
   Sam has to figure out what changed and whether it's right by reading
   code or just trying the app.

   What Sam needs to see:
   - What the agent did (summary, not the full diff)
   - What to verify (human-readable checklist)
   - Screenshots if it's UI work
   - A big approve/reject button with a notes field
```

### Holes vs. Gaps

A **gap** is a finding: the system doesn't do the thing, and the story marks it inline. A **hole** is a defect in the document: the story implied behavior and never said what it is. To whoever builds from this doc the two read identically, and only one of them is supposed to be there.

Narrative makes holes cheap to create. A story follows one path and says nothing about the others — "Derek clicks [Merge]" is silent on the merge that conflicts, the double-click, the empty queue. That silence is invisible while writing and expensive later: an implementer fills it with a plausible guess, and the guess compiles.

Where a story is what an implementer gets — no design doc between it and the code — hold it to `design-doc`'s *Completeness* bar. Every question someone must answer to build it is **answered in the story**, **opened as a question** with a stable ID, or **delegated in as many words** ("error wording is theirs"). Silence is the only illegal state. The `**What would trip them up:**` section is the natural place to walk the paths the narrative skipped.

### Before/After Contrast

When exploring a new capability, show the current state first:

```markdown
**What happens today:**

All 3 agents work in the same working tree, on main. If they touch
different files, they can commit sequentially. If they touch the same
file, one agent's commit overwrites the other's changes — silent data
loss. There's no isolation and no review step.

**What happens with agent PRs:**

1. Each agent claims a feature. Tillr creates an isolated workspace...
```

### Progressive Layers (The Derek Pattern)

When a system has optional complexity, show the minimal version first:

```markdown
## 6. Derek — Just the Simple Version

**Context:** Derek doesn't want merge queues yet. He just wants branches
and merge buttons. He'll add the queue later.

**The minimal workflow:**

1. Agent claims → tillr creates branch + worktree
2. Agent implements → commits to branch
3. Agent submits → PR record created, feature to human-qa
4. Derek reviews in UI → sees diff, validation results
5. Derek clicks [Merge] → branch merges to main, cleanup
6. Done.

No queue. No rebase. No preview server. No conflict detection. Just
isolated branches with a merge button.

**This is Layer 1.** Everything else builds on top:
- Layer 2: Add diff viewer in UI
- Layer 3: Add conflict detection (advisory warnings)
- Layer 4: Add merge queue (sequential rebase + validate + merge)
- Layer 5: Add preview server
- Layer 6: Add agent reviews
```

## Closing Sections

### Analysis Sections (per story)

End each story with one or more of these (use whichever fit):

| Section | Purpose |
|---------|---------|
| **What would trip them up:** | Friction, confusion, missing affordances |
| **What makes this work:** | Key design properties that enable the experience |
| **Technical reality check:** | Constraints, performance, scaling concerns |
| **The aha moment:** | When the user "gets it" — what makes them stay |

### Technical Architecture (per document, optional)

When the stories imply technical decisions, add a section at the end with:
- SQL schemas
- Status flow diagrams (ASCII)
- CLI command tables
- Config file examples
- Background process pseudocode

### Open Questions (per document, required)

Every document ends with open questions. These are **unresolved design decisions** surfaced by the stories — not TODOs or bugs.

Use status emojis at the start of each question title for immediate scanning:
- 💬 **Open Question:** Active decision awaiting user ruling.
- 💬 🤷 **Deferred Question:** Pure subjective user preference where agent has no technical recommendation.
- ✅ **Answered / Resolved:** Decided question (recorded in place with resolution date).
- 🔒 **Blocked:** Blocked on an upstream decision or external input before it can be answered.

```markdown
## Open Questions

1. 💬 **OQ-1: Queue position on re-entry.** When a PR fails and the agent fixes
   it, does it go to the back of the queue or retain its position?

   <!-- vantage: oq id=OQ-1 leaning="Back of the queue — the fix might interact with what merged while it was out." -->

   _Leaning:_ Back of the queue — the fix might interact with things
   that merged while it was out.

   **Answer:**
   > _(empty — fill in when decided)_

2. 💬 🤷 **OQ-2: Concurrent agents sharing the DB.** Multiple agents write to the
   DB simultaneously. SQLite WAL mode handles reads, but writes are
   serialized.

   <!-- vantage: oq id=OQ-2 leaning="A 5s busy timeout, so a contended write waits instead of failing." -->

   _Leaning:_ Set a busy timeout of 5 seconds to avoid "database is
   locked" errors under load.

   **Answer:**
   > _(empty — fill in when decided)_
```

**Format rules for Open Questions:**

- **Emoji prefix + stable ID + bold question title** on the first line — status emoji (💬, 💬 🤷, ✅, 🔒), the id, then a bold sentence fragment or direct question.
- Context and reasoning on the following lines (plain text)
- `_Leaning:_` (italic) — your current best guess, with brief rationale
- **`Answer:`** on its own line, followed by a blockquote
- An **`oq` directive** on every 💬 question that states a leaning, indented inside the list item with blank lines around it, carrying the id and the leaning restated in words. Without it the question renders with nothing for the reviewer to click, and `vantage-check` reports it as an error. See the **`design-doc`** skill, which owns this format.
- The blockquote starts with `_(empty — fill in when decided)_` as placeholder
- The human fills in their answer in the blockquote **without erasing anything**
- When processed: flip `💬` to `✅`, append `— RESOLVED (<date>)` to the title. When settled or when compacting, migrate the ruling into the story body, preserve any refuted traps as warnings, and compact into a Decision Ledger table.

**Answered example:**

```markdown
3. ✅ **OQ-3: Merge commit message format — RESOLVED (2026-08-16).** What should the merge queue put in
   the commit message?

   _Leaning:_ Include feature name, priority, approver, and a reference
   to the PR record.

   **Answer:**
   > Use the format: "Merge: {feature} (PR #{id})" with feature name,
   > priority, and workstream in the body. Skip approver — it's in the
   > PR record already.
```

## Writing Style & Formatting

Follow the **`vantage-docs`** style guide for core Markdown formatting (YAML frontmatter, callout alerts, Mermaid diagrams, KaTeX math, tables, line anchors) and for its rule that a reference — a question id, a section number, a filename — is written as a link.

- **Present tense.** "Sam opens the dashboard" not "Sam would open the dashboard."
- **Concrete, not abstract.** Show the command, the output, the screen state.
- **Conversational but precise.** Technical accuracy in a readable voice.
- **Let the story reveal the design.** Don't state requirements — show someone hitting them (or missing them).
- **Include failure.** Stories where everything works are boring and useless. Show what breaks.
- **No filler.** Every paragraph either advances the workflow, reveals a gap, or explains a design property.

## Document Variants

### Exploratory (default)

Broad, many personas, lots of gaps and open questions. Used early in design.
- 5-10 stories per doc
- Long context sections
- Many `**Gap:**` callouts
- Large open questions section

### Feature Design

Deep dive into one capability. Technical architecture included.
- 3-6 stories, all exploring the same feature from different angles
- Before/after contrast with "What happens today"
- SQL schemas, status flows, CLI tables at the end
- Fewer gaps (more decisions already made)

### First-Time Experience

Focuses on onboarding. Every story starts from zero.
- "First 10 minutes" is always the first phase
- "The aha moment" appears in most stories
- Installation friction is called out explicitly
- Empty states and missing guidance are primary gap categories

## Quality Checklist

Before finalizing a user stories document:

- [ ] Every story has a named persona with concrete context
- [ ] CLI commands and output are copy-paste realistic
- [ ] At least one story shows what happens when things go wrong
- [ ] Paths the narrative skipped are answered, opened as questions, or delegated — no silent holes left to be guessed
- [ ] Gaps are inline, not deferred to a separate section
- [ ] Gaps accepted as work, and every open question, are on the roadmap — not stranded inline
- [ ] Open questions have status emoji (💬/✅), leaning, and answer placeholder
- [ ] At least one non-technical or minimal-complexity persona (a "Derek")
- [ ] Numbers are real (not "several" or "a few")
- [ ] The document title says what it explores, not what it specifies
