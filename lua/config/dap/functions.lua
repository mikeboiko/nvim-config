local M = {}

-- Adapter configurations for different languages
-- TODO: Create common config object, which will be inherited by all of these
local adapter_configs = {
  python = {
    name = 'main',
    type = 'python',
    request = 'launch',
    console = 'integratedTerminal',
    program = '${file}', -- nvim-dap will resolve this to the current buffer's file
    justMyCode = true,
  },
  python_module = {
    name = 'main',
    type = 'python',
    request = 'launch',
    console = 'integratedTerminal',
    justMyCode = true,
  },
  node = {
    name = 'main',
    type = 'node2',
    request = 'launch',
    program = '',
    console = 'integratedTerminal',
  },
}

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
  vim.notify(vim.inspect(cmd), nil, { title = '🪚 cmd', ft = 'lua' })
  -- Extract the first command after shebang
  local first_command = cmd:match('#!/[^\n]*\n([^%s]+)')

  if first_command then
    local config = language_configs[first_command]
    if config then
      -- Extract the file (next word after the command)
      local file = cmd:match('#!/[^\n]*\n[^%s]+%s+([^%s]+)')
      -- Extract args (everything after the file)
      local args = cmd:match('#!/[^\n]*\n[^%s]+%s+[^%s]+%s+(.*)')
      vim.notify(vim.inspect(file), nil, { title = '🪚 file', ft = 'lua' })
      vim.notify(vim.inspect(args), nil, { title = '🪚 args', ft = 'lua' })
      return first_command, args, config.adapter, file
    end
  end

  return nil, nil, nil, nil
end

M.flow_debug = function(cmd)
  -- vim.notify(vim.inspect(cmd), nil, { title = '🪚 cmd', ft = 'lua' })
  local language, args, adapter, file = detect_language_and_args(cmd)

  -- Add args to adapter config if not nill
  if args ~= nil then
    local config = adapter_configs[adapter]
    config.args = {}
    for arg in args:gmatch('%S+') do
      table.insert(config.args, arg)
    end
    vim.notify(vim.inspect(config), nil, { title = '🪚 config', ft = 'lua' })
  end

  local dap = require('dap')
  local filetype = vim.bo.filetype

  vim.notify(
    vim.inspect(dap.configurations[filetype]),
    nil,
    { title = '🪚 dap.configurations[filetype]1', ft = 'lua' }
  )

  -- Clear existing configurations for this filetype
  dap.configurations[filetype] = {}

  -- Add dap configuration
  table.insert(dap.configurations[filetype], config)
  vim.notify(
    vim.inspect(dap.configurations[filetype]),
    nil,
    { title = '🪚 dap.configurations[filetype]2', ft = 'lua' }
  )

  dap.continue()
end

return M
