return {
  { -- aerial.nvim {{{1
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('aerial').setup({
        -- optionally use on_attach to set keymaps when aerial has attached to a buffer
        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set('n', '[f', '<cmd>AerialPrev<CR>', { buffer = bufnr })
          vim.keymap.set('n', ']f', '<cmd>AerialNext<CR>', { buffer = bufnr })
        end,
        layout = {
          default_direction = 'right',
        },
        close_automatic_events = { 'switch_buffer' },
        close_on_select = true,
      })
    end,
    -- You probably also want to set a keymap to toggle aerial
    vim.keymap.set('n', '<leader>tb', '<cmd>AerialToggle<CR>'),
  }, -- }}}
  { -- nvim-treesitter {{{1
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate', -- Ensures parsers are installed/updated
    event = { 'BufReadPost', 'BufNewFile' }, -- Lazy-load on file open
    config = function()
      require('nvim-treesitter.configs').setup({
        -- A list of parser names, or "all" (the five listed parsers should always be installed)
        ensure_installed = {
          'c_sharp',
          'diff',
          'git_config',
          'git_rebase',
          'gitattributes',
          'gitcommit',
          'gitignore',
          'go',
          'javascript',
          'json',
          'lua',
          'markdown',
          'markdown_inline',
          'mermaid',
          'python',
          'typescript',
          'vim',
          'vimdoc',
          'vue',
          'yaml',
        },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,

        highlight = {
          enable = true,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
        textobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              -- You can optionally set descriptions to the mappings (used in the desc parameter of
              -- nvim_buf_set_keymap) which plugins like which-key display
              ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
              -- You can also use captures from other query groups like `locals.scm`
              ['as'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
              ['@parameter.outer'] = 'v', -- charwise
              ['@function.outer'] = 'V', -- linewise
              ['@class.outer'] = '<c-v>', -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true of false
            include_surrounding_whitespace = true,
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              -- [']f'] = '@function.outer',
              [']]'] = { query = '@class.outer', desc = 'Next class start' },
              --
              -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
              [']o'] = '@loop.*',
              -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
              --
              -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
              -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
              -- [']s'] = { query = '@scope', query_group = 'locals', desc = 'Next scope' },
              [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next fold' },
            },
            goto_next_end = {
              [']F'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              -- ['[f'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[F'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            -- goto_next = {
            -- ["]d"] = "@conditional.outer",
            -- },
            -- goto_previous = {
            -- ["[d"] = "@conditional.outer",
            -- }
          },
        },
        indent = {
          enable = true,
        },
      })
    end,
  }, -- }}}
  { -- nvim-treesitter-context {{{1
    'nvim-treesitter/nvim-treesitter-context',
  }, -- }}}
  { -- nvim-treesitter-textobjects {{{1
    'nvim-treesitter/nvim-treesitter-textobjects',
  }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
