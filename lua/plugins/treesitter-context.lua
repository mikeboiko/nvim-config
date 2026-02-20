return {
  -- nvim-treesitter-context
  'nvim-treesitter/nvim-treesitter-context',
  config = function()
    require 'treesitter-context'.setup {
      max_lines = 6,
    }
  end,
}
