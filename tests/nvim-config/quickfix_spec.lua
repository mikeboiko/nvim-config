describe('nvim-config quickfix helpers', function()
  local function quickfix_items()
    local buf = vim.api.nvim_get_current_buf()
    return {
      { bufnr = buf, lnum = 1, col = 1, text = 'first quickfix item' },
      { bufnr = buf, lnum = 1, col = 1, text = 'second quickfix item' },
    }
  end

  local function location_items()
    local buf = vim.api.nvim_get_current_buf()
    return {
      { bufnr = buf, lnum = 1, col = 1, text = 'first location item' },
      { bufnr = buf, lnum = 1, col = 1, text = 'second location item' },
    }
  end

  it('keeps the legacy ToggleList() entrypoint working for quickfix', function()
    require('config.commands')

    vim.fn.setqflist(quickfix_items(), 'r')

    assert.are.equal(0, vim.fn.getqflist({ winid = 0 }).winid)

    vim.cmd([[call ToggleList('Quickfix List', 'c')]])
    assert.is_true(vim.fn.getqflist({ winid = 0 }).winid ~= 0)

    vim.cmd([[call ToggleList('Quickfix List', 'c')]])
    assert.are.equal(0, vim.fn.getqflist({ winid = 0 }).winid)
  end)

  it('wraps quickfix and location list navigation commands', function()
    require('config.commands')

    vim.fn.setqflist(quickfix_items(), 'r')
    vim.cmd('silent cfirst')
    vim.cmd('silent Cprev')
    assert.are.equal(2, vim.fn.getqflist({ idx = 0 }).idx)
    vim.cmd('silent Cnext')
    assert.are.equal(1, vim.fn.getqflist({ idx = 0 }).idx)

    vim.fn.setloclist(0, location_items(), 'r')
    vim.cmd('silent lfirst')
    vim.cmd('silent Lprev')
    assert.are.equal(2, vim.fn.getloclist(0, { idx = 0 }).idx)
    vim.cmd('silent Lnext')
    assert.are.equal(1, vim.fn.getloclist(0, { idx = 0 }).idx)
  end)

  it('does not open an empty location list', function()
    require('config.quickfix')

    vim.fn.setloclist(0, {}, 'r')

    require('config.quickfix').toggle_list('l')

    assert.are.equal(0, vim.fn.getloclist(0, { winid = 0 }).winid)
  end)
end)
