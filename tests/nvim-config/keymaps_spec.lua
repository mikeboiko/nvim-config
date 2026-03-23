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

  it('routes rename prompts through FancyPromptRename with the expected arguments', function()
    local normal_call
    local visual_call

    vim.g.FancyPromptRename = function(func, prompt, visual)
      if visual == 1 then
        visual_call = { func = func, prompt = prompt, visual = visual }
      else
        normal_call = { func = func, prompt = prompt, visual = visual }
      end
    end

    assert.is_true(keymaps.prompt_rename(false))
    assert.is_true(keymaps.prompt_rename(true))

    assert.are.equal('RenameWord', normal_call.func)
    assert.are.equal('New Word', normal_call.prompt)
    assert.is_nil(normal_call.visual)
    assert.are.equal('RenameWord', visual_call.func)
    assert.are.equal('New Word', visual_call.prompt)
    assert.are.equal(1, visual_call.visual)

    vim.g.FancyPromptRename = nil
  end)
end)
