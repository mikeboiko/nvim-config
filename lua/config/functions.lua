local M = {}

local function get_visual_selection()
  local bufnr = vim.api.nvim_get_current_buf()
  local start_pos = vim.api.nvim_buf_get_mark(bufnr, '<')
  local end_pos = vim.api.nvim_buf_get_mark(bufnr, '>')
  local line = vim.api.nvim_buf_get_lines(bufnr, start_pos[1] - 1, start_pos[1], false)[1]
  local selection = string.sub(line, start_pos[2] + 1, end_pos[2] + 1)
  return selection
end

vim.api.nvim_create_user_command('EchoSelection', get_visual_selection, { range = true })

function M.cdo(new, original)
  local cmd = string.format(':silent cdo s/%s/%s/g | update', original, new)
  vim.cmd(cmd)
end

function M.rename_word(new, original)
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  for i, line in ipairs(lines) do
    lines[i] = line:gsub(original, new)
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

function M.fancy_prompt_rename(func, prompt, visual)
  local original
  if visual then
    original = get_visual_selection()
  else
    original = vim.fn.expand('<cword>')
  end
  vim.ui.input({ prompt = prompt, default = original }, function(query)
    if query == nil then
      return
    end
    func(query, original)
  end)
end

-- Function to find repository root (e.g., where .git is)
function M.get_repo_root()
  local git = require('config.git')
  local root = git.get_root()
  if root then
    return root
  end
  return vim.fn.getcwd()
end

-- Function to find DLL file in repo root
function M.find_dotnet_dll()
  local repo_root = M.get_repo_root()
  local repo_name = vim.fn.fnamemodify(repo_root, ':t')
  local dll_pattern = repo_name .. '.dll'
  local dll_path = vim.fs.find(dll_pattern, { path = repo_root, type = 'file', limit = 1 })[1]
  return dll_path
end

-- Git: add all, commit, and push
function M.git_add_commit_push()
  local prev_win = vim.api.nvim_get_current_win()
  vim.cmd('split')
  local gap = vim.fn.expand('~/git/Linux/git/gap')
  vim.cmd('terminal bash ' .. vim.fn.fnameescape(gap))
  local term_win = vim.api.nvim_get_current_win()
  local term_buf = vim.api.nvim_get_current_buf()
  vim.cmd('startinsert')
  vim.api.nvim_create_autocmd('BufEnter', {
    buffer = term_buf,
    callback = function()
      if vim.api.nvim_get_current_win() == term_win then
        vim.cmd('startinsert')
      end
    end,
  })
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(prev_win) then
      vim.api.nvim_set_current_win(prev_win)
      vim.cmd('stopinsert')
    end
  end, 20)
end

return M
