describe('nvim-config python helpers', function()
  local python
  local created_paths = {}

  local function track(path)
    table.insert(created_paths, path)
    return path
  end

  local function write_file(path)
    local fh = assert(io.open(path, 'w'))
    fh:write('')
    fh:close()
  end

  local function project_bin_dir(project_root)
    return vim.fs.joinpath(project_root, '.venv', 'bin')
  end

  before_each(function()
    package.loaded['config.python'] = nil
    python = require('config.python')
    created_paths = {}
  end)

  after_each(function()
    for _, path in ipairs(created_paths) do
      vim.fn.delete(path, 'rf')
    end
  end)

  it('prefers the project .venv basedpyright server and interpreter', function()
    local project_root = track(vim.fn.tempname())
    local bin_dir = project_bin_dir(project_root)
    vim.fn.mkdir(bin_dir, 'p')
    write_file(vim.fs.joinpath(bin_dir, 'python'))
    write_file(vim.fs.joinpath(bin_dir, 'basedpyright-langserver'))

    local config = {
      settings = {
        basedpyright = {
          analysis = {
            typeCheckingMode = 'basic',
          },
        },
      },
    }

    python.apply_basedpyright_settings(config, project_root)

    assert.are.same(
      { vim.fs.joinpath(bin_dir, 'basedpyright-langserver'), '--stdio' },
      python.project_basedpyright_cmd(project_root)
    )
    assert.are.equal(vim.fs.joinpath(bin_dir, 'python'), config.settings.python.pythonPath)
    assert.are.equal(project_root, config.settings.basedpyright.analysis.configFilePath)
    assert.are.equal('basic', config.settings.basedpyright.analysis.typeCheckingMode)
  end)

  it('keeps the global basedpyright server when only the project interpreter exists', function()
    local project_root = track(vim.fn.tempname())
    local bin_dir = project_bin_dir(project_root)
    vim.fn.mkdir(bin_dir, 'p')
    write_file(vim.fs.joinpath(bin_dir, 'python'))

    local config = {
      settings = {},
    }

    python.apply_basedpyright_settings(config, project_root)

    assert.is_nil(python.project_basedpyright_cmd(project_root))
    assert.are.equal(vim.fs.joinpath(bin_dir, 'python'), config.settings.python.pythonPath)
    assert.are.equal(project_root, config.settings.basedpyright.analysis.configFilePath)
  end)

  it('pins config discovery to the project root when no .venv exists', function()
    local project_root = track(vim.fn.tempname())
    vim.fn.mkdir(project_root, 'p')

    local config = {
      settings = {},
    }

    python.apply_basedpyright_settings(config, project_root)

    assert.is_nil(python.project_basedpyright_cmd(project_root))
    assert.is_nil(config.settings.python)
    assert.are.equal(project_root, config.settings.basedpyright.analysis.configFilePath)
  end)
end)
