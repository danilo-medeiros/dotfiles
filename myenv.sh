codeview() {
    z $1 || return 1
    tmux split-window -h
    tmux resize-pane -R 70
    tmux send-keys -t 1 'git status' Enter
    tmux select-pane -L
    tmux split-window -v
    tmux resize-pane -D 20
    tmux select-pane -U
    nvim README.md
}
