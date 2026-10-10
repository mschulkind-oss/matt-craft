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
| **[`roadmap`](skills/roadmap/SKILL.md)** | Use when prioritizing unfinished work with readable ordering reasons while source documents own planning state. |
| **[`system-doc`](skills/system-doc/SKILL.md)** | Use when documenting how an implemented system works, graduating a shipped design, or re-verifying a system reference. |
| **[`user-stories`](skills/user-stories/SKILL.md)** | Use when exploring a product or feature through realistic narrative workflows and the gaps they expose. |
| **[`vantage-docs`](skills/vantage-docs/SKILL.md)** | Use when authoring, formatting, reviewing, or render-verifying Markdown documentation for Vantage and GitHub. |

The pack also ships a briefing, [`briefing/document-lifecycle.md`](briefing/document-lifecycle.md), that names each skill by the situation that calls for it. Installed as an agent pack, it reaches the agent's context, so the trigger is read as a rule rather than only as a catalog entry.

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
3. **Prioritize (`/roadmap`):** Order unfinished work and explain why one effort precedes another. Source documents own their stage, next step, dependencies, and questions; the roadmap links them without copying state. Descriptive links and short annotations remain useful without Vantage's badges.
4. **Plan (`/implementation-plan`):** Ground settled designs into task checklists tied directly to current repository paths.
5. **Graduate (`/system-doc`):** Transition completed designs into permanent system references with freshness tracking.

---

## Enhanced by Vantage

While `matt-craft` skills work in any Markdown-compatible environment, they are designed to pair with [Vantage](https://github.com/mschulkind-oss/vantage):

- **Invisible in Standard Markdown:** Skills embed review directives and decision metadata using standard HTML comments (e.g. `<!-- vantage: question id=... leaning="..." -->`). On GitHub, VS Code, or standard Markdown viewers, these are completely invisible—your documents stay clean and readable.
- **Interactive in Vantage:** When opened with Vantage, those hidden comments are parsed into interactive decision widgets, live status badges, and review threads without leaving your local terminal flow.
- **Mechanical Link & Quality Verification:** The [`vantage-docs`](skills/vantage-docs/SKILL.md) skill and `uvx vantage-check` cover broken relative links and frontmatter validity before you commit. Term definitions still require author review.

---

## Installation & Compatibility

These skills are plain Markdown prompt templates and work with any coding agent, model, or harness that supports skills.

### With yolo-jail

Add `matt-craft` to the `packs` array in your host's user config at `~/.config/yolo-jail/config.jsonc`, alongside your existing agent packs:

```jsonc
{
  "packs": [
    "claude",
    "git+https://github.com/mschulkind-oss/matt-craft"
  ]
}
```

Keep your existing entries; `claude` is an example agent pack. Packs belong in the user config, not the workspace config. Restart your jail to make the skills available to your configured agents. See [yolo-jail](https://github.com/mschulkind-oss/yolo-jail) for setup details.

### As a Claude Code Plugin

Register the GitHub-hosted marketplace (a catalog of installable plugins), then install the plugin:

```bash
claude plugin marketplace add mschulkind-oss/matt-craft
claude plugin install matt-craft@matt-craft
```

Once installed, invoke a skill as `/matt-craft:design-doc` (or select it from Claude Code's skill list).

### With Other Agents and Sandboxes

The repository layout follows standard agent skill conventions:
- Each skill lives in `skills/<name>/SKILL.md` with YAML frontmatter triggers (`description: Use when...`).
- Fully compatible with tools and container sandboxes that consume Git-based skill packs.

---

## Development & Verification

Edit public skills directly in this repository and commit them with a description
of the actual change. Publication pushes those existing commits; it does not copy
from another authoring tree or create commits during deployment.

Skills in this repository are verified with:

```bash
just done
```

- `just test` validates YAML frontmatter, `Use when` triggers, local references,
  status-script behavior, and copyable question examples (requires Python 3).
- `just check` runs `uvx vantage-check` across README and skill bodies.

Planning guidance names Vantage 0.8.0 explicitly. An older checker cannot verify
that notation; never delete valid directives or change the human-owned `target`
just to satisfy it. See [checker selection](skills/vantage-docs/SKILL.md#getting-the-binary).
The example test checks question directives and title shape statically,
then checks extracted specimens as real Markdown with `uvx vantage-check@0.8.0`,
and fails, never skips, on a checker older than 0.8.0. To test with another build, run:

```bash
VANTAGE_CHECK=/path/to/vantage-check python3 tests/question-examples.test.py
```

The shipped style-guide snapshot is `uvx vantage-check@0.8.0 style-guide` output, first line included. Regenerate it only from a published release.

---

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
