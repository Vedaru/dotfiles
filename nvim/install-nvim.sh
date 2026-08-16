#!/usr/bin/env bash
# install-nvim.sh — Neovim config installer
# ------------------------------------------------------------------
# Clones plugins and copies config to the right places.
#
# Usage:
#   ./install-nvim.sh        # install everything
#   ./install-nvim.sh --help # show this help
#
# Requirements:
#   - git, curl, tar
#   - Network access to GitHub / Codeberg
#   - tree-sitter CLI (for parser compilation; npm i -g tree-sitter-cli)
# ------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NVIM_CONFIG="${NVIM_CONFIG:-$HOME/.config/nvim}"
NVIM_DATA="${NVIM_DATA:-$HOME/.local/share/nvim}"
LAZY_DIR="$NVIM_DATA/lazy"

# ── plugin list (name → URL) ──────────────────────────────────────
declare -A PLUGINS=(
  ["lazy.nvim"]="https://github.com/folke/lazy.nvim.git"
  ["LazyVim"]="https://github.com/LazyVim/LazyVim.git"
  ["gruvbox.nvim"]="https://github.com/ellisonleao/gruvbox.nvim.git"
  ["snacks.nvim"]="https://github.com/folke/snacks.nvim.git"
  ["oil.nvim"]="https://github.com/stevearc/oil.nvim.git"
  ["nvim-web-devicons"]="https://github.com/nvim-tree/nvim-web-devicons.git"
  ["nvim-treesitter"]="https://github.com/nvim-treesitter/nvim-treesitter.git"
  ["nvim-cmp"]="https://github.com/hrsh7th/nvim-cmp.git"
  ["cmp-buffer"]="https://github.com/hrsh7th/cmp-buffer.git"
  ["cmp-path"]="https://github.com/hrsh7th/cmp-path.git"
  ["git-conflict.nvim"]="https://github.com/akinsho/git-conflict.nvim.git"
  ["gitsigns.nvim"]="https://github.com/lewis6991/gitsigns.nvim.git"
  ["grug-far.nvim"]="https://github.com/MagicDuck/grug-far.nvim.git"
  ["mini.icons"]="https://github.com/nvim-mini/mini.icons.git"
  ["mini.statusline"]="https://github.com/nvim-mini/mini.statusline.git"
  ["mini.surround"]="https://github.com/nvim-mini/mini.surround.git"
  ["leap.nvim"]="https://codeberg.org/andyg/leap.nvim"
)

# ── config files to install ───────────────────────────────────────
CONFIG_FILES=("init.lua" "lazyvim.json" "lua")

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

install_config() {
  echo ""
  echo "── Config ───────────────────────────────────────────"
  mkdir -p "$NVIM_CONFIG"
  for item in "${CONFIG_FILES[@]}"; do
    local src="$SCRIPT_DIR/$item" dst="$NVIM_CONFIG/$item"
    if [[ ! -e "$src" ]]; then echo "  [warn] $item missing"; continue; fi
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

# Disable LazyVim distro keymaps at source (all keymaps live in user config)
patch_lazyvim_keymaps() {
  local f="$LAZY_DIR/LazyVim/lua/lazyvim/config/keymaps.lua"
  [[ -f "$f" ]] || return 0
  if grep -q 'Disabled at source' "$f"; then
    echo "  [skip] lazyvim keymaps already disabled"
    return 0
  fi
  cat > "$f" <<'EOF'
-- Disabled at source — all keymaps now live in ~/.config/nvim/lua/config/keymaps.lua
-- This avoids the fragile LazyVim.safe_keymap_set → Snacks.keymap.set chain.
return {}
EOF
  echo "  [patch] lazyvim keymaps disabled at source"
}

# Disable LazyVim distro autocmds at source (all autocmds live in user config)
patch_lazyvim_autocmds() {
  local f="$LAZY_DIR/LazyVim/lua/lazyvim/config/autocmds.lua"
  [[ -f "$f" ]] || return 0
  if grep -q 'Disabled at source' "$f"; then
    echo "  [skip] lazyvim autocmds already disabled"
    return 0
  fi
  cat > "$f" <<'EOF'
-- Disabled at source — all autocmds now live in ~/.config/nvim/lua/config/autocmds.lua
return {}
EOF
  echo "  [patch] lazyvim autocmds disabled at source"
}

# Strip LazyVim's VeryLazy callback down to what this config needs:
# autocmds/keymaps loads (they also pull in the user config/*.lua files)
# and the deferred clipboard restore. Removes format/news/root setup,
# LazyExtras/LazyHealth commands, health-valid extension, import-order check.
patch_lazyvim_init() {
  local f="$LAZY_DIR/LazyVim/lua/lazyvim/config/init.lua"
  [[ -f "$f" ]] || return 0
  if grep -q 'PATCHED (vedaru)' "$f"; then
    echo "  [skip] lazyvim init already patched"
    return 0
  fi
  local awkfile
  awkfile="$(mktemp)"
  cat > "$awkfile" <<'AWKEOF'
/^    callback = function\(\)$/ {
  print
  print "      -- PATCHED (vedaru): stripped format/news/root setup, LazyExtras/LazyHealth commands,"
  print "      -- health-valid extension and import-order check. Kept: autocmds/keymaps loads"
  print "      -- (they also load the user config/*.lua files) and the deferred clipboard restore."
  print "      if lazy_autocmds then"
  print "        M.load(\"autocmds\")"
  print "      end"
  print "      M.load(\"keymaps\")"
  print "      if lazy_clipboard ~= nil then"
  print "        vim.opt.clipboard = lazy_clipboard"
  print "      end"
  in_cb = 1
  next
}
in_cb && /^    end,$/ { print; in_cb = 0; next }
in_cb { next }
{ print }
AWKEOF
  awk -f "$awkfile" "$f" > "$f.new" && mv "$f.new" "$f"
  rm -f "$awkfile"
  echo "  [patch] lazyvim init stripped (format/news/root, LazyExtras/LazyHealth)"
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

  install_config

  echo ""
  echo "── Plugins ──────────────────────────────────────────"
  mkdir -p "$LAZY_DIR"
  for name in "${!PLUGINS[@]}"; do
    clone_one "$name" "${PLUGINS[$name]}"
  done

  patch_snacks
  patch_git_conflict
  patch_lazyvim_keymaps
  patch_lazyvim_autocmds
  patch_lazyvim_init

  echo ""
  echo "── Treesitter parsers ───────────────────────────────"
  echo "   Launch nvim once (online) and it will auto-install"
  echo "   all parsers from the ensure_installed list."

  echo ""
  echo "Done."
  echo "Config:  $NVIM_CONFIG"
  echo "Plugins: $LAZY_DIR"
}

main "$@"
