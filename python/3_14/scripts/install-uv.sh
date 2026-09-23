#!/bin/sh
# Installs uv, the Python package and project manager, on Linux and macOS.
#
# Runs Astral's official standalone installer
# (https://docs.astral.sh/uv/getting-started/installation/), which checks the
# download's SHA-256 checksum, puts uv in ~/.local/bin, and adds that directory
# to PATH in your shell profiles. Does nothing if uv is already installed;
# update an existing installation with `uv self update`.
#
# Usage: sh scripts/install-uv.sh [VERSION]    (for example 0.12.18; default: latest)
#
# The installer honours the UV_INSTALL_DIR, UV_NO_MODIFY_PATH and
# UV_UNMANAGED_INSTALL environment variables. The script is POSIX sh, so it
# runs under bash, zsh (the macOS default), dash and BusyBox ash alike.
set -eu

version="${1:-}"
case "$version" in
    -h | --help)
        echo "usage: sh scripts/install-uv.sh [VERSION]"
        exit 0
        ;;
esac

if command -v uv >/dev/null 2>&1; then
    echo "uv is already installed: $(uv --version) ($(command -v uv))"
    echo "Update it with: uv self update"
    exit 0
fi

if [ -z "$version" ]; then
    url="https://astral.sh/uv/install.sh"
elif printf '%s\n' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    url="https://astral.sh/uv/$version/install.sh"
else
    echo "error: VERSION must look like 0.12.18, got '$version'" >&2
    exit 2
fi

if command -v curl >/dev/null 2>&1; then
    download() { curl --proto '=https' --tlsv1.2 -LsSf "$1" -o "$2"; }
elif command -v wget >/dev/null 2>&1; then
    download() { wget -q -O "$2" "$1"; }
else
    echo "error: curl or wget is required to download the installer" >&2
    exit 1
fi

installer="$(mktemp "${TMPDIR:-/tmp}/uv-install.XXXXXX")"
trap 'rm -f "$installer"' EXIT

echo "Installing uv with the official installer: $url"
download "$url" "$installer"
sh "$installer"

# The installer changes PATH for new shells only. Extend the PATH of this
# process so the installation can be checked right away.
for dir in "${UV_UNMANAGED_INSTALL:-}" "${UV_INSTALL_DIR:-}" "${XDG_BIN_HOME:-}" "$HOME/.local/bin"; do
    if [ -n "$dir" ] && [ -x "$dir/uv" ]; then
        PATH="$dir:$PATH"
        break
    fi
done
if ! command -v uv >/dev/null 2>&1; then
    echo "error: uv was installed, but was not found in the expected directories" >&2
    exit 1
fi

echo "Installed $(uv --version)."
echo "Open a new terminal so uv is on your PATH, then run: uv sync"
