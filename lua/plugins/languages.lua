return {
  { -- csvview {{{1
    'hat0uma/csvview.nvim',
    ft = { 'csv' },
    config = function()
      require('csvview').setup()
    end,
  }, -- }}}
  { -- vim-log-highlighting syntax {{{1
    'mtdl9/vim-log-highlighting',
  }, -- }}}
  { -- vim-ps1: powershell syntax {{{1
    'PProvost/vim-ps1',
  }, -- }}}
  { -- which-key.nvim {{{1
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show({ global = false })
        end,
        desc = 'Buffer Local Keymaps (which-key)',
      },
    },
  }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
