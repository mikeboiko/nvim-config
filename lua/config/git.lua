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

local function run_git(root, args)
  local command = { 'git', '-C', root }
  vim.list_extend(command, args)

  local output = M.systemlist(command)
  if vim.v.shell_error ~= 0 then
    return nil, string.format('git %s failed with exit code %d', args[1], vim.v.shell_error)
  end

  return output
end

local function pathspecs(args)
  for index, arg in ipairs(args) do
    if arg == '--' then
      local result = {}
      for path_index = index + 1, #args do
        table.insert(result, args[path_index])
      end
      return result
    end
  end

  return {}
end

--- Lists tracked additions and untracked files for the given diff args, as absolute paths.
---@return string[]|nil files
---@return string|nil error_message
function M.list_new_files(args, git_root)
  local root = git_root or M.get_root()
  if not root then
    return nil, 'Not in a git repository'
  end

  local diff_args = args or {}
  local added_files, added_error = run_git(
    root,
    vim.list_extend({
      'diff',
      '--no-color',
      '--diff-filter=A',
      '--name-only',
    }, diff_args)
  )
  if not added_files then
    return nil, added_error
  end

  local untracked_command = { 'ls-files', '--others', '--exclude-standard' }
  local explicit_pathspecs = pathspecs(diff_args)
  if #explicit_pathspecs > 0 then
    table.insert(untracked_command, '--')
    vim.list_extend(untracked_command, explicit_pathspecs)
  end

  local untracked_files, untracked_error = run_git(root, untracked_command)
  if not untracked_files then
    return nil, untracked_error
  end

  local files = {}
  local seen = {}
  for _, file in ipairs(vim.list_extend(added_files, untracked_files)) do
    if file ~= '' and not seen[file] then
      seen[file] = true
      table.insert(files, root .. '/' .. file)
    end
  end

  return files
end

return M
