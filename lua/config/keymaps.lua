local M = {}

local clipboard = require('config.clipboard')
local comments = require('config.comments')
local editor = require('config.editor')
local folds = require('config.folds')
local quickfix = require('config.quickfix')
local shell = require('config.shell')

function M.set_terminal_keymaps(buffer)
  vim.keymap.set('t', '<C-g>', '<C-W>:tabp<CR>')
  vim.keymap.set('t', '<C-j>', '<C-W>j')
  vim.keymap.set('t', '<C-k>', '<C-W>k')
  vim.keymap.set('t', '<C-h>', '<C-W>h')
  vim.keymap.set('t', '<C-l>', '<C-W>l')
end

function M.call_global(name, ...)
  local callback = vim.g[name]
  if type(callback) ~= 'function' then
    vim.notify('Missing global callback: ' .. name, vim.log.levels.ERROR)
    return false
  end

  callback(...)
  return true
end

function M.copilot_quick_chat(mode)
  return M.call_global('CopilotQuickChat', mode)
end

function M.prompt_rename(visual)
  if visual then
    return M.call_global('FancyPromptRename', 'RenameWord', 'New Word', 1)
  end

  return M.call_global('FancyPromptRename', 'RenameWord', 'New Word')
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
  M.call_global('CopilotCommitMsg', git_dir)
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

vim.keymap.set('n', '<leader>a:', function()
  editor.append_to_current_line(':')
end, { silent = true, desc = 'Append colon at end of line' })

vim.keymap.set('n', '<leader>a,', function()
  editor.append_to_current_line(',')
end, { silent = true, desc = 'Append comma at end of line' })

vim.keymap.set('n', '<leader>a.', function()
  editor.append_to_current_line('.')
end, { silent = true, desc = 'Append period at end of line' })

vim.keymap.set('n', '<leader>a;', function()
  editor.append_to_current_line(';')
end, { silent = true, desc = 'Append semicolon at end of line' })

vim.keymap.set('n', '<leader>cfp', function()
  clipboard.copy_current_file_path()
end, { silent = true, desc = 'Copy current file path to clipboard' })

vim.keymap.set('n', '<leader>cwd', function()
  clipboard.copy_current_file_dir()
end, { silent = true, desc = 'Copy current file directory to clipboard' })

vim.keymap.set('n', '<leader>ct', ':CloseToggle<CR>', { silent = true, desc = 'Toggle terminal auto-close' })
vim.keymap.set('n', '<leader>ca', ':call CloseAll()<CR>', { silent = true, desc = 'Close helper windows and lists' })
vim.keymap.set('n', 'qr', '@:', { desc = 'Rerun last command-line command' })
vim.keymap.set('n', 'q;', 'q:', { desc = 'Open command-line window' })
vim.keymap.set('n', 'cp', 'mzgcap`z', { remap = true, desc = 'Comment paragraph and restore cursor' })

vim.keymap.set('n', '<leader>ac', ':CopilotChatToggle<CR>', { silent = true, desc = 'Toggle Copilot chat' })
vim.keymap.set(
  'n',
  '<leader>af',
  ':CopilotChatFixDiagnostic<CR>',
  { silent = true, desc = 'Fix diagnostics with Copilot' }
)
vim.keymap.set('n', '<leader>aq', function()
  M.copilot_quick_chat('Buffer')
end, { silent = true, desc = 'Ask Copilot about the current buffer' })
vim.keymap.set('n', '<leader>at', ':CopilotChatTests<CR>', { silent = true, desc = 'Generate tests with Copilot' })
vim.keymap.set('v', '<leader>ac', ':<C-u>CopilotChatToggle<CR>', { silent = true, desc = 'Toggle Copilot chat' })
vim.keymap.set('v', '<leader>ad', ':CopilotChatDocs<CR>', { silent = true, desc = 'Document selection with Copilot' })
vim.keymap.set('v', '<leader>ae', ':CopilotChatExplainBrief<CR>', { silent = true, desc = 'Explain selection briefly' })
vim.keymap.set('v', '<leader>af', ':CopilotChatFix<CR>', { silent = true, desc = 'Fix selection with Copilot' })
vim.keymap.set(
  'v',
  '<leader>ao',
  ':CopilotChatOptimize<CR>',
  { silent = true, desc = 'Optimize selection with Copilot' }
)
vim.keymap.set('v', '<leader>aq', function()
  M.copilot_quick_chat('Visual')
end, { silent = true, desc = 'Ask Copilot about the selection' })
vim.keymap.set('v', '<leader>ar', ':CopilotChatReview<CR>', { silent = true, desc = 'Review selection with Copilot' })

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

vim.keymap.set('n', '<leader>ctd', function()
  editor.reload_with_fileformat('dos')
end, { silent = true, desc = 'Reload buffer as DOS fileformat' })

vim.keymap.set('n', '<leader>ctm', function()
  editor.reload_with_fileformat('mac')
end, { silent = true, desc = 'Reload buffer as Mac fileformat' })

vim.keymap.set('n', '<leader>ctu', function()
  editor.reload_with_fileformat('unix')
end, { silent = true, desc = 'Reload buffer as Unix fileformat' })

vim.keymap.set({ 'n', 'v' }, 'H', '^', { silent = true, desc = 'Move to line start' })
vim.keymap.set({ 'n', 'v' }, 'L', '$', { silent = true, desc = 'Move to line end' })
vim.keymap.set('o', 'H', '^', { desc = 'Move to line start' })
vim.keymap.set('o', 'L', '$', { desc = 'Move to line end' })

vim.keymap.set('n', 'zx', 'zMzvzz', { desc = 'Close other folds and center current section' })
vim.keymap.set('n', "'", '`', { desc = 'Jump to exact mark column' })

vim.keymap.set('n', 'j', function()
  return vim.v.count > 0 and 'j' or 'gj'
end, { expr = true, desc = 'Move down by screen line unless count is given' })

vim.keymap.set('n', 'k', function()
  return vim.v.count > 0 and 'k' or 'gk'
end, { expr = true, desc = 'Move up by screen line unless count is given' })

vim.keymap.set('n', '<BS>', '<C-^>', { desc = 'Switch to alternate buffer' })

vim.keymap.set('n', '<leader>aj', function()
  editor.insert_blank_line_below()
end, { silent = true, desc = 'Insert blank line below current line' })

vim.keymap.set('n', '<leader>ak', function()
  editor.insert_blank_line_above()
end, { silent = true, desc = 'Insert blank line above current line' })

vim.keymap.set('n', '<leader>al', function()
  editor.insert_blank_line_around()
end, { silent = true, desc = 'Insert blank lines around current line' })

vim.keymap.set('n', 'qj', '<C-W>j', { desc = 'Move to window below' })
vim.keymap.set('n', 'qk', '<C-W>k', { desc = 'Move to window above' })
vim.keymap.set('n', 'qh', '<C-W>h', { desc = 'Move to left window' })
vim.keymap.set('n', 'ql', '<C-W>l', { desc = 'Move to right window' })
vim.keymap.set('n', '<C-h>', '<C-W>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-l>', '<C-W>l', { desc = 'Move to right window' })
vim.keymap.set({ 'n', 'x', 'o' }, 'gI', 'mm:tabe %<CR>`mgizMzvzz', {
  remap = true,
  desc = 'Open current file in a tab and jump to the last insert position',
})
vim.keymap.set({ 'n', 'x', 'o' }, 'gT', 'mm:tabe %<CR>`mgDzMzvzz', {
  remap = true,
  desc = 'Open current file in a tab and jump to the global declaration',
})
vim.keymap.set({ 'n', 'x', 'o' }, 'gt', 'mm:tabe %<CR>`mgdzMzvzz', {
  remap = true,
  desc = 'Open current file in a tab and jump to the local declaration',
})
vim.keymap.set({ 'n', 'x', 'o' }, 'gs', 'mm:sp %<CR>`mgdzMzvzz', {
  remap = true,
  desc = 'Open current file in a split and jump to the local declaration',
})
vim.keymap.set({ 'n', 'x', 'o' }, 'gv', 'mm:vs %<CR>`mgdzMzvzz', {
  remap = true,
  desc = 'Open current file in a vertical split and jump to the local declaration',
})
vim.keymap.set('n', '<C-t>', 'mm:tabe <C-r>%<CR>`m', {
  remap = true,
  desc = 'Open current file in a new tab',
})
vim.keymap.set('n', '<C-Tab>', ':tabnext<CR>', { silent = true, desc = 'Go to the next tab' })
vim.keymap.set('n', '<Tab>', ':tabprevious<CR>', { silent = true, desc = 'Go to the previous tab' })

vim.keymap.set('n', '<leader>rd', function()
  shell.open_git_diff_in_terminal()
end, { silent = true, desc = 'Open git diff in a terminal split' })

vim.keymap.set('n', '<leader>gd', ':Gvdiffsplit! ', { desc = 'Open Fugitive vertical diff split prompt' })
vim.keymap.set('n', '<leader>gdt', ':Git difftool -y --diff-filter=ACMRTUXB ', { desc = 'Open git difftool prompt' })
vim.keymap.set('n', '<leader>gs', ':Git<CR>', { silent = true, desc = 'Open Fugitive status' })

vim.keymap.set('n', '<leader>oe', function()
  shell.open_explorer()
end, { silent = true, desc = 'Open current directory in Explorer' })

vim.keymap.set('n', '<leader>ob', function()
  shell.open_markdown_preview()
end, { silent = true, desc = 'Open markdown preview' })

vim.keymap.set('n', '<leader>tp', function()
  shell.open_tables_report()
end, { silent = true, desc = 'Open balances report terminal tab' })

vim.keymap.set('n', '<leader>cw', function()
  shell.open_weather_report()
end, { silent = true, desc = 'Open Calgary weather report terminal tab' })

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
vim.keymap.set('n', '<leader>/', [[/\v<C-r>/\|]], { desc = 'Start a multi-term very-magic search' })
vim.keymap.set('n', '<leader>so', 'vip:sort<CR>', { desc = 'Sort the current paragraph' })
vim.keymap.set({ 'n', 'x', 's', 'o' }, '<C-z>', '<Nop>', { desc = 'Disable suspend' })
vim.keymap.set('n', '<C-y>', '<C-r>', { desc = 'Redo' })
vim.keymap.set('i', '<C-y>', '<Esc><C-r>', { desc = 'Redo from insert mode' })
vim.keymap.set('n', 'gf', 'gf', { remap = true, desc = 'Restore built-in gf behavior' })

if vim.fn.has('gui_running') == 1 then
  vim.keymap.set('n', '<F6>', function()
    editor.font_size_plus()
  end, { silent = true, desc = 'Increase GUI font size' })
  vim.keymap.set('n', '<S-F6>', function()
    editor.font_size_minus()
  end, { silent = true, desc = 'Decrease GUI font size' })
end

-- Quickfix/location list helpers
vim.keymap.set('n', '<leader>q', function()
  quickfix.toggle_list('c')
end, { silent = true, desc = 'Toggle quickfix list' })

vim.keymap.set('n', 'Q', ':q!<CR>', { silent = true, desc = 'Force quit current window' })
vim.keymap.set('n', 'qw', ':w<CR>', { silent = true, desc = 'Write buffer' })
vim.keymap.set('n', '<C-s>', ':w<CR>', { silent = true, desc = 'Write buffer' })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>', { silent = true, desc = 'Write buffer' })
vim.keymap.set('n', '<leader>rw', function()
  M.prompt_rename(false)
end, { silent = true, desc = 'Prompt to rename word under cursor' })
vim.keymap.set('v', '<leader>rw', function()
  M.prompt_rename(true)
end, { silent = true, desc = 'Prompt to rename current selection' })
vim.keymap.set('n', 'Y', 'y$', { desc = 'Yank to end of line' })
vim.keymap.set('n', '<leader>ya', function()
  editor.yank_all()
end, { silent = true, desc = 'Yank entire buffer' })

vim.keymap.set({ 'n', 'v' }, 'K', '5k', { desc = 'Move up 5 lines' })
vim.keymap.set({ 'n', 'v' }, 'J', '5j', { desc = 'Move down 5 lines' })

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

return M
