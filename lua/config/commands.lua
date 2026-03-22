local comments = require('config.comments')
local clipboard = require('config.clipboard')
local editor = require('config.editor')
local folds = require('config.folds')
local shell = require('config.shell')
local windows = require('config.windows')
local quickfix = require('config.quickfix')

clipboard.register_legacy_functions()
comments.register_legacy_functions()
editor.register_legacy_functions()
shell.register_legacy_functions()
windows.register_legacy_functions()
quickfix.register_legacy_functions()

vim.api.nvim_create_user_command('CloseAll', function()
  windows.close_all()
end, {})

vim.api.nvim_create_user_command('FoldOpen', function()
  folds.open_current_fold()
end, {})

vim.api.nvim_create_user_command('FindLocal', function(opts)
  folds.find_local(opts.args)
  vim.o.hlsearch = true
end, {
  nargs = '+',
  complete = 'command',
})

local function echo(message)
  vim.api.nvim_echo({ { message } }, false, {})
end

vim.api.nvim_create_user_command('CloseToggle', function()
  if vim.g.term_close == '' then
    vim.g.term_close = '++close'
    echo('Term will close')
  else
    vim.g.term_close = ''
    echo('Term will not close')
  end
end, {})

vim.api.nvim_create_user_command('Cnext', function()
  quickfix.cycle('c', 'next')
end, {})

vim.api.nvim_create_user_command('Cprev', function()
  quickfix.cycle('c', 'prev')
end, {})

vim.api.nvim_create_user_command('Lnext', function()
  quickfix.cycle('l', 'next')
end, {})

vim.api.nvim_create_user_command('Lprev', function()
  quickfix.cycle('l', 'prev')
end, {})

vim.api.nvim_create_user_command('Bufdo', function(opts)
  editor.bufdo(opts.args)
end, {
  nargs = '+',
  complete = 'command',
})

vim.api.nvim_create_user_command('Windo', function(opts)
  editor.windo(opts.args)
end, {
  nargs = '+',
  complete = 'command',
})

vim.api.nvim_create_user_command('Windofast', function(opts)
  editor.windo(opts.args, { noautocmd = true })
end, {
  nargs = '+',
  complete = 'command',
})

vim.api.nvim_create_user_command('SpellToggle', function()
  editor.toggle_spell()
end, {})

vim.api.nvim_create_user_command('Figlet', function(opts)
  shell.figlet(opts.args)
end, {
  nargs = '+',
  complete = 'command',
})

vim.api.nvim_create_user_command('Grep', function(opts)
  shell.grep(opts.args)
end, {
  nargs = '+',
})

vim.api.nvim_create_user_command('ReplaceMwithBlank', function()
  shell.replace_m_with_blank()
end, {})

vim.api.nvim_create_user_command('ReplaceMwithNewLine', function()
  shell.replace_m_with_newline()
end, {})

vim.api.nvim_create_user_command('Mani', function(opts)
  shell.mani(opts.args)
end, {
  nargs = '+',
  complete = 'command',
})

vim.api.nvim_create_user_command('StartAsyncNeoVim', function(opts)
  shell.start_async_neovim(opts.fargs[1])
end, {
  nargs = 1,
})
