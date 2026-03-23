local git = require('config.git')
local shell = require('config.shell')

local M = {}

function M.register(api)
  vim.keymap.set('n', '<leader>nh', ':lua Snacks.notifier.show_history()<CR>', { desc = 'Show Notification History' })

  vim.keymap.set('n', '<leader>gap', function()
    vim.cmd('wa')
    require('config.functions').git_add_commit_push()
  end, { silent = true, desc = 'Git add/commit/push (gap)' })

  vim.keymap.set('n', '<leader>ag', function()
    local git_dir = git.get_root()
    if not git_dir then
      vim.notify('Not in a git repository', vim.log.levels.ERROR)
      return
    end

    vim.fn.system('git -C ' .. git_dir .. ' add -A')
    api.call_global('CopilotCommitMsg', git_dir)
  end, { silent = true, desc = 'AI-generated commit message (ag)' })

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
end

return M
