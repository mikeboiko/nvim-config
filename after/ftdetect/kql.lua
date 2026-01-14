vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.kql',
  callback = function()
    vim.opt.filetype = 'kusto'
  end,
})
