describe('nvim-config clipboard helpers', function()
  local clipboard

  before_each(function()
    clipboard = require('config.clipboard')
  end)

  it('pastes clipboard text below the current line', function()
    local original_targets = clipboard.clipboard_targets
    local original_register = vim.fn.getreg('+')
    local original_register_type = vim.fn.getregtype('+')

    require('config.commands')

    clipboard.clipboard_targets = function()
      return {}
    end

    vim.cmd('enew')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'current line' })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.fn.setreg('+', 'clipboard text')

    clipboard.paste_clipboard()

    assert.are.same({ 'current line', 'clipboard text' }, vim.api.nvim_buf_get_lines(0, 0, -1, false))

    vim.fn.setreg('+', original_register, original_register_type)
    clipboard.clipboard_targets = original_targets
    vim.cmd('bwipe!')
  end)

  it('delegates image clipboard pastes to the markdown image helper', function()
    local original_targets = clipboard.clipboard_targets
    local original_markdown_clipboard_image = clipboard.markdown_clipboard_image
    local called = 0

    clipboard.clipboard_targets = function()
      return { 'application/x-qt-image' }
    end

    clipboard.markdown_clipboard_image = function()
      called = called + 1
    end

    assert.are.equal('image', clipboard.paste_clipboard())
    assert.are.equal(1, called)

    clipboard.clipboard_targets = original_targets
    clipboard.markdown_clipboard_image = original_markdown_clipboard_image
  end)

  it('copies the current file path and directory into the clipboard register', function()
    local original_register = vim.fn.getreg('+')
    local original_register_type = vim.fn.getregtype('+')
    local file = vim.fn.tempname() .. '.txt'

    vim.cmd('edit ' .. vim.fn.fnameescape(file))

    assert.are.equal(vim.fn.fnamemodify(file, ':p:~'), clipboard.copy_current_file_path())
    assert.are.equal(vim.fn.fnamemodify(file, ':p:~'), vim.fn.getreg('+'))

    assert.are.equal(vim.fn.fnamemodify(file, ':p:~:h'), clipboard.copy_current_file_dir())
    assert.are.equal(vim.fn.fnamemodify(file, ':p:~:h'), vim.fn.getreg('+'))

    vim.fn.setreg('+', original_register, original_register_type)
    vim.cmd('bwipe!')
  end)
end)
