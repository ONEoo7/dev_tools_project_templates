# Design

Engineering design documentation for **my-project**: the *why* and *how* behind
the code. User-facing documentation (usage guide, API reference) lives in
[`docs/`](../docs/) and is built with Sphinx.

| Path | Contents |
| --- | --- |
| [`architecture.md`](architecture.md) | Architecture overview: goals, context, building blocks, runtime and deployment. |
| [`adr/`](adr/) | Architecture Decision Records: one file per significant decision. |
| [`diagrams/`](diagrams/) | Diagram sources (Mermaid `.mmd`, PlantUML `.puml`, draw.io `.drawio`) and their exports. |

## Conventions

- Prefer text-based diagrams. Mermaid renders natively on GitHub, and diagrams
  kept as text can be diffed and reviewed like code.
- To record a decision, copy [`adr/0000-template.md`](adr/0000-template.md) to
  `adr/NNNN-short-title.md` using the next free number.
- Accepted ADRs are immutable. To change a decision, write a new ADR and mark
  the old one `Superseded by ADR-NNNN`.
