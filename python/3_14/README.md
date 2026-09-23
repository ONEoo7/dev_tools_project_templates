# my-project

One-line description of my-project.

> **Using this template**
>
> 1. Copy this directory to a new repository.
> 2. Rename `src/my_project/`, then replace every `my_project` and `my-project`
>    in the files with your import name and distribution name.
> 3. Update the `[project]` metadata in `pyproject.toml` (description, authors,
>    license) and `author` in `docs/conf.py`.
> 4. Keep the files for your platform and delete the others: `.github/` (GitHub
>    Actions, Dependabot) on GitHub; `.gitlab-ci.yml` and `renovate.json` on
>    GitLab.
> 5. Run `uv sync` and commit the generated `uv.lock`; CI installs with
>    `uv sync --locked`.
> 6. Go through [`TASKS.md`](TASKS.md) and keep the additions that fit the
>    project.
> 7. Delete this note.

## Requirements

- [Python 3.14](https://docs.python.org/3.14/whatsnew/3.14.html); run
  `uv python install 3.14` if it is missing
- [uv](https://docs.astral.sh/uv/) 0.11 or newer (enforced by `required-version`
  in `pyproject.toml`)

## Quick start

Install uv if you don't have it yet. The scripts run Astral's official
installer and do nothing if uv is already installed:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install-uv.ps1   # Windows
```

```bash
sh scripts/install-uv.sh                                          # Linux and macOS
```

Then set up the project:

```bash
uv sync                    # create .venv and install the project with its dev tools
uv run pre-commit install  # run the checks on every commit
uv run my-project Ada      # prints "Hello, Ada!"
```

## Development

| Task | Command |
| --- | --- |
| Format | `uv run ruff format` |
| Lint (with auto-fix) | `uv run ruff check --fix` |
| Type-check | `uv run mypy` |
| Run all tests | `uv run pytest` |
| Run unit tests only | `uv run pytest tests/unit` |
| Tests with coverage | `uv run pytest --cov` |
| Run all pre-commit hooks | `uv run pre-commit run --all-files` |
| Build the documentation | `uv run --group docs sphinx-build --fail-on-warning docs docs/_build/html` |
| Audit dependencies | `uv audit` |
| Build sdist and wheel | `uv build` |

All tool settings live in [`pyproject.toml`](pyproject.toml). CI runs the same
checks: [`.github/workflows/ci.yml`](.github/workflows/ci.yml) on GitHub Actions,
[`.gitlab-ci.yml`](.gitlab-ci.yml) on GitLab CI/CD (which also publishes test,
coverage, and code-quality reports to merge requests).
[`AGENTS.md`](AGENTS.md) gives AI coding agents the same commands and
conventions; [`CLAUDE.md`](CLAUDE.md) imports it for Claude Code.

## Dependencies

- Add and remove dependencies with `uv add` and `uv remove` (`--group dev` or
  `--group docs` for tooling). `uv lock --upgrade` upgrades everything.
- **Cooldown:** `exclude-newer = "1 week"` in `pyproject.toml` makes uv ignore
  releases younger than a week, which keeps most compromised releases out
  ([uv docs](https://docs.astral.sh/uv/concepts/resolution/)).
- **Updates:** Dependabot (GitHub) or Renovate (GitLab) opens grouped weekly
  update requests, with the same one-week cooldown. GitLab has no built-in
  Renovate: run it with [renovate-runner](https://gitlab.com/renovate-bot/renovate-runner)
  or another [supported option](https://docs.renovatebot.com/getting-started/running/),
  and give it a read-only GitHub token (`RENOVATE_GITHUB_COM_TOKEN`) so it can
  look up the pre-commit hooks, which are hosted on GitHub.
- **Vulnerabilities:** CI runs `uv audit` (OSV database) in every pipeline and
  weekly: GitHub Actions has the schedule built in; on GitLab, add a pipeline
  schedule. `uv audit` is still marked experimental in uv 0.12.

## Releasing

1. Move the entries under **Unreleased** in [`CHANGELOG.md`](CHANGELOG.md) to a
   new version heading, for example `## [0.2.0] - 2026-10-01`.
2. Bump the version with `uv version --bump minor` (or `patch` or `major`); this
   updates `pyproject.toml` and `uv.lock`.
3. Commit, tag the release with `git tag "v$(uv version --short)"`, and push the
   tag.
4. Build the distributions with `uv build`; publish them with `uv publish` if the
   project is released to a package index.

## Project layout

```text
.
├── .github/
│   ├── dependabot.yml         GitHub: weekly dependency updates
│   └── workflows/ci.yml       GitHub Actions: lint, type-check, tests, docs, audit
├── .vscode/                   recommended extensions and workspace settings
├── design/                    engineering design documentation
│   ├── architecture.md        architecture overview (arc42-lite)
│   ├── adr/                   architecture decision records
│   └── diagrams/              diagram sources
├── docs/                      user documentation (Sphinx, MyST Markdown)
│   ├── conf.py                Sphinx configuration
│   ├── index.md               landing page and table of contents
│   ├── usage.md               installation and usage
│   ├── api.md                 API reference generated from docstrings
│   └── changelog.md           includes CHANGELOG.md
├── scripts/
│   ├── install-uv.ps1         installs uv on Windows
│   └── install-uv.sh          installs uv on Linux and macOS
├── src/
│   └── my_project/            the importable package (src layout)
│       ├── __init__.py        public API
│       ├── __main__.py        CLI: `my-project` / `python -m my_project`
│       ├── core.py            domain logic
│       └── py.typed           PEP 561 marker: the package ships type hints
├── tests/
│   ├── conftest.py            shared fixtures
│   ├── unit/                  fast, isolated tests
│   └── integration/           tests that run the installed CLI
├── .editorconfig              editor whitespace settings
├── .gitattributes             line endings (LF) and diff settings
├── .gitignore
├── .gitlab-ci.yml             GitLab CI/CD: the same checks plus MR reports
├── .pre-commit-config.yaml    Git hooks: file hygiene, config schemas, ruff, mypy
├── .python-version            Python version uv uses (3.14)
├── AGENTS.md                  instructions for AI coding agents
├── CHANGELOG.md               release notes (Keep a Changelog)
├── CLAUDE.md                  Claude Code entry point; imports AGENTS.md
├── pyproject.toml             metadata, dependencies, tool configuration
├── README.md
├── renovate.json              GitLab: weekly dependency updates (Renovate)
└── TASKS.md                   backlog: additions that depend on the kind of project
```
