local clipboard = require('config.clipboard')
local comments = require('config.comments')
local editor = require('config.editor')
local folds = require('config.folds')
local quickfix = require('config.quickfix')
local shell = require('config.shell')

function _G.set_terminal_keymaps()
  vim.keymap.set('t', '<C-j>', '<C-W>j')
  vim.keymap.set('t', '<C-k>', '<C-W>k')
  vim.keymap.set('t', '<C-h>', '<C-W>h')
  vim.keymap.set('t', '<C-l>', '<C-W>l')
  -- local opts = { noremap = true }
  -- vim.api.nvim_buf_set_keymap(0, 't', '<Esc>', [[<C-\><C-n>]], opts)
  -- vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
end

local function delete_keymap_if_present(mode, lhs)
  if vim.fn.maparg(lhs, mode) ~= '' then
    vim.keymap.del(mode, lhs)
  end
end

-- General
vim.keymap.set('n', '<leader>nh', ':lua Snacks.notifier.show_history()<CR>', { desc = 'Show Notification History' })

-- Git: Add all changes, commit, and push
vim.keymap.set('n', '<leader>gap', function()
  vim.cmd('wa')
  require('config.functions').git_add_commit_push()
end, { silent = true, desc = 'Git add/commit/push (gap)' })

-- Git: AI-generated commit message
vim.keymap.set('n', '<leader>ag', function()
  local git_dir = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    vim.notify('Not in a git repository', vim.log.levels.ERROR)
    return
  end
  vim.fn.system('git -C ' .. git_dir .. ' add -A')
  vim.g.CopilotCommitMsg(git_dir)
end, { silent = true, desc = 'AI-generated commit message (ag)' })

-- Delete keymaps
delete_keymap_if_present('n', '<C-W><C-D>')
delete_keymap_if_present('n', '<C-W>d')

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

vim.keymap.set('i', '<C-q>', function()
  vim.cmd('stopinsert')
  vim.cmd('update')
  editor.quit()
end, { silent = true, desc = 'Save and quit current window' })

vim.keymap.set('n', '<C-q>', function()
  vim.cmd('update')
  editor.quit()
end, { silent = true, desc = 'Save and quit current window' })

vim.keymap.set('n', '<C-w>', function()
  editor.quit()
end, { silent = true, desc = 'Quit current window' })

vim.keymap.set('n', 'qq', function()
  editor.quit()
end, { silent = true, desc = 'Quit current window' })

-- Add empty comment above current line
vim.keymap.set('n', 'co', function()
  local comment_string = comments.get_commentstring()
  comment_string = comment_string:gsub('%%s', '')
  local current_line = vim.api.nvim_get_current_line()
  local indent = current_line:match('^%s+') or ''
  local line = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, line - 1, line - 1, false, { indent .. comment_string })
  vim.cmd('normal! k$')
  vim.cmd('startinsert!')
end, { desc = 'Add empty comment above' })

vim.keymap.set('n', 'cii', function()
  comments.prompt_and_comment(true, 'Comment Text: ', '')
end, { silent = true, desc = 'Insert inline comment from prompt' })

vim.keymap.set('n', 'ci1', function()
  comments.insert_inline_comment('1')
end, { silent = true, desc = 'Insert inline fold marker 1' })

vim.keymap.set('n', 'ci2', function()
  comments.insert_inline_comment('2')
end, { silent = true, desc = 'Insert inline fold marker 2' })

vim.keymap.set('n', 'ci3', function()
  comments.insert_inline_comment('3')
end, { silent = true, desc = 'Insert inline fold marker 3' })

vim.keymap.set('n', 'ci4', function()
  comments.insert_inline_comment('4')
end, { silent = true, desc = 'Insert inline fold marker 4' })

vim.keymap.set('n', 'cy', function()
  comments.comment_yank()
end, { silent = true, desc = 'Insert commented copy above current line' })

vim.keymap.set('n', '<C-v>', function()
  clipboard.paste_clipboard()
end, { silent = true, desc = 'Paste clipboard below current line' })

vim.keymap.set('i', '<C-v>', '<C-r>+', { desc = 'Paste clipboard register' })
vim.keymap.set('c', '<C-v>', '<C-r>+', { desc = 'Paste clipboard register' })

vim.keymap.set('n', '<leader>st', function()
  editor.toggle_spell()
end, { silent = true, desc = 'Toggle spell check' })

vim.keymap.set('n', '<leader>ms', function()
  shell.mani_git_status()
end, { silent = true, desc = 'Mani git status' })

vim.keymap.set('n', '<leader>mu', function()
  shell.mani_git_up()
end, { silent = true, desc = 'Mani git up' })

vim.keymap.set('n', '<leader>fc', function()
  shell.prefill_grep_for_filetype()
end, { silent = true, desc = 'Prefill grep for current filetype in ~/git' })

vim.keymap.set('n', '<leader>fn', function()
  shell.prefill_grep_for_notes()
end, { silent = true, desc = 'Prefill grep for notes in ~/git' })

vim.keymap.set('n', '<leader>fg', function()
  shell.prefill_grep_for_git_repo()
end, { silent = true, desc = 'Prefill grep for current git repo' })

vim.keymap.set('n', '<leader>gw', function()
  shell.grep_current_word_in_git_repo()
end, { silent = true, desc = 'Grep current word in current git repo' })

vim.keymap.set('n', '<leader>fl', function()
  shell.prefill_grep_for_current_file()
end, { silent = true, desc = 'Prefill grep for current file' })

vim.keymap.set('n', '<leader>fw', function()
  shell.grep_current_word_in_current_file()
end, { silent = true, desc = 'Grep current word in current file' })

-- Quickfix/location list helpers
vim.keymap.set('n', '<leader>q', function()
  quickfix.toggle_list('c')
end, { silent = true, desc = 'Toggle quickfix list' })

vim.keymap.set('n', '<C-f>', function()
  quickfix.cycle('c', 'next')
  folds.open_current_fold()
end, { silent = true, desc = 'Quickfix next' })

vim.keymap.set('n', '<C-d>', function()
  quickfix.cycle('c', 'prev')
  folds.open_current_fold()
end, { silent = true, desc = 'Quickfix previous' })

-- Fix standard Ctrl-i mapping. Not sure which of my plugins is breaking it.
vim.keymap.set('n', '<C-i>', '<C-i>')
