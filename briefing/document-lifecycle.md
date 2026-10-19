## Engineering documents

The documents an engineering task produces are owned by these skills. Read the
owning skill before writing its document — the skill body, not this list, is the
specification.

- **Settling what to build and why** — the architecture, the trade-offs, and the
  decisions still open — is a **`design-doc`**, written by the **designer**: the
  expensive role that holds the design. Start it when the design starts, not
  once it has settled: the open questions are the point, and they are where the
  user rules. Per-file build detail belongs in the companion
  **`implementation-plan`**, which the designer only **seeds** with what the
  design work happened to surface. It never digs through the tree for the plan,
  and "just the design doc" is a complete instruction.
- **Turning an accepted design into a build** is the **planner** role's job, and
  it starts at exactly one cue: the design's `status: accepted` with no question
  open. The planner reads the tree and completes the plan against a stamped
  commit. Until then the plan is a seed stamped `SKETCH` and nothing is built
  from it — that state, accepted design and unbuilt plan, is a stage of its own,
  not a hand-off.
- **Building it** is the **implementer** role — the cheap one that executes well
  and must not diagnose — from the completed plan alone, never from the seed or
  from the design.
- **A shipped system's reference** is a **`system-doc`**; a built design
  graduates out of the design doc into it, and the design doc is deleted.
- **Unfinished work, and the reason one effort precedes another**, is a
  **`roadmap`**, which links source documents rather than restating them.
- **Before a direction exists**, exploration is **`research`** (external
  questions), **`brainstorming`** (a choice among options), or **`user-stories`**
  (product behavior through realistic use).
- **Markdown that must pass Vantage or GitHub review** — links, directives,
  terms of art — is **`vantage-docs`**.
