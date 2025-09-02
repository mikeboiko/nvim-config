local M = {}

-- Language-specific configurations
local language_configs = {
  python = {
    pattern = 'python%s+(.*)',
    adapter = 'python',
  },
  node = {
    pattern = 'node%s+(.*)',
    adapter = 'node2',
  },
  -- Add more languages as needed
}

-- Detect language from shebang and extract arguments
local function detect_language_and_args(cmd)
  -- Extract the first command after shebang
  local first_command = cmd:match('#!/[^\n]*\n([^%s]+)')

  if first_command then
    local config = language_configs[first_command]
    if config then
      local args = cmd:match(config.pattern)
      return first_command, args, config.adapter
    end
  end

  return nil, nil, nil
end

M.flow_debug = function(cmd)
  -- vim.notify(vim.inspect(cmd), nil, { title = '🪚 cmd', ft = 'lua' })
  local language, python_args, adapter = detect_language_and_args(cmd)
  vim.notify(vim.inspect(adapter), nil, { title = '🪚 adapter', ft = 'lua' })
  vim.notify(vim.inspect(python_args), nil, { title = '🪚 python_args', ft = 'lua' })
  vim.notify(vim.inspect(language), nil, { title = '🪚 language', ft = 'lua' })
  -- TODO: uncomment
  -- vim.cmd('wa')
  -- local dap = require('dap')
  -- dap.continue()
end

return M
