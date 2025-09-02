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
  -- Extract the first command after shebang
  local first_command = cmd:match('#!/[^\n]*\n([^%s]+)')

  if first_command then
    local config = language_configs[first_command]
    if config then
      -- Extract args (everything after the file)
      local args = cmd:match('#!/[^\n]*\n[^%s]+%s+[^%s]+%s+(.*)')
      return args, config.adapter
    end
  end

  return nil, nil
end

M.flow_debug = function(cmd)
  local args, adapter = detect_language_and_args(cmd)

  local config = adapter_configs[adapter]

  -- Add args to adapter config if not nill
  if args ~= nil then
    config.args = {}
    for arg in args:gmatch('%S+') do
      table.insert(config.args, arg)
    end
  end

  local dap = require('dap')
  local filetype = vim.bo.filetype

  -- Clear existing configurations for this filetype
  dap.configurations[filetype] = {}

  -- Add dap configuration
  table.insert(dap.configurations[filetype], config)
  vim.notify(vim.inspect(config), nil, { title = '🪚 config', ft = 'lua' })

  dap.continue()
end

return M
