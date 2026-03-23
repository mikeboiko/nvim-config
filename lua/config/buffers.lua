local M = {}

function M.is_valid(buf)
  return vim.api.nvim_buf_is_valid(buf)
end

function M.get_name(buf)
  if not M.is_valid(buf) then
    return ''
  end

  return vim.api.nvim_buf_get_name(buf)
end

function M.get_var(buf, name, default)
  local ok, value = pcall(vim.api.nvim_buf_get_var, buf, name)
  if ok then
    return value
  end

  return default
end

function M.collect(predicate)
  local matched = {}

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if M.is_valid(buf) and predicate(buf) then
      table.insert(matched, buf)
    end
  end

  return matched
end

function M.delete(buf, opts)
  if not M.is_valid(buf) then
    return false
  end

  opts = opts or {}
  return pcall(vim.api.nvim_buf_delete, buf, { force = opts.force or false })
end

function M.restore_last_position()
  local mark = vim.api.nvim_buf_get_mark(0, '"')
  local line = mark[1]

  if line <= 0 or line > vim.api.nvim_buf_line_count(0) then
    return false
  end

  pcall(vim.api.nvim_win_set_cursor, 0, { line, mark[2] })
  return true
end

function M.remove_auto_comment_formatoptions()
  vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
end

function M.set_preview_window_options()
  if vim.wo.previewwindow then
    vim.opt_local.foldmethod = 'manual'
    return true
  end

  return false
end

function M.set_commit_buffer_defaults()
  vim.opt_local.spell = true
  pcall(vim.api.nvim_win_set_cursor, 0, { 1, 0 })
end

function M.set_nowrap()
  vim.opt_local.wrap = false
end

function M.set_two_space_indent()
  vim.opt_local.tabstop = 2
  vim.opt_local.shiftwidth = 2
  vim.opt_local.softtabstop = 2
end

return M
