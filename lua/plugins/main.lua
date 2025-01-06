return {
  { -- ReplaceWithRegister: Replace without copying to buffer {{{1
    'vim-scripts/ReplaceWithRegister',
  }, -- }}}
  { -- dressing.nvim: UI {{{1
    'stevearc/dressing.nvim',
    opts = {},
    config = function()
      require('dressing').setup({
        input = {
          insert_only = false,
          start_in_insert = false,
        },
      })
    end,
  }, -- }}}
  { -- gruvbox: Theme {{{1
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme gruvbox]])
    end,
  }, -- }}}
  { -- gv.vim {{{1
    'junegunn/gv.vim',
  }, -- }}}
  { -- indent-blankline.nvim {{{1
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    ---@module "ibl"
    opts = {},
    config = function()
      require('ibl').setup()
    end,
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
  { -- nvim-tree.lua {{{1
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      -- https://github.com/nvim-tree/nvim-tree.lua/wiki/Recipes#refactoring-of-on_attach-generated-code

      -- global
      vim.api.nvim_set_keymap('n', '<leader>on', ':NvimTreeFindFileToggle .<cr>', { silent = true, noremap = true })

      local function my_on_attach(bufnr)
        local api = require('nvim-tree.api')

        -- Add descriptions to ? help menu
        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- custom mappings
        vim.keymap.set('n', 'h', api.tree.change_root_to_parent, opts('Up'))
        vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', '<C-s>', api.node.open.horizontal, opts('Open: Horizontal Split'))
        vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
      end

      -- See :h nvim-tree-opts

      -- pass to setup along with your other options
      require('nvim-tree').setup({
        on_attach = my_on_attach,
        sort = {
          sorter = 'case_sensitive',
        },
        view = {
          width = 50,
        },
        renderer = {
          group_empty = true,
        },
        actions = {
          open_file = {
            quit_on_open = true,
            window_picker = {
              enable = false,
            },
          },
        },
      })
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
  { -- tabular: Align things {{{1
    'godlygeek/tabular',
  }, -- }}}
  { -- vim-airline: Status bar {{{1
    'vim-airline/vim-airline',
  }, -- }}}
  { -- vim-checkbox {{{1
    'jkramer/vim-checkbox',
  }, -- }}}
  { -- vim-repeat: Repeat surround {{{1
    'tpope/vim-repeat',
  }, -- }}}
  { -- vim-scimark: TUI spreadsheet {{{1
    'mipmip/vim-scimark',
  }, -- }}}
  { -- vim-scriptease: Help with vimscript {{{1
    'tpope/vim-scriptease',
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
  { -- vim-surround  {{{1
    'tpope/vim-repeat',
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
  { -- vira {{{1
    'n0v1c3/vira',
    build = './install.sh',
    branch = 'dev',
  }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
