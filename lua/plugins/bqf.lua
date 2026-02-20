return {
  -- nvim-bqf: preview window and handy actions
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
}
