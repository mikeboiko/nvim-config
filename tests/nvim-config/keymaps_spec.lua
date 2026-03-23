describe('nvim-config keymap helpers', function()
  local keymaps

  before_each(function()
    package.loaded['config.keymaps'] = nil
    keymaps = require('config.keymaps')
  end)

  it('sets terminal keymaps buffer-locally', function()
    vim.cmd('enew')
    local terminal_buffer = vim.api.nvim_get_current_buf()

    keymaps.set_terminal_keymaps(terminal_buffer)

    local terminal_map = vim.fn.maparg('<C-g>', 't', false, true)
    assert.are.equal('<C-G>', terminal_map.lhs)
    assert.are.equal('<C-W>:tabp<CR>', terminal_map.rhs)
    assert.are.equal(1, terminal_map.buffer)

    vim.cmd('enew')
    local other_map = vim.fn.maparg('<C-g>', 't', false, true)
    assert.is_true(vim.tbl_isempty(other_map))

    vim.cmd('bwipe!')
    vim.api.nvim_buf_delete(terminal_buffer, { force = true })
  end)

  it('opens a tab and jumps to the last insert position for gI', function()
    local file = vim.fn.tempname() .. '.txt'
    local fh = assert(io.open(file, 'w'))
    fh:write('alpha\nbeta\n')
    fh:close()

    vim.cmd('edit ' .. vim.fn.fnameescape(file))
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.cmd('normal! Axyz')
    vim.cmd('stopinsert')
    vim.cmd('normal! gg0')

    vim.cmd('normal gI')

    assert.are.equal(2, vim.fn.tabpagenr('$'))
    assert.are.equal('n', vim.api.nvim_get_mode().mode)
    assert.are.same({ 1, 7 }, vim.api.nvim_win_get_cursor(0))

    vim.cmd('tabonly!')
    vim.cmd('bwipe!')
    vim.fn.delete(file)
  end)
end)
