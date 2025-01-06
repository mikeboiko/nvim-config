return {
  { -- nvim-dap-ui {{{1
    'rcarriga/nvim-dap-ui',
    dependencies = { 'mfussenegger/nvim-dap', 'mfussenegger/nvim-dap-python', 'nvim-neotest/nvim-nio' },
    config = function()
      require('dapui').setup()
    end,
  }, -- }}}
  { -- one-small-step-for-vimkind {{{1
    'jbyuki/one-small-step-for-vimkind',
    config = function()
      local dap = require('dap')

      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = 'Attach to running Neovim instance',
        },
      }

      dap.adapters.nlua = function(callback, config)
        callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 })
      end

      -- TODO-MB [250106] - Restore after deprecating vimspector
      -- vim.keymap.set(
      --   'n',
      --   '<leader>db',
      --   require('dap').toggle_breakpoint,
      --   { noremap = true, desc = 'dap: toggle_breakpoint' }
      -- )
      -- vim.keymap.set('n', '<leader>dc', require('dap').continue, { noremap = true, desc = 'dap: continue' })
      -- vim.keymap.set('n', '<leader>do', require('dap').step_over, { noremap = true, desc = 'dap: step_over' })
      -- vim.keymap.set('n', '<leader>di', require('dap').step_into, { noremap = true, desc = 'dap: step_into' })
      -- vim.keymap.set('n', '<leader>dl', function()
      --   require('osv').launch({ port = 8086 })
      -- end, { noremap = true, desc = 'dap: launch neovim lua server' })
    end,
  }, -- }}}
  { -- {{{1
    'puremourning/vimspector',
    build = function()
      local install_cmd = './install_gadget.py'
      vim.fn.system(install_cmd .. ' --enable-python')
      vim.fn.system(install_cmd .. ' --enable-go --update-gadget-config')
      vim.fn.system(install_cmd .. ' --force-enable-csharp --update-gadget-config')
      vim.fn.system(install_cmd .. ' --force-enable-node --update-gadget-config')
    end,
  }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
