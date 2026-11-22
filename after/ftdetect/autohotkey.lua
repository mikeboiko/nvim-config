vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*.ahk', '*.ah2', '*.ahk2' },
  callback = function()
    vim.opt.filetype = 'autohotkey'
  end,
})
