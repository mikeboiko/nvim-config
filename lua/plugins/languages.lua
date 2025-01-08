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
}
-- vim: foldmethod=marker:foldlevel=1
