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

  it('inserts figlet output as commented lines below the cursor', function()
    local original_figlet_lines = shell.figlet_lines

    shell.figlet_lines = function(text)
      assert.are.equal('Hello', text)
      return { 'AA', 'BB' }
    end

    vim.cmd('enew')
    vim.bo.filetype = 'lua'
    vim.bo.commentstring = '-- %s'
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'seed' })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    shell.figlet('Hello')

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

  it('notifies when repo-scoped grep helpers are used outside a git repository', function()
    local original_notify = shell.notify
    local original_get_git_root = shell.get_git_root
    local messages = {}

    shell.notify = function(message, level)
      table.insert(messages, { message = message, level = level })
    end

    shell.get_git_root = function()
      shell.notify('Not in a git repository', vim.log.levels.ERROR)
      return nil
    end

    assert.is_false(shell.prefill_grep_for_git_repo())
    assert.is_false(shell.grep_current_word_in_git_repo())
    assert.are.same({
      { message = 'Not in a git repository', level = vim.log.levels.ERROR },
      { message = 'Not in a git repository', level = vim.log.levels.ERROR },
    }, messages)

    shell.notify = original_notify
    shell.get_git_root = original_get_git_root
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
