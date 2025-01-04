-- Append backup files with timestamp
vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function()
    local extension = '~' .. vim.fn.strftime('%Y-%m-%d-%H%M%S')
    vim.o.backupext = extension
  end,
})
