local folds = require('config.folds')
local quickfix = require('config.quickfix')
local shell = require('config.shell')

local M = {}

function M.register()
  vim.keymap.set('n', '<leader>q', function()
    quickfix.toggle_list('c')
  end, { silent = true, desc = 'Toggle quickfix list' })

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

  vim.keymap.set('n', '<C-f>', function()
    quickfix.cycle('c', 'next')
    folds.open_current_fold()
  end, { silent = true, desc = 'Quickfix next' })

  vim.keymap.set('n', '<C-d>', function()
    quickfix.cycle('c', 'prev')
    folds.open_current_fold()
  end, { silent = true, desc = 'Quickfix previous' })
end

return M
