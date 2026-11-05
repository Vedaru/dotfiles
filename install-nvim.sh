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

# ── plugin list (name → URL) ──────────────────────────────────────
declare -A PLUGINS=(
  ["lazy.nvim"]="https://github.com/folke/lazy.nvim.git"
  ["gruvbox.nvim"]="https://github.com/ellisonleao/gruvbox.nvim.git"
  ["snacks.nvim"]="https://github.com/folke/snacks.nvim.git"
  ["oil.nvim"]="https://github.com/stevearc/oil.nvim.git"
  ["nvim-web-devicons"]="https://github.com/nvim-tree/nvim-web-devicons.git"
  ["git-conflict.nvim"]="https://github.com/akinsho/git-conflict.nvim.git"
  ["gitsigns.nvim"]="https://github.com/lewis6991/gitsigns.nvim.git"
  ["grug-far.nvim"]="https://github.com/MagicDuck/grug-far.nvim.git"
  ["mini.icons"]="https://github.com/nvim-mini/mini.icons.git"
  ["mini.statusline"]="https://github.com/nvim-mini/mini.statusline.git"
  ["mini.surround"]="https://github.com/nvim-mini/mini.surround.git"
  ["mini.pairs"]="https://github.com/nvim-mini/mini.pairs.git"
  ["undotree"]="https://github.com/mbbill/undotree.git"
  ["leap.nvim"]="https://codeberg.org/andyg/leap.nvim"
)

# ── config files to install ───────────────────────────────────────
CONFIG_FILES=("init.lua" "lua")

# ── banner ────────────────────────────────────────────────────────
banner() {
  cat <<'EOF'
╔══════════════════════════════════════════════════════════╗
║              Neovim Config Installer                      ║
╚══════════════════════════════════════════════════════════╝
EOF
}

# ── helpers ───────────────────────────────────────────────────────
clone_one() {
  local name="$1" url="$2" dest="$LAZY_DIR/$name"
  if [[ -d "$dest" ]]; then echo "  [skip] $name"; return 0; fi
  echo "  [clone] $name ← $url"
  GIT_TERMINAL_PROMPT=0 git clone --depth 1 --filter=blob:none "$url" "$dest" 2>&1 | sed 's/^/    /'
  rm -rf "$dest/.git"
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

patch_snacks() {
  local sc="$LAZY_DIR/snacks.nvim/lua/snacks/statuscolumn.lua"
  if [[ -f "$sc" ]] && grep -q '%T"' "$sc"; then
    sed -i 's/%T"/%X"/' "$sc"
    echo "  [patch] snacks statuscolumn %T → %X"
  fi
}

patch_git_conflict() {
  local f="$LAZY_DIR/git-conflict.nvim/lua/git-conflict.lua"
  [[ -f "$f" ]] || return 0

  # Already patched? (idempotent)
  if grep -q 'if position.marks then' "$f"; then
    echo "  [skip] git-conflict already patched"
    return 0
  fi

  # Block 1: visual-mode choose path (8-space indent)
  sed -i '
    /^        api.nvim_buf_set_lines(0, pos_start, pos_end, false, lines)$/{
      a\        if position.marks then
      n
      s/^/  /
      n
      s/^/  /
      n
      s/^/  /
      n
      s/^/  /
      n
      s/^/  /
      a\        end
    }' "$f"

  # Block 2: normal-mode choose path (2-space indent)
  sed -i '
    /^  api.nvim_buf_set_lines(0, pos_start, pos_end, false, lines)$/{
      a\  if position.marks then
      n
      s/^/  /
      n
      s/^/  /
      n
      s/^/  /
      n
      s/^/  /
      n
      s/^/  /
      a\  end
    }' "$f"

  echo "  [patch] git-conflict nil-guard on position.marks"
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
  for name in "${!PLUGINS[@]}"; do
    clone_one "$name" "${PLUGINS[$name]}"
  done

  patch_snacks
  patch_git_conflict

  echo ""
  echo "Done."
  echo "Binary:  $NVIM_PREFIX/bin/nvim  ($NVIM_BIN_LINK)"
  echo "Config:  $NVIM_CONFIG"
  echo "Plugins: $LAZY_DIR"
}

main "$@"
