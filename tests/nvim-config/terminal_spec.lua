describe('nvim-config terminal helpers', function()
  local terminal

  before_each(function()
    terminal = require('config.terminal')
  end)

  it('parses a terminal exit status above trailing blank lines', function()
    vim.cmd('enew')
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(buf, 'term://test/flow')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      'running command',
      '[Process exited 0]',
      '',
      '',
    })

    assert.are.equal(0, terminal.get_exit_status(buf))

    vim.cmd('bwipe!')
  end)

  it('falls back to terminal channel exit metadata when no marker line is present', function()
    vim.cmd('enew')
    local buf = vim.api.nvim_get_current_buf()
    local original_get_chan_info = vim.api.nvim_get_chan_info

    vim.api.nvim_buf_set_name(buf, 'term://test/flow')
    vim.api.nvim_buf_set_var(buf, 'terminal_job_id', 42)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      'running command',
      '',
      '',
    })

    vim.api.nvim_get_chan_info = function(channel)
      assert.are.equal(42, channel)
      return { exitcode = 7 }
    end

    local ok, exit_code = pcall(terminal.get_exit_status, buf)
    vim.api.nvim_get_chan_info = original_get_chan_info

    assert.is_true(ok)
    assert.are.equal(7, exit_code)
    vim.cmd('bwipe!')
  end)

  it('auto-closes a flow terminal when CloseToggle is enabled and the exit code is zero', function()
    vim.cmd('enew')
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(buf, 'term://test//tmp/flow')
    vim.api.nvim_buf_set_var(buf, 'nvim_flow_terminal', 1)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      'running command',
      '[Process exited 0]',
      '',
    })

    vim.g.term_close = '++close'
    terminal.on_term_close(buf)

    assert.is_true(vim.wait(200, function()
      return not vim.api.nvim_buf_is_valid(buf)
    end))

    vim.g.term_close = ''
  end)

  it('auto-closes a gap terminal with a zero exit code', function()
    vim.cmd('enew')
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(buf, 'term://test/' .. vim.fn.expand('~/git/Linux/git/gap'))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      'running gap',
      '[Process exited 0]',
      '',
    })

    terminal.on_term_close(buf)

    assert.is_true(vim.wait(200, function()
      return not vim.api.nvim_buf_is_valid(buf)
    end))
  end)

  it('keeps a flow terminal buffer when the exit code is non-zero', function()
    vim.cmd('enew')
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(buf, 'term://test//tmp/flow')
    vim.api.nvim_buf_set_var(buf, 'nvim_flow_terminal', 1)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      'running command',
      '[Process exited 1]',
      '',
    })

    vim.g.term_close = '++close'
    terminal.on_term_close(buf)

    assert.is_false(vim.wait(80, function()
      return not vim.api.nvim_buf_is_valid(buf)
    end))
    assert.is_true(vim.api.nvim_buf_is_valid(buf))

    vim.g.term_close = ''
    vim.cmd('bwipe!')
  end)
end)
