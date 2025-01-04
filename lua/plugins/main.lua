return {
  { 'stevearc/dressing.nvim', opts = {} },
  { 'ellisonleao/gruvbox.nvim', priority = 1000, config = true },
  {
    'dstein64/vim-startuptime',
    -- lazy-load on a command
    cmd = 'StartupTime',
    -- init is called during startup. Configuration for vim plugins typically should be set in an init function
    init = function()
      vim.g.startuptime_tries = 10
    end,
  },
  { 'akinsho/bufferline.nvim', version = '*', dependencies = 'nvim-tree/nvim-web-devicons' },
}
