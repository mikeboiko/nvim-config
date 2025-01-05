require('config.lazy')

-- TODO-MB [250104] - convert all of these to lua
vim.cmd('source ~/.config/nvim/vimscript/functions.vim')

-- require('config.functions')
-- require('config.commands')

require('config.constants')
require('config.keymaps')
require('config.options')
require('config.autocmds')
