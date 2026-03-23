describe('nvim-config shell helpers', function()
  local git
  local shell

  before_each(function()
    git = require('config.git')
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

  it('prefills grep prompts for filetype, notes, repo, and current file searches', function()
    local original_prefill_grep = shell.prefill_grep
    local original_get_git_root = shell.get_git_root
    local calls = {}

    shell.prefill_grep = function(args, cursor_keys)
      table.insert(calls, { args = args, cursor_keys = cursor_keys })
    end

    shell.get_git_root = function()
      return '/tmp/repo'
    end

    vim.bo.filetype = 'lua'

    shell.prefill_grep_for_filetype()
    shell.prefill_grep_for_notes()
    shell.prefill_grep_for_git_repo()
    shell.prefill_grep_for_current_file()

    assert.are.same({
      { args = '--lua ~/git', cursor_keys = '<S-Left><Space><Left>' },
      { args = '--md ~/git', cursor_keys = '<S-Left><Space><Left>' },
      { args = '"/tmp/repo"', cursor_keys = '<Home><S-Right><Space>' },
      { args = '%', cursor_keys = '<Home><S-Right><Space>' },
    }, calls)

    shell.prefill_grep = original_prefill_grep
    shell.get_git_root = original_get_git_root
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

  it('looks up the current git root through the shared helper', function()
    local original_systemlist = git.systemlist
    local original_notify = shell.notify
    local messages = {}

    git.systemlist = function(command)
      assert.are.equal('git rev-parse --show-toplevel', command)
      return { '/tmp/example-repo' }
    end

    shell.notify = function(message, level)
      table.insert(messages, { message = message, level = level })
    end

    assert.are.equal('/tmp/example-repo', shell.get_git_root())
    assert.are.same({}, messages)

    git.systemlist = original_systemlist
    shell.notify = original_notify
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

  it('wraps the current-word grep and mani shortcut helpers', function()
    local original_get_git_root = shell.get_git_root
    local original_get_current_word = shell.get_current_word
    local original_grep = shell.grep
    local original_mani = shell.mani
    local grep_calls = {}
    local mani_calls = {}

    shell.get_git_root = function()
      return '/tmp/repo'
    end

    shell.get_current_word = function()
      return 'needle'
    end

    shell.grep = function(args)
      table.insert(grep_calls, args)
    end

    shell.mani = function(args)
      table.insert(mani_calls, args)
    end

    assert.is_true(shell.grep_current_word_in_git_repo())
    shell.grep_current_word_in_current_file()
    shell.mani_git_status()
    shell.mani_git_up()

    assert.are.same({
      'needle "/tmp/repo"',
      'needle %',
    }, grep_calls)
    assert.are.same({
      [[run git-status --parallel --tags-expr '$MANI_EXPR']],
      [[run git-up --parallel --tags-expr '$MANI_EXPR']],
    }, mani_calls)

    shell.get_git_root = original_get_git_root
    shell.get_current_word = original_get_current_word
    shell.grep = original_grep
    shell.mani = original_mani
  end)

  it('runs external workflow helpers with the expected commands', function()
    local original_run_ex = shell.run_ex
    local calls = {}

    shell.run_ex = function(command)
      table.insert(calls, command)
    end

    shell.open_git_diff_in_terminal()
    shell.open_explorer()
    shell.open_markdown_preview()
    shell.open_tables_report()
    shell.open_weather_report()

    assert.are.same({
      'terminal git --no-pager diff',
      'silent !explorer.exe .',
      'redraw!',
      'MarkdownPreview',
      'tabe term://' .. shell.tables_report_command,
      '$',
      'tabe term://curl ' .. shell.weather_report_url,
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
