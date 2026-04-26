# nvim-config

A Lua-only Neovim configuration focused on fast navigation, solid language tooling, AI-assisted workflows, and practical test/debug support.

## Highlights

- Lua-first structure with shared config in `lua/config/`, plugin specs in `lua/plugins/`, and filetype overrides in `after/`.
- Strong code-navigation workflow built around `fzf-lua`, `nvim-tree`, `aerial.nvim`, Tree-sitter, and a custom always-visible tabline that keeps the current tab visible when crowded.
- Comment helpers stay usable in non-Tree-sitter buffers by falling back to the buffer-local `commentstring`, so mappings like `co` still work in files such as `.env`.
- Completion and AI tooling with `blink.cmp`, `copilot.lua`, `blink-cmp-copilot`, and `CopilotChat.nvim`.
- Language tooling powered by `nvim-lspconfig`, `mason.nvim`, `conform.nvim`, and `nvim-treesitter`.
- Testing and debugging workflows via `neotest`, `nvim-dap`, and `nvim-dap-ui`.
- Git and review workflow with `vim-fugitive`, `vim-rhubarb`, `gv.vim`, quickfix helpers, repo-aware shell helpers, and shell-parity shortcuts like `<leader>ga` for `git add -A` with a completion notification.
- Local automation with `lefthook` and a Plenary-based headless test suite.

## Selected plugins

- Plugin management: `lazy.nvim`
- Navigation and UI: `fzf-lua`, `nvim-tree.lua`, `aerial.nvim`, `treesitter-context.nvim`, `lualine.nvim`, `snacks.nvim` (notifications and popup input), `nvim-origami`
- Completion and editing: `blink.cmp`, `copilot.lua`, `blink-cmp-copilot`, `nvim-autopairs`, `nvim-surround`, `substitute.nvim`
- Markdown workflow: `selimacerbas/markdown-preview.nvim`, `img-paste.vim`
- Markdown folds use `nvim-origami` with a `zx` refresh on markdown `InsertLeave` and `TextChanged` events to recover clean fold state after edits.
- Language tooling: `nvim-lspconfig`, `mason.nvim`, `conform.nvim`, `nvim-treesitter`
- Testing and debugging: `neotest`, `neotest-dotnet`, `neotest-python`, `nvim-dap`, `nvim-dap-ui`
- Git and diffing: `vim-fugitive`, `vim-rhubarb`, `gv.vim`

## Language support

This config is set up for everyday work across:

- Lua
- Python
- TypeScript / JavaScript / Vue
- C#
- Go
- SQL
- Markdown
- YAML / JSON / TOML / Bash

## Repository layout

- `init.lua` bootstraps the config and loads `lazy.nvim`.
- `lua/config/` contains shared editor behavior, commands, autocmds, and focused helper modules for buffers, terminals, windows, and keymap facades.
- `lua/config/commands.lua` also preserves legacy function-style entrypoints when plugin workflows still call them directly.
- `lua/plugins/` contains one Lazy spec per plugin or plugin group.
- `after/ftplugin/` and `after/ftdetect/` contain filetype-local behavior.
- `tests/` contains the Plenary test harness and a focused set of repo-level behavior tests.

## Requirements

- Neovim `0.11.x` stable or newer
- `git`
- `make` for building `CopilotChat.nvim`
- `mmdr` (`cargo install mermaid-rs-renderer`) for Rust-backed Mermaid rendering in `markdown-preview.nvim`
- Language servers / formatters installed through Mason or system packages, depending on the tool

For local test runs, the suite expects `plenary.nvim` at:

```bash
$HOME/.local/share/nvim/lazy/plenary.nvim
```

Override with `PLENARY_PATH` if needed.

The suite is intentionally biased toward startup, module-loading, commands, and stateful editor behaviors instead of exhaustive snapshots of every option or keymap.

## Installation

Place the repository at `~/.config/nvim`. For example:

```bash
git clone <repo-url> ~/.config/nvim
# or
ln -s /path/to/this/repo ~/.config/nvim
```

Then start Neovim to let `lazy.nvim` bootstrap itself and install plugins.

Useful follow-up commands:

```vim
:Lazy sync
:Mason
:TSUpdateSync
```

To restore plugin versions exactly from `lazy-lock.json`:

```bash
nvim --headless -u init.lua "+Lazy! restore" +qa
```

## Validation

Format the Lua tree:

```bash
stylua init.lua lua after tests
```

Check formatting without rewriting files:

```bash
stylua --check init.lua lua after tests
```

Run the focused Plenary suite:

```bash
PLENARY_PATH="$HOME/.local/share/nvim/lazy/plenary.nvim" \
  nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/nvim-config { minimal_init = 'tests/minimal_init.lua' }" \
  -c "qa"
```

Run a single test file:

```bash
PLENARY_PATH="$HOME/.local/share/nvim/lazy/plenary.nvim" \
  nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedFile tests/nvim-config/config_modules_spec.lua" \
  -c "qa"
```

Run a headless startup smoke test:

```bash
nvim --headless -u init.lua -c "qa"
```

## Automation

- Install hooks with `lefthook install`
- Run the local automation stack with `lefthook run pre-commit`

The `pre-commit` hook runs:

- staged Lua formatting
- `stylua --check`
- Lua syntax checks
- the focused Plenary suite
- a headless startup smoke test
