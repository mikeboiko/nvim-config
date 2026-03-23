# nvim-config

My neovim config files

## Requirements

- This config targets modern Neovim, currently `0.11.x` stable or newer.
- Local hook checks assume a matching modern Neovim runtime and a local `plenary.nvim` checkout at `$HOME/.local/share/nvim/lazy/plenary.nvim` unless `PLENARY_PATH` is overridden.

## Structure

- Shared Lua wiring lives in `lua/config/`.
- Reusable helper modules live in focused `lua/config/*.lua` files such as `git.lua`, `windows.lua`, `quickfix.lua`, `folds.lua`, `comments.lua`, `terminal.lua`, `clipboard.lua`, `tabline.lua`, `editor.lua`, `shell.lua`, `buffers.lua`, and `workspace.lua`.
- Keymap registration is split by concern under `lua/config/keymaps/*.lua`, with `lua/config/keymaps.lua` exposing the shared helper functions used by tests and autocmds.
- Core editing behaviors such as fileformat conversion, blank-line insertion, spell toggles, yanking helpers, and GUI font resizing live in `lua/config/editor.lua`, with the keymap modules owning the user-facing bindings.
- Search, quickfix, Git, Copilot, and external workflow bindings are routed through Lua helpers instead of ad hoc command strings where practical.
- `lua/config/autocmds.lua` calls `require('config.keymaps').set_terminal_keymaps(...)` on `TermOpen` so terminal navigation maps stay buffer-local while using the same keymap facade.
- Help-lookup mappings for `help` and `vim` buffers now live in `after/ftplugin/help.lua` and `after/ftplugin/vim.lua`, so buffer-local editor behavior is fully configured from Lua.
- Startup globals, options, clipboard provider settings, and GUI enter behavior all live in Lua under `lua/config/{constants,options,autocmds,gui,editor}.lua`.
- Filetype-local Markdown/sebol behavior and the AutoHotkey syntax setup live in Lua through `lua/config/filetypes.lua` plus `after/ftplugin/*.lua`.
- Plugin-local bootstrap and setup live in `lua/plugins/`.
- Filetype-local overrides live in `after/ftplugin/` and custom detection in `after/ftdetect/`.
- The active config is Lua-native and does not rely on a repo-owned Vimscript compatibility layer.

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
- There is no GitHub Actions workflow at the moment; hook-based validation is the source of truth.
