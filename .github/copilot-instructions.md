# Copilot instructions for `nvim-config`

## Build, test, and lint commands

- Lua formatting uses Stylua with the repo's `.stylua.toml`:
  - `stylua .`
  - `stylua --check .`
- After changing plugin specs in `lua/plugins/*.lua` or the plugin lockfile:
  - `nvim --headless "+Lazy! sync" +qa`
- After changing Tree-sitter parser configuration in `lua/plugins/nvim-treesitter.lua`:
  - `nvim --headless "+TSUpdateSync" +qa`
- Format the current buffer from inside Neovim:
  - `<leader>fi`
  - `:ConformInfo`
- Tests are run from inside Neovim through `neotest` (`lua/plugins/neotest.lua`):
  - nearest test: `:lua require('neotest').run.run()`
  - current file: `:lua require('neotest').run.run(vim.fn.expand('%'))`
  - debug nearest test: `:lua require('neotest').run.run({ strategy = 'dap' })`
  - open/close the summary pane: `<leader>ts`
- C# Roslyn setup is handled through Mason:
  - `:MasonInstall roslyn`

## High-level architecture

- `init.lua` is the entrypoint. It optionally launches `osv` for debugging when `init_debug` is set, then sources `vimscript/init.vim`, then loads shared Lua modules from `lua/config/*`, and finally bootstraps `lazy.nvim` through `lua/config/lazy.lua`.
- `vimscript/init.vim` is still active, not historical. It holds a large amount of real behavior: custom functions, user commands, mappings, terminal helpers, search helpers, filetype comment settings, and older autocmds. Search it before assuming a behavior is not configured yet.
- `lua/config/lazy.lua` imports the `plugins` namespace, so each file under `lua/plugins/` is a Lazy spec module. `lazy-lock.json` pins the resolved plugin versions.
- Shared editor behavior is split across `lua/config/` modules such as `constants.lua`, `options.lua`, `autocmds.lua`, `functions.lua`, `comments.lua`, and `keymaps.lua`.
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
- Lua style follows `.stylua.toml`: 2-space indentation, 120-column width, Unix line endings, and single quotes when Stylua can preserve them.
- LSP setup is explicit in `lua/plugins/lspconfig.lua`; Mason does not define the active servers for you. When changing a language workflow, also check `conform.lua`, `neotest.lua`, and `dap-ui.lua` so formatting, testing, and debugging stay aligned.
- There are intentional C# exceptions:
  - Roslyn formatting is disabled in `lua/plugins/lspconfig.lua`
  - Tree-sitter indentation is skipped for `c_sharp` in `lua/plugins/nvim-treesitter.lua`
  - `after/ftplugin/cs.lua` forces `cindent`
- Custom filetypes use a multi-file pattern. `sebol` is the example: detection in `after/ftdetect/sebol.lua`, syntax in `syntax/sebol.vim`, and comment/filetype glue still present in `vimscript/init.vim`.
- Copilot is split across multiple modules:
  - `copilot-lua.lua` enables the service but disables Copilot's own suggestion UI
  - `blink-cmp-copilot.lua` feeds Copilot into `blink.cmp`
  - `copilot-chat.lua` configures chat prompts and commit-message helpers separately
- Project-local overrides are expected. `lua/config/options.lua` enables both `exrc` and `secure`, so `.nvim.lua` files in other repositories can affect runtime behavior during debugging.
- Snippets are JSON-based and registered through `snippets/package.json`; completion pulls them in through `blink.cmp` plus `friendly-snippets`.
