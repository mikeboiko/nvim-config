describe('nvim-config comment helpers', function()
  local comments

  before_each(function()
    comments = require('config.comments')
  end)

  it('keeps the legacy InsertInlineComment() entrypoint working', function()
    require('config.commands')

    vim.cmd('enew')
    vim.bo.filetype = 'lua'
    vim.bo.commentstring = '-- %s'
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'local value = 1' })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    vim.cmd([[call InsertInlineComment('2')]])

    assert.are.same({ 'local value = 1 -- {{{2' }, vim.api.nvim_buf_get_lines(0, 0, -1, false))

    vim.cmd('bwipe!')
  end)

  it('creates a commented copy above the current line and restores the original cursor line', function()
    local original_toggle = comments.toggle_comment_lines

    comments.toggle_comment_lines = function(line_start, line_end)
      assert.are.equal(1, line_start)
      assert.are.equal(1, line_end)

      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      lines[1] = '-- ' .. lines[1]
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end

    vim.cmd('enew')
    vim.bo.filetype = 'lua'
    vim.bo.commentstring = '-- %s'
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'local value = 1', 'next line' })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    comments.comment_yank()

    assert.are.same(
      { '-- local value = 1', 'local value = 1', 'next line' },
      vim.api.nvim_buf_get_lines(0, 0, -1, false)
    )
    assert.are.same({ 2, 0 }, vim.api.nvim_win_get_cursor(0))

    vim.cmd('bwipe!')
    comments.toggle_comment_lines = original_toggle
  end)

  it('prompts for an inline comment and restores autopairs state', function()
    local original_user_input = comments.user_input

    comments.user_input = function(prompt)
      assert.are.equal('Comment Text: ', prompt)
      return 'note'
    end

    vim.cmd('enew')
    vim.bo.filetype = 'lua'
    vim.bo.commentstring = '-- %s'
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'local value = 1' })
    vim.api.nvim_buf_set_var(0, 'autopairs_enabled', 1)

    assert.is_true(comments.prompt_and_comment(true, 'Comment Text: ', ''))

    assert.are.same({ 'local value = 1 -- note' }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    assert.are.equal(1, vim.api.nvim_buf_get_var(0, 'autopairs_enabled'))

    vim.cmd('bwipe!')
    comments.user_input = original_user_input
  end)

  it('does nothing when the prompt is cancelled', function()
    local original_user_input = comments.user_input

    comments.user_input = function()
      return ''
    end

    vim.cmd('enew')
    vim.bo.filetype = 'lua'
    vim.bo.commentstring = '-- %s'
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'local value = 1' })

    assert.is_false(comments.prompt_and_comment(true, 'Comment Text: ', ''))
    assert.are.same({ 'local value = 1' }, vim.api.nvim_buf_get_lines(0, 0, -1, false))

    vim.cmd('bwipe!')
    comments.user_input = original_user_input
  end)
end)
