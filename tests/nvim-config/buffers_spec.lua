describe('nvim-config buffer helpers', function()
  local buffers

  before_each(function()
    buffers = require('config.buffers')
  end)

  local function write_file(path, contents)
    local file = assert(io.open(path, 'w'))
    file:write(contents)
    file:close()
  end

  local function wipe_current_buffer()
    local buffer = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_valid(buffer) then
      vim.api.nvim_buf_delete(buffer, { force = true })
    end
  end

  it('restores the last cursor position from the quote mark when it is in range', function()
    vim.cmd('enew')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'one', 'two', 'three' })
    vim.api.nvim_buf_set_mark(0, '"', 3, 1, {})
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    assert.is_true(buffers.restore_last_position())
    assert.are.same({ 3, 1 }, vim.api.nvim_win_get_cursor(0))

    wipe_current_buffer()
  end)

  it('removes automatic comment continuation flags from formatoptions', function()
    vim.cmd('enew')
    vim.bo.formatoptions = 'croql'

    buffers.remove_auto_comment_formatoptions()

    local formatoptions = vim.bo.formatoptions
    assert.is_false(formatoptions:find('c', 1, true) ~= nil)
    assert.is_false(formatoptions:find('r', 1, true) ~= nil)
    assert.is_false(formatoptions:find('o', 1, true) ~= nil)
    assert.is_true(formatoptions:find('q', 1, true) ~= nil)

    wipe_current_buffer()
  end)

  it('configures preview windows to use manual folds', function()
    vim.cmd('enew')
    vim.cmd('vsplit')

    local preview_win = vim.api.nvim_get_current_win()
    vim.wo.previewwindow = true
    vim.wo.foldmethod = 'expr'

    assert.is_true(buffers.set_preview_window_options())
    assert.are.equal('manual', vim.wo.foldmethod)

    pcall(vim.cmd, 'close')
    wipe_current_buffer()
  end)

  it('applies commit-buffer defaults and two-space filetype settings through Lua autocmds', function()
    package.loaded['config.autocmds'] = nil
    require('config.autocmds')

    vim.cmd('enew')
    vim.bo.formatoptions = 'cro'
    vim.cmd('setfiletype markdown')

    assert.are.equal(2, vim.bo.tabstop)
    assert.are.equal(2, vim.bo.shiftwidth)
    assert.are.equal(2, vim.bo.softtabstop)
    assert.is_false(vim.bo.formatoptions:find('c', 1, true) ~= nil)
    wipe_current_buffer()

    local commit_dir = vim.fn.tempname()
    vim.fn.mkdir(commit_dir, 'p')
    local commit_file = commit_dir .. '/COMMIT_EDITMSG'
    write_file(commit_file, 'line one\nline two\nline three\n')

    vim.cmd('edit ' .. vim.fn.fnameescape(commit_file))
    vim.api.nvim_win_set_cursor(0, { 3, 0 })
    vim.api.nvim_exec_autocmds('BufEnter', { buffer = 0, modeline = false })

    assert.is_true(vim.wo.spell)
    assert.are.same({ 1, 0 }, vim.api.nvim_win_get_cursor(0))

    vim.cmd('bwipe!')
    vim.fn.delete(commit_file)
    vim.fn.delete(commit_dir, 'd')
  end)

  it('disables wrapping for delimited files through Lua autocmds', function()
    package.loaded['config.autocmds'] = nil
    require('config.autocmds')

    local delimited_file = vim.fn.tempname() .. '.psv'
    write_file(delimited_file, 'a|b|c\n')

    vim.cmd('edit ' .. vim.fn.fnameescape(delimited_file))

    assert.is_false(vim.wo.wrap)

    vim.cmd('bwipe!')
    vim.fn.delete(delimited_file)
  end)
end)
