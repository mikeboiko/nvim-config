# nvim-config

My neovim config files

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
- `.github/workflows/ci.yml` mirrors the local checks in CI while the Lua migration is still in progress.
