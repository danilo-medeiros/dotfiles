#!/bin/bash
#
# Bootstrap a fresh macOS machine from this dotfiles repo.
#
# Safe to re-run: every step checks for existing state before acting.
#
#   ./setup.sh            # install packages and link configs
#   ./setup.sh --link     # only (re)create the symlinks
#
set -euo pipefail

# Resolve the repo root from this script's own location, so the repo can live
# anywhere without editing paths below.
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
skip() { printf '    %s\n' "$*"; }

# ---------------------------------------------------------------------------
# Symlinks: repo path -> location in $HOME
# ---------------------------------------------------------------------------
# Both directories and files are linked; parent dirs are created as needed.
link_config() {
  local src="$DOTFILES/$1" dest="$HOME/$2"

  if [ ! -e "$src" ]; then
    echo "    !! missing in repo, skipping: $1" >&2
    return
  fi

  mkdir -p "$(dirname "$dest")"

  # Already pointing where we want it.
  if [ "$(readlink "$dest" 2>/dev/null)" = "$src" ]; then
    skip "ok: ~/$2"
    return
  fi

  # Something else is there -- move it aside rather than clobbering it.
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="$dest.backup.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    skip "backed up existing ~/$2 -> $(basename "$backup")"
  fi

  ln -s "$src" "$dest"
  log "linked ~/$2"
}

link_all() {
  log "Linking configs from $DOTFILES"
  link_config ".tmux.conf"        ".tmux.conf"
  link_config "nvim"              ".config/nvim"
  link_config "alacritty"         ".config/alacritty"
  link_config "hammerspoon/init.lua" ".hammerspoon/init.lua"
  link_config "claude/CLAUDE.md"  ".claude/CLAUDE.md"
  link_config "claude/templates"  ".claude/templates"
}

# --link: skip the package installs, just refresh symlinks.
if [ "${1:-}" = "--link" ]; then
  link_all
  exit 0
fi

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  skip "Homebrew already installed"
fi

# ---------------------------------------------------------------------------
# oh-my-zsh
# ---------------------------------------------------------------------------
if [ ! -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
  log "Installing oh-my-zsh"
  # --unattended: don't launch a new shell or overwrite an existing .zshrc.
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  skip "oh-my-zsh already installed"
fi

# ---------------------------------------------------------------------------
# Formulae
# ---------------------------------------------------------------------------
# Kept in step with what the configs in this repo actually invoke:
#   zoxide  -> myenv.sh runs `zoxide init zsh` on every shell start
#   gh      -> nvim :PR, :PRs, :Review
#   ripgrep -> fzf-lua live_grep
formulae=(
  neovim
  tmux
  fzf
  ripgrep
  zoxide
  gh
  asdf
  zsh-autosuggestions

  # Language servers enabled in nvim/init.lua
  lua-language-server
  pyright
  gopls
  jdtls
  ruby-lsp
)

log "Installing formulae"
for f in "${formulae[@]}"; do
  if brew list --formula "$f" >/dev/null 2>&1; then
    skip "ok: $f"
  else
    brew install "$f"
  fi
done

log "Installing casks"
if brew list --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1; then
  skip "ok: font-jetbrains-mono-nerd-font"
else
  brew install --cask font-jetbrains-mono-nerd-font
fi

# ---------------------------------------------------------------------------
# npm-based language servers
# ---------------------------------------------------------------------------
# ts_ls, tailwindcss and eslint are enabled in nvim/init.lua but have no brew
# formula. Requires node (install via `asdf` or `brew install node`).
if command -v npm >/dev/null 2>&1; then
  log "Installing npm language servers"
  npm install -g \
    typescript \
    typescript-language-server \
    @tailwindcss/language-server \
    vscode-langservers-extracted
else
  skip "npm not found -- skipping ts_ls/tailwindcss/eslint servers"
fi

# elixirls has no formula and no npm package; nvim/init.lua expects it at
# ~/.local/share/elixir-ls (see the comment there for the manual steps).
if [ ! -x "$HOME/.local/share/elixir-ls/language_server.sh" ]; then
  skip "elixir-ls not installed (manual: see nvim/init.lua)"
fi

# ---------------------------------------------------------------------------
# Configs
# ---------------------------------------------------------------------------
link_all

# ---------------------------------------------------------------------------
# Shell hook
# ---------------------------------------------------------------------------
zshrc="$HOME/.zshrc"
source_line="source $DOTFILES/myenv.sh"
if [ -f "$zshrc" ] && grep -qF "$source_line" "$zshrc"; then
  skip "ok: myenv.sh already sourced from .zshrc"
else
  log "Adding myenv.sh to .zshrc"
  printf '\n%s\n' "$source_line" >> "$zshrc"
fi

log "Done. Restart your shell (or: exec zsh) to pick up changes."
