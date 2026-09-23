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
| Build installers and portable archive | `uv run installers/build.py` |

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

## Installers

[`installers/build.py`](installers/build.py) builds native installers and a
portable archive for the operating system it runs on. It freezes the CLI with
[PyInstaller](https://pyinstaller.org) into a folder that bundles its own Python,
then packages that folder into `dist/`:

| Platform | Installer | Portable archive | Also needs |
| --- | --- | --- | --- |
| Windows | `my-project-<version>-windows-x64-setup.exe`: NSIS, per-user, adds the tool to `PATH` | `my-project-<version>-windows-x64-portable.zip` | [NSIS](https://nsis.sourceforge.io): `winget install NSIS.NSIS` |
| Linux | `my-project_<version>_amd64.deb` and `my-project-<version>-1.x86_64.rpm` | `my-project-<version>-linux-x86_64-portable.tar.gz` | [nFPM](https://nfpm.goreleaser.com/docs/install/) and binutils |
| macOS | `my-project-<version>-macos-arm64.dmg` | `my-project-<version>-macos-arm64-portable.tar.gz` | nothing; `hdiutil` ships with macOS |

```bash
uv run installers/build.py
```

The portable archives need no installation or administrator rights: extract
them anywhere, for example onto a USB stick, and run `my-project/my-project`
(`my-project\my-project.exe` on Windows).

PyInstaller always runs on a uv-managed CPython, so the Linux packages work on
any distribution with glibc 2.17 or newer. Installers target the architecture
of the machine that builds them.

CI builds them for version tags (`v*`) and on demand: GitHub Actions
([`installers.yml`](.github/workflows/installers.yml)) builds everything for all
three platforms and attaches it to a draft release; GitLab CI/CD builds the
Linux packages and portable archive.

Nothing is code-signed yet (see [`TASKS.md`](TASKS.md)). Windows SmartScreen and
macOS Gatekeeper warn about the installers and portable builds, and Windows
computers that enforce Smart App Control refuse to run them.

## Project layout

```text
.
├── .github/
│   ├── dependabot.yml         GitHub: weekly dependency updates
│   └── workflows/
│       ├── ci.yml             GitHub Actions: lint, type-check, tests, docs, audit
│       └── installers.yml     GitHub Actions: installers for version tags
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
├── installers/                native installers (see "Installers")
│   ├── build.py               freezes the CLI; builds this OS's installers and portable archive
│   ├── linux/nfpm.yaml        .deb and .rpm package definition
│   ├── macos/README.txt       instructions shipped inside the .dmg
│   └── windows/installer.nsi  NSIS installer script (edits PATH itself, runs no scripts)
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
