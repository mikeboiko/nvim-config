return {
  { -- quicker.nvim {{{1
    'stevearc/quicker.nvim',
    event = 'FileType qf',
    opts = {},
  }, -- }}}
  { -- nvim-bqf {{{1
    'kevinhwang91/nvim-bqf',
    config = function()
      require('bqf').setup({
        auto_enable = true,
        auto_resize_height = true,
        func_map = {
          split = '<C-s>',
          tabdrop = '<C-t>',
        },
      })
    end,
  }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
