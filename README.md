# notreallyuri // dotfiles

A minimal, logic-heavy configuration focused on Neovim, Hyprland, and custom
Lua-powered CLI tools.

## Dependencies

- Lua: Almost EVERYTHING here uses lua, including the CLI tools.
- Fastfetch: Used for the nofetch wrapper
- noshot: `grim`, `slurp`, `wl-clipboard`, `hyprctl`, `jq` and `notify-send`.
  Optional per feature: `satty` (--edit), `tesseract` (--ocr), `curl`
  (--search) and `gpu-screen-recorder` or `wf-recorder` (recording).
- Nerd Fonts: Most of them can be found inside of ./fonts `(To be added)`

## Structure

```
├──  bin/          # Custom CLI wrappers (nofetch, noquote)
├──  nothings/     # The config center - options, data (ASCII art, JSON), plugins
├──  noshot/       # Hyprland screenshot & recording tool (Lua)
├──  nvim/         # LazyVim-based Neovim config
├──  hypr/         # Hyprland tiling window manager configs
├──  fastfetch/    # Custom fetch layouts
├──  wezterm/      # Lua-configured terminal emulator
├──  src/          # The installer, in Rust
└──  installer-*   # Prebuilt installers (linux, mac)
```

## Custom tools

Unlike traditional shell-heavy dotfiles, the logic here is handled by Lua for
better maintainability and performance.

### nofetch

A custom wrapper for fastfetch.

- Dynamic ASCII: Loads art from nothings/arts/.
- Modes: Supports --mini for a compact view.
- Smart Fallbacks: Lists available logos if the requested one is missing.

### noquote

A "cringe" generator (or general quote tool).

- Uses nothings/cringe.lua to parse cringe.json.
- Weighted randomization for different quote categories.

### noshot

A screenshot and screen recording tool for Hyprland.

- Captures: region, monitor, window or every screen at once, with the screen
  frozen while you drag a selection.
- Extras: annotate in satty, OCR straight to the clipboard, reverse image
  search, and recording with instant replay.
- Layered config: defaults, then nothings/noshot.conf.lua, then its drop-ins,
  then whatever a front-end writes, then env vars and flags. `noshot config`
  prints every option and where its value came from.
- Front-end: nothings/noctalia/noshot is a Noctalia shell plugin for it.

Run `noshot help` for the full command list.

## Installation

1. Copy this repository
2. Run the proper `installer` based on your current system. (Works on linux & macOS)

The installer symlinks (or copies) the folders you pick into `~/.config` and
puts `bin/` on `~/.local/bin`. When noshot is among them it also offers to
install a `noshot` command there, so the tool works outside of the Hyprland
keybinds.

It is built from `src/`: run `cargo build --release` and copy
`target/release/dotinstaller` over `installer-linux` after changing it.
