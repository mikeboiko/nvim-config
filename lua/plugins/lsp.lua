return {
  { -- lsp-zero {{{1
    -- For Troubleshooting/Help, run:
    -- :LspLog
    -- :LspInfo
    -- :help lsp-zero-keybindings

    -- To learn what capabilities are available you can run the following command in
    -- a buffer with a started LSP client: >vim
    -- :lua =vim.lsp.get_clients()[1].server_capabilities
    -- Note, I tried to get LSP file renaming to work with pyright, but pyright
    -- doesn't have the proper workspace capabilities.
    -- This is the plugin I tried
    -- https://github.com/antosha417/nvim-lsp-file-operations?tab=readme-ov-file

    'VonHeikemen/lsp-zero.nvim',
    config = function()
      local lsp_zero = require('lsp-zero')
      lsp_zero.on_attach(function(_, bufnr)
        lsp_zero.default_keymaps({ buffer = bufnr })
        local opts = {}
        vim.keymap.set('n', '<leader>h', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', '<leader>fr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gR', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
        vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
        -- vim.keymap.set({ "n", "x" }, "<leader>fi", function()
        -- vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
        -- end, opts)
      end)

      lsp_zero.set_sign_icons({
        error = '✘',
        warn = '▲',
        hint = '⚑',
        info = '»',
      })

      -- `format_on_save` should run only once, before the language servers are active.
      lsp_zero.format_on_save({
        format_opts = {
          async = false,
          timeout_ms = 10000,
        },
        servers = {
          ['null-ls'] = {
            'python',
            'markdown',
            'lua',
            'vim',
            'vue',
            'yaml',
            'json',
            'sql',
            'javascript',
            'css',
            'scss',
          },
        },
      })
    end,
  }, -- }}}
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
          null_ls.builtins.formatting.yapf,
        },
      })
    end,
  }, -- }}}
  { -- nvim-lspconfig {{{1
    -- Setup language servers.
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

    'neovim/nvim-lspconfig',
    cmd = 'LspInfo',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
    },
    init = function()
      -- Reserve a space in the gutter
      -- This will avoid an annoying layout shift in the screen
      vim.opt.signcolumn = 'yes'
    end,
    config = function()
      local lspconfig = require('lspconfig')

      lspconfig.bashls.setup({})

      lspconfig.pyright.setup({
        init_options = {
          settings = {
            args = {},
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
                -- Depending on the usage, you might want to add additional paths here.
                -- "${3rd}/luv/library"
                -- "${3rd}/busted/library",
              },
              -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
              -- library = vim.api.nvim_get_runtime_file("", true)
            },
          })
        end,
        settings = {
          Lua = {
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
    end,
  }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
