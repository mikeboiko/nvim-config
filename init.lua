require('config.lazy')

-- one-small-step-for-vimkind nvim-dap debugging
if init_debug then
  require('osv').launch({ port = 8086, blocking = true })
end

-- TODO-MB [250104] - convert all of these to lua
vim.cmd('source ~/.config/nvim/vimscript/functions.vim')

-- require('config.functions')
-- require('config.commands')

require('config.constants')
require('config.keymaps')
require('config.options')
require('config.autocmds')
