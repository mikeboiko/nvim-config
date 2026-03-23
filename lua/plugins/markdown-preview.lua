return {
  'selimacerbas/markdown-preview.nvim',
  dependencies = { 'selimacerbas/live-server.nvim' },
  cmd = { 'MarkdownPreview', 'MarkdownPreviewRefresh', 'MarkdownPreviewStop' },
  keys = {
    { '<leader>ob', '<cmd>MarkdownPreview<CR>', desc = 'Open markdown preview' },
  },
  init = function()
    vim.api.nvim_create_user_command('MarkdownPreviewToggle', function()
      require('lazy').load({ plugins = { 'markdown-preview.nvim' } })

      local markdown_preview = require('markdown_preview')
      if markdown_preview._server_instance or markdown_preview._takeover_port then
        markdown_preview.stop()
        return
      end

      markdown_preview.start()
    end, { desc = 'Toggle markdown preview' })
  end,
  ft = { 'markdown' },
  config = function()
    require('markdown_preview').setup({
      mermaid_renderer = 'rust',
    })
  end,
}
