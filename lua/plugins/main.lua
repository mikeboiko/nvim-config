return {
  { -- {{{1
  }, -- }}}
  { -- indent-blankline.nvim {{{1
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
    config = function()
      require('ibl').setup()
    end,
  }, -- }}}
  { -- nvim-bqf {{{1
    'kevinhwang91/nvim-bqf',
    config = function()
      require('bqf').setup({
        auto_enable = true,
        auto_resize_height = true,
        func_map = {
          split = '<C-s>',
          tabdrop = '<C-t>',
        },
      })
    end,
  }, -- }}}
  { -- gv.vim {{{1
    'junegunn/gv.vim',
  }, -- }}}
  { -- vim-checkbox {{{1
    'jkramer/vim-checkbox',
  }, -- }}}
  { -- markdown-preview.nvim {{{1
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  }, -- }}}
  { -- tabular: Align things {{{1
    'godlygeek/tabular',
  }, -- }}}
  { -- dressing.nvim: UI {{{1
    'stevearc/dressing.nvim',
    opts = {},
  }, -- }}}
  { -- gruvbox: Theme {{{1
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme gruvbox]])
    end,
  }, -- }}}
  { -- nvim-ts-context-commentstring: Vue comment strings {{{1
    'JoosepAlviste/nvim-ts-context-commentstring',
    config = function()
      require('ts_context_commentstring').setup {
        enable_autocmd = false,
      }
    end,
  }, -- }}}
  { -- vim-startup-time {{{1
    'dstein64/vim-startuptime',
    -- lazy-load on a command
    cmd = 'StartupTime',
    -- init is called during startup. Configuration for vim plugins typically should be set in an init function
    init = function()
      vim.g.startuptime_tries = 10
    end,
  }, -- }}}
  { -- vim-tmux-navigator {{{1
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
      'TmuxNavigatorProcessList',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
    },
  }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
