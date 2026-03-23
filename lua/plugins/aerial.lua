return {
  -- aerial.nvim
  'stevearc/aerial.nvim',
  opts = {},
  -- Optional dependencies
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { '<leader>tb', '<cmd>AerialToggle<CR>', desc = 'Toggle Aerial' },
  },
  config = function()
    require('aerial').setup({
      on_attach = function(bufnr)
        vim.keymap.set('n', '[f', '<cmd>AerialPrev<CR>', { buffer = bufnr, desc = 'Aerial prev' })
        vim.keymap.set('n', ']f', '<cmd>AerialNext<CR>', { buffer = bufnr, desc = 'Aerial next' })
      end,
      layout = {
        default_direction = 'right',
      },
      close_automatic_events = { 'switch_buffer' },
      close_on_select = true,
    })
  end,
}
