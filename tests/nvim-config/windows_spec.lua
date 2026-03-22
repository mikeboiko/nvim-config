describe('nvim-config window helpers', function()
  it('keeps the legacy :call CloseAll() entrypoint working', function()
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
      vim.cmd('call CloseAll()')
    end)

    assert.are.equal(0, vim.fn.getqflist({ winid = 0 }).winid)
    assert.are.equal(0, vim.fn.getloclist(0, { winid = 0 }).winid)
  end)

  it('deletes flow-managed terminal buffers', function()
    require('config.commands')

    local flow_buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_var(flow_buf, 'nvim_flow_terminal', 1)

    require('config.windows').close_all()

    assert.are.equal(0, vim.fn.buflisted(flow_buf))
  end)
end)
