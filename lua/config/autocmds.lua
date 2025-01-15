-- -- Append backup files with timestamp
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   callback = function()
--     local extension = '~' .. vim.fn.strftime('%Y-%m-%d-%H%M%S')
--     vim.o.backupext = extension
--   end,
-- })

local function update_git_repo_name()
  local file = io.popen('git rev-parse --show-toplevel 2> /dev/null')
  if file then
    local output = file:read('*a')
    file:close()
    if output and output ~= '' then
      local repo_name = vim.fn.fnamemodify(output:gsub('\n$', ''), ':t')
      vim.b.git_repo_name = repo_name
    else
      vim.b.git_repo_name = ''
    end
  end
end

vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    update_git_repo_name()
  end,
})

-- Disable search highlighting after moving the cursor
vim.api.nvim_create_autocmd('CursorMoved', {
  group = vim.api.nvim_create_augroup('auto-hlsearch', { clear = true }),
  callback = function()
    if vim.v.hlsearch == 1 and vim.fn.searchcount().exact_match == 0 then
      vim.schedule(function()
        vim.cmd.nohlsearch()
      end)
    end
  end,
})
