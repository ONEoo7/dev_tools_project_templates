"""Sphinx configuration for the my-project documentation.

Build the HTML documentation with::

    uv run --group docs sphinx-build --fail-on-warning docs docs/_build/html
"""

import importlib.metadata

# -- Project information --------------------------------------------------------
project = "my-project"
author = "Your Name"
copyright = f"%Y, {author}"  # Sphinx replaces %Y with the current year
release = importlib.metadata.version(project)
version = ".".join(release.split(".")[:2])

# -- General configuration ------------------------------------------------------
extensions = [
    "myst_parser",  # Markdown (MyST) sources
    "sphinx.ext.autodoc",  # API reference from docstrings
    "sphinx.ext.intersphinx",  # links into the Python documentation
    "sphinx.ext.napoleon",  # Google-style docstrings
    "sphinx.ext.viewcode",  # links to the highlighted source code
]
exclude_patterns = ["_build"]

autodoc_member_order = "bysource"
autodoc_typehints = "description"
napoleon_numpy_docstring = False
intersphinx_mapping = {"python": ("https://docs.python.org/3.14", None)}

# -- HTML output ----------------------------------------------------------------
html_theme = "furo"
