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

  it('reloads the buffer with a requested fileformat and preserves the cursor', function()
    local original_run_ex = editor.run_ex
    local original_replace_m_with_blank = editor.replace_m_with_blank
    local calls = {}
    local replace_calls = 0

    vim.cmd('enew')
    local buffer = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'alpha', 'beta' })
    vim.api.nvim_win_set_cursor(0, { 2, 2 })

    editor.run_ex = function(command)
      table.insert(calls, command)
    end

    editor.replace_m_with_blank = function()
      replace_calls = replace_calls + 1
    end

    editor.reload_with_fileformat('dos')
    editor.reload_with_fileformat('unix')

    assert.are.same({ 'edit ++ff=dos', 'edit ++ff=unix' }, calls)
    assert.are.equal(1, replace_calls)
    assert.are.same({ 2, 2 }, vim.api.nvim_win_get_cursor(0))

    editor.run_ex = original_run_ex
    editor.replace_m_with_blank = original_replace_m_with_blank
    wipe_if_valid(buffer)
  end)

  it('inserts a blank line below the current line and keeps the cursor on the original text', function()
    vim.cmd('enew')
    local buffer = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'alpha', 'beta' })
    vim.api.nvim_win_set_cursor(0, { 1, 2 })

    editor.insert_blank_line_below()

    assert.are.same({ 'alpha', '', 'beta' }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    assert.are.same({ 1, 2 }, vim.api.nvim_win_get_cursor(0))

    wipe_if_valid(buffer)
  end)

  it('inserts a blank line above the current line and keeps the cursor on the original text', function()
    vim.cmd('enew')
    local buffer = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'alpha', 'beta' })
    vim.api.nvim_win_set_cursor(0, { 2, 1 })

    editor.insert_blank_line_above()

    assert.are.same({ 'alpha', '', 'beta' }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    assert.are.same({ 3, 1 }, vim.api.nvim_win_get_cursor(0))

    wipe_if_valid(buffer)
  end)

  it('inserts blank lines around the current line and keeps the cursor on the original text', function()
    vim.cmd('enew')
    local buffer = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'alpha', 'beta' })
    vim.api.nvim_win_set_cursor(0, { 2, 1 })

    editor.insert_blank_line_around()

    assert.are.same({ 'alpha', '', 'beta', '' }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    assert.are.same({ 3, 1 }, vim.api.nvim_win_get_cursor(0))

    wipe_if_valid(buffer)
  end)

  it('yanks the whole buffer and restores the current view', function()
    vim.cmd('enew')
    local buffer = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'alpha', 'beta', 'gamma' })
    vim.api.nvim_win_set_cursor(0, { 2, 1 })

    editor.yank_all()

    assert.are.equal('alpha\nbeta\ngamma\n', vim.fn.getreg('"'))
    assert.are.equal('V', vim.fn.getregtype('"'))
    assert.are.same({ 2, 1 }, vim.api.nvim_win_get_cursor(0))

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
