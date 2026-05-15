local M = {}

local uv = vim.uv or vim.loop

local function venv_bin_dir()
  if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
    return 'Scripts'
  end

  return 'bin'
end

local function executable_name(name)
  if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
    return name .. '.exe'
  end

  return name
end

function M.path_exists(path)
  return path ~= nil and uv.fs_stat(path) ~= nil
end

function M.project_venv_dir(root_dir)
  local venv_dir = vim.fs.joinpath(root_dir, '.venv')
  if M.path_exists(venv_dir) then
    return venv_dir
  end

  return nil
end

function M.project_python_path(root_dir)
  local venv_dir = M.project_venv_dir(root_dir)
  if not venv_dir then
    return nil
  end

  local python_path = vim.fs.joinpath(venv_dir, venv_bin_dir(), executable_name('python'))
  if M.path_exists(python_path) then
    return python_path
  end

  return nil
end

function M.project_basedpyright_cmd(root_dir)
  local venv_dir = M.project_venv_dir(root_dir)
  if not venv_dir then
    return nil
  end

  local basedpyright_path = vim.fs.joinpath(venv_dir, venv_bin_dir(), executable_name('basedpyright-langserver'))
  if M.path_exists(basedpyright_path) then
    return { basedpyright_path, '--stdio' }
  end

  return nil
end

function M.apply_basedpyright_settings(config, root_dir)
  if not root_dir or root_dir == '' then
    return
  end

  local settings = {
    basedpyright = {
      analysis = {
        configFilePath = root_dir,
      },
    },
  }

  local python_path = M.project_python_path(root_dir)
  if python_path then
    settings.python = {
      pythonPath = python_path,
    }
  end

  config.settings = vim.tbl_deep_extend('force', config.settings or {}, settings)
end

return M
