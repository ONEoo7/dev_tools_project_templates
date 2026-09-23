"""Build installers and a portable archive of the command-line tool.

The tool is first frozen with PyInstaller into a self-contained folder that
bundles its own CPython, so users do not need Python. That folder is packed as
a portable archive and packaged for the operating system this script runs on:

* Windows: a portable ``.zip`` and an NSIS installer (needs NSIS, e.g.
  ``winget install NSIS.NSIS``).
* Linux: a portable ``.tar.gz`` plus ``.deb`` and ``.rpm`` packages (needs nFPM
  and binutils).
* macOS: a portable ``.tar.gz`` and a ``.dmg`` disk image (uses ``hdiutil``,
  which ships with macOS).

Run it with ``uv run installers/build.py``; the results land in ``dist/``.
"""

import os
import platform
import re
import shutil
import subprocess
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = ROOT / "installers"
BUILD = ROOT / "build" / "installers"
DIST = ROOT / "dist"
ENTRY_POINT = ROOT / "src" / "my_project" / "__main__.py"


def main() -> None:
    """Freeze the application and package it for the current platform."""
    pyproject = tomllib.loads((ROOT / "pyproject.toml").read_text(encoding="utf-8"))
    project = pyproject["project"]
    name: str = project["name"]
    version: str = project["version"]
    author = project.get("authors", [{}])[0]
    publisher: str = author.get("name", name)
    maintainer = f"{publisher} <{author['email']}>" if "email" in author else publisher

    bundle = freeze(name)
    DIST.mkdir(exist_ok=True)
    stem = f"{name}-{version}-{platform_tag()}"
    build_portable(stem, bundle)
    match sys.platform:
        case "win32":
            build_windows(name, version, publisher, bundle, DIST / f"{stem}-setup.exe")
        case "linux":
            build_linux(version, project["description"], maintainer, bundle)
        case "darwin":
            build_macos(name, bundle, DIST / f"{stem}.dmg")
        case _:
            print(f"No installer for {sys.platform}; built the portable archive only.")


def freeze(name: str) -> Path:
    """Freeze the command-line tool with PyInstaller.

    uv runs PyInstaller in a fresh environment on a uv-managed CPython. Those
    standalone builds only need glibc 2.17 on Linux, so the frozen tool runs on
    practically every distribution, whatever Python the build machine has.

    Args:
        name: Name of the executable and of the output folder.

    Returns:
        The folder that holds the executable and its runtime.
    """
    # `uv run installers/build.py` activates the project environment, and uv
    # would build on its interpreter; without VIRTUAL_ENV, uv picks a managed one.
    env = {key: value for key, value in os.environ.items() if key != "VIRTUAL_ENV"}
    run(
        tool("uv"),
        *("run", "--locked", "--isolated", "--no-dev", "--group", "installers"),
        *("--python-preference", "only-managed"),
        *("pyinstaller", "--noconfirm", "--clean", "--onedir", "--console"),
        *("--name", name),
        *("--distpath", BUILD / "dist", "--workpath", BUILD / "work"),
        *("--specpath", BUILD),
        ENTRY_POINT,
        env=env,
    )
    return BUILD / "dist" / name


def build_portable(stem: str, bundle: Path) -> None:
    """Pack the frozen folder as a portable archive: .zip on Windows, else .tar.gz.

    Args:
        stem: Archive file name without the ``-portable`` suffix and extension.
        bundle: The folder produced by :func:`freeze`.
    """
    archive_format = "zip" if sys.platform == "win32" else "gztar"
    archive = shutil.make_archive(
        str(DIST / f"{stem}-portable"),
        archive_format,
        root_dir=bundle.parent,
        base_dir=bundle.name,
    )
    print("+ packed", archive, flush=True)


def build_windows(
    name: str, version: str, publisher: str, bundle: Path, output: Path
) -> None:
    """Compile the NSIS installer (installers/windows/installer.nsi)."""
    program_files = Path(os.environ.get("ProgramFiles(x86)", r"C:\Program Files (x86)"))
    makensis = tool(
        "makensis",
        program_files / "NSIS" / "makensis.exe",
        hint="install NSIS, e.g. `winget install NSIS.NSIS`",
    )
    run(
        makensis,
        *("-V2", "-WX"),  # print warnings and errors only; warnings fail the build
        f"-DAPP_NAME={name}",
        f"-DVERSION={version}",
        f"-DVI_VERSION={numeric_version(version)}",
        f"-DPUBLISHER={publisher}",
        f"-DSOURCE_DIR={bundle}",
        f"-DOUTFILE={output}",
        HERE / "windows" / "installer.nsi",
    )


def build_linux(version: str, description: str, maintainer: str, bundle: Path) -> None:
    """Build the .deb and .rpm packages with nFPM (installers/linux/nfpm.yaml)."""
    nfpm = tool("nfpm", hint="install nFPM: https://nfpm.goreleaser.com/docs/install/")
    machine = platform.machine()
    env = os.environ | {
        "ARCH": {"x86_64": "amd64", "aarch64": "arm64"}.get(machine, machine),
        "BUNDLE_DIR": str(bundle),
        "DESCRIPTION": description,
        "MAINTAINER": maintainer,
        "VERSION": version,
    }
    for packager in ("deb", "rpm"):
        run(
            nfpm,
            *("package", "--config", HERE / "linux" / "nfpm.yaml"),
            *("--packager", packager, "--target", DIST),
            env=env,
        )


def build_macos(name: str, bundle: Path, output: Path) -> None:
    """Build the disk image with hdiutil."""
    hdiutil = tool("hdiutil", hint="hdiutil ships with macOS")
    stage = BUILD / "dmg"
    shutil.rmtree(stage, ignore_errors=True)
    shutil.copytree(bundle, stage / name, symlinks=True)
    shutil.copy2(HERE / "macos" / "README.txt", stage / "README.txt")
    run(
        hdiutil,
        *("create", "-volname", name, "-srcfolder", stage),
        *("-format", "UDZO", "-ov", output),
    )


def platform_tag() -> str:
    """Return the platform part of the file names, e.g. ``windows-x64``."""
    machine = platform.machine().lower()
    match sys.platform:
        case "win32":
            return "windows-" + {"amd64": "x64", "x86_64": "x64"}.get(machine, machine)
        case "darwin":
            return f"macos-{machine}"
        case _:
            return f"{sys.platform}-{machine}"


def numeric_version(version: str) -> str:
    """Return the four-part X.Y.Z.W version that Windows file properties require.

    Args:
        version: A PEP 440 version such as ``1.2.0rc1``.

    Returns:
        The numeric release part, padded or cut to four fields, e.g. ``1.2.0.0``.
    """
    release = re.match(r"\d+(?:\.\d+)*", version)
    parts = (release.group() if release else "0").split(".")[:4]
    return ".".join(parts + ["0"] * (4 - len(parts)))


def tool(name: str, *candidates: Path, hint: str = "") -> str:
    """Find an external program on PATH or in the given candidate locations.

    Args:
        name: Program name to look up on PATH.
        *candidates: Further paths to try, e.g. default install locations.
        hint: How to install the program, shown when it is missing.

    Returns:
        The full path of the program.
    """
    found = shutil.which(name) or next(
        (str(path) for path in candidates if path.is_file()), None
    )
    if found is None:
        sys.exit(f"error: {name} not found" + (f"; {hint}" if hint else ""))
    return found


def run(*command: str | Path, env: dict[str, str] | None = None) -> None:
    """Print and run a command; stop the build if it fails."""
    args = [str(part) for part in command]
    print("+", subprocess.list2cmdline(args), flush=True)
    result = subprocess.run(args, check=False, env=env)
    if result.returncode:
        sys.exit(result.returncode)


if __name__ == "__main__":
    main()
