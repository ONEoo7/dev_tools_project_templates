# Tasks

Additions that were considered for this template but not added yet. Most depend
on the kind of project: when starting a project from the template, pick the
ones that apply and delete the rest.

## Library published to PyPI

- [ ] Release job triggered by version tags (`v*`): run `uv build`, then publish
  with [PyPI Trusted Publishing](https://docs.pypi.org/trusted-publishers/),
  which needs no API tokens and works from GitHub Actions and GitLab CI/CD.
- [ ] `--version` flag for the command-line interface, reading the installed
  version with `importlib.metadata`.
- [ ] Fill in `[project.urls]` in `pyproject.toml` (repository, documentation,
  changelog, issue tracker).

## Service shipped as a container

- [ ] Multi-stage `Dockerfile` following
  [uv's Docker guide](https://docs.astral.sh/uv/guides/integration/docker/),
  plus a `.dockerignore`.
- [ ] Settings from environment variables, documented in a committed
  `.env.example` (`.gitignore` already allows that file).
- [ ] Logging setup: configure `logging` once in the entry point; library code
  only creates loggers.

## Team or open-source project

- [ ] `CONTRIBUTING.md`: setup, required checks, review and release process.
- [ ] `SECURITY.md`: how to report vulnerabilities privately.
- [ ] `CODEOWNERS` (in `.github/` or `.gitlab/`).
- [ ] Templates for pull/merge requests and issues (in `.github/` or `.gitlab/`).
- [ ] `CODE_OF_CONDUCT.md` for open-source projects.

## User documentation

- [x] Sphinx documentation in `docs/`, built in CI with warnings as errors.
- [ ] Publish the documentation: GitHub Pages, GitLab Pages, or
  [Read the Docs](https://docs.readthedocs.com/platform/stable/).

## Optional tooling

- [ ] `pytest-xdist` to run the tests in parallel (`uv run pytest -n auto`).
- [ ] `hypothesis` for property-based tests.
- [ ] `pytest-randomly` to run the tests in random order, which exposes hidden
  dependencies between them.
- [ ] [ty](https://docs.astral.sh/ty/), Astral's type checker (still beta), as a
  faster second checker next to mypy; it runs through `uv check`.

## Other open items

- [ ] Add Python 3.15 to the CI test matrix once it is released (scheduled for
  2026-10-01); `requires-python = ">=3.14"` already claims support for it.
- [ ] Try `scripts/install-uv.sh` on macOS; so far it has been tested on Linux
  only.
