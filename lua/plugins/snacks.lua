return {
  -- snacks
  'folke/snacks.nvim',
  opts = {
    bigfile = {},
    indent = {},
    notifier = {},
    image = { convert = { notify = false } },
    input = {
      -- Fancy vim.ui.input
      win = {
        relative = 'cursor',
        row = -3,
        col = 0,
      },
    },
  },
}
