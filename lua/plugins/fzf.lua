return {
  -- { -- fzf-folds.vim {{{1
  --   'roosta/fzf-folds.vim',
  -- }, -- }}}
  { -- fzf.lua {{{1
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
    config = function()
      vim.keymap.set('n', '<C-p>', ':FzfLua oldfiles<CR>', { silent = true, desc = 'FzfLua recent files' })
      vim.keymap.set('n', '<leader>p', ':FzfLua git_files<CR>', { silent = true, desc = 'FzfLua git files' })
      vim.keymap.set('n', '<leader>.', ':FzfLua tags<CR>', { silent = true, desc = 'FzfLua ctags' })
      vim.keymap.set('n', '<leader>fk', ':FzfLua keymaps<CR>', { silent = true, desc = 'FzfLua keymaps' })
    end,
  }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
