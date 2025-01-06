-- Set filetype for .sebol files
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.sebol',
  callback = function()
    vim.opt.filetype = 'sebol'
  end,
})

-- Set tab settings for sebol filetype
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'sebol',
  callback = function()
    vim.opt_local.tabstop = 6
    vim.opt_local.softtabstop = 6
  end,
})
