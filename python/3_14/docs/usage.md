# Usage

## Installation

Add the package to a project, or install it as a standalone command-line tool:

```console
$ uv add my-project
$ uv tool install my-project
```

## Command line

```console
$ my-project Ada
Hello, Ada!
```

Run `my-project --help` for all options. `python -m my_project` works as well.

## Python API

```pycon
>>> from my_project import greet
>>> greet("Ada")
'Hello, Ada!'
```

The {doc}`api` describes every public function.
