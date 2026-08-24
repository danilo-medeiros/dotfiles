# Sourced from ~/.zshrc (see setup.sh).

# asdf shims. Guarded so re-sourcing this file doesn't stack duplicate PATH
# entries -- ~/.zshrc may already export this.
asdf_shims="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
case ":$PATH:" in
  *":$asdf_shims:"*) ;;
  *) export PATH="$asdf_shims:$PATH" ;;
esac
unset asdf_shims

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

ulimit -n 64000

zsh_autosuggestions="/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -r "$zsh_autosuggestions" ] && source "$zsh_autosuggestions"
unset zsh_autosuggestions

# Machine-local settings: anything host-specific or not for a public repo.
# This repo is public, so work URLs, tokens and the like belong here.
#
# nvim's :Ticket command (nvim/init.lua) reads PMS_BASE_URL from the
# environment and opens "$PMS_BASE_URL<TICKET>" for the ticket id in the
# current branch name. Set it in ~/.myenv.local, e.g.:
#
#   export PMS_BASE_URL="https://your-org.atlassian.net/browse/"
#
[ -r "$HOME/.myenv.local" ] && source "$HOME/.myenv.local"
