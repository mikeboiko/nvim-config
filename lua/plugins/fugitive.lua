local git = require('config.git')

local function prefill_command(command)
  return function()
    vim.api.nvim_feedkeys(vim.keycode(':' .. command), 'n', false)
  end
end

-- Newly tracked and untracked files have no prior version to diff against, so
-- fugitive's ":Git difftool" errors on tracked additions. Run difftool on
-- everything else, then append new files as full-content tabs. With no args
-- this mirrors plain "git diff" (unstaged changes only); pass a ref like HEAD
-- to include staged changes too, matching git diff's own semantics.
local function difftool_with_new_tabs(args, fargs)
  local new_files, error_message = git.list_new_files(fargs)
  if not new_files then
    vim.notify(error_message, vim.log.levels.ERROR)
    return
  end

  vim.cmd('Git difftool -y --diff-filter=CMRTUXB ' .. args)

  if #new_files > 0 then
    vim.cmd('tablast')
    for _, file in ipairs(new_files) do
      vim.cmd('tabedit ' .. vim.fn.fnameescape(file))
    end
  end
end

return {
  -- vim-fugitive: Git wrapper
  'tpope/vim-fugitive',
  lazy = false,
  keys = {
    { '<leader>gd', prefill_command('Gvdiffsplit! '), desc = 'Open Fugitive vertical diff split prompt' },
    { '<leader>gt', prefill_command('GDifftool '), desc = 'Open git difftool prompt (new files open as tabs)' },
    { '<leader>gs', ':Git<CR>', silent = true, desc = 'Open Fugitive status' },
  },
  config = function()
    vim.api.nvim_create_user_command('GDifftool', function(opts)
      difftool_with_new_tabs(opts.args, opts.fargs)
    end, {
      nargs = '*',
      complete = 'customlist,fugitive#CompleteObject',
      desc = 'Git difftool excluding additions, plus new files opened as tabs',
    })
  end,
}
