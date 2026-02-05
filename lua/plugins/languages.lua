return {
  { -- csvview
    'hat0uma/csvview.nvim',
    ft = { 'csv' },
    config = function()
      require('csvview').setup()
    end,
  },
  { -- log-highlight.nvim
    'fei6409/log-highlight.nvim',
    opts = {},
  },
  { -- vim-ps1: powershell syntax
    'PProvost/vim-ps1',
  },
  { -- which-key.nvim
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
  },
}
