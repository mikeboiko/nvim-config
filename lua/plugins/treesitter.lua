return {
  { -- aerial.nvim
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
  },
  { -- nvim-treesitter
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate', -- Ensures parsers are installed/updated
    lazy = false,
    config = function()
      local ts = require('nvim-treesitter')

      -- Track buffers waiting for parser installation: { lang = { [buf] = true, ... } }
      local waiting_buffers = {}
      -- Track languages currently being installed to avoid duplicate install tasks
      local installing_langs = {}

      local group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true })

      -- Enable treesitter for a buffer
      local function enable_treesitter(buf, lang)
        if not vim.api.nvim_buf_is_valid(buf) then
          return false
        end

        local ok = pcall(vim.treesitter.start, buf, lang)
        if ok then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
        return ok
      end

      -- Install core parsers after lazy.nvim finishes loading all plugins
      vim.api.nvim_create_autocmd('User', {
        group = group,
        pattern = 'LazyDone',
        once = true,
        desc = 'Install core treesitter parsers',
        callback = function()
          ts.install({
            'bash',
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
            'powershell',
            'python',
            'sql',
            'toml',
            'typescript',
            'vim',
            'vimdoc',
            'vue',
            'yaml',
          }, {
            max_jobs = 8,
          })
        end,
      })

      local ignore_filetypes = {
        checkhealth = true,
        lazy = true,
        mason = true,
        qf = true,
        snacks_dashboard = true,
        snacks_notif = true,
        snacks_win = true,
        toggleterm = true,
      }

      -- Auto-install parsers and enable highlighting on FileType
      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        desc = 'Enable treesitter highlighting and indentation',
        callback = function(event)
          if ignore_filetypes[event.match] then
            return
          end

          local lang = vim.treesitter.language.get_lang(event.match) or event.match
          local buf = event.buf

          if not enable_treesitter(buf, lang) then
            -- Parser not available, queue buffer (set handles duplicates)
            waiting_buffers[lang] = waiting_buffers[lang] or {}
            waiting_buffers[lang][buf] = true

            -- Only start install if not already in progress
            if not installing_langs[lang] then
              installing_langs[lang] = true
              local task = ts.install({ lang })

              -- Register callback for when installation completes
              if task and task.await then
                task:await(function()
                  vim.schedule(function()
                    installing_langs[lang] = nil

                    -- Enable treesitter on all waiting buffers for this language
                    local buffers = waiting_buffers[lang]
                    if buffers then
                      for b in pairs(buffers) do
                        enable_treesitter(b, lang)
                      end
                      waiting_buffers[lang] = nil
                    end
                  end)
                end)
              else
                -- Fallback: clear state if task doesn't support await
                installing_langs[lang] = nil
                waiting_buffers[lang] = nil
              end
            end
          end
        end,
      })

      -- Clean up waiting buffers when buffer is deleted
      vim.api.nvim_create_autocmd('BufDelete', {
        group = group,
        desc = 'Clean up treesitter waiting buffers',
        callback = function(event)
          for lang, buffers in pairs(waiting_buffers) do
            buffers[event.buf] = nil
            if next(buffers) == nil then
              waiting_buffers[lang] = nil
            end
          end
        end,
      })
    end,
  },
  { -- nvim-treesitter-context
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require 'treesitter-context'.setup {
        max_lines = 6,
      }
    end,
  },
  { -- nvim-treesitter-textobjects
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
  },
}
