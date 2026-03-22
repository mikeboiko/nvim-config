local buffers = require('config.buffers')
local editor = require('config.editor')
local terminal = require('config.terminal')

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

vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('restore-last-position', { clear = true }),
  pattern = '*',
  callback = function()
    buffers.restore_last_position()
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

local terminal_group = vim.api.nvim_create_augroup('terminal-settings', { clear = true })
local quickfix_group = vim.api.nvim_create_augroup('quickfix-settings', { clear = true })
local editor_group = vim.api.nvim_create_augroup('editor-settings', { clear = true })

vim.api.nvim_create_autocmd('TermOpen', {
  group = terminal_group,
  pattern = 'term://*',
  callback = function(args)
    if type(_G.set_terminal_keymaps) == 'function' then
      _G.set_terminal_keymaps()
    end

    terminal.on_term_open(args.buf)
  end,
})

vim.api.nvim_create_autocmd('TermClose', {
  group = terminal_group,
  pattern = 'term://*',
  callback = function(args)
    terminal.on_term_close(args.buf)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = quickfix_group,
  pattern = 'qf',
  callback = function()
    vim.opt_local.cursorline = true
  end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  group = editor_group,
  pattern = '*',
  callback = function()
    editor.on_save()
  end,
})

vim.api.nvim_create_autocmd('CmdwinEnter', {
  group = editor_group,
  pattern = '*',
  callback = function()
    vim.keymap.set('n', '<C-w>', '<cmd>q!<cr>', { buffer = true, silent = true, desc = 'Quit command window' })
    vim.keymap.set('n', 'qq', '<cmd>q!<cr>', { buffer = true, silent = true, desc = 'Quit command window' })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = editor_group,
  pattern = '*',
  callback = function()
    buffers.remove_auto_comment_formatoptions()
  end,
})

vim.api.nvim_create_autocmd('WinEnter', {
  group = editor_group,
  pattern = '*',
  callback = function()
    buffers.set_preview_window_options()
  end,
})

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufEnter' }, {
  group = editor_group,
  pattern = 'COMMIT_EDITMSG',
  callback = function()
    buffers.set_commit_buffer_defaults()
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  group = editor_group,
  pattern = { '*.csv', '*.psv', '*.tsv' },
  callback = function()
    buffers.set_nowrap()
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = editor_group,
  pattern = {
    'html',
    'javascript',
    'json',
    'vue',
    'css',
    'scss',
    'yml',
    'yaml',
    'markdown',
    'vim',
    'javascriptreact',
    'typescriptreact',
  },
  callback = function()
    buffers.set_two_space_indent()
  end,
})
