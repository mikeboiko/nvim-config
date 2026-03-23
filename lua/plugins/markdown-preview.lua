return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  keys = {
    { '<leader>ob', '<cmd>MarkdownPreview<CR>', desc = 'Open markdown preview' },
  },
  build = 'cd app && yarn install',
  init = function()
    vim.g.mkdp_filetypes = { 'markdown' }
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_refresh_slow = 1
  end,
  ft = { 'markdown' },
}
