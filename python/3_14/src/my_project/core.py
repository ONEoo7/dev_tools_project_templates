"""Core logic of my_project, kept free of I/O so it is easy to unit-test."""


def greet(name: str) -> str:
    """Build a greeting for ``name``.

    Args:
        name: Who to greet. Surrounding whitespace is ignored.

    Returns:
        The greeting, for example ``"Hello, Ada!"``.

    Raises:
        ValueError: If ``name`` is empty or contains only whitespace.
    """
    cleaned = name.strip()
    if not cleaned:
        raise ValueError("name must not be empty")
    return f"Hello, {cleaned}!"
