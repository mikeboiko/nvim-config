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
    local mp = require('markdown_preview')
    mp.setup({
      mermaid_renderer = 'rust',
    })

    vim.api.nvim_create_autocmd('BufDelete', {
      group = vim.api.nvim_create_augroup('markdown-preview-auto-stop', { clear = true }),
      callback = function(args)
        if mp._active_bufnr == args.buf and (mp._server_instance or mp._takeover_port) then
          mp.stop()
        end
      end,
    })
  end,
}
