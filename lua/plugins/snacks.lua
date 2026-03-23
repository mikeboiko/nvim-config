return {
  -- snacks
  'folke/snacks.nvim',
  lazy = false,
  keys = {
    {
      '<leader>nh',
      function()
        Snacks.notifier.show_history()
      end,
      desc = 'Show Notification History',
    },
  },
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
