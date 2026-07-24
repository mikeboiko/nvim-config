local filetypes = require('config.filetypes')

vim.cmd([[syntax match markdownError "\w\@<=\w\@="]])
vim.opt_local.spell = true
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = 'nc'

vim.keymap.set('n', 'ys`', function()
  filetypes.surround_markdown_paragraph_with_backticks()
end, { buffer = true, silent = true, desc = 'Surround current paragraph with fenced code markers' })
