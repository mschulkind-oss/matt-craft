# matt-craft

> Matt Schulkind's workflow and documentation skills for AI-assisted engineering.

`matt-craft` is an opinionated suite of 8 agentic workflow skills for Claude Code, Codex, and YOLO jails. It structures the way developers and AI agents collaborate—moving architectural decisions out of ephemeral, rotting chat windows into a durable, machine-verifiable Markdown document lifecycle.

---

## The Skills

| Skill | Trigger / Description |
| :--- | :--- |
| **[`brainstorming`](skills/brainstorming/SKILL.md)** | Use when a user wants to explore, compare, or rank ideas before choosing a direction. |
| **[`design-doc`](skills/design-doc/SKILL.md)** | Use when designing or revising a feature, system, or architecture that needs settled decisions. |
| **[`implementation-plan`](skills/implementation-plan/SKILL.md)** | Use when a settled design needs a build hand-off grounded in the current repository tree. |
| **[`research`](skills/research/SKILL.md)** | Use when investigating, evaluating, comparing, or looking into a topic, tool, library, or design space for a project. |
| **[`roadmap`](skills/roadmap/SKILL.md)** | Use when creating, updating, reconciling, or compacting a project's living roadmap. |
| **[`system-doc`](skills/system-doc/SKILL.md)** | Use when documenting how an implemented system works, graduating a shipped design, or re-verifying a system reference. |
| **[`user-stories`](skills/user-stories/SKILL.md)** | Use when exploring a product or feature through realistic narrative workflows and the gaps they expose. |
| **[`vantage-docs`](skills/vantage-docs/SKILL.md)** | Use when authoring, formatting, reviewing, or render-verifying Markdown documentation for Vantage and GitHub. |

---

## Installation

### As a Claude Code Plugin

Install directly from GitHub via the Claude Code plugin manager:

```bash
claude plugin install github:mschulkind-oss/matt-craft
```

Once installed, invoke skills with standard Claude slash commands (e.g. `/design-doc` or namespaced `/matt-craft:design-doc`).

### As a YOLO Jail Pack

In your host `~/.config/yolo-jail/config.jsonc` (or project `yolo-jail.jsonc`), add the Git repository to your pack roster:

```jsonc
"packs": [
  "git+https://github.com/mschulkind-oss/matt-craft"
]
```

YOLO natively discovers [`.claude-plugin/plugin.json`](.claude-plugin/plugin.json), extracts the skills, and distributes them across all configured agent directories (`.claude/skills`, `.pi/agent/skills`, `.codex/skills`, `.gemini/skills`).

---

## The Document Lifecycle

This suite encodes a disciplined document lifecycle for pair programming with AI agents:

```
┌──────────────┐     ┌──────────────┐     ┌─────────────────────┐     ┌──────────────────┐
│   RESEARCH   │ ──> │  DESIGN DOC  │ ──> │ IMPLEMENTATION PLAN │ ──> │ TASK CHECKLIST & │
│ (Exploration)│     │  (Decisions) │     │     (Grounding)     │     │   VERIFICATION   │
└──────────────┘     └──────────────┘     └─────────────────────┘     └──────────────────┘
```

1. **Research (`/research`):** Survey the landscape, gather constraints, and document trade-offs without committing to architecture prematurely.
2. **Design (`/design-doc`):** Draft the system architecture with explicit, machine-readable Open Questions (`<!-- vantage: oq -->`) and a decision ledger.
3. **Plan (`/implementation-plan`):** Once decisions are settled, ground the build into concrete, file-by-file tasks and verification commands against the active repository tree.
4. **Graduation (`/system-doc`):** Once implemented and verified, graduate the design doc into a permanent, living system reference.

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
