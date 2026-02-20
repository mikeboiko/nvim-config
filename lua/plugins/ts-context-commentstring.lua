return {
  -- nvim-ts-context-commentstring: Vue comment strings
  'JoosepAlviste/nvim-ts-context-commentstring',
  config = function()
    require('ts_context_commentstring').setup {
      enable_autocmd = false,
    }
  end,
}
