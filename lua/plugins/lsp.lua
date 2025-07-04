return {
  { -- none-ls {{{1
    'nvimtools/none-ls.nvim',
    config = function()
      -- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md

      local null_ls = require('null-ls')
      null_ls.setup({
        sources = {
          null_ls.builtins.completion.tags,
          null_ls.builtins.diagnostics.trail_space,
          null_ls.builtins.diagnostics.sqlfluff.with({
            extra_args = { '--dialect', 'tsql', '--exclude-rules', 'CP02' },
          }),
          -- null_ls.builtins.diagnostics.vint,
          null_ls.builtins.formatting.isort,
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.sqlfluff.with({
            extra_args = { '--dialect', 'tsql', '--exclude-rules', 'CP02' },
          }),
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.shfmt.with({
            extra_args = { '--apply-ignore' },
          }),
        },
      })
    end,
  }, -- }}}
  { -- nvim-lsp-file-operations {{{1
    'antosha417/nvim-lsp-file-operations',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-tree.lua',
    },
    config = function()
      require('lsp-file-operations').setup()
    end,
  }, -- }}}
  { -- nvim-lspconfig {{{1
    -- Setup language servers.
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

    -- For Troubleshooting/Help, run:
    -- :LspLog
    -- :LspInfo

    -- To see what capabilities are available, you can run the following command in
    -- a buffer with a connected LSP client:
    -- :lua for i, c in ipairs(vim.lsp.get_clients()) do print(i, c._log_prefix) end
    -- :lua =vim.lsp.get_clients()[1].server_capabilities

    'neovim/nvim-lspconfig',
    cmd = 'LspInfo',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'b0o/schemastore.nvim' },
    },
    init = function()
      -- Reserve a space in the gutter
      -- This will avoid an annoying layout shift in the screen
      vim.opt.signcolumn = 'yes'
    end,
    config = function()
      local lspconfig = require('lspconfig')

      lspconfig.bashls.setup({})

      -- Used for formatting and linting
      -- https://docs.astral.sh/ruff/editors/setup/#neovim
      lspconfig.ruff.setup({
        init_options = {
          settings = {
            lint = {
              ignore = { 'F821', 'F841' },
            },
          },
        },
      })

      -- Note: install basedpyright in each virtual-env
      lspconfig.basedpyright.setup({
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = 'basic',
            },
            settings = {},
          },
        },
      })

      -- npm install -g @vue/language-server
      lspconfig.volar.setup({
        filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
        init_options = {
          typescript = {
            tsdk = '/home/mike/npm-global/lib/node_modules/typescript/lib',
          },
          vue = {
            hybridMode = false,
          },
        },
      })

      lspconfig.jsonls.setup {
        init_options = {
          provideFormatter = false,
        },
        settings = {
          json = {
            schemas = require('schemastore').json.schemas {},
            validate = { enable = true },
          },
        },
      }

      -- lspconfig.yamlls.setup {
      --   -- TODO: Fix ERROR method workspace/symbol is not supported by any of the servers registered for the current buffer
      --   -- capabilities = {
      --   --   workspace = {
      --   --     symbol = false,
      --   --   },
      --   -- },
      --   settings = {
      --     yaml = {
      --       schemas = require('schemastore').yaml.schemas {},
      --       validate = true,
      --     },
      --   },
      -- }

      lspconfig.lua_ls.setup({
        on_init = function(client)
          -- if client.workspace_folders then
          --   local path = client.workspace_folders[1].name
          --   if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
          --     return
          --   end
          -- end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              -- Tell the language server which version of Lua you're using
              -- (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                -- '${3rd}/luv/library',
                -- "${3rd}/busted/library",
              },
            },
          })
        end,
        on_attach = function(client, _)
          -- Disable LSP syntax highlighting
          client.server_capabilities.semanticTokensProvider = nil
        end,

        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            format = {
              defaultConfig = {
                -- max_line_length = 120,
                indent_style = 'space',
                indent_size = 2,
                -- quote_style = "single"
              },
            },
            diagnostics = {
              globals = { 'init_debug', 'vim' },
            },
          },
        },
      })

      -- First, install `omnisharp-roslyn` from AUR
      local pid = vim.fn.getpid()
      lspconfig.omnisharp.setup({
        cmd = { '/usr/bin/omnisharp', '--languageserver', '--hostPID', tostring(pid) },
      })

      -- Key mappings
      vim.keymap.set(
        'n',
        '<Leader>se',
        '<cmd>lua vim.diagnostic.setqflist()<CR>',
        { silent = true, desc = 'Set diagnostics in quickfix list' }
      )
      vim.keymap.set(
        'n',
        '<leader>fr',
        '<cmd>lua vim.lsp.buf.references()<cr>',
        { desc = 'Find all references of symbol under cursor' }
      )
      vim.keymap.set(
        'n',
        '<leader>h',
        '<cmd>lua vim.lsp.buf.hover()<cr>',
        { desc = 'Show hover documentation for symbol under cursor' }
      )
      vim.keymap.set(
        'n',
        '[d',
        '<cmd>lua vim.diagnostic.jump({count=-1, float=false})<cr>',
        { desc = 'Jump to previous diagnostic' }
      )
      vim.keymap.set(
        'n',
        ']d',
        '<cmd>lua vim.diagnostic.jump({count=1, float=true})<cr>',
        { desc = 'Jump to next diagnostic' }
      )
      vim.keymap.set(
        'n',
        'gD',
        '<cmd>lua vim.lsp.buf.declaration()<cr>',
        { desc = 'Jump to declaration of symbol under cursor' }
      )
      vim.keymap.set(
        'n',
        'gR',
        '<cmd>lua vim.lsp.buf.rename()<cr>',
        { desc = 'Rename symbol under cursor across workspace' }
      )
      vim.keymap.set('n', 'ga', ':FzfLua lsp_code_actions<cr>', { desc = 'LSP Code Actions' })
      vim.keymap.set(
        'n',
        'gd',
        '<cmd>lua vim.lsp.buf.definition()<cr>',
        { desc = 'Jump to definition of symbol under cursor' }
      )
      vim.keymap.set(
        'n',
        'gi',
        '<cmd>lua vim.lsp.buf.implementation()<cr>',
        { desc = 'Find implementations of interface/class under cursor' }
      )

      -- Format on save
      vim.api.nvim_create_autocmd('BufWritePre', {
        -- Only format these filetypes
        pattern = {
          '*.js',
          '*.json',
          '*.jsonc',
          '*.lua',
          '*.md',
          '*.py',
          '*.sh',
          '*.sql',
          '*.vue',
          '*.yaml',
          '*.yml',
        },
        callback = function()
          vim.lsp.buf.format {
            async = false,
            -- Ignore these LSP formatters, they are handled by null-ls
            filter = function(client)
              local exclude_formatters = { 'lua_ls', 'volar' }
              return not vim.tbl_contains(exclude_formatters, client.name)
            end,
          }
        end,
      })

      -- Don't format commands.sh with bashls
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'sh',
        callback = function()
          if vim.fn.expand('%:t') == 'commands.sh' then
            vim.cmd('LspStop bashls')
          end
        end,
      })
    end,
  }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
