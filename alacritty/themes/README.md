# Alacritty Theme

Collection of colorschemes for easy configuration of the [Alacritty terminal
emulator].

[Alacritty terminal emulator]: https://github.com/alacritty/alacritty

Vendored from <https://github.com/alacritty/alacritty-theme>. See `LICENSE`.

The upstream README carries a screenshot gallery of every theme; those images
were dropped here to keep this dotfiles repo small. Browse the gallery upstream:
<https://github.com/alacritty/alacritty-theme#themes>

## Usage

Themes are imported by `alacritty/alacritty.toml` via `general.import`:

```toml
general.import = [
  "~/.config/alacritty/themes/one_light.toml"
]
```

To switch themes, change the filename in that import and reload Alacritty.
