local M = {}

M.systemlist = vim.fn.systemlist

function M.get_root()
  local git_root = M.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 or not git_root or git_root == '' then
    return nil
  end

  return git_root
end

function M.get_repo_name()
  local git_root = M.get_root()
  if not git_root then
    return nil
  end

  return vim.fn.fnamemodify(git_root, ':t')
end

return M
