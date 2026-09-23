"""End-to-end tests: run the installed command-line interface in a subprocess."""

import shutil
import subprocess
import sys
import sysconfig


def run(*command: str) -> subprocess.CompletedProcess[str]:
    """Run ``command`` and return its captured, decoded output."""
    return subprocess.run(command, capture_output=True, text=True, check=True)


def test_python_dash_m_entry_point() -> None:
    result = run(sys.executable, "-m", "my_project", "Ada")
    assert result.stdout == "Hello, Ada!\n"


def test_console_script_entry_point() -> None:
    script = shutil.which("my-project", path=sysconfig.get_path("scripts"))
    assert script is not None, "console script not installed - run `uv sync` first"
    result = run(script, "Ada")
    assert result.stdout == "Hello, Ada!\n"
