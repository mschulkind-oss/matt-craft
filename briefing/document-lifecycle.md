## Engineering documents

The documents an engineering task produces are owned by these skills. Read the
owning skill before writing its document — the skill body, not this list, is the
specification.

- **Settling what to build and why** — the architecture, the trade-offs, and the
  decisions still open — is a **`design-doc`**. Start it when the design starts,
  not once it has settled: the open questions are the point, and they are where
  the user rules. Per-file build detail belongs in the companion
  **`implementation-plan`**, which opens as a sketch while the design is open
  and must not be built from while it is one.
- **A shipped system's reference** is a **`system-doc`**; a built design
  graduates out of the design doc into it, and the design doc is deleted.
- **Unfinished work, and the reason one effort precedes another**, is a
  **`roadmap`**, which links source documents rather than restating them.
- **Before a direction exists**, exploration is **`research`** (external
  questions), **`brainstorming`** (a choice among options), or **`user-stories`**
  (product behavior through realistic use).
- **Markdown that must pass Vantage or GitHub review** — links, directives,
  terms of art — is **`vantage-docs`**.
