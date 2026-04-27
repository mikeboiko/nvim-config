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

  it('runs a command across all buffers and restores the current buffer', function()
    vim.cmd('enew')
    local buffer_one = vim.api.nvim_get_current_buf()

    vim.cmd('enew')
    local buffer_two = vim.api.nvim_get_current_buf()

    vim.api.nvim_set_current_buf(buffer_one)
    editor.bufdo('let b:nvim_config_editor_iterated = 1')

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

  it('runs the save autocmd through config.editor', function()
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

  it('updates normal file buffers before quit flows', function()
    vim.cmd('enew')
    local buffer = vim.api.nvim_get_current_buf()
    local commands = {}
    local original_cmd = vim.cmd

    vim.cmd = function(command)
      table.insert(commands, command)
    end

    local ok, wrote = pcall(editor.update_before_quit)

    vim.cmd = original_cmd

    assert.is_true(ok)
    assert.is_true(wrote)
    assert.are.same({ 'update' }, commands)

    wipe_if_valid(buffer)
  end)

  it('skips special buffers before quit flows', function()
    vim.cmd('enew')
    local buffer = vim.api.nvim_get_current_buf()
    local commands = {}
    local original_cmd = vim.cmd

    vim.bo[buffer].buftype = 'nofile'
    vim.cmd = function(command)
      table.insert(commands, command)
    end

    local ok, wrote = pcall(editor.update_before_quit)

    vim.cmd = original_cmd

    assert.is_true(ok)
    assert.is_false(wrote)
    assert.are.same({}, commands)

    wipe_if_valid(buffer)
  end)

  it('skips readonly buffers before quit flows', function()
    local file = vim.fn.tempname() .. '.txt'
    local fh = assert(io.open(file, 'w'))
    local commands = {}
    local original_cmd = vim.cmd

    fh:write('alpha\n')
    fh:close()

    vim.cmd('edit ' .. vim.fn.fnameescape(file))
    local buffer = vim.api.nvim_get_current_buf()
    vim.bo[buffer].readonly = true
    vim.bo[buffer].modified = true
    vim.cmd = function(command)
      table.insert(commands, command)
    end

    local ok, wrote = pcall(editor.update_before_quit)

    vim.cmd = original_cmd

    assert.is_true(ok)
    assert.is_false(wrote)
    assert.are.same({}, commands)

    wipe_if_valid(buffer)
    vim.fn.delete(file)
  end)

  it('skips non-modifiable buffers before quit flows', function()
    vim.cmd('enew')
    local buffer = vim.api.nvim_get_current_buf()
    local commands = {}
    local original_cmd = vim.cmd

    vim.bo[buffer].modifiable = false
    vim.cmd = function(command)
      table.insert(commands, command)
    end

    local ok, wrote = pcall(editor.update_before_quit)

    vim.cmd = original_cmd

    assert.is_true(ok)
    assert.is_false(wrote)
    assert.are.same({}, commands)

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
