local M = {}

-- Launch configurations from .vscode/launch.json
M.load_launch_json_for_repo = function()
  local repo_root = require('config.functions').get_repo_root()
  local launch_path = repo_root .. '/.vscode/launch.json'

  local ok, lines = pcall(vim.fn.readfile, launch_path)
  if not ok then
    return
  end

  local json = vim.fn.json_decode(lines)
  if not json or not json.configurations then
    vim.notify('Invalid JSON in ' .. launch_path, vim.log.levels.ERROR)
    return
  end

  local dap = require('dap')
  local filetype = vim.bo.filetype

  dap.configurations[filetype] = {}
  for _, config in ipairs(json.configurations) do
    if config.type == filetype then
      table.insert(dap.configurations[filetype], config)
    end
  end
end

return M
