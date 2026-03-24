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

  it('registers representative commands, keymaps, and UI hooks', function()
    require_core_modules()

    local commands = vim.api.nvim_get_commands({})
    assert.is_truthy(commands.CloseAll)
    assert.is_truthy(commands.Grep)
    assert.is_truthy(commands.SpellToggle)
    assert.is_truthy(commands.StartAsyncNeoVim)
    assert.is_truthy(commands.TodoPrompt)
    assert.is_nil(commands.ViraEnable)

    local todo_map = vim.fn.maparg('<Space>ti', 'n', false, true)
    local quickfix_map = vim.fn.maparg('<Space>q', 'n', false, true)
    local grep_repo_map = vim.fn.maparg('<Space>fg', 'n', false, true)

    assert.are.equal('<Space>ti', todo_map.lhs)
    assert.are.equal('<Space>q', quickfix_map.lhs)
    assert.are.equal('<Space>fg', grep_repo_map.lhs)
    assert.are.equal('', vim.fn.maparg('<Space>sv', 'n'))
    assert.is_true(vim.o.foldtext:find('config.folds', 1, true) ~= nil)
    assert.is_true(vim.o.tabline:find('config.tabline', 1, true) ~= nil)
  end)

  it('keeps the legacy CloseAll() function available for plugin workflows', function()
    require_core_modules()

    vim.fn.setqflist({
      { bufnr = vim.api.nvim_get_current_buf(), lnum = 1, col = 1, text = 'quickfix item' },
    })
    vim.cmd('copen')

    assert.are.equal(1, vim.fn.exists('*CloseAll'))
    assert.has_no.errors(function()
      vim.cmd('silent call CloseAll()')
    end)
    assert.are.equal(0, vim.fn.getqflist({ winid = 0 }).winid)
  end)

  it('registers migrated toggle commands with the same state changes', function()
    require_core_modules()

    vim.g.term_close = ''
    vim.cmd('silent CloseToggle')
    assert.are.equal('++close', vim.g.term_close)
    vim.cmd('silent CloseToggle')
    assert.are.equal('', vim.g.term_close)

    vim.opt_local.spell = false
    vim.cmd('silent SpellToggle')
    assert.is_true(vim.wo.spell)
    vim.cmd('silent SpellToggle')
    assert.is_false(vim.wo.spell)
  end)
end)
