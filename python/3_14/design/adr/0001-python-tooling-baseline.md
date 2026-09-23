# ADR-0001: Python tooling baseline

- **Status:** Accepted
- **Date:** 2026-09-23
- **Deciders:** project maintainers

## Context

The project needs a reproducible, standards-based setup that a new contributor
can bootstrap with one command and that CI can enforce. Python has no single
official "project template"; the normative sources are the PyPA packaging
specifications and the PEPs they come from.

## Decision

| Concern | Choice | Standard or reference |
| --- | --- | --- |
| Interpreter | CPython 3.14: `requires-python = ">=3.14"`, `.python-version` | PEP 745 (3.14 release schedule) |
| Metadata and tool config | Everything in `pyproject.toml` | PEP 517, 518, 621; PEP 639 (license) |
| Layout | `src/` layout; tests outside the package | PyPA: src layout vs flat layout |
| Environments and locking | uv; `uv.lock` is committed | uv docs (`uv export` can write PEP 751 `pylock.toml`) |
| Development dependencies | `[dependency-groups]` | PEP 735 |
| Build backend | `uv_build` | PEP 517 |
| Lint and format | Ruff: default rule set plus A, ARG, D, N, PT, PTH, S, T20; Google docstrings | PEP 8, PEP 257 |
| Type checking | mypy `strict` plus extra error codes; ships `py.typed` | PEP 484, PEP 561, typing specification |
| Tests | pytest (native `[tool.pytest]` table, strict mode, importlib import mode) and coverage.py (branch coverage, at least 90 %) | pytest good practices |
| Documentation | Sphinx with MyST Markdown and the Furo theme; API reference from docstrings (autodoc, napoleon) | PEP 257 |
| Local checks | pre-commit: file hygiene, schema checks for CI files, and ruff and mypy via `uv run` | pre-commit |
| Dependency updates | Dependabot (GitHub) or Renovate (GitLab), weekly and grouped | Dependabot, Renovate docs |
| Supply-chain security | One-week cooldown (`exclude-newer`), `uv audit` in CI, GitHub Actions pinned to commit SHAs | uv docs; GitHub security hardening guide |
| Native installers and portable builds | PyInstaller on a uv-managed CPython, packaged with NSIS (Windows), nFPM `.deb`/`.rpm` (Linux) and `hdiutil` `.dmg` (macOS), plus a portable `.zip`/`.tar.gz` per platform | PyInstaller, NSIS and nFPM docs |

## Alternatives considered

- **pip + venv + requirements files:** no lock file for the whole project and
  more manual steps.
- **Poetry / PDM / Hatch:** capable, but uv is faster and covers Python
  installation, locking, building, and tool execution in one binary.
- **hatchling or setuptools as build backend:** fully supported; switching only
  requires changing the `[build-system]` table.
- **pyright or other type checkers instead of mypy:** fine, but mypy is the
  reference implementation maintained under the Python organisation.

## Consequences

- `uv sync` bootstraps the development environment. CI runs the same commands
  as developers do, on GitHub Actions (`.github/workflows/ci.yml`) or GitLab
  CI/CD (`.gitlab-ci.yml`).
- `uv_build` is capped below its next minor release (`<0.13`); when uv 0.13 is
  released, bump the cap together with `UV_VERSION` in `.gitlab-ci.yml`
  (Renovate groups both into one merge request).
- The cooldown delays every new release by a week, security fixes included;
  `exclude-newer-package` lets an urgent fix through. Lower bounds in
  `pyproject.toml` name feature releases so they stay outside the cooldown.
- `uv audit` is experimental in uv 0.12; `pip-audit` is the stable fallback if
  its interface changes.
- pytest's strict mode also enables strictness checks added in future releases.
  That is safe because `uv.lock` pins the pytest version.
- No `from __future__ import annotations`: Python 3.14 evaluates annotations
  lazily (PEP 649 and PEP 749).
