return {
  -- nvim-treesitter
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  build = ':TSUpdate', -- Ensures parsers are installed/updated
  lazy = false,
  config = function()
    local ts = require('nvim-treesitter')

    local group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true })

    -- Enable treesitter for a buffer
    local function enable_treesitter(buf, lang)
      if not vim.api.nvim_buf_is_valid(buf) then
        return false
      end

      local ok = pcall(vim.treesitter.start, buf, lang)
      -- TODO: Remove this after csharp treesitter parser is fixed
      if ok and lang ~= 'c_sharp' then
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
          'caddy',
          'diff',
          'dockerfile',
          'git_config',
          'git_rebase',
          'gitattributes',
          'gitcommit',
          'gitignore',
          'go',
          'html',
          'javascript',
          'json',
          'jsx',
          'kusto',
          'lua',
          'markdown',
          'markdown_inline',
          'mermaid',
          'powershell',
          'python',
          'sql',
          'toml',
          'tsx',
          'typescript',
          'vim',
          'vimdoc',
          'vue',
          'xml',
          'yaml',
        }, {
          max_jobs = 8,
        })
      end,
    })

    -- Enable treesitter highlighting and indentation on FileType
    vim.api.nvim_create_autocmd('FileType', {
      group = group,
      desc = 'Enable treesitter highlighting and indentation',
      callback = function(event)
        if not event.match or event.match == '' then
          return
        end

        local lang = vim.treesitter.language.get_lang(event.match) or event.match
        enable_treesitter(event.buf, lang)
      end,
    })
  end,
}
