-- For nvim-dap debugging
if init_debug then
  require('osv').launch({ port = 8086, blocking = true })
end

local source = debug.getinfo(1, 'S').source:sub(2)
local config_root = vim.fn.fnamemodify(source, ':p:h')
local legacy_init = config_root .. '/vimscript/init.vim'

-- TODO-MB [250104] - Convert to lua
vim.cmd('source ' .. vim.fn.fnameescape(legacy_init))

require('config.autocmds')
require('config.commands')
require('config.constants')
require('config.comments')
require('config.functions')
require('config.keymaps')
require('config.options')

require('config.lazy')
