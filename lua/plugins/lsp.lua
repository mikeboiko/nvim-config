return {
  { -- none-ls {{{1
    'nvimtools/none-ls.nvim',
    config = function()
      -- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md

      local null_ls = require('null-ls')
      null_ls.setup({
        notify_format_error = false,
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

    -- For Troubleshooting/Help, run:
    -- :LspLog
    -- :LspInfo

    -- To learn what capabilities are available you can run the following command in
    -- a buffer with a started LSP client: >vim
    -- :lua =vim.lsp.get_clients()[1].server_capabilities
    -- Note, I tried to get LSP file renaming to work with pyright, but pyright
    -- doesn't have the proper workspace capabilities.
    -- This is the plugin I tried
    -- https://github.com/antosha417/nvim-lsp-file-operations?tab=readme-ov-file

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
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
              return
            end
          end

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
                '${3rd}/luv/library',
                -- "${3rd}/busted/library",
              },
            },
          })
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
      local opts = {}
      vim.keymap.set(
        'n',
        '<Leader>se',
        '<cmd>lua vim.diagnostic.setqflist()<CR>',
        { silent = true, desc = 'Set diagnostics in quickfix list' }
      )
      vim.keymap.set('n', '<leader>fr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
      vim.keymap.set('n', '<leader>h', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
      vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
      vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
      vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
      vim.keymap.set('n', 'gR', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
      vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
      vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)

      -- Format on save
      vim.api.nvim_create_autocmd('BufWritePre', {
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
    end,
  }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
