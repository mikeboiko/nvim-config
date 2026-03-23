describe('nvim-config window helpers', function()
  local terminal = require('config.terminal')

  local function wait_for_exit_status(buf, expected_code)
    return vim.wait(500, function()
      local ok, exit_code = pcall(terminal.get_exit_status, buf)
      return ok and exit_code == expected_code
    end)
  end

  it('closes quickfix and location list windows via close_all()', function()
    require('config.commands')

    vim.fn.setqflist({
      { bufnr = vim.api.nvim_get_current_buf(), lnum = 1, col = 1, text = 'quickfix item' },
    })
    vim.cmd('copen')

    vim.fn.setloclist(0, {
      { bufnr = vim.api.nvim_get_current_buf(), lnum = 1, col = 1, text = 'location item' },
    })
    vim.cmd('lopen')

    assert.has_no.errors(function()
      require('config.windows').close_all()
    end)

    assert.are.equal(0, vim.fn.getqflist({ winid = 0 }).winid)
    assert.are.equal(0, vim.fn.getloclist(0, { winid = 0 }).winid)
  end)

  it('keeps running flow-managed terminal buffers', function()
    require('config.commands')

    vim.cmd('terminal sleep 5')
    local flow_buf = vim.api.nvim_get_current_buf()
    local job_id = vim.api.nvim_buf_get_var(flow_buf, 'terminal_job_id')
    vim.api.nvim_buf_set_var(flow_buf, 'nvim_flow_terminal', 1)

    require('config.windows').close_all()

    assert.is_true(vim.api.nvim_buf_is_valid(flow_buf))
    assert.are.equal(1, vim.fn.buflisted(flow_buf))
    assert.are.equal(-1, vim.fn.jobwait({ job_id }, 0)[1])

    vim.fn.jobstop(job_id)
    assert.is_true(vim.wait(500, function()
      return vim.fn.jobwait({ job_id }, 0)[1] ~= -1
    end))
    vim.cmd('enew')
    pcall(vim.api.nvim_buf_delete, flow_buf, { force = true })
  end)

  it('deletes completed flow-managed terminal buffers', function()
    require('config.commands')

    vim.cmd([[terminal sh -c 'exit 0']])
    local flow_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_var(flow_buf, 'nvim_flow_terminal', 1)

    assert.is_true(wait_for_exit_status(flow_buf, 0))

    require('config.windows').close_all()

    assert.is_true(vim.wait(200, function()
      return not vim.api.nvim_buf_is_valid(flow_buf)
    end))
  end)
end)
