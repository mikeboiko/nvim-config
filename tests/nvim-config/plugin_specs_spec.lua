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

  it('disables the roslyn razor extension by default', function()
    local spec = load_plugin('plugins.roslyn')

    assert.is_table(spec.opts)
    assert.is_table(spec.opts.extensions)
    assert.is_table(spec.opts.extensions.razor)
    assert.is_false(spec.opts.extensions.razor.enabled)
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
