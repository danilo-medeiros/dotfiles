export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
eval "$(zoxide init zsh)"
alias cd=z

ulimit -n 64000
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
