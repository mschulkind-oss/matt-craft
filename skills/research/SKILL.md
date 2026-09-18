---
name: research
description: Use when investigating, evaluating, comparing, or looking into a topic, tool, library, or design space for a project.
---

# Research

Research is cumulative. Every round starts from what the project already knows and ends with the knowledge base knowing more. The failure mode this skill exists to prevent: burning a session rediscovering what a previous session already wrote down.

## The loop

1. **Read first.** Skim `docs/research/` before any web search. If a domain doc exists, it is the starting point — not a blank page. If the KB already answers the question, stop there: report the answer and skip the web entirely.
2. **Investigate.** Web search, source reading, and local experiments to fill the gaps the existing docs don't cover — only the gaps.
3. **Synthesize back.** End the round by updating the evergreen domain doc so the next round starts ahead. A round that produces only chat output is a failed round; the doc is the deliverable.
4. **Push what the round changed onto the roadmap.** A finding that rules an option out, or that opens a decision only the user can make, is invisible at the bottom of a domain doc. Wherever the project keeps a roadmap (`roadmap.md` at the root, or the local equivalent; see **`roadmap`**), the ruling-out lands on the thread it affects and the decision becomes a `💬` **Attention Required** item — same commit as the doc update. Most rounds change nothing outside their own doc and need no roadmap edit; the ones that unblock or block work always do.

## Two artifact kinds

- **Evergreen domain doc** — `docs/research/<domain>.md`. One per domain, updated every round, organized by topic rather than by date. This is the durable artifact and what future rounds read first.
- **Dated log** — `docs/research/YYYY-MM-DD_<topic>.md`. Optional trail for a single deep investigation: what was tried, what was ruled out, in what order. Fine to write, but never the only output — the salient findings still land in the domain doc.

## Writing conventions

Follow the **`vantage-docs`** style guide for core Markdown formatting (YAML frontmatter, callout alerts, Mermaid diagrams, KaTeX math, tables, line anchors).

- **Terms carry provenance too.** Research is the border crossing where the field's vocabulary enters the tree, so a term arrives with the link that defines it — the spec, the paper, the vendor's own docs — not with a confident gloss you reconstructed from context. Vocabulary the field genuinely disputes is a finding: say who uses it which way. See the **Defined Terms** section of the `vantage-docs` skill.
- **Findings carry provenance.** Distinguish verified-from-source ("re-analyzed FROM SOURCE, 2026-08-12"), read-in-docs, and inferred — and date the check. A claim someone will build on gets a link and a check date, not vibes.
- **Perishable facts are fenced.** Prices, model capabilities, API limits, version windows: collect them under a `## Fast-moving — verify before building` section so a future reader knows what to re-check instead of what to trust.
- **Evaluations end in verdicts.** When comparing options, each gets an explicit disposition — "rejected: 5× the code for this scope", "shortlisted", "adopt for v1". A comparison table with no conclusion just pushes the decision onto the next reader.
- **Dead ends are findings.** Record what was ruled out and why; otherwise the next round re-walks the same path.
- **Sources are annotated.** A Sources / See also list gives one line of *why* per link, never a bare URL dump.
- **Decisions only the user can make** use the Open Questions format from the `design-doc` skill (status emoji `💬`/`✅`, bold title, stakes, `_Leaning:_`, fill-in `**Answer:**` blockquote, and the `oq` directive that makes it answerable in one click) — in the research doc itself, or graduated into a design doc when the research turns into a design.
