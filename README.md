# nvim-config

My neovim config files

## Requirements

- This config targets modern Neovim, currently `0.11.x` stable or newer.
- Local hook checks assume a matching modern Neovim runtime and a local `plenary.nvim` checkout at `$HOME/.local/share/nvim/lazy/plenary.nvim` unless `PLENARY_PATH` is overridden.

## Structure

- Shared Lua wiring lives in `lua/config/`.
- Reusable migrated helpers are starting to live in focused `lua/config/*.lua` modules such as `windows.lua`, `quickfix.lua`, `folds.lua`, `comments.lua`, `terminal.lua`, `clipboard.lua`, `tabline.lua`, `editor.lua`, `shell.lua`, `buffers.lua`, and `workspace.lua`.
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
