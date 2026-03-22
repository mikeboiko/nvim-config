local source = debug.getinfo(1, 'S').source:sub(2)
local root = vim.fn.fnamemodify(source, ':p:h:h:h')
local plugin_files = vim.fn.glob(root .. '/lua/plugins/*.lua', false, true)

describe('nvim-config plugin specs', function()
  it('load every plugin spec module without errors', function()
    for _, path in ipairs(plugin_files) do
      local module = 'plugins.' .. vim.fn.fnamemodify(path, ':t:r')
      package.loaded[module] = nil

      local ok, spec = pcall(require, module)

      assert.is_true(ok, module)
      assert.is_table(spec)
    end
  end)
end)
