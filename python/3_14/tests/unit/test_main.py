"""Unit tests for the command-line interface in ``my_project.__main__``."""

import pytest

from my_project.__main__ import main


def test_main_greets_world_by_default(capsys: pytest.CaptureFixture[str]) -> None:
    assert main([]) == 0
    assert capsys.readouterr().out == "Hello, World!\n"


def test_main_greets_given_name(capsys: pytest.CaptureFixture[str]) -> None:
    assert main(["Ada"]) == 0
    assert capsys.readouterr().out == "Hello, Ada!\n"


def test_main_rejects_blank_name(capsys: pytest.CaptureFixture[str]) -> None:
    with pytest.raises(SystemExit) as exc_info:
        main(["   "])

    assert exc_info.value.code == 2
    assert "name must not be empty" in capsys.readouterr().err
