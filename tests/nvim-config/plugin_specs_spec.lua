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

local function key_has_mode(entry, mode)
  if entry.mode == nil then
    return mode == 'n'
  end

  if type(entry.mode) == 'string' then
    return entry.mode == mode
  end

  return vim.tbl_contains(entry.mode, mode)
end

local function find_key(spec, lhs, mode)
  for _, entry in ipairs(spec.keys or {}) do
    if entry[1] == lhs and key_has_mode(entry, mode or 'n') then
      return entry
    end
  end

  return nil
end

describe('nvim-config plugin specs', function()
  it('load every plugin spec module without errors', function()
    for _, path in ipairs(plugin_files) do
      local module = 'plugins.' .. vim.fn.fnamemodify(path, ':t:r')
      load_plugin(module)
    end
  end)

  it('keeps plugin-exclusive keymaps with the owning plugin specs', function()
    local copilot = load_plugin('plugins.copilot-chat')
    local fugitive = load_plugin('plugins.fugitive')
    local markdown_preview = load_plugin('plugins.markdown-preview')
    local snacks = load_plugin('plugins.snacks')

    assert.is_truthy(find_key(copilot, '<leader>ac', 'n'))
    assert.is_truthy(find_key(copilot, '<leader>af', 'n'))
    assert.is_truthy(find_key(copilot, '<leader>aq', 'n'))
    assert.is_truthy(find_key(copilot, '<leader>at', 'n'))
    assert.is_truthy(find_key(copilot, '<leader>ac', 'v'))
    assert.is_truthy(find_key(copilot, '<leader>ad', 'v'))
    assert.is_truthy(find_key(copilot, '<leader>ae', 'v'))
    assert.is_truthy(find_key(copilot, '<leader>af', 'v'))
    assert.is_truthy(find_key(copilot, '<leader>ao', 'v'))
    assert.is_truthy(find_key(copilot, '<leader>aq', 'v'))
    assert.is_truthy(find_key(copilot, '<leader>ar', 'v'))
    assert.are.equal('function', type(find_key(copilot, '<leader>aq', 'n')[2]))
    assert.are.equal('function', type(find_key(copilot, '<leader>aq', 'v')[2]))

    assert.is_truthy(find_key(fugitive, '<leader>gd', 'n'))
    assert.is_truthy(find_key(fugitive, '<leader>gdt', 'n'))
    assert.is_truthy(find_key(fugitive, '<leader>gs', 'n'))
    assert.are.equal('function', type(find_key(fugitive, '<leader>gd', 'n')[2]))
    assert.are.equal('function', type(find_key(fugitive, '<leader>gdt', 'n')[2]))

    local markdown_preview_key = find_key(markdown_preview, '<leader>ob', 'n')
    assert.is_truthy(markdown_preview_key)
    assert.are.equal('<cmd>MarkdownPreview<CR>', markdown_preview_key[2])

    local snacks_history_key = find_key(snacks, '<leader>nh', 'n')
    assert.is_truthy(snacks_history_key)
    assert.are.equal('function', type(snacks_history_key[2]))
  end)
end)
