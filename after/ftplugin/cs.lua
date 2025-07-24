vim.keymap.set('n', '<leader>ts', function()
  require('neotest').summary.toggle()
end, { silent = true })
