local buffers = require('config.buffers')
local editor = require('config.editor')
local folds = require('config.folds')
local git = require('config.git')
local gui = require('config.gui')
local terminal = require('config.terminal')

-- -- Append backup files with timestamp
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   callback = function()
--     local extension = '~' .. vim.fn.strftime('%Y-%m-%d-%H%M%S')
--     vim.o.backupext = extension
--   end,
-- })

vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    vim.b.git_repo_name = git.get_repo_name() or ''
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
local gui_group = vim.api.nvim_create_augroup('gui-settings', { clear = true })

if gui.is_available() then
  gui.apply_options()

  vim.api.nvim_create_autocmd('GUIEnter', {
    group = gui_group,
    pattern = '*',
    callback = function()
      gui.on_gui_enter()
    end,
  })
end

vim.api.nvim_create_autocmd('TermOpen', {
  group = terminal_group,
  pattern = 'term://*',
  callback = function(args)
    require('config.keymaps').set_terminal_keymaps(args.buf)
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

vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
  group = editor_group,
  pattern = '*',
  desc = 'Refresh markdown folds after edits',
  callback = function(args)
    if vim.api.nvim_get_current_buf() ~= args.buf then
      return
    end

    if vim.bo[args.buf].buftype ~= '' or vim.bo[args.buf].filetype ~= 'markdown' then
      return
    end

    folds.refresh_folds()
  end,
})
