#!/usr/bin/env bash
# install-nvim.sh — Neovim installer (binary + config + plugins)
# ------------------------------------------------------------------
# The single entry point for a working nvim: installs the prebuilt binary,
# copies the config into place, and clones the plugin set.
#
# Usage:
#   ./install-nvim.sh        # install everything
#   ./install-nvim.sh --help # show this help
#
# Requirements:
#   - git, curl, tar
#   - sudo for the binary (installs into /opt, links into /usr/local/bin);
#     set NVIM_PREFIX/NVIM_BIN_LINK to a writable path to avoid it
#   - Network: the binary comes from the NJU GitHub-release mirror, the
#     plugins from GitHub / Codeberg
# ------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NVIM_CONFIG="${NVIM_CONFIG:-$HOME/.config/nvim}"
NVIM_DATA="${NVIM_DATA:-$HOME/.local/share/nvim}"
LAZY_DIR="$NVIM_DATA/lazy"

# Prebuilt release. The default is the NJU GitHub-release mirror, which serves
# a byte-identical copy of the official asset — github.com itself is blocked
# from mainland China and cannot be fetched directly. Override NVIM_ARCHIVE_URL
# to pin a version or use a different mirror.
NVIM_PREFIX="${NVIM_PREFIX:-/opt/nvim-linux-x86_64}"
NVIM_BIN_LINK="${NVIM_BIN_LINK:-/usr/local/bin/nvim}"
NVIM_ARCHIVE_URL="${NVIM_ARCHIVE_URL:-https://mirror.nju.edu.cn/github-release/neovim/neovim/LatestRelease/nvim-linux-x86_64.tar.gz}"

# ── pinned plugins (name|url|ref|commit) ──────────────────────────
LOCK_FILE="$SCRIPT_DIR/plugins.lock"

# codediff ships a prebuilt diff engine. Fetch it from the pinned release and
# verify the published checksum; the plugin itself does not verify it.
CODEDIFF_VERSION="4.0.6"
CODEDIFF_LIB_SHA256="ac2a1d416dc99f7d864c0362db4b5baa6633fa68ebc90c9c9f3b3a9ae9cce081"

# ── config files to install ───────────────────────────────────────
CONFIG_FILES=("init.lua" "plugins.lock" "lua")

# ── banner ────────────────────────────────────────────────────────
banner() {
  cat <<'EOF'
╔══════════════════════════════════════════════════════════╗
║              Neovim Config Installer                      ║
╚══════════════════════════════════════════════════════════╝
EOF
}

# ── helpers ───────────────────────────────────────────────────────
# Clone one plugin at its pinned commit. The lock file is the single source of
# truth: adding a plugin means adding a line there, not editing this script.
# Fetches the commit SHA directly (not the tag), so a moved tag cannot change
# what gets installed.
clone_pinned() {
  local name="$1" url="$2" ref="$3" commit="$4" dest="$LAZY_DIR/$name"
  if [[ -d "$dest" ]]; then echo "  [skip] $name"; return 0; fi
  echo "  [clone] $name @ ${ref:--} (${commit:0:12})"
  git init -q "$dest" 2>/dev/null
  git -C "$dest" remote add origin "$url"
  if ! GIT_TERMINAL_PROMPT=0 git -C "$dest" fetch -q --depth 1 origin "$commit"; then
    echo "  [error] failed to fetch $name@$commit" >&2
    rm -rf "$dest"
    return 1
  fi
  git -C "$dest" checkout -q FETCH_HEAD
  local actual
  actual="$(git -C "$dest" rev-parse HEAD)"
  if [[ "$actual" != "$commit" ]]; then
    echo "  [error] $name checked out $actual, expected $commit" >&2
    return 1
  fi
  rm -rf "$dest/.git"
}

# Fetch and verify the codediff native engine (x86_64 Linux only).
install_codediff_lib() {
  local dir="$LAZY_DIR/codediff.nvim"
  [[ -d "$dir" ]] || return 0
  if [[ "$(uname -s)" != "Linux" || "$(uname -m)" != "x86_64" ]]; then
    echo "  [skip] codediff engine (unsupported platform, plugin will download on first use)"
    return 0
  fi
  local name="libvscode_diff_${CODEDIFF_VERSION}.so"
  local dest="$dir/$name"
  if [[ -f "$dest" ]]; then echo "  [skip] codediff engine"; return 0; fi

  local url="https://github.com/esmuellert/codediff.nvim/releases/download/v${CODEDIFF_VERSION}/libvscode_diff_linux_x64_${CODEDIFF_VERSION}.so"
  echo "  [fetch] codediff engine $CODEDIFF_VERSION"
  if ! curl -fsSL -o "$dest.tmp" "$url"; then
    rm -f "$dest.tmp"
    echo "  [error] codediff engine download failed" >&2
    return 1
  fi
  local actual
  actual="$(sha256sum "$dest.tmp" | awk '{print $1}')"
  if [[ "$actual" != "$CODEDIFF_LIB_SHA256" ]]; then
    rm -f "$dest.tmp"
    echo "  [error] codediff engine checksum mismatch" >&2
    return 1
  fi
  mv "$dest.tmp" "$dest"
  echo "  [ok] codediff engine verified"
}

# Install the prebuilt binary. Skips entirely when one is already in place, so
# re-running the script never re-downloads ~12 MB. The unpack target is the
# tarball's own top-level directory name, nvim-linux-x86_64, which is why
# NVIM_PREFIX has to match it.
install_binary() {
  echo ""
  echo "── Binary ───────────────────────────────────────────"
  if [[ -x "$NVIM_PREFIX/bin/nvim" ]]; then
    echo "  [skip] $("$NVIM_PREFIX/bin/nvim" --version | head -1) at $NVIM_PREFIX"
    link_binary
    return 0
  fi

  local tmp; tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  echo "  [fetch] $NVIM_ARCHIVE_URL"
  curl -4 -fL --retry 3 -o "$tmp/nvim.tar.gz" "$NVIM_ARCHIVE_URL" 2>&1 | sed 's/^/    /'

  echo "  [unpack] -> $NVIM_PREFIX"
  if [[ -w "$(dirname "$NVIM_PREFIX")" ]]; then
    rm -rf "$NVIM_PREFIX"
    tar -xzf "$tmp/nvim.tar.gz" -C "$(dirname "$NVIM_PREFIX")"
  else
    sudo rm -rf "$NVIM_PREFIX"
    sudo tar -xzf "$tmp/nvim.tar.gz" -C "$(dirname "$NVIM_PREFIX")"
  fi

  [[ -x "$NVIM_PREFIX/bin/nvim" ]] ||
    {
      echo "  [error] $NVIM_PREFIX/bin/nvim did not appear — unexpected tarball layout" >&2
      return 1
    }
  link_binary
}

link_binary() {
  local target="$NVIM_PREFIX/bin/nvim"
  [[ -x "$target" ]] || return 0
  if [[ -L "$NVIM_BIN_LINK" && "$(readlink -f "$NVIM_BIN_LINK")" == "$(readlink -f "$target")" ]]; then
    echo "  [skip] $NVIM_BIN_LINK already points here"
  elif [[ -w "$(dirname "$NVIM_BIN_LINK")" ]]; then
    ln -sfn "$target" "$NVIM_BIN_LINK"
    echo "  [link] $NVIM_BIN_LINK -> $target"
  else
    sudo ln -sfn "$target" "$NVIM_BIN_LINK"
    echo "  [link] $NVIM_BIN_LINK -> $target"
  fi
  echo "  [ok] $("$target" --version | head -1)"
}

install_config() {
  echo ""
  echo "── Config ───────────────────────────────────────────"
  mkdir -p "$NVIM_CONFIG"
  for item in "${CONFIG_FILES[@]}"; do
    local src="$SCRIPT_DIR/$item" dst="$NVIM_CONFIG/$item"
    if [[ ! -e "$src" ]]; then echo "  [warn] $item missing"; continue; fi
    # In-place run (repo == config dir): src and dst are the same file
    if [[ "$(readlink -f "$src")" == "$(readlink -f "$dst")" ]]; then
      echo "  [skip] $item (already in place)"
      continue
    fi
    if [[ -d "$src" ]]; then mkdir -p "$dst"; cp -r "$src"/* "$dst"/
    else cp "$src" "$dst"; fi
    echo "  [copy] $item"
  done
}

# ── main ──────────────────────────────────────────────────────────
main() {
  local mode="${1:-}"

  case "$mode" in
    --help|-h)
      sed -n '2,/^$/p' "$0" | sed 's/^# //'
      exit 0
      ;;
  esac

  banner

  install_binary
  install_config

  echo ""
  echo "── Plugins ──────────────────────────────────────────"
  mkdir -p "$LAZY_DIR"
  if [[ ! -f "$LOCK_FILE" ]]; then
    echo "  [error] missing $LOCK_FILE" >&2
    exit 1
  fi
  while IFS='|' read -r name url ref commit; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    clone_pinned "$name" "$url" "$ref" "$commit"
  done < "$LOCK_FILE"
  install_codediff_lib

  echo ""
  echo "Done."
  echo "Binary:  $NVIM_PREFIX/bin/nvim  ($NVIM_BIN_LINK)"
  echo "Config:  $NVIM_CONFIG"
  echo "Plugins: $LAZY_DIR"
}

main "$@"
