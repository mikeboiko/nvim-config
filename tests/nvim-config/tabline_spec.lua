describe('nvim-config tabline helpers', function()
  local tabline

  before_each(function()
    tabline = require('config.tabline')
  end)

  after_each(function()
    pcall(vim.cmd, 'tabonly!')
  end)

  it('labels unnamed buffers as [No Name]', function()
    vim.cmd('enew')
    assert.are.equal('[No Name]', tabline.label(1))
  end)

  it('renders tab labels using buffer basenames', function()
    local prefix = tostring(vim.loop.hrtime())

    vim.cmd('enew')
    vim.api.nvim_buf_set_name(0, '/tmp/' .. prefix .. '-alpha.txt')

    vim.cmd('tabnew')
    vim.api.nvim_buf_set_name(0, '/tmp/' .. prefix .. '-beta.lua')

    assert.are.equal(prefix .. '-alpha.txt', tabline.label(1))
    assert.are.equal(prefix .. '-beta.lua', tabline.label(2))

    local rendered = tabline.render()
    assert.is_true(rendered:find(prefix .. '-alpha.txt', 1, true) ~= nil)
    assert.is_true(rendered:find(prefix .. '-beta.lua', 1, true) ~= nil)
    assert.is_true(rendered:find('%#TabLineSel#', 1, true) ~= nil)
    assert.is_true(rendered:find('%#TabLineFill#%T', 1, true) ~= nil)
  end)
end)
