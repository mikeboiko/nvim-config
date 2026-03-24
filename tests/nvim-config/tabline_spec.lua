describe('nvim-config tabline helpers', function()
  local tabline
  local original_columns

  before_each(function()
    tabline = require('config.tabline')
    original_columns = vim.o.columns
  end)

  after_each(function()
    vim.o.columns = original_columns
    pcall(vim.cmd, 'tabonly!')
  end)

  it('labels unnamed buffers as [No Name]', function()
    vim.cmd('enew')
    assert.are.equal('[No Name]', tabline.label(1))
  end)

  it('renders tab labels using buffer basenames', function()
    local prefix = tostring(vim.loop.hrtime())

    vim.cmd('enew')
    vim.api.nvim_buf_set_name(0, '/tmp/' .. prefix .. '/alpha.txt')

    vim.cmd('tabnew')
    vim.api.nvim_buf_set_name(0, '/tmp/' .. prefix .. '/beta.lua')

    assert.are.equal('alpha.txt', tabline.label(1))
    assert.are.equal('beta.lua', tabline.label(2))

    local rendered = tabline.render()
    assert.is_true(rendered:find('alpha.txt', 1, true) ~= nil)
    assert.is_true(rendered:find('beta.lua', 1, true) ~= nil)
    assert.is_true(rendered:find('%#TabLineSel#', 1, true) ~= nil)
    assert.is_true(rendered:find('%#TabLineFill#%T', 1, true) ~= nil)
  end)

  it('keeps the current tab visible when the tabline is crowded', function()
    local prefix = tostring(vim.loop.hrtime())
    local names = {
      'alpha.txt',
      'beta.lua',
      'gamma.md',
      'delta.json',
      'epsilon.go',
    }

    vim.o.columns = 30

    vim.cmd('enew')
    vim.api.nvim_buf_set_name(0, '/tmp/' .. prefix .. '/' .. names[1])

    for index = 2, #names do
      vim.cmd('tabnew')
      vim.api.nvim_buf_set_name(0, '/tmp/' .. prefix .. '/' .. names[index])
    end

    vim.cmd('tabnext 3')

    local rendered = tabline.render()
    assert.is_true(rendered:find('%<', 1, true) ~= nil)
    assert.is_true(rendered:find('gamma.md', 1, true) ~= nil)
    assert.is_true(rendered:find(' < ', 1, true) ~= nil)
    assert.is_true(rendered:find(' > ', 1, true) ~= nil)
    assert.is_nil(rendered:find('alpha.txt', 1, true))
    assert.is_nil(rendered:find('epsilon.go', 1, true))
  end)

  it('keeps moderately long tab labels untruncated', function()
    local prefix = tostring(vim.loop.hrtime())
    local longish_name = string.rep('a', 22) .. '.txt'

    vim.cmd('enew')
    vim.api.nvim_buf_set_name(0, '/tmp/' .. prefix .. '/' .. longish_name)

    local rendered = tabline.render()
    assert.is_true(rendered:find(longish_name, 1, true) ~= nil)
  end)

  it('truncates long tab labels to keep more tabs visible', function()
    local long_name = string.rep('a', 30) .. '.txt'

    vim.cmd('enew')
    vim.api.nvim_buf_set_name(0, '/tmp/' .. long_name)

    local rendered = tabline.render()
    assert.is_true(rendered:find('...', 1, true) ~= nil)
    assert.is_nil(rendered:find(long_name, 1, true))
  end)
end)
