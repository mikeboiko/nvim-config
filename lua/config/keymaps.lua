function _G.set_terminal_keymaps()
  vim.keymap.set('t', '<C-j>', '<C-W>j')
  vim.keymap.set('t', '<C-k>', '<C-W>k')
  vim.keymap.set('t', '<C-h>', '<C-W>h')
  vim.keymap.set('t', '<C-l>', '<C-W>l')
  -- local opts = { noremap = true }
  -- vim.api.nvim_buf_set_keymap(0, 't', '<Esc>', [[<C-\><C-n>]], opts)
  -- vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
end

-- General
vim.keymap.set('n', '<leader>nh', ':lua Snacks.notifier.show_history()<CR>', { desc = 'Show Notification History' })

-- Delete keymaps
vim.keymap.del('n', '<C-W><C-D>')
vim.keymap.del('n', '<C-W>d')

-- Resize window using <ctrl> arrow keys
vim.keymap.set('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
vim.keymap.set('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

-- Close current tab with 'qt' keymap
vim.keymap.set('n', 'qt', function()
  if vim.fn.tabpagenr('$') == 1 then
    vim.cmd('quit')
  else
    vim.cmd('tabclose')
  end
end, { silent = true })

-- Add empty comment above current line
vim.keymap.set('n', 'co', function()
  local comment_string = require('ts_context_commentstring').calculate_commentstring()
  if comment_string == nil then
    comment_string = vim.bo.commentstring
  end
  comment_string = comment_string:gsub('%%s', '')
  local current_line = vim.api.nvim_get_current_line()
  local indent = current_line:match('^%s+') or ''
  local line = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, line - 1, line - 1, false, { indent .. comment_string })
  vim.cmd('normal! k$')
  vim.cmd('startinsert!')
end, { desc = 'Add empty comment above' })

-- Run Script in terminal with vim-flow
-- Create an autogroup for buffer-specific mappings
local flow_group = vim.api.nvim_create_augroup('FlowMappings', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = flow_group,
  pattern = { '*' },
  callback = function()
    -- Only set mapping for normal buffers
    if vim.bo.buftype == '' then
      vim.keymap.set('n', '<CR>', function()
        vim.cmd('wa')
        vim.cmd('call CloseAll()')
        vim.cmd('FlowRun')
        vim.cmd('$')
        vim.cmd('wincmd j')
      end, { buffer = true, silent = true })
    end
  end,
})
