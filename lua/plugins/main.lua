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
  { -- lualine.nvim {{{1
    -- https://github.com/nvim-lualine/lualine.nvim?tab=readme-ov-file#component-specific-options
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        sections = {
          lualine_a = {
            function()
              return vim.b.git_repo_name or ''
            end,
          },
          lualine_b = { 'aerial' },
          lualine_c = { { 'filename', path = 3 } },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'branch', 'diff', 'diagnostics', 'location' },
          lualine_z = {
            'progress',
            function()
              return tostring(vim.api.nvim_buf_line_count(0))
            end,
          },
        },
      })
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
  { -- nvim-chainsaw: logging for all languages {{{1
    'chrisgrieser/nvim-chainsaw',
    event = 'VeryLazy',
    opts = {}, -- required even if left empty
    config = function()
      require('chainsaw').setup {
        logStatements = {
          variableLog = {
            javascript = {
              '/* prettier-ignore */ // {{marker}}',
              'console.log("{{marker}} {{var}}:", {{var}});',
            },
          },
        },
      }

      -- Remove logs
      vim.api.nvim_set_keymap(
        'n',
        '<leader>lr',
        ':lua require("chainsaw").removeLogs()<CR>',
        { silent = true, noremap = true }
      )

      -- Clear log
      vim.api.nvim_set_keymap(
        'n',
        '<leader>lc',
        ':lua require("chainsaw").clearLog()<CR>',
        { silent = true, noremap = true }
      )

      -- Log variable
      vim.api.nvim_set_keymap(
        'n',
        '<leader>lv',
        ':lua require("chainsaw").variableLog()<CR>',
        { silent = true, noremap = true }
      )
      vim.api.nvim_set_keymap(
        'v',
        '<leader>lv',
        ':lua require("chainsaw").variableLog()<CR>',
        { silent = true, noremap = true }
      )

      -- Log object
      vim.api.nvim_set_keymap(
        'n',
        '<leader>lo',
        ':lua require("chainsaw").objectLog()<CR>',
        { silent = true, noremap = true }
      )
      vim.api.nvim_set_keymap(
        'v',
        '<leader>lo',
        ':lua require("chainsaw").objectLog()<CR>',
        { silent = true, noremap = true }
      )

      -- Log type
      vim.api.nvim_set_keymap(
        'n',
        '<leader>lt',
        ':lua require("chainsaw").typeLog()<CR>',
        { silent = true, noremap = true }
      )
      vim.api.nvim_set_keymap(
        'v',
        '<leader>lt',
        ':lua require("chainsaw").typeLog()<CR>',
        { silent = true, noremap = true }
      )
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
  { -- tiny-glimmer.nvim {{{1
    'rachartier/tiny-glimmer.nvim',
    event = 'TextYankPost',
    config = function()
      require('tiny-glimmer').setup({
        animations = {
          fade = {
            from_color = 'DiffDelete',
            to_color = 'DiffAdd',
          },
          bounce = {
            from_color = '#ff0000',
            to_color = '#00ff00',
          },
        },
      })
    end,
  }, -- }}}
  { -- vim-checkbox {{{1
    'jkramer/vim-checkbox',
  }, -- }}}
  { -- vim-repeat  {{{1
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
  { -- vim-surround {{{1
    'tpope/vim-surround',
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
    cmd = { 'ViraIssues', 'ViraLoadProject' },
  }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
