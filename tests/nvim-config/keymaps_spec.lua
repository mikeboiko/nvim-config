describe('nvim-config keymap helpers', function()
  local keymaps

  before_each(function()
    package.loaded['config.keymaps'] = nil
    keymaps = require('config.keymaps')
  end)

  it('calls named global callbacks when present', function()
    local received

    vim.g.nvim_config_test_callback = function(arg_one, arg_two)
      received = { arg_one, arg_two }
    end

    assert.is_true(keymaps.call_global('nvim_config_test_callback', 'alpha', 2))
    assert.are.same({ 'alpha', 2 }, received)

    vim.g.nvim_config_test_callback = nil
  end)

  it('notifies when a named global callback is missing', function()
    local original_notify = vim.notify
    local notified

    vim.notify = function(message, level)
      notified = { message, level }
    end

    assert.is_false(keymaps.call_global('nvim_config_missing_callback'))
    assert.are.same({ 'Missing global callback: nvim_config_missing_callback', vim.log.levels.ERROR }, notified)

    vim.notify = original_notify
  end)
end)
