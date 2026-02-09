# notreallyuri // dotfiles

A minimal, logic-heavy configuration focused on Neovim, Hyprland, and custom
Lua-powered CLI tools.

## Dependencies

- Zsh: I made the installer with zsh in mind, don't ask why.
- Lua: Almost EVERYTHING here uses lua, including the CLI tools.
- Fastfetch: Used for the nofetch wrapper
- Nerd Fonts: Most of them can be found inside of ./fonts `(To be added)`

## Structure

```
├──  bin/          # Custom CLI wrappers (nofetch, noquote)
├──  nothings/     # The "brain" - Lua modules and data (ASCII art, JSON)
├──  nvim/         # LazyVim-based Neovim config
├──  hypr/         # Hyprland tiling window manager configs
├──  fastfetch/    # Custom fetch layouts
├──  wezterm/      # Lua-configured terminal emulator
└──  install.sh    # Zsh automated symlink manager
```

## Custom tools

Unlike traditional shell-heavy dotfiles, the logic here is handled by Lua for
better maintainability and performance.

### nofetch

A custom wrapper for fastfetch.

- Dynamic ASCII: Loads art from nothings/ascii/.
- Modes: Supports --mini for a compact view.
- Smart Fallbacks: Lists available logos if the requested one is missing.

### noquote

A "cringe" generator (or general quote tool).

- Uses nothings/cringe.lua to parse cringe.json.
- Weighted randomization for different quote categories.

## Installation

1. Copy this repository
2. Run the proper `installer` based on your current system. (Works on linux & macOS)
