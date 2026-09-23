# AGENTS.md

Instructions for AI coding agents working in this repository. Humans should
start with [README.md](README.md).

## Project

- Python 3.14 package `my_project` (distribution name `my-project`) in a `src/`
  layout, managed with [uv](https://docs.astral.sh/uv/).
- `src/my_project/`: the package. `__main__.py` is the command-line interface;
  domain logic lives in modules such as `core.py`, free of I/O.
- `tests/unit/` (fast, isolated) and `tests/integration/` (subprocesses, files);
  pytest, no `__init__.py` files in `tests/`.
- `docs/`: user documentation, Sphinx with MyST Markdown.
- `design/`: architecture overview and architecture decision records (ADRs).

## Commands

Run every tool through uv so the versions locked in `uv.lock` are used.

| Task | Command |
| --- | --- |
| Set up or refresh the environment | `uv sync` |
| Format | `uv run ruff format` |
| Lint, with safe auto-fixes | `uv run ruff check --fix` |
| Type-check | `uv run mypy` |
| Test | `uv run pytest` |
| Build the documentation | `uv run --group docs sphinx-build --fail-on-warning docs docs/_build/html` |
| All pre-commit hooks | `uv run pre-commit run --all-files` |

A change is complete when formatting, linting, type-checking, the tests, and the
documentation build all pass.

## Conventions

- Manage dependencies with `uv add` and `uv remove` (`--group dev` or
  `--group docs` for tooling). Never edit `uv.lock` by hand.
- Type-annotate all code; mypy runs in strict mode. Do not add
  `from __future__ import annotations`, since Python 3.14 evaluates annotations
  lazily.
- Write Google-style docstrings for public modules, classes, and functions.
- Use `pathlib` instead of `os.path`. Only the CLI prints; library code returns
  values or raises exceptions.
- Do not silence a lint or type error (`# noqa: CODE`, `# type: ignore[code]`)
  without a comment that explains why.
- Add tests for every behaviour change; branch coverage must stay at 90 % or more.
- Record user-visible changes under **Unreleased** in `CHANGELOG.md`, and
  significant design decisions as a new ADR in `design/adr/`.
