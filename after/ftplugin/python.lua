-- Parallelization must be disabled for debugpy dap adapter to work properly
vim.env.PYTEST_ADDOPTS = '-n 0'

vim.keymap.set('n', '<leader>.', ':FzfLua treesitter<CR>', { silent = true, desc = 'FzfLua treesitter', buffer = true })

vim.keymap.set('n', '<leader>df', function()
  vim.cmd('wa')
  vim.cmd('call CloseAll()')
  vim.cmd('FlowDebug')
end, { buffer = true, silent = true })
