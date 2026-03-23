local M = {}

function M.get_commentstring()
  local commentstring
  local ok, ts_context_commentstring = pcall(require, 'ts_context_commentstring')

  if ok then
    commentstring = ts_context_commentstring.calculate_commentstring()
  end

  if commentstring == nil or commentstring == vim.NIL then
    commentstring = vim.bo.commentstring
  end

  return commentstring
end

function M.toggle_comment_lines(line_start, line_end)
  require('mini.comment').toggle_lines(line_start, line_end)
end

function M.user_input(prompt)
  vim.fn.inputsave()
  local reply = vim.fn.input(prompt)
  vim.fn.inputrestore()
  return reply
end

local function render_comment(text)
  return M.get_commentstring():gsub('%%s', function()
    return text
  end)
end

local function with_autopairs_disabled(callback)
  local has_autopairs, original_state = pcall(vim.api.nvim_buf_get_var, 0, 'autopairs_enabled')

  if has_autopairs then
    vim.api.nvim_buf_set_var(0, 'autopairs_enabled', 0)
  end

  local ok, result = xpcall(callback, debug.traceback)

  if has_autopairs then
    vim.api.nvim_buf_set_var(0, 'autopairs_enabled', original_state)
  end

  if not ok then
    error(result)
  end

  return result
end

function M.insert_inline_comment(fold_marker)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local comment = render_comment((vim.g.fold_marker_string or '{{{') .. tostring(fold_marker))

  vim.api.nvim_set_current_line(line .. ' ' .. comment)
  vim.api.nvim_win_set_cursor(0, { cursor[1], #vim.api.nvim_get_current_line() })
end

function M.comment_yank()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line():gsub('\n$', '')

  vim.api.nvim_buf_set_lines(0, cursor[1] - 1, cursor[1] - 1, false, { line })
  M.toggle_comment_lines(cursor[1], cursor[1])
  vim.api.nvim_win_set_cursor(0, { cursor[1] + 1, cursor[2] })
end

function M.prompt_and_comment(inline_comment, prompt_text, comment_prefix)
  local prompt = M.user_input(prompt_text)
  if prompt == nil or prompt == '' then
    return false
  end

  local comment = render_comment((comment_prefix or '') .. prompt)

  with_autopairs_disabled(function()
    if inline_comment then
      local cursor = vim.api.nvim_win_get_cursor(0)
      local line = vim.api.nvim_get_current_line()
      vim.api.nvim_set_current_line(line .. ' ' .. comment)
      vim.api.nvim_win_set_cursor(0, { cursor[1], #vim.api.nvim_get_current_line() })
      return
    end

    local current_line = vim.api.nvim_get_current_line()
    local indent = current_line:match('^%s*') or ''
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local commented_line = indent .. comment

    vim.api.nvim_buf_set_lines(0, row, row, false, { commented_line })
    vim.api.nvim_win_set_cursor(0, { row + 1, #commented_line })
  end)

  return true
end

local function todo_prompt(cb)
  local input = require('snacks.input')
  input({
    win = {
      relative = 'cursor',
      row = -3,
      col = 0,
    },
  }, function(text)
    if text and text ~= '' then
      local todo = string.format('TODO: %s', text)
      if cb then
        cb(todo)
      end
    end
  end)
end

vim.api.nvim_create_user_command('TodoPrompt', function()
  todo_prompt(function(todo)
    local line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
    local current_line = vim.api.nvim_get_current_line()
    local indent = current_line:match('^%s+') or ''
    vim.api.nvim_buf_set_lines(0, line_nr, line_nr, false, { indent .. todo })
    M.toggle_comment_lines(line_nr + 1, line_nr + 1)
  end)
end, {})

M.todo_prompt = todo_prompt

return M
