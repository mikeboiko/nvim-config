local folds = require('config.folds')
local windows = require('config.windows')
local quickfix = require('config.quickfix')

windows.register_legacy_functions()
quickfix.register_legacy_functions()

vim.api.nvim_create_user_command('CloseAll', function()
  windows.close_all()
end, {})

vim.api.nvim_create_user_command('FoldOpen', function()
  folds.open_current_fold()
end, {})

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
