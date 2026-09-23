"""Command-line interface, run as ``my-project`` or ``python -m my_project``."""

import argparse
from collections.abc import Sequence

from my_project.core import greet


def main(argv: Sequence[str] | None = None) -> int:
    """Run the command-line interface.

    Args:
        argv: Arguments to parse; defaults to ``sys.argv[1:]``.

    Returns:
        The process exit code.
    """
    parser = argparse.ArgumentParser(
        prog="my-project",
        description="Print a friendly greeting.",
    )
    parser.add_argument("name", nargs="?", default="World", help="who to greet")
    args = parser.parse_args(argv)

    try:
        message = greet(args.name)
    except ValueError as exc:
        parser.error(str(exc))  # prints usage and exits with status 2

    print(message)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
