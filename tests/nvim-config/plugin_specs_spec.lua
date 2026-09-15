local source = debug.getinfo(1, 'S').source:sub(2)
local root = vim.fn.fnamemodify(source, ':p:h:h:h')
local plugin_files = vim.fn.glob(root .. '/lua/plugins/*.lua', false, true)

local function load_plugin(module)
  package.loaded[module] = nil

  local ok, spec = pcall(require, module)
  assert.is_true(ok, module)
  assert.is_table(spec)

  return spec
end

describe('nvim-config plugin specs', function()
  it('loads every plugin spec module without errors', function()
    for _, path in ipairs(plugin_files) do
      local module = 'plugins.' .. vim.fn.fnamemodify(path, ':t:r')
      load_plugin(module)
    end
  end)

  it('automatically installs the available Roslyn package after refreshing Mason', function()
    local spec = load_plugin('plugins.mason')
    local original_mason = package.loaded.mason
    local original_registry = package.loaded['mason-registry']
    local original_schedule = vim.schedule
    local original_list_uis = vim.api.nvim_list_uis
    local setup_opts
    local install_called = false

    vim.schedule = function(callback)
      callback()
    end
    vim.api.nvim_list_uis = function()
      return { {} }
    end
    package.loaded.mason = {
      setup = function(opts)
        setup_opts = opts
      end,
    }
    package.loaded['mason-registry'] = {
      is_installed = function(name)
        assert.is_true(name == 'roslyn-nightly' or name == 'roslyn')
        return false
      end,
      refresh = function(callback)
        callback(true)
      end,
      has_package = function(name)
        assert.equal('roslyn-nightly', name)
        return true
      end,
      get_package = function(name)
        assert.equal('roslyn-nightly', name)
        return {
          is_installed = function()
            return false
          end,
          is_installing = function()
            return false
          end,
          install = function(_, opts, callback)
            assert.same({}, opts)
            install_called = true
            callback(true)
          end,
        }
      end,
    }
    spec.config()
    vim.schedule = original_schedule
    vim.api.nvim_list_uis = original_list_uis
    package.loaded.mason = original_mason
    package.loaded['mason-registry'] = original_registry

    assert.same({
      registries = {
        'github:mason-org/mason-registry',
        'github:Crashdummyy/mason-registry',
      },
    }, setup_opts)
    assert.is_true(install_called)
  end)

  it('schedules Mason failure notifications outside fast callbacks', function()
    local spec = load_plugin('plugins.mason')
    local original_mason = package.loaded.mason
    local original_registry = package.loaded['mason-registry']
    local original_schedule = vim.schedule
    local original_list_uis = vim.api.nvim_list_uis
    local original_notify = vim.notify
    local scheduled = {}
    local notifications = {}

    vim.schedule = function(callback)
      table.insert(scheduled, callback)
    end
    vim.api.nvim_list_uis = function()
      return { {} }
    end
    vim.notify = function(message)
      table.insert(notifications, message)
    end
    package.loaded.mason = {
      setup = function() end,
    }
    package.loaded['mason-registry'] = {
      is_installed = function()
        return false
      end,
      refresh = function(callback)
        callback(true)
      end,
      has_package = function(name)
        return name == 'roslyn-nightly'
      end,
      get_package = function()
        return {
          is_installed = function()
            return false
          end,
          is_installing = function()
            return false
          end,
          install = function(_, _, callback)
            callback(false, 'download failed')
          end,
        }
      end,
    }

    spec.config()
    assert.equal(1, #scheduled)
    scheduled[1]()
    assert.equal(2, #scheduled)
    scheduled[2]()
    assert.equal(3, #scheduled)
    assert.equal(0, #notifications)
    scheduled[3]()

    vim.schedule = original_schedule
    vim.api.nvim_list_uis = original_list_uis
    vim.notify = original_notify
    package.loaded.mason = original_mason
    package.loaded['mason-registry'] = original_registry

    assert.equal(1, #notifications)
    assert.matches('Mason failed to install roslyn%-nightly: download failed', notifications[1])
  end)

  it('points the roslyn LSP command at the Mason binary', function()
    local spec = load_plugin('plugins.roslyn')

    -- The deprecated `extensions` option lived under `opts`; it must be gone.
    assert.is_nil(spec.opts)
    assert.is_function(spec.config)

    local original_roslyn = package.loaded['roslyn']
    local original_executable = vim.fn.executable
    local original_lsp_config = vim.lsp.config
    local setup_called = false
    local configured

    package.loaded['roslyn'] = {
      setup = function()
        setup_called = true
      end,
    }
    vim.fn.executable = function()
      return 1
    end
    vim.lsp.config = function(name, cfg)
      if name == 'roslyn' then
        configured = cfg
      end
    end

    spec.config()

    package.loaded['roslyn'] = original_roslyn
    vim.fn.executable = original_executable
    vim.lsp.config = original_lsp_config

    assert.is_true(setup_called)
    assert.is_table(configured)
    assert.is_table(configured.cmd)
    assert.matches('mason/bin/roslyn$', configured.cmd[1])
    assert.equal('--stdio', configured.cmd[2])
  end)

  it('runs markdown preview in multi-instance mode', function()
    local spec = load_plugin('plugins.markdown-preview')
    local original_markdown_preview = package.loaded['markdown_preview']
    local original_create_autocmd = vim.api.nvim_create_autocmd
    local original_create_augroup = vim.api.nvim_create_augroup
    local setup_opts

    package.loaded['markdown_preview'] = {
      setup = function(opts)
        setup_opts = opts
      end,
    }
    vim.api.nvim_create_autocmd = function() end
    vim.api.nvim_create_augroup = function()
      return 1
    end

    spec.config()

    vim.api.nvim_create_autocmd = original_create_autocmd
    vim.api.nvim_create_augroup = original_create_augroup
    package.loaded['markdown_preview'] = original_markdown_preview

    assert.is_table(setup_opts)
    assert.equal('multi', setup_opts.instance_mode)
    assert.equal('rust', setup_opts.mermaid_renderer)
  end)
end)
