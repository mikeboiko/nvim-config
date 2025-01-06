-- For nvim-dap debugging
if init_debug then
  require('osv').launch({ port = 8086, blocking = true })
end

-- TODO-MB [250104] - Convert to lua
vim.cmd('source ~/.config/nvim/vimscript/init.vim')

require('config.autocmds')
require('config.commands')
require('config.constants')
require('config.functions')
require('config.keymaps')
require('config.options')

require('config.lazy')
