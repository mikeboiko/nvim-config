vim.keymap.set(
  'n',
  '<leader>.',
  ':FzfLua treesitter<CR>',
  { silent = true, desc = 'FzfLua buffer tags', buffer = true }
)
