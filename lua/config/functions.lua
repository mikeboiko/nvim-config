local function get_visual_selection()
  local bufnr = vim.api.nvim_get_current_buf()
  local start_pos = vim.api.nvim_buf_get_mark(bufnr, '<')
  local end_pos = vim.api.nvim_buf_get_mark(bufnr, '>')
  local line = vim.api.nvim_buf_get_lines(bufnr, start_pos[1] - 1, start_pos[1], false)[1]
  local selection = string.sub(line, start_pos[2] + 1, end_pos[2] + 1)
  return selection
  -- print(selection)
end

vim.api.nvim_create_user_command('EchoSelection', get_visual_selection, { range = true })

vim.g.Cdo = function(new, original)
  local cmd = string.format(':silent cdo s/%s/%s/g | update', original, new)
  vim.cmd(cmd)
  -- vim.api.nvim_echo({ { "New: " .. new .. " Original: " .. original } }, true, {})
end

vim.g.RenameWord = function(new, original)
  -- vim.api.nvim_echo({ { "New: " .. new .. " Original: " .. original } }, true, {})
  local buf = vim.api.nvim_get_current_buf()
  local start = 0
  local finish = -1
  local strict_indexing = false
  local lines = vim.api.nvim_buf_get_lines(buf, start, finish, strict_indexing)

  for i, line in ipairs(lines) do
    lines[i] = line:gsub(original, new)
  end

  vim.api.nvim_buf_set_lines(buf, start, finish, strict_indexing, lines)
end

vim.g.FancyPromptRename = function(func, prompt, visual)
  local original
  if visual then
    original = get_visual_selection()
  else
    original = vim.api.nvim_eval('expand("<cword>")')
  end
  vim.ui.input({ prompt = prompt, default = original }, function(query)
    if query == nil then
      return
    end
    -- vim.g.RenameWord(query, original)
    vim.g[func](query, original)
  end)
end

-- Note, this function has an issue with wshada.
-- I'm not using it right now, but will keep it here for reference.
vim.api.nvim_create_user_command('FilterAndSaveOldfiles', function()
  print('Initial v:oldfiles: ' .. vim.inspect(vim.v.oldfiles))
  local oldfiles = vim.v.oldfiles
  if oldfiles == nil then
    print('Warning: vim.v.oldfiles was nil at the start.')
    oldfiles = {}
  end

  local filtered_oldfiles = {}
  for _, file_path in ipairs(oldfiles) do
    if file_path:sub(1, #'/mnt/') ~= '/mnt/' then
      table.insert(filtered_oldfiles, file_path)
    end
  end
  print('Filtered oldfiles (Lua table to be set): ' .. vim.inspect(filtered_oldfiles))

  vim.v.oldfiles = filtered_oldfiles
  print('v:oldfiles after Lua assignment: ' .. vim.inspect(vim.v.oldfiles))

  vim.cmd('wshada!')
  print('Executed wshada! Removed /mnt/ from oldfiles. Check :messages for any errors.')
end, { nargs = 0 })
