-- For nvim-dap debugging
if init_debug then
  require('osv').launch({ port = 8086, blocking = true })
end

vim.g.mapleader = ' '
vim.cmd('filetype plugin indent on')

require('config.autocmds')
require('config.commands')
require('config.constants')
require('config.comments')
require('config.functions')
require('config.keymaps')
require('config.options')

require('config.lazy')
