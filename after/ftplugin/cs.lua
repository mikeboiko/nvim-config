vim.keymap.set(
  'n',
  'gd',
  '<cmd>lua require("omnisharp_extended").lsp_definition()<cr>',
  { desc = 'Jump to definition of symbol under cursor' }
)
vim.keymap.set(
  'n',
  '<leader>fr',
  '<cmd>lua require("omnisharp_extended").lsp_references()<cr>',
  { desc = 'Find all references of symbol under cursor' }
)
