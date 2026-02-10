return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>fi',
        function()
          require('conform').format({ async = true, lsp_format = 'fallback' })
        end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'ruff_format' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        javascriptreact = { 'prettier' },
        typescriptreact = { 'prettier' },
        vue = { 'prettier' },
        json = { 'prettier' },
        jsonc = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
        bash = { 'shfmt' },
        sh = { 'shfmt' },
        rust = { 'rustfmt' },
        sql = { 'sqlfluff' },
        cs = { 'csharpier' },
        xml = { 'csharpier' },
      },
      format_on_save = function(bufnr)
        -- Don't auto-format in work repos
        local current_file = vim.api.nvim_buf_get_name(bufnr)
        local excluded_paths = {
          vim.fn.expand('~/git/CT'),
        }
        for _, path in ipairs(excluded_paths) do
          if vim.startswith(current_file, path) then
            return
          end
        end

        return {
          timeout_ms = 3000,
          lsp_format = 'fallback',
        }
      end,
      formatters = {
        shfmt = {
          prepend_args = { '--apply-ignore' },
        },
      },
    },
  },
}
