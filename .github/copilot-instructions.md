# Copilot instructions for `nvim-config`

## Build, test, and lint commands

- Hook automation currently checks the full Lua tree with Stylua:
  - `stylua init.lua lua after tests`
  - `stylua --check init.lua lua after tests`
- The pre-commit hook is the active automation entrypoint. It formats staged Lua files first, then runs Stylua checks, Lua syntax checks, the Plenary suite, and a headless startup smoke test.
- Repo tests use Plenary's busted harness:
  - full suite: `PLENARY_PATH="$HOME/.local/share/nvim/lazy/plenary.nvim" nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/nvim-config { minimal_init = 'tests/minimal_init.lua' }" -c "qa"`
  - single test file: `PLENARY_PATH="$HOME/.local/share/nvim/lazy/plenary.nvim" nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/nvim-config/config_modules_spec.lua" -c "qa"`
- Headless startup smoke test for this checkout:
  - `nvim --headless -u init.lua -c "qa"`
- Run the same local automation explicitly with:
  - `lefthook run pre-commit`
- After changing plugin specs in `lua/plugins/*.lua` or the plugin lockfile, use a deterministic restore:
  - `nvim --headless -u init.lua "+Lazy! restore" +qa`
- After changing Tree-sitter parser configuration in `lua/plugins/nvim-treesitter.lua`:
  - `nvim --headless -u init.lua "+TSUpdateSync" +qa`
- Lefthook also runs Lua syntax checks across `init.lua`, `lua/`, `after/`, and `tests/` with `lua -e "assert(loadfile(...))"`.
- Format the current buffer from inside Neovim:
  - `<leader>fi`
  - `:ConformInfo`
- C# Roslyn setup is handled through Mason:
  - `:MasonInstall roslyn`

## High-level architecture

- `init.lua` is the entrypoint. It optionally launches `osv` for debugging when `init_debug` is set, then loads shared Lua modules from `lua/config/*`, and finally bootstraps `lazy.nvim` through `lua/config/lazy.lua`.
- Look in `lua/config/*`, `after/ftplugin/*.lua`, `after/ftdetect/*.lua`, and `lua/plugins/*.lua` before assuming a behavior is not configured yet.
- `lua/config/lazy.lua` imports the `plugins` namespace, so each file under `lua/plugins/` is a Lazy spec module. `lazy-lock.json` pins the resolved plugin versions.
- The repo currently relies on local hook-based validation rather than GitHub Actions, and it targets Neovim stable (`0.11.x` today).
- Shared editor behavior is split across `lua/config/` modules such as `constants.lua`, `options.lua`, `autocmds.lua`, `functions.lua`, `comments.lua`, and `keymaps.lua`.
- Reusable helper modules live in focused files under `lua/config/`, with `git.lua`, `windows.lua`, `quickfix.lua`, `folds.lua`, `comments.lua`, `terminal.lua`, `clipboard.lua`, `tabline.lua`, `editor.lua`, `shell.lua`, `buffers.lua`, and `workspace.lua` as current examples.
- Keymap registration is split by concern under `lua/config/keymaps/*.lua`, with `lua/config/keymaps.lua` exposing shared helpers like `call_global()`, `prompt_rename()`, and `set_terminal_keymaps()`.
- `lua/config/autocmds.lua` calls `require('config.keymaps').set_terminal_keymaps(...)` directly on `TermOpen`, and those terminal maps are intentionally buffer-local.
- Core editing behavior such as fileformat reloads, blank-line insertion, whole-buffer yanks, spell toggles, and GUI font resizing is routed through `lua/config/editor.lua`.
- Search, quickfix, Git, Copilot, and external workflow bindings live in the keymap modules and defer to helpers like `shell.lua`, `quickfix.lua`, and `folds.lua` where appropriate.
- Help lookup for `help`/`vim` buffers now lives in `after/ftplugin/help.lua` and `after/ftplugin/vim.lua`; buffer-local editor behavior is configured from Lua.
- Startup globals, options, clipboard provider settings, and GUI enter behavior now live in `lua/config/{constants,options,autocmds,gui,editor}.lua`.
- Markdown/sebol filetype behavior and the AutoHotkey syntax setup live in Lua through `lua/config/filetypes.lua` plus `after/ftplugin/*.lua`.
- Plugin-local startup globals should live in plugin spec `init` blocks instead of unrelated startup code; `nvim-tree`, markdown preview, and img-paste already follow this pattern.
- The repo now has a lightweight test harness under `tests/`; `tests/minimal_init.lua` prepends the repo and Plenary to `runtimepath`, and specs under `tests/nvim-config/` intentionally cover Lua modules and repo-owned behavior without depending on a full interactive session.
- Filetype behavior is layered:
  - late Lua overrides in `after/ftplugin/`
  - custom filetype detection in `after/ftdetect/`
  - snippet definitions registered from `snippets/package.json`
- Language tooling is spread across a few focused files:
  - `lua/plugins/lspconfig.lua` enables and configures LSP servers with `vim.lsp.config(...)` / `vim.lsp.enable(...)`
  - `lua/plugins/mason.lua` configures Mason registries, but it is not the source of truth for per-server settings
  - `lua/plugins/conform.lua` owns formatter selection and format-on-save behavior
  - `lua/plugins/nvim-treesitter.lua` installs parsers after `LazyDone` and starts Tree-sitter per filetype
  - `lua/plugins/neotest.lua`, `lua/plugins/dap-ui.lua`, and `lua/config/dap/functions.lua` provide test and debug workflows
- The C# and Python workflows are intentionally cross-file:
  - C#: `roslyn.lua`, `lspconfig.lua`, `conform.lua`, `neotest.lua`, `dap-ui.lua`, `after/ftplugin/cs.lua`
  - Python: `lspconfig.lua`, `conform.lua`, `neotest.lua`, `dap-ui.lua`

## Key conventions

- Keep the Lua-first split intact. Shared editor behavior belongs in `lua/config/*`, plugin wiring belongs in `lua/plugins/*`, and filetype-specific behavior belongs in `after/ftplugin/` or `after/ftdetect/`. Avoid hiding buffer-local tweaks inside unrelated plugin specs.
- Follow the existing plugin-spec pattern: one plugin per file under `lua/plugins/`, with each file returning a Lazy spec table. If plugin definitions change, keep `lazy-lock.json` in sync.
- If a setting only bootstraps one plugin before it loads, put it in that plugin spec's `init` block instead of unrelated startup code.
- Lua style follows `.stylua.toml`: 2-space indentation, 120-column width, Unix line endings, and single quotes when Stylua can preserve them.
- LSP setup is explicit in `lua/plugins/lspconfig.lua`; Mason does not define the active servers for you. When changing a language workflow, also check `conform.lua`, `neotest.lua`, and `dap-ui.lua` so formatting, testing, and debugging stay aligned.
- For repo tests, prefer the lightweight Plenary harness first; reserve `nvim --headless -u init.lua` smoke checks for cases where you need the whole config and plugin bootstrap path.
- There are intentional C# exceptions:
  - Roslyn formatting is disabled in `lua/plugins/lspconfig.lua`
  - Tree-sitter indentation is skipped for `c_sharp` in `lua/plugins/nvim-treesitter.lua`
  - `after/ftplugin/cs.lua` forces `cindent`
- Custom filetypes can use a multi-file Lua pattern. `sebol` is the example now: detection in `after/ftdetect/sebol.lua`, filetype-local defaults in `after/ftplugin/sebol.lua`, and custom syntax loaded from `lua/config/filetypes.lua`.
- New filetype-local defaults should land in `after/ftplugin/*.lua`; for example, custom commentstrings now live there for `kusto`, `sebol`, `autohotkey`, and `vader`.
- Copilot is split across multiple modules:
  - `copilot-lua.lua` enables the service but disables Copilot's own suggestion UI
  - `blink-cmp-copilot.lua` feeds Copilot into `blink.cmp`
  - `copilot-chat.lua` configures chat prompts and commit-message helpers separately
- Project-local overrides are expected. `lua/config/options.lua` enables both `exrc` and `secure`, so `.nvim.lua` files in other repositories can affect runtime behavior during debugging.
- Snippets are JSON-based and registered through `snippets/package.json`; completion pulls them in through `blink.cmp` plus `friendly-snippets`.
