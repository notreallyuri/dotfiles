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
- Format Lua with `stylua` before committing changes to `.lua` files. The repo root has a `stylua.toml` (two-space indent, `collapse_simple_statement = "FunctionOnly"`) that stylua finds by walking up, so run it without flags. Mason installs stylua; `.styluaignore` excludes the vendored `nothings/dkjson.lua`.
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
- C# is handled by `roslyn.nvim` (`lsp/csharp.lua`), which ships its own `lsp/roslyn.lua` on the runtimepath and calls `vim.lsp.enable("roslyn")` itself — so `roslyn` must **not** be added to the enable list in `lsp.lua`. The spec's `init` only layers `vim.lsp.config("roslyn", { settings = ... })` on top; those settings use the server's flat `["csharp|<section>"]` key format, not a nested table.
- Java is handled by `nvim-jdtls` (`lsp/java.lua`, a bare `lazy = true` spec) and started per-project from `ftplugin/java.lua`, not by `vim.lsp.enable`. jdtls needs a dedicated `-data` workspace dir plus the `java-test`/`java-debug-adapter` jars in `init_options.bundles`, which the native path can't express. Its settings table lives in `lsp/settings/jdtls.lua`.
- Because of that, `mason-lspconfig`'s `automatic_enable` (which defaults to **on** and enables every installed server) must keep excluding `jdtls` in `lsp/mason.lua` — otherwise a second, unconfigured jdtls client spawns alongside the nvim-jdtls one.
- Mason (`lsp/mason.lua`) installs LSP servers via `mason-lspconfig`'s `ensure_installed`, and separately installs non-LSP CLI tools via `mason-tool-installer`. Two guards there skip tools whose toolchain is missing: npm-backed ones (`prettier`, `markdownlint-cli2`, `markdown-toc`) and dotnet-backed ones (`roslyn-language-server`, `csharpier`, `netcoredbg`). `roslyn-language-server` has to go through `mason-tool-installer` because it isn't an `nvim-lspconfig` server name.

### Formatting (`lua/plugins/coding/conform.lua`)

`conform.nvim` drives `formatters_by_ft`, mostly with `stop_after_first` fallback chains (e.g. TS/JS try `biome_sort` then `prettier`). `biome_sort` is a custom formatter entry (not a stock conform formatter) defined to run `biome check --write --unsafe` for import sorting before the primary formatter runs. Java is deliberately absent from `formatters_by_ft` so `format_on_save`'s `lsp_format = "fallback"` routes it to jdtls' own formatter.

### Debugging (`lua/plugins/coding/dap.lua`)

All `nvim-dap` adapters and configurations live in that **single** spec. lazy.nvim keeps only the last `config` function when one plugin is declared by several specs, so splitting per-language dap config into a second `mfussenegger/nvim-dap` spec silently discards one of them. C# uses `coreclr`/`netcoredbg`; Java's adapter is registered by nvim-jdtls' `setup_dap` from `ftplugin/java.lua`; Rust's comes from rustaceanvim.

### Testing (`lua/plugins/coding/neotest.lua`)

Rust, vitest and .NET have neotest adapters. Java does **not** — it runs tests through jdtls' own java-test bridge, bound to the same `<leader>t*` keys buffer-locally in `ftplugin/java.lua`.

### Adding a new plugin

Drop a new file under the relevant `lua/plugins/<category>/` directory returning a `lazy.nvim` spec (or list of specs); it's picked up automatically by the directory import in `init.lua`. No manual registration needed elsewhere unless it needs an LSP config (add to `lsp.lua` + `mason.lua`) or a formatter (add to `conform.lua`).
