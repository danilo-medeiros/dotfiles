# dotfiles

Personal macOS configuration: zsh, tmux, Neovim, Alacritty, Hammerspoon, and
Claude Code.

> This repo is **public**. Anything host-specific or work-related belongs in
> `~/.myenv.local`, which is untracked and sourced by `myenv.sh`.

## Install

```sh
git clone git@github.com:danilo-medeiros/dotfiles.git ~/personal/dotfiles
cd ~/personal/dotfiles
./setup.sh
exec zsh
```

`setup.sh` installs Homebrew, oh-my-zsh, the formulae the configs depend on, and
symlinks everything into place. It is safe to re-run: existing packages and
correct symlinks are skipped, and anything already at a link target is moved to
`<name>.backup.<timestamp>` rather than overwritten.

The repo can live anywhere — `setup.sh` resolves paths from its own location.

```sh
./setup.sh --link   # only refresh the symlinks, skip package installs
```

## What gets linked

| Repo path                | Linked to             |
| ------------------------ | --------------------- |
| `.tmux.conf`             | `~/.tmux.conf`        |
| `nvim/`                  | `~/.config/nvim`      |
| `alacritty/`             | `~/.config/alacritty` |
| `hammerspoon/init.lua`   | `~/.hammerspoon/init.lua` |
| `claude/CLAUDE.md`       | `~/.claude/CLAUDE.md` |
| `claude/templates/`      | `~/.claude/templates` |

`myenv.sh` is not linked; `setup.sh` appends a `source` line for it to
`~/.zshrc`.

## Machine-local settings

`myenv.sh` sources `~/.myenv.local` if present. Use it for anything that
shouldn't be public:

```sh
# ~/.myenv.local
export PMS_BASE_URL="https://your-org.atlassian.net/browse/"
```

`PMS_BASE_URL` powers Neovim's `:Ticket`, which extracts a ticket id from the
current branch name and opens `$PMS_BASE_URL<TICKET>`.

## Manual steps

Not handled by `setup.sh`:

- **elixir-ls** — download a release from
  [elixir-ls releases](https://github.com/elixir-lsp/elixir-ls/releases/latest),
  unzip to `~/.local/share/elixir-ls` (see the comment in `nvim/init.lua`).
- **Node** — install via `asdf` (or `brew install node`) before `setup.sh` can
  install the TypeScript, Tailwind, and ESLint language servers.
- **Hammerspoon** and **Alacritty** apps themselves, plus Hammerspoon's
  Accessibility permission.

## Neovim commands

Custom commands defined in `nvim/init.lua`:

| Command    | Does                                                  |
| ---------- | ----------------------------------------------------- |
| `:P`       | Copy relative file path                               |
| `:L`       | Copy relative file path with line number              |
| `:G`       | Copy + open the GitHub permalink for the line/range   |
| `:GC`      | Open the GitHub commit that last touched the line     |
| `:GP`      | `git pull origin <current branch>`                    |
| `:R`       | Reload buffer and refresh gitsigns                    |
| `:D`       | Diffview of unstaged changes                          |
| `:PR`      | Open the current branch's PR in the browser           |
| `:PRs`     | Open your PRs for this repo                           |
| `:Review N`| Check out PR `N` and diff it against its base branch   |
| `:Ticket`  | Open the ticket named in the branch (`PMS_BASE_URL`)   |

`:PR`, `:PRs`, and `:Review` require the `gh` CLI to be authenticated
(`gh auth login`).

## Alacritty themes

`alacritty/themes/` is vendored from
[alacritty/alacritty-theme](https://github.com/alacritty/alacritty-theme) with
the screenshot gallery removed. Switch themes by editing the import at the top
of `alacritty/alacritty.toml`.
