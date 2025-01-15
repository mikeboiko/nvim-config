-- vimsepctor JSON commenting
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile' }, {
  pattern = '*.vimspector.json',
  callback = function()
    vim.bo.filetype = 'jsonc'
    vim.bo.commentstring = '// %s'
    vim.cmd([[
      syntax match jsonComment "\/\/.*"
      highlight link jsonComment Comment
    ]])
  end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '.vimspector.json',
  command = 'set filetype=jsonc',
})
