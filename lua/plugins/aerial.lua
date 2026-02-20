return {
  -- aerial.nvim
  'stevearc/aerial.nvim',
  opts = {},
  -- Optional dependencies
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('aerial').setup({
      -- optionally use on_attach to set keymaps when aerial has attached to a buffer
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set('n', '[f', '<cmd>AerialPrev<CR>', { buffer = bufnr })
        vim.keymap.set('n', ']f', '<cmd>AerialNext<CR>', { buffer = bufnr })
      end,
      layout = {
        default_direction = 'right',
      },
      close_automatic_events = { 'switch_buffer' },
      close_on_select = true,
    })
  end,
  vim.keymap.set('n', '<leader>tb', '<cmd>AerialToggle<CR>'),
}
