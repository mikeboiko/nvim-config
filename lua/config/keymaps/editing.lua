local clipboard = require('config.clipboard')
local comments = require('config.comments')
local editor = require('config.editor')

local M = {}

local function add_empty_comment_above()
  local comment_string = comments.get_commentstring():gsub('%%s', '')
  local current_line = vim.api.nvim_get_current_line()
  local indent = current_line:match('^%s+') or ''
  local line = vim.api.nvim_win_get_cursor(0)[1]

  vim.api.nvim_buf_set_lines(0, line - 1, line - 1, false, { indent .. comment_string })
  vim.cmd('normal! k$')
  vim.cmd('startinsert!')
end

function M.register(api)
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

  vim.keymap.set('n', 'co', add_empty_comment_above, { desc = 'Add empty comment above' })

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

  vim.keymap.set('n', 'Q', ':q!<CR>', { silent = true, desc = 'Force quit current window' })
  vim.keymap.set('n', 'qw', ':w<CR>', { silent = true, desc = 'Write buffer' })
  vim.keymap.set('n', '<C-s>', ':w<CR>', { silent = true, desc = 'Write buffer' })
  vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>', { silent = true, desc = 'Write buffer' })

  vim.keymap.set('n', '<leader>rw', function()
    api.prompt_rename(false)
  end, { silent = true, desc = 'Prompt to rename word under cursor' })

  vim.keymap.set('v', '<leader>rw', function()
    api.prompt_rename(true)
  end, { silent = true, desc = 'Prompt to rename current selection' })

  vim.keymap.set('n', 'Y', 'y$', { desc = 'Yank to end of line' })
  vim.keymap.set('n', '<leader>ya', function()
    editor.yank_all()
  end, { silent = true, desc = 'Yank entire buffer' })

  vim.keymap.set({ 'n', 'v' }, 'K', '5k', { desc = 'Move up 5 lines' })
  vim.keymap.set({ 'n', 'v' }, 'J', '5j', { desc = 'Move down 5 lines' })

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

  vim.keymap.set('n', '<leader>ti', ':TodoPrompt<CR>', { silent = true, desc = 'Insert TODO at cursor' })
end

return M
