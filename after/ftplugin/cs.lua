vim.keymap.set(
  'n',
  'gd',
  '<cmd>lua require("omnisharp_extended").lsp_definition()<cr>',
  { desc = 'Jump to definition of symbol under cursor' }
)
vim.keymap.set(
  'n',
  '<leader>gD',
  '<cmd>lua require("omnisharp_extended").lsp_type_definition()<cr>',
  { desc = 'Find all references of symbol under cursor' }
)
vim.keymap.set(
  'n',
  '<leader>fr',
  '<cmd>lua require("omnisharp_extended").lsp_references()<cr>',
  { desc = 'Find all references of symbol under cursor' }
)

require('dapui').setup({
  layouts = {
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        { id = 'breakpoints', size = 0.25 },
        'watches',
        'scopes',
        'stacks',
      },
      size = 40, -- 40 columns
      position = 'left',
    },
    {
      elements = {
        'repl',
      },
      size = 0.25, -- 25% of total lines
      position = 'bottom',
    },
  },
})
