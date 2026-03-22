local M = {}

function M.open_current_fold()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local ok = pcall(vim.cmd, 'silent foldopen!')

  if not ok then
    vim.api.nvim_win_set_cursor(0, cursor)
  end
end

return M
