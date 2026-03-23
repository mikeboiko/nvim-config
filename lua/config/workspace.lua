local M = {}

local todo_wildignore_patterns = { '*.jpg', '*.docx', '*.xlsm', '*.mp4' }

function M.run_ex(command)
  vim.cmd(command)
end

function M.edit_common_file(filename)
  M.run_ex('silent tabedit ' .. vim.fn.fnameescape(filename))
end

function M.get_buffer_list()
  return vim.api.nvim_exec2('silent! ls!', { output = true }).output
end

function M.get_todos()
  local original_wildignore = vim.opt.wildignore:get()

  vim.opt.wildignore:append(todo_wildignore_patterns)

  local ok, result = xpcall(function()
    M.run_ex([[vimgrep /TODO-MB \[\d\{6}]/ **/* **/.* | cw 5]])
  end, debug.traceback)

  vim.opt.wildignore = original_wildignore

  if not ok then
    error(result)
  end
end

return M
