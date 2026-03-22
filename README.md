# nvim-config

My neovim config files

## Requirements

- This config targets modern Neovim, currently `0.11.x` stable or newer.
- CI installs the official Neovim stable tarball instead of Ubuntu's distro package so the test environment matches the Lua runtime and `after/ftplugin/*.lua` behavior used by this repo.

## Structure

- Shared Lua wiring lives in `lua/config/`.
- Plugin-local bootstrap and setup live in `lua/plugins/`.
- Filetype-local overrides live in `after/ftplugin/` and custom detection in `after/ftdetect/`.
- Legacy Vimscript is still sourced during the migration, but low-risk startup settings are being moved into Lua as each stage is completed.

## Testing

Format the Stage 1 managed Lua surface:

```bash
stylua init.lua tests
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
- `.lefthook.yml` formats staged Lua files with Stylua on pre-commit and runs Stage 1 checks on pre-push.
- `.github/workflows/ci.yml` mirrors the local checks in CI while the Lua migration is still in progress, and it installs official Neovim stable instead of the older Ubuntu package.
