return {
  -- nvim-lspconfig
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
    -- I couldn't figure out how to disable roslyn formatting in a cleaner way
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client.name == 'roslyn' then
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end
      end,
    })

    vim.lsp.config('bashls', { filetypes = { 'bash', 'sh' } })
    vim.lsp.enable('bashls')

    -- Used for formatting and linting
    -- https://docs.astral.sh/ruff/editors/setup/#neovim
    vim.lsp.config('ruff', {
      init_options = {
        settings = {
          lint = {
            ignore = { 'F821', 'F841' },
          },
        },
      },
    })
    vim.lsp.enable('ruff')

    -- Note: install basedpyright in each virtual-env
    vim.lsp.config('basedpyright', {
      settings = {
        autoImportCompletions = true,
        disableOrganizeImports = true, -- use ruff instead
        basedpyright = {
          analysis = {
            typeCheckingMode = 'basic',
          },
          settings = {},
        },
      },
    })
    vim.lsp.enable('basedpyright')

    -- TODO: volar is deprecated, use vue_ls instead.
    -- -- npm install -g @vue/language-server
    -- vim.lsp.config('volar', {
    --   filetypes = { 'vue' },
    --   init_options = {
    --     typescript = {
    --       tsdk = '/home/mike/npm-global/lib/node_modules/typescript/lib',
    --     },
    --     vue = {
    --       hybridMode = false,
    --     },
    --   },
    -- })
    -- vim.lsp.enable('volar')

    -- TypeScript/JavaScript language server for React
    vim.lsp.config('ts_ls', {
      filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact' },
      -- init_options = {
      --   preferences = {
      --     disableSuggestions = true,
      --   },
      -- },
    })
    vim.lsp.enable('ts_ls')

    vim.lsp.config('jsonls', {
      init_options = {
        provideFormatter = false,
      },
      settings = {
        json = {
          schemas = require('schemastore').json.schemas {},
          validate = { enable = true },
        },
      },
    })
    vim.lsp.enable('jsonls')

    -- toml
    vim.lsp.enable('taplo')

    -- rust
    vim.lsp.enable('rust_analyzer')

    vim.lsp.config('yamlls', {
      -- TODO: Fix ERROR method workspace/symbol is not supported by any of the servers registered for the current buffer
      -- capabilities = {
      --   workspace = {
      --     symbol = false,
      --   },
      -- },
      settings = {
        yaml = {
          schemaStore = {
            -- You must disable built-in schemaStore support if you want to use
            -- this plugin and its advanced options like `ignore`.
            enable = false,
            -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
            url = '',
          },
          schemas = require('schemastore').yaml.schemas {},
          validate = true,
        },
      },
    })
    vim.lsp.enable('yamlls')

    -- lua
    vim.lsp.config('lua_ls', {
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
            disable = { 'missing-fields', 'undefined-global' },
            globals = { 'init_debug', 'vim' },
          },
        },
      },
    })
    vim.lsp.enable('lua_ls')

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
      'gD',
      '<cmd>lua vim.lsp.buf.type_definition()<cr>',
      { desc = 'Jump to type definition of symbol under cursor' }
    )
    vim.keymap.set(
      'n',
      'gi',
      '<cmd>lua vim.lsp.buf.implementation()<cr>',
      { desc = 'Find implementations of interface/class under cursor' }
    )

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
}
