-- vim.keymap.set('t', '<C-k>', '<C-W>k')
-- vim.keymap.set('t', '<C-h>', '<C-W>h')
-- vim.keymap.set('t', '<C-l>', '<C-W>l')

function _G.set_terminal_keymaps()
  local opts = { noremap = true }
  vim.keymap.set('t', '<C-j>', '<C-W>j')
  -- vim.api.nvim_buf_set_keymap(0, 't', '<Esc>', [[<C-\><C-n>]], opts)
  -- vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-w>h]], opts)
  -- vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-w>j]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-w>k]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-w>l]], opts)
end
