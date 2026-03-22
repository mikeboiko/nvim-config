describe('nvim-config fold helpers', function()
  it('formats markdown fold context from the enclosing fold heading', function()
    local folds = require('config.folds')

    vim.cmd('enew')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      '# Parent {{{1',
      '## Child {{{2',
      'TODO item',
    })
    vim.bo.filetype = 'markdown'
    vim.bo.commentstring = '# %s'
    vim.opt_local.foldmethod = 'manual'
    vim.opt_local.foldenable = true

    vim.cmd('silent 1,3fold')
    vim.cmd('silent 2,3fold')

    assert.are.equal('| Parent | Parent |', folds.get_fold_strings(3))
    assert.are.equal(' Parent |$}{$', folds.get_last_fold_string(3))

    vim.cmd('bwipe!')
  end)

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

  it('FindLocal opens the matching fold and populates the location list', function()
    require('config.commands')

    vim.cmd('enew')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      '# Parent {{{1',
      '## Child {{{2',
      'TODO item',
      'other line',
    })
    vim.bo.filetype = 'markdown'
    vim.bo.commentstring = '# %s'
    vim.opt_local.foldmethod = 'manual'
    vim.opt_local.foldenable = true

    vim.cmd('silent 1,4fold')
    vim.cmd('silent 2,3fold')
    vim.cmd('silent 1foldclose')
    vim.cmd('silent 2foldclose')

    local main_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_cursor(main_win, { 1, 0 })

    vim.cmd('silent FindLocal TODO')

    local loc = vim.api.nvim_win_call(main_win, function()
      return vim.fn.getloclist(0, { items = 0, winid = 0 })
    end)
    local cursor = vim.api.nvim_win_call(main_win, function()
      return vim.api.nvim_win_get_cursor(0)
    end)
    local fold_state = vim.api.nvim_win_call(main_win, function()
      return vim.fn.foldclosed(2)
    end)

    assert.are.equal(3, cursor[1])
    assert.are.equal(-1, fold_state)
    assert.is_true(loc.winid ~= 0)
    assert.are.equal(1, #loc.items)
    assert.are.equal(3, loc.items[1].lnum)
    assert.is_true(loc.items[1].text:find('Parent', 1, true) ~= nil)
    assert.is_true(loc.items[1].text:find('TODO item', 1, true) ~= nil)

    vim.api.nvim_win_call(main_win, function()
      vim.cmd('lclose')
    end)
    vim.cmd('bwipe!')
  end)
end)
