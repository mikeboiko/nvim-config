local M = {}

function M.register(api)
  vim.keymap.set('n', '<leader>ac', ':CopilotChatToggle<CR>', { silent = true, desc = 'Toggle Copilot chat' })
  vim.keymap.set(
    'n',
    '<leader>af',
    ':CopilotChatFixDiagnostic<CR>',
    { silent = true, desc = 'Fix diagnostics with Copilot' }
  )
  vim.keymap.set('n', '<leader>aq', function()
    api.copilot_quick_chat('Buffer')
  end, { silent = true, desc = 'Ask Copilot about the current buffer' })
  vim.keymap.set('n', '<leader>at', ':CopilotChatTests<CR>', { silent = true, desc = 'Generate tests with Copilot' })
  vim.keymap.set('v', '<leader>ac', ':<C-u>CopilotChatToggle<CR>', { silent = true, desc = 'Toggle Copilot chat' })
  vim.keymap.set('v', '<leader>ad', ':CopilotChatDocs<CR>', { silent = true, desc = 'Document selection with Copilot' })
  vim.keymap.set(
    'v',
    '<leader>ae',
    ':CopilotChatExplainBrief<CR>',
    { silent = true, desc = 'Explain selection briefly' }
  )
  vim.keymap.set('v', '<leader>af', ':CopilotChatFix<CR>', { silent = true, desc = 'Fix selection with Copilot' })
  vim.keymap.set(
    'v',
    '<leader>ao',
    ':CopilotChatOptimize<CR>',
    { silent = true, desc = 'Optimize selection with Copilot' }
  )
  vim.keymap.set('v', '<leader>aq', function()
    api.copilot_quick_chat('Visual')
  end, { silent = true, desc = 'Ask Copilot about the selection' })
  vim.keymap.set('v', '<leader>ar', ':CopilotChatReview<CR>', { silent = true, desc = 'Review selection with Copilot' })
end

return M
