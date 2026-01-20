vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { 'Caddyfile', 'Caddyfile*', '*.Caddyfile' },
  callback = function()
    vim.opt.filetype = 'caddy'
  end,
})
