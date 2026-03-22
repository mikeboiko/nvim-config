describe('nvim-config shell helpers', function()
  local shell

  before_each(function()
    shell = require('config.shell')
  end)

  local function wipe_current_buffer()
    local buffer = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_valid(buffer) then
      vim.api.nvim_buf_delete(buffer, { force = true })
    end
  end

  it('keeps the legacy Figlet() entrypoint working and comments inserted lines', function()
    local original_figlet_lines = shell.figlet_lines

    require('config.commands')

    shell.figlet_lines = function(text)
      assert.are.equal('Hello', text)
      return { 'AA', 'BB' }
    end

    vim.cmd('enew')
    vim.bo.filetype = 'lua'
    vim.bo.commentstring = '-- %s'
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'seed' })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    vim.cmd([[call Figlet('Hello')]])

    assert.are.same({ 'seed', '-- AA', '-- BB' }, vim.api.nvim_buf_get_lines(0, 0, -1, false))

    shell.figlet_lines = original_figlet_lines
    wipe_current_buffer()
  end)

  it('runs grep with the existing ignore flags and opens quickfix', function()
    local original_run_ex = shell.run_ex
    local calls = {}

    shell.run_ex = function(command)
      table.insert(calls, command)
    end

    shell.grep('--lua ~/git')

    assert.are.same({
      'silent grep! --ignore node_modules --follow --lua ~/git',
      'copen',
    }, calls)

    shell.run_ex = original_run_ex
  end)

  it('swallows replace-M command errors while preserving the exact ex commands', function()
    local original_run_ex = shell.run_ex
    local calls = {}

    shell.run_ex = function(command)
      table.insert(calls, command)
      error('no matches')
    end

    assert.has_no.errors(function()
      shell.replace_m_with_blank()
      shell.replace_m_with_newline()
    end)

    assert.are.same({
      [[%s/\r$//]],
      [[%s/\r/\r/]],
    }, calls)

    shell.run_ex = original_run_ex
  end)

  it('opens mani in a terminal split with the configured mani file', function()
    local original_run_ex = shell.run_ex
    local calls = {}

    shell.run_ex = function(command)
      table.insert(calls, command)
    end

    shell.mani([[run git-status --parallel --tags-expr '$MANI_EXPR']])

    assert.are.same({
      'sp term://mani -c ' .. shell.mani_config .. [[ run git-status --parallel --tags-expr '$MANI_EXPR']],
    }, calls)

    shell.run_ex = original_run_ex
  end)

  it('starts an async job and reports its exit code', function()
    local original_jobstart = shell.jobstart
    local original_echo = shell.echo
    local seen_command
    local on_exit
    local echoed

    shell.jobstart = function(command, opts)
      seen_command = command
      on_exit = opts.on_exit
      return 12
    end

    shell.echo = function(message)
      echoed = message
    end

    assert.are.equal(12, shell.start_async_neovim('nvim'))
    assert.are.equal('nvim', seen_command)

    on_exit(nil, 3)
    assert.are.equal('command finished with exit status 3', echoed)

    shell.jobstart = original_jobstart
    shell.echo = original_echo
  end)
end)
