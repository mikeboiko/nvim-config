return {
  -- fzf.lua
  'ibhagwan/fzf-lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {},
  config = function()
    require('fzf-lua').setup({
      oldfiles = {
        prompt = 'Old Files❯ ',
        cwd_only = false,
        stat_file = true, -- verify files exist on disk
        -- stat_file = false,
        include_current_session = false, -- include bufs from current session
      },
    })
    require('fzf-lua').register_ui_select({})
    vim.keymap.set('n', '<C-p>', ':rshada!<CR>:FzfLua oldfiles<CR>', { silent = true, desc = 'FzfLua recent files' })
    vim.keymap.set('n', '<leader>p', ':FzfLua git_files<CR>', { silent = true, desc = 'FzfLua git files' })
    vim.keymap.set('n', '<leader>fk', ':FzfLua keymaps<CR>', { silent = true, desc = 'FzfLua keymaps' })
    vim.keymap.set('n', '<C-.>', ':FzfLua tags_grep<CR>', { silent = true, desc = 'FzfLua ctags' })
    vim.keymap.set('n', '<leader>.', ':FzfLua btags<CR>', { silent = true, desc = 'FzfLua buffer tags' })
  end,
}
