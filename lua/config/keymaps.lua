local M = {}

local functions = require('config.functions')

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
  functions.fancy_prompt_rename(functions.rename_word, 'New Word', visual and true or nil)
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
