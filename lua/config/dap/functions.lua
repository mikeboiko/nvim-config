local M = {}

-- Adapter configurations for different languages
-- TODO: Create common config object, which will be inherited by all of these
local adapter_configs = {
  python = {
    name = 'python file',
    type = 'python',
    request = 'launch',
    console = 'integratedTerminal',
    program = '${file}', -- nvim-dap will resolve this to the current buffer's file
    justMyCode = true,
  },
  python_module = {
    name = 'python module',
    type = 'python',
    module = 'yok',
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

-- Extract language, command and args from command string
local function parse_command(cmd)
  -- Extract the first command after shebang. Ex: python
  local first_word = cmd:match('#!/[^\n]*\n([^%s]+)')

  if first_word then
    local config = language_configs[first_word]
    if config then
      -- Extract the second word to check for module flag (-m)
      local second_word = cmd:match('#!/[^\n]*\n[^%s]+%s+([^%s]+)')
      -- Extract the third word (module)
      local module = cmd:match('#!/[^\n]*\n[^%s]+%s+[^%s]+%s+([^%s]+)')

      -- Determine adapter based on second word
      local adapter_key = first_word
      local args

      if second_word == '-m' then
        adapter_key = first_word .. '_module'
        -- Extract args (everything after the 3rd word)
        args = cmd:match('#!/[^\n]*\n[^%s]+%s+[^%s]+%s+[^%s]+%s+(.*)')
      else
        -- Extract args (everything after the 2nd word)
        args = cmd:match('#!/[^\n]*\n[^%s]+%s+[^%s]+%s+(.*)')
      end

      return args, adapter_key, module
    end
  end

  return nil, nil, nil
end

M.flow_debug = function(cmd)
  local args, adapter, module = parse_command(cmd)

  local config = adapter_configs[adapter]

  -- Add args to adapter config if not nill
  if args ~= nil then
    config.args = {}

    -- This will transform `'{"Selected":"x"}'` to `{"Selected":"x"}`, which Fire can then parse as JSON.
    args = args:gsub("'({.-})'", '%1')

    for arg in args:gmatch('%S+') do
      table.insert(config.args, arg)
    end
  end

  -- Set python module
  if module ~= nil then
    config.module = module
  end

  local dap = require('dap')
  local filetype = vim.bo.filetype

  -- Clear existing configurations for this filetype
  dap.configurations[filetype] = {}

  -- Add dap configuration
  table.insert(dap.configurations[filetype], config)

  dap.continue()
end

M.load_launch_json_for_repo = function()
  local repo_root = require('config.functions').get_repo_root()
  local launch_path = repo_root .. '/.vscode/launch.json'

  local ok, lines = pcall(vim.fn.readfile, launch_path)
  if not ok then
    -- vim.notify('Failed to read ' .. launch_path, vim.log.levels.ERROR)
    return
  end

  local json = vim.fn.json_decode(lines)
  if not json or not json.configurations then
    vim.notify('Invalid JSON in ' .. launch_path, vim.log.levels.ERROR)
    return
  end

  local dap = require('dap')
  local filetype = vim.bo.filetype

  -- Clear existing configurations for this filetype
  dap.configurations[filetype] = {}

  -- Add configurations from launch.json
  for _, config in ipairs(json.configurations) do
    if config.type == filetype then
      table.insert(dap.configurations[filetype], config)
    end
  end
end

return M
