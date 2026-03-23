local M = {}

function M.call_global(name, ...)
  local callback = vim.g[name]
  if type(callback) ~= 'function' then
    vim.notify('Missing global callback: ' .. name, vim.log.levels.ERROR)
    return false
  end

  callback(...)
  return true
end

function M.prompt_rename(visual)
  if visual then
    return M.call_global('FancyPromptRename', 'RenameWord', 'New Word', 1)
  end

  return M.call_global('FancyPromptRename', 'RenameWord', 'New Word')
end

local navigation = require('config.keymaps.navigation')

function M.set_terminal_keymaps(buffer)
  navigation.set_terminal_keymaps(buffer)
end

local modules = {
  require('config.keymaps.editing'),
  navigation,
  require('config.keymaps.search'),
  require('config.keymaps.workflow'),
}

for _, module in ipairs(modules) do
  module.register(M)
end

return M
