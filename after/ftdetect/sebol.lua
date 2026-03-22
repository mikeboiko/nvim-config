-- Set filetype for .sebol files
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.sebol',
  callback = function()
    vim.opt.filetype = 'sebol'
  end,
})
