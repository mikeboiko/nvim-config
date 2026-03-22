describe('nvim-config fold helpers', function()
  it('keeps FoldOpen from moving the cursor when no fold exists', function()
    require('config.commands')

    vim.cmd('enew')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'alpha', 'beta', 'gamma' })
    vim.opt_local.foldmethod = 'manual'
    vim.opt_local.foldenable = true
    vim.api.nvim_win_set_cursor(0, { 2, 1 })

    assert.has_no.errors(function()
      vim.cmd('silent FoldOpen')
    end)

    assert.are.same({ 2, 1 }, vim.api.nvim_win_get_cursor(0))

    vim.cmd('bwipe!')
  end)

  it('opens the closed fold under the cursor', function()
    require('config.commands')

    vim.cmd('enew')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'alpha', 'beta', 'gamma', 'delta' })
    vim.opt_local.foldmethod = 'manual'
    vim.opt_local.foldenable = true

    vim.cmd('silent 1,3fold')
    vim.cmd('silent 1foldclose')
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    assert.are.equal(1, vim.fn.foldclosed(1))

    vim.cmd('silent FoldOpen')

    assert.are.equal(-1, vim.fn.foldclosed(1))

    vim.cmd('bwipe!')
  end)
end)
