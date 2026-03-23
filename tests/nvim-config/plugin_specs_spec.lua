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
end)
