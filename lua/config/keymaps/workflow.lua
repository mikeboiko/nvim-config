local git = require('config.git')
local shell = require('config.shell')

local M = {}

local function git_add_all_or_notify()
  local ok, git_dir_or_error = git.add_all()
  if not ok then
    vim.notify(git_dir_or_error, vim.log.levels.ERROR)
    return nil
  end

  vim.notify('Staged all changes in ' .. vim.fn.fnamemodify(git_dir_or_error, ':t') .. ' (git add -A)')
  return git_dir_or_error
end

function M.register(api)
  vim.keymap.set('n', '<leader>ga', function()
    git_add_all_or_notify()
  end, { silent = true, desc = 'Git add -A (ga)' })

  vim.keymap.set('n', '<leader>gap', function()
    vim.cmd('wa')
    require('config.functions').git_add_commit_push()
  end, { silent = true, desc = 'Git add/commit/push (gap)' })

  vim.keymap.set('n', '<leader>ag', function()
    local git_dir = git_add_all_or_notify()
    if not git_dir then
      return
    end

    api.call_global('CopilotCommitMsg', git_dir)
  end, { silent = true, desc = 'AI-generated commit message (ag)' })

  vim.keymap.set('n', '<leader>rd', function()
    shell.open_git_diff_in_terminal()
  end, { silent = true, desc = 'Open git diff in a terminal split' })

  vim.keymap.set('n', '<leader>oe', function()
    shell.open_explorer()
  end, { silent = true, desc = 'Open current directory in Explorer' })

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
