local windows = require('config.windows')

windows.register_legacy_functions()

vim.api.nvim_create_user_command('CloseAll', function()
  windows.close_all()
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
