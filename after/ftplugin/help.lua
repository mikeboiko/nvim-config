vim.keymap.set('n', '<leader>h', function()
  return ':help ' .. vim.fn.expand('<cword>') .. '\r'
end, { expr = true, buffer = true, desc = 'Open help for word under cursor' })
