local function require_core_modules()
  vim.g.mapleader = ' '

  require('config.autocmds')
  require('config.commands')
  require('config.constants')
  require('config.comments')
  require('config.functions')
  require('config.keymaps')
  require('config.options')
end

describe('nvim-config core Lua modules', function()
  it('load in init order without errors', function()
    assert.has_no.errors(require_core_modules)
  end)

  it('registers baseline Lua commands and keymaps', function()
    require_core_modules()

    local commands = vim.api.nvim_get_commands({})
    assert.is_truthy(commands.CloseAll)
    assert.is_truthy(commands.TodoPrompt)
    assert.is_truthy(commands.EchoSelection)
    assert.is_truthy(commands.FilterAndSaveOldfiles)
    assert.is_nil(commands.ViraEnable)

    local todo_map = vim.fn.maparg('<Space>ti', 'n', false, true)
    local history_map = vim.fn.maparg('<Space>nh', 'n', false, true)

    assert.are.equal('<Space>ti', todo_map.lhs)
    assert.are.equal('<Space>nh', history_map.lhs)
  end)

  it('registers migrated toggle commands with the same state changes', function()
    require_core_modules()

    vim.g.term_close = ''
    vim.cmd('silent CloseToggle')
    assert.are.equal('++close', vim.g.term_close)
    vim.cmd('silent CloseToggle')
    assert.are.equal('', vim.g.term_close)
  end)
end)
