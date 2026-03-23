# nvim-config

My neovim config files

## Requirements

- This config targets modern Neovim, currently `0.11.x` stable or newer.
- Local hook checks assume a matching modern Neovim runtime and a local `plenary.nvim` checkout at `$HOME/.local/share/nvim/lazy/plenary.nvim` unless `PLENARY_PATH` is overridden.

## Structure

- Shared Lua wiring lives in `lua/config/`.
- Reusable migrated helpers are starting to live in focused `lua/config/*.lua` modules such as `windows.lua`, `quickfix.lua`, `folds.lua`, `comments.lua`, `terminal.lua`, `clipboard.lua`, `tabline.lua`, `editor.lua`, `shell.lua`, `buffers.lua`, and `workspace.lua`.
- The ongoing keymap migration is moving repo-owned search and workflow maps into `lua/config/keymaps.lua` on top of those helper modules, instead of leaving behavior split across Vimscript remaps and Lua commands.
- Core editing behaviors such as fileformat conversion and blank-line insertion are also moving behind tested helpers in `lua/config/editor.lua`, with `lua/config/keymaps.lua` owning the user-facing maps.
- Terminal navigation maps now route through a Lua helper as well: `lua/config/autocmds.lua` calls `lua/config/keymaps.lua` on `TermOpen` instead of relying on a legacy global function.
- Copilot workflow maps are now also owned by `lua/config/keymaps.lua`, with a small tested helper for invoking plugin-provided global callbacks without crashing when a callback is missing.
- External workflow maps like git-diff terminals, markdown preview, Explorer launchers, and report tabs are now routed through tested helpers in `lua/config/shell.lua` instead of being hard-coded as Vimscript remaps.
- Fugitive/Git prompt maps and the prompt-based rename shortcut are now also managed from `lua/config/keymaps.lua`, with the rename path covered through the same tested global-callback bridge used by other workflow maps.
- Small utility maps such as append-at-EOL helpers, path-copy shortcuts, close helpers, rerun-command/command-history entry, and paragraph commenting are now also managed from Lua, and the old `<leader>redo` compatibility map has been removed.
- Tab/window navigation helpers such as `gI`, `gT`, `gt`, `gs`, `gv`, `<C-t>`, `<C-Tab>`, and `<Tab>` are now also owned by `lua/config/keymaps.lua`, with the matching legacy Vimscript maps removed.
- Search/sort and compatibility maps such as `<leader>/`, `<leader>so`, `<C-z>`, and `<C-y>` are now also owned by `lua/config/keymaps.lua`; the old `<leader>sv` self-reload shortcut has been removed.
- The last general `vimscript/init.vim` mappings, including the `gf` workaround and GUI font hotkeys, now route through Lua-backed helpers in `lua/config/keymaps.lua` and `lua/config/editor.lua`.
- Help-lookup mappings for `help` and `vim` buffers now live in `after/ftplugin/help.lua` and `after/ftplugin/vim.lua`, so there are no active `:map` definitions left in repo `.vim` files.
- Plugin-local bootstrap and setup live in `lua/plugins/`.
- Filetype-local overrides live in `after/ftplugin/` and custom detection in `after/ftdetect/`.
- Legacy Vimscript is still sourced during the migration, but low-risk startup settings are being moved into Lua as each stage is completed.

## Testing

Format the full Lua tree:

```bash
stylua init.lua lua after tests
```

Check formatting without rewriting files:

```bash
stylua --check init.lua lua after tests
```

Run the Plenary test suite:

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

Run a headless startup smoke test against this checkout:

```bash
nvim --headless -u init.lua -c "qa"
```

## Automation

- Install local git hooks with `lefthook install`.
- `.lefthook.yml` now runs the repo checks directly in `pre-commit`: staged-Lua formatting, `stylua --check init.lua lua after tests`, Lua syntax checks, the Plenary suite, and a headless startup smoke test.
- There is no GitHub Actions workflow at the moment; hook-based validation is the source of truth during the Lua migration.
