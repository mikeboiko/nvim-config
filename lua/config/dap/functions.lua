local M = {}

local function find_venv_path()
  local current_dir = vim.fn.getcwd()

  while current_dir ~= '/' do
    local venv_path = current_dir .. '/.venv'
    if vim.fn.isdirectory(venv_path) == 1 then
      return venv_path .. '/bin/python'
    end

    -- Move up one directory
    current_dir = vim.fn.fnamemodify(current_dir, ':h')
  end

  return nil -- No venv found
end

-- Adapter configurations for different languages
-- TODO: Create common config object, which will be inherited by all of these
local adapter_configs = {
  python = {
    name = 'python',
    type = 'python',
    request = 'launch',
    console = 'integratedTerminal',
    pythonPath = find_venv_path() or 'python',
    -- justMyCode = false,
  },
  node = {
    name = 'main',
    type = 'node',
    request = 'launch',
    program = '',
    console = 'integratedTerminal',
  },
}

-- Launch configurations from .vscode/launch.json
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

-- Extract language, command and args from command string
local function parse_command(cmd)
  -- Extract the first command after shebang. Ex: python
  local first_word = cmd:match('#!/[^\n]*\n([^%s]+)')

  if not first_word then
    return nil, nil, nil, nil
  end

  -- Extract the second word to check for module flag (-m)
  local second_word = cmd:match('#!/[^\n]*\n[^%s]+%s+([^%s]+)')
  -- Extract the third word (module)
  local third_word = cmd:match('#!/[^\n]*\n[^%s]+%s+[^%s]+%s+([^%s]+)')

  -- Determine adapter based on second word
  local adapter_key = first_word
  local args, module, file_name

  if first_word == 'uv' then
    adapter_key = 'python'
  end

  if first_word == 'uv' or second_word == '-m' then -- module
    -- Extract args (everything after the 3rd word)
    args = cmd:match('#!/[^\n]*\n[^%s]+%s+[^%s]+%s+[^%s]+%s+(.*)')
    module = third_word
    file_name = nil
  else -- file
    -- Extract args (everything after the 2nd word)
    args = cmd:match('#!/[^\n]*\n[^%s]+%s+[^%s]+%s+(.*)')
    module = nil
    file_name = second_word
  end

  return args, adapter_key, module, file_name
end

M.flow_debug = function(cmd)
  local args, adapter, module, file_name = parse_command(cmd)

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
  else
    config.program = file_name
  end

  local dap = require('dap')
  local filetype = vim.bo.filetype

  -- Clear existing configurations for this filetype
  dap.configurations[filetype] = {}

  -- Add dap configuration
  table.insert(dap.configurations[filetype], config)
  vim.notify(vim.inspect(config), nil, { title = 'dap config', ft = 'lua' })

  dap.continue()
end

return M
