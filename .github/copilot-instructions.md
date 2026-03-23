# Copilot instructions for `nvim-config`

## Build, test, and lint commands

- Hook automation currently checks the full Lua tree with Stylua:
  - `stylua init.lua lua after tests`
  - `stylua --check init.lua lua after tests`
- The pre-commit hook is the active automation entrypoint during the migration. It formats staged Lua files first, then runs Stylua checks, Lua syntax checks, the Plenary suite, and a headless startup smoke test.
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

- `init.lua` is the entrypoint. It optionally launches `osv` for debugging when `init_debug` is set, then sources `vimscript/init.vim`, then loads shared Lua modules from `lua/config/*`, and finally bootstraps `lazy.nvim` through `lua/config/lazy.lua`.
- `vimscript/init.vim` is still active, not historical. It holds a large amount of real behavior: custom functions, user commands, mappings, terminal helpers, search helpers, filetype comment settings, and older autocmds. Search it before assuming a behavior is not configured yet.
- `lua/config/lazy.lua` imports the `plugins` namespace, so each file under `lua/plugins/` is a Lazy spec module. `lazy-lock.json` pins the resolved plugin versions.
- The repo currently relies on local hook-based validation rather than GitHub Actions, and it targets Neovim stable (`0.11.x` today).
- Shared editor behavior is split across `lua/config/` modules such as `constants.lua`, `options.lua`, `autocmds.lua`, `functions.lua`, `comments.lua`, and `keymaps.lua`.
- Reusable migrated legacy helpers are increasingly landing in focused modules under `lua/config/`, with `windows.lua`, `quickfix.lua`, `folds.lua`, `comments.lua`, `terminal.lua`, `clipboard.lua`, `tabline.lua`, `editor.lua`, `shell.lua`, `buffers.lua`, and `workspace.lua` as current examples.
- Search- and workflow-oriented user mappings are being migrated into `lua/config/keymaps.lua` on top of helper modules such as `shell.lua`, rather than staying as standalone Vimscript remaps.
- Core editing maps are also moving into `lua/config/keymaps.lua`, with stateful behavior such as fileformat reloads and blank-line insertion routed through tested helpers in `lua/config/editor.lua`.
- Terminal navigation maps are no longer wired through a `v:lua` global shim; `lua/config/autocmds.lua` now calls `require('config.keymaps').set_terminal_keymaps(...)` directly on `TermOpen`.
- Copilot workflow mappings now live in `lua/config/keymaps.lua` too, and the module includes a tested helper for safely invoking plugin-provided globals like `CopilotQuickChat` / `CopilotCommitMsg`.
- External launcher/report maps now use tested helpers in `lua/config/shell.lua` for things like git diff terminals, markdown preview, Explorer launchers, and report tabs.
- Fugitive/Git prompt maps and the prompt-based rename workflow now live in `lua/config/keymaps.lua` as well; `keymaps.prompt_rename()` uses the same tested global-callback bridge used for other prompt-driven workflows.
- Small utility maps such as append-at-EOL helpers, path-copy shortcuts, close helpers, rerun-command/command-history entry, and paragraph commenting now live in Lua too, and the old `<leader>redo` compatibility mapping has been removed.
- Tab/window navigation helpers such as `gI`, `gT`, `gt`, `gs`, `gv`, `<C-t>`, `<C-Tab>`, and `<Tab>` now live in `lua/config/keymaps.lua` too; the smoke spec covers their registered RHS values because they intentionally preserve odd legacy key-sequence behavior for parity.
- Search/sort/reload and compatibility maps such as `<leader>/`, `<leader>so`, `<leader>sv`, `<C-z>`, and `<C-y>` now live in `lua/config/keymaps.lua` too; the smoke spec asserts their normalized RHS values so literal command-line/search behavior stays stable during migration.
- Plugin-local startup globals are being moved into plugin spec `init` blocks instead of staying in `vimscript/init.vim`; `nvim-tree`, markdown preview, and img-paste already follow this pattern.
- The repo now has a lightweight test harness under `tests/`; `tests/minimal_init.lua` prepends the repo and Plenary to `runtimepath`, and specs under `tests/nvim-config/` intentionally cover Lua modules and repo-owned behavior without depending on a full interactive session.
- Filetype behavior is layered:
  - late Lua overrides in `after/ftplugin/`
  - older Vimscript overrides in `ftplugin/`
  - custom filetype detection in `after/ftdetect/`
  - custom syntax definitions in `syntax/`
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

- Keep the hybrid split intact. Shared editor behavior belongs in `lua/config/*`, plugin wiring belongs in `lua/plugins/*`, and filetype-specific behavior belongs in `after/ftplugin/` or `ftplugin/`. Avoid hiding buffer-local tweaks inside unrelated plugin specs.
- Follow the existing plugin-spec pattern: one plugin per file under `lua/plugins/`, with each file returning a Lazy spec table. If plugin definitions change, keep `lazy-lock.json` in sync.
- If a setting only bootstraps one plugin before it loads, put it in that plugin spec's `init` block instead of the legacy Vimscript entrypoint.
- Lua style follows `.stylua.toml`: 2-space indentation, 120-column width, Unix line endings, and single quotes when Stylua can preserve them.
- LSP setup is explicit in `lua/plugins/lspconfig.lua`; Mason does not define the active servers for you. When changing a language workflow, also check `conform.lua`, `neotest.lua`, and `dap-ui.lua` so formatting, testing, and debugging stay aligned.
- For repo tests, prefer the lightweight Plenary harness first; reserve `nvim --headless -u init.lua` smoke checks for cases where you need the whole config and plugin bootstrap path.
- There are intentional C# exceptions:
  - Roslyn formatting is disabled in `lua/plugins/lspconfig.lua`
  - Tree-sitter indentation is skipped for `c_sharp` in `lua/plugins/nvim-treesitter.lua`
  - `after/ftplugin/cs.lua` forces `cindent`
- Custom filetypes use a multi-file pattern. `sebol` is the example: detection in `after/ftdetect/sebol.lua`, syntax in `syntax/sebol.vim`, and comment/filetype glue still present in `vimscript/init.vim`.
- New filetype-local defaults should land in `after/ftplugin/*.lua`; for example, custom commentstrings now live there for `kusto`, `sebol`, `autohotkey`, and `vader`.
- Copilot is split across multiple modules:
  - `copilot-lua.lua` enables the service but disables Copilot's own suggestion UI
  - `blink-cmp-copilot.lua` feeds Copilot into `blink.cmp`
  - `copilot-chat.lua` configures chat prompts and commit-message helpers separately
- Project-local overrides are expected. `lua/config/options.lua` enables both `exrc` and `secure`, so `.nvim.lua` files in other repositories can affect runtime behavior during debugging.
- Snippets are JSON-based and registered through `snippets/package.json`; completion pulls them in through `blink.cmp` plus `friendly-snippets`.
