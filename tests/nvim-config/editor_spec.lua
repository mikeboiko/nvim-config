describe('nvim-config editor helpers', function()
  local editor

  before_each(function()
    editor = require('config.editor')
  end)

  local function wipe_if_valid(buffer)
    if buffer ~= nil and vim.api.nvim_buf_is_valid(buffer) then
      vim.api.nvim_buf_delete(buffer, { force = true })
    end
  end

  it('keeps the legacy BufDo() entrypoint working and restores the current buffer', function()
    require('config.commands')

    vim.cmd('enew')
    local buffer_one = vim.api.nvim_get_current_buf()

    vim.cmd('enew')
    local buffer_two = vim.api.nvim_get_current_buf()

    vim.api.nvim_set_current_buf(buffer_one)
    vim.cmd([[call BufDo("let b:nvim_config_editor_iterated = 1")]])

    assert.are.equal(buffer_one, vim.api.nvim_get_current_buf())
    assert.are.equal(1, vim.api.nvim_buf_get_var(buffer_one, 'nvim_config_editor_iterated'))
    assert.are.equal(1, vim.api.nvim_buf_get_var(buffer_two, 'nvim_config_editor_iterated'))

    wipe_if_valid(buffer_two)
    wipe_if_valid(buffer_one)
  end)

  it('restores the current window after running windo commands', function()
    vim.cmd('enew')
    local original_window = vim.api.nvim_get_current_win()
    vim.cmd('vsplit')
    local second_window = vim.api.nvim_get_current_win()

    vim.api.nvim_set_current_win(original_window)
    editor.windo('setlocal cursorline', { noautocmd = true })

    assert.are.equal(original_window, vim.api.nvim_get_current_win())
    assert.is_true(vim.api.nvim_get_option_value('cursorline', { win = original_window }))
    assert.is_true(vim.api.nvim_get_option_value('cursorline', { win = second_window }))

    if vim.api.nvim_win_is_valid(second_window) then
      vim.api.nvim_win_close(second_window, true)
    end
    wipe_if_valid(vim.api.nvim_get_current_buf())
  end)

  it('runs the migrated save autocmd through config.editor', function()
    package.loaded['config.autocmds'] = nil

    local called = 0
    local original_on_save = editor.on_save
    editor.on_save = function()
      called = called + 1
    end

    require('config.autocmds')
    vim.cmd('enew')
    local buffer = vim.api.nvim_get_current_buf()
    vim.api.nvim_exec_autocmds('BufWritePre', { buffer = buffer, modeline = false })

    assert.are.equal(1, called)

    editor.on_save = original_on_save
    wipe_if_valid(buffer)
  end)

  it('sets command-window quit maps on CmdwinEnter', function()
    package.loaded['config.autocmds'] = nil

    require('config.autocmds')
    vim.cmd('enew')
    local buffer = vim.api.nvim_get_current_buf()
    vim.api.nvim_exec_autocmds('CmdwinEnter', { buffer = buffer, modeline = false })

    local command_window_quit = vim.fn.maparg('<C-w>', 'n', false, true)
    local command_window_quick_quit = vim.fn.maparg('qq', 'n', false, true)

    assert.is_truthy(command_window_quit.buffer == 1)
    assert.is_truthy(command_window_quick_quit.buffer == 1)

    wipe_if_valid(buffer)
  end)
end)
