local M = {}

M.systemlist = vim.fn.systemlist
M.system = vim.fn.system

function M.get_root()
  local git_root = M.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 or not git_root or git_root == '' then
    return nil
  end

  return git_root
end

function M.add_all(git_root)
  local root = git_root or M.get_root()
  if not root then
    return false, 'Not in a git repository'
  end

  local output = M.system('git -C ' .. vim.fn.shellescape(root) .. ' add -A')
  if vim.v.shell_error ~= 0 then
    local message = vim.trim(output)
    if message == '' then
      message = 'git add -A failed'
    end

    return false, message
  end

  return true, root
end

function M.get_repo_name()
  local git_root = M.get_root()
  if not git_root then
    return nil
  end

  return vim.fn.fnamemodify(git_root, ':t')
end

return M
