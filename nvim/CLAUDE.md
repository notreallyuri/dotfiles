# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a hand-rolled Neovim configuration (not the LazyVim distribution, despite the top-level dotfiles `README.md` calling it "LazyVim-based" — it only uses `folke/lazy.nvim` as the plugin manager, bootstrapped directly in `init.lua`). It lives in a larger dotfiles monorepo at `../` and is normally consumed by symlinking this directory to `~/.config/nvim` via the repo's `install.sh`.

## Commands

There is no build/test suite — this is an editor config. Useful in-editor commands while iterating:

- `:Lazy sync` — install/update/clean plugins after editing a spec under `lua/plugins/`.
- `:Lazy reload <plugin>` — reload a single plugin spec without restarting.
- `:Mason` — manage LSP servers/formatters installed via `mason-lspconfig`/`mason-tool-installer` (see `lua/plugins/lsp/mason.lua`).
- `:TSUpdate` — (re)compile treesitter parsers; requires the `tree-sitter` CLI on `$PATH`.
- `:checkhealth` — diagnose LSP/treesitter/plugin issues.
- Format Lua with `stylua` (no repo-local `stylua.toml`; defaults apply) before committing changes to `.lua` files.
- Launch with a scratch config to test changes in isolation: `nvim --clean -u init.lua` from this directory (or `nvim -u NONE` to bypass entirely).

## Architecture

### Load order (`init.lua`)

1. `vim.g.mapleader`/`maplocalleader` set first.
2. `lua/config/options.lua`, `autocmds.lua`, `keymaps.lua` load — these are plain `vim.opt`/`vim.keymap` calls with no plugin dependencies.
3. `package.path` is extended to reach `~/.config/nothings/?.lua`, a sibling dotfiles module (ASCII art / data helpers from the monorepo's `nothings/` dir) used by things like the dashboard.
4. `lazy.nvim` is bootstrapped (cloned to stdpath if missing) and plugin specs are loaded via directory imports: `plugins.ui`, `plugins.editor`, `plugins.lsp`, `plugins.coding`, `plugins.ai`. Import order matters for load priority within `lazy.nvim`.
5. `config/colorscheme.lua` runs **last**, after plugins are set up.

### `lua/config/` vs `lua/plugins/`

- `lua/config/` holds plugin-independent editor behavior (options, autocmds, keymaps) plus `colorscheme.lua`/`transparency.lua`: these persist the active theme + transparency toggle to a plain-text file at `stdpath("data")/colorscheme` (format: `theme = <name>\nclear = <bool>`), read on startup and rewritten by the `<leader>ut` (theme picker) and `<leader>uc` (toggle transparency) keymaps in `keymaps.lua`. Any change to the theme-switching UX has to keep the write side (`keymaps.lua`) and read side (`colorscheme.lua`) in sync on this file format.
- All treesitter setup (parser installs, highlighting, indent, and textobjects) lives in the `nvim-treesitter`/`nvim-treesitter-textobjects` plugin specs in `lua/plugins/lsp/treesitter.lua` — there is no separate manual bootstrap.
- `lua/plugins/` is organized by concern, each subdirectory imported independently from `init.lua`: `ui/`, `editor/`, `lsp/`, `coding/`, `ai/`. One file per plugin (or tightly related group), returning a `lazy.nvim` spec table.

### LSP setup (`lua/plugins/lsp/`)

Uses Neovim's **native** LSP config API (`vim.lsp.config(name, cfg)` + `vim.lsp.enable({...})`) directly in `lsp.lua`, not the older `require("lspconfig").<server>.setup{}` pattern — `nvim-lspconfig` is present only as a dependency providing default server configs. Per-server settings tables that grow large enough to want their own file live under `lsp/settings/` (e.g. `vtsls.lua`, `clangd.lua`, `tailwindcss.lua`) and are `require`d into `lsp.lua`.

- `rust_analyzer` is explicitly disabled in `lsp.lua` (`vim.lsp.enable("rust_analyzer", false)`) because Rust is handled entirely by `rustaceanvim` (`lsp/rust.lua`), which manages its own rust-analyzer instance — don't re-enable it there without removing rustaceanvim's ownership first.
- `copilot` is likewise disabled as an LSP client (`vim.lsp.enable("copilot", false)`) since `copilot.lua` (`plugins/ai/copilot.lua`) runs in suggestion mode, not as a completion-source LSP.
- C#/omnisharp uses a custom `textDocument/definition` handler from `omnisharp-extended-lsp.nvim`.
- Mason (`lsp/mason.lua`) installs LSP servers via `mason-lspconfig`'s `ensure_installed`, and separately installs non-LSP CLI tools (formatters like `prettier`, `markdownlint-cli2`, `csharpier`-adjacent tooling) via `mason-tool-installer`.

### Formatting (`lua/plugins/coding/conform.lua`)

`conform.nvim` drives `formatters_by_ft`, mostly with `stop_after_first` fallback chains (e.g. TS/JS try `biome_sort` then `prettier`). `biome_sort` is a custom formatter entry (not a stock conform formatter) defined to run `biome check --write --unsafe` for import sorting before the primary formatter runs.

### Adding a new plugin

Drop a new file under the relevant `lua/plugins/<category>/` directory returning a `lazy.nvim` spec (or list of specs); it's picked up automatically by the directory import in `init.lua`. No manual registration needed elsewhere unless it needs an LSP config (add to `lsp.lua` + `mason.lua`) or a formatter (add to `conform.lua`).
