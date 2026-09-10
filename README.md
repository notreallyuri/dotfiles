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
- Neovim: 0.12+. Language toolchains are only needed for the languages you
  actually open: a JDK 21+ for Java, the .NET SDK for C#, and node for the
  npm-backed formatters. Mason skips whatever is missing.

## Structure

```
├──  bin/          # Custom CLI wrappers (nofetch, noquote)
├──  nothings/     # The config center - options, data (ASCII art, JSON), plugins
├──  noshot/       # Hyprland screenshot & recording tool (Lua)
├──  nvim/         # Hand-rolled Neovim config (lazy.nvim only)
├──  hypr/         # Hyprland tiling window manager configs
├──  fastfetch/    # Custom fetch layouts
├──  wezterm/      # Lua-configured terminal emulator
├──  src/          # The installer, in Rust
└──  installer-*   # Prebuilt installers (linux, mac)
```

Hyprland currently launches `ghostty`, which has no config in this repo yet.
`wezterm/` is still here and still works if you point `hypr/variables.lua` back
at it.

## Neovim

Hand-rolled rather than a distribution: `lazy.nvim` is only the plugin manager,
bootstrapped from `init.lua`. Specs live under `nvim/lua/plugins/`, grouped by
concern (`ui`, `editor`, `lsp`, `coding`), one file per plugin. Servers are
configured with Neovim's native `vim.lsp.config` / `vim.lsp.enable` API, not
`lspconfig.<server>.setup{}`. Mason installs the servers, formatters and debug
adapters, skipping any whose toolchain is missing.

| Language | Server | Format | Debug | Test |
| --- | --- | --- | --- | --- |
| Rust | rust-analyzer (rustaceanvim) | rustfmt | codelldb | neotest |
| TypeScript / JS | vtsls, eslint, biome | biome, prettier | js-debug | neotest (vitest) |
| Java | jdtls (nvim-jdtls) | jdtls | java-debug | java-test |
| C# | roslyn (roslyn.nvim) | csharpier | netcoredbg | neotest |
| C / C++ | clangd | clangd | - | - |
| Lua | lua_ls | stylua | - | - |
| Markdown | marksman | markdownlint-cli2 | - | - |

Lua is the exception to Mason-managed tooling. conform calls `stylua`, but this
config predates it and only 20 of its 49 Lua files match stylua's output, so it
is left to `$PATH` rather than installed automatically. Installing it would
quietly reformat the config on the next save.

Java is the one server not started by `vim.lsp.enable`. jdtls needs its own
workspace directory and the test/debug jars wired in per project, so
`nvim/ftplugin/java.lua` starts it through nvim-jdtls instead. Java tests run on
jdtls' own java-test bridge, bound to the same `<leader>t` keys neotest uses
everywhere else.

Theme changes persist. `<leader>ut` picks a colorscheme and `<leader>uc` toggles
transparency, both written to `stdpath("data")/colorscheme` and read back on the
next start.

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
