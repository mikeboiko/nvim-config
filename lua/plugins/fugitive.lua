local function prefill_command(command)
  return function()
    vim.api.nvim_feedkeys(vim.keycode(':' .. command), 'n', false)
  end
end

return {
  -- vim-fugitive: Git wrapper
  'tpope/vim-fugitive',
  lazy = false,
  keys = {
    { '<leader>gd', prefill_command('Gvdiffsplit! '), desc = 'Open Fugitive vertical diff split prompt' },
    { '<leader>gt', prefill_command('Git difftool -y --diff-filter=ACMRTUXB '), desc = 'Open git difftool prompt' },
    { '<leader>gs', ':Git<CR>', silent = true, desc = 'Open Fugitive status' },
  },
}
