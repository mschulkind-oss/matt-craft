# matt-craft

> Matt Schulkind's workflow and documentation skills for AI-assisted engineering.

`matt-craft` is an opinionated suite of 8 workflow and documentation skills for AI-assisted engineering. It structures the way developers and AI coding agents collaborate—moving architectural decisions out of ephemeral, rotting chat windows into a durable, machine-verifiable Markdown document lifecycle.

---

## The Skills

| Skill | Trigger / Description |
| :--- | :--- |
| **[`brainstorming`](skills/brainstorming/SKILL.md)** | Use when exploring, comparing, or ranking candidate ideas before choosing an architectural direction. |
| **[`design-doc`](skills/design-doc/SKILL.md)** | Use when designing or revising a feature, system, or architecture that requires settled decisions and explicit Open Questions. |
| **[`implementation-plan`](skills/implementation-plan/SKILL.md)** | Use when a settled design needs a concrete, file-by-file build hand-off grounded in the current repository tree. |
| **[`research`](skills/research/SKILL.md)** | Use when investigating, evaluating, comparing, or looking into a topic, tool, library, or design space for a project. |
| **[`roadmap`](skills/roadmap/SKILL.md)** | Use when tracking open questions and workstreams across multiple designs into a single high-level altitude view. |
| **[`system-doc`](skills/system-doc/SKILL.md)** | Use when documenting how an implemented system works, graduating a shipped design, or re-verifying a system reference. |
| **[`user-stories`](skills/user-stories/SKILL.md)** | Use when exploring a product or feature through realistic narrative workflows and the gaps they expose. |
| **[`vantage-docs`](skills/vantage-docs/SKILL.md)** | Use when authoring, formatting, reviewing, or render-verifying Markdown documentation for Vantage and GitHub. |

---

## The Document Lifecycle

This suite encodes a disciplined document state machine for AI-assisted engineering:

```
┌──────────────┐     ┌──────────────┐     ┌─────────────────────┐     ┌──────────────────┐
│   RESEARCH   │ ──> │  DESIGN DOC  │ ──> │ IMPLEMENTATION PLAN │ ──> │ TASK CHECKLIST & │
│ (Exploration)│     │  (Decisions) │     │     (Grounding)     │     │   VERIFICATION   │
└──────────────┘     └──────────────┘     └─────────────────────┘     └──────────────────┘
                            │
                            ▼
                     ┌──────────────┐
                     │   ROADMAP    │ (Cross-design routing & high-level altitude)
                     └──────────────┘
```

1. **Explore (`/research`, `/brainstorming`, `/user-stories`):** Survey constraints, map edge cases, and evaluate options before committing to code.
2. **Decide (`/design-doc`):** Capture architecture with explicit, machine-readable Open Questions and a decision ledger.
3. **Track (`/roadmap`):** Aggregate open questions, rulings, and execution states across all active design docs. The roadmap acts as an altitude router—giving you a single-pane view of what needs a decision next across the whole project.
4. **Plan (`/implementation-plan`):** Ground settled designs into task checklists tied directly to current repository paths.
5. **Graduate (`/system-doc`):** Transition completed designs into permanent system references with freshness tracking.

---

## Enhanced by Vantage

While `matt-craft` skills work in any Markdown-compatible environment, they are designed to pair with [Vantage](https://github.com/mschulkind-oss/vantage):

- **Invisible in Standard Markdown:** Skills embed review directives and decision metadata using standard HTML comments (e.g. `<!-- vantage: oq id=... leaning="..." -->`). On GitHub, VS Code, or standard Markdown viewers, these are completely invisible—your documents stay clean and readable.
- **Interactive in Vantage:** When opened with Vantage, those hidden comments are parsed into interactive decision widgets, live status badges, and review threads without leaving your local terminal flow.
- **Mechanical Link & Quality Verification:** The [`vantage-docs`](skills/vantage-docs/SKILL.md) skill and `uvx vantage-check` verify broken relative links, frontmatter validity, and term definitions automatically before you commit.

---

## Installation & Compatibility

These skills are plain Markdown prompt templates and work with any coding agent, model, or harness that supports skills.

### As a Claude Code Plugin

Install directly via the Claude Code plugin manager:

```bash
claude plugin install github:mschulkind-oss/matt-craft
```

Once installed, invoke skills with standard slash commands (e.g. `/design-doc` or namespaced `/matt-craft:design-doc`).

### With Other Agents and Sandboxes

The repository layout follows standard agent skill conventions:
- Each skill lives in `skills/<name>/SKILL.md` with YAML frontmatter triggers (`description: Use when...`).
- Fully compatible with tools and container sandboxes that consume Git-based skill packs (such as [`yolo-jail`](https://github.com/mschulkind-oss/yolo-jail) via `"packs": ["git+https://github.com/mschulkind-oss/matt-craft"]`).

---

## Development & Verification

Skills in this repository are verified with:

```bash
just done
```

- `just test` validates YAML frontmatter, `Use when` triggers, and resolves local references.
- `just check` runs `uvx vantage-check` across all documentation and skill files.

---

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
