"""Unit tests for ``my_project.core``."""

import pytest

from my_project.core import greet


def test_greet_returns_greeting() -> None:
    assert greet("Ada") == "Hello, Ada!"


def test_greet_strips_surrounding_whitespace() -> None:
    assert greet("  Ada  ") == "Hello, Ada!"


@pytest.mark.parametrize(
    "name",
    ["", "   ", "\t\n"],
    ids=["empty", "spaces", "tab-and-newline"],
)
def test_greet_rejects_blank_name(name: str) -> None:
    with pytest.raises(ValueError, match="must not be empty"):
        greet(name)
