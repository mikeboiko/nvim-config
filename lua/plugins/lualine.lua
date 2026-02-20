return {
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
}
