return {
  -- nvim-chainsaw: logging for all languages
  'chrisgrieser/nvim-chainsaw',
  event = 'VeryLazy',
  config = function()
    require('chainsaw').setup({
      logStatements = {
        variableLog = {
          javascript = {
            '/* prettier-ignore */ // {{marker}}',
            'console.log("{{marker}} {{var}}:", {{var}});',
          },
        },
      },
    })

    local chainsaw = require('chainsaw')

    vim.keymap.set('n', '<leader>lr', chainsaw.removeLogs, { silent = true, desc = 'Remove logs' })
    vim.keymap.set('n', '<leader>lc', chainsaw.clearLog, { silent = true, desc = 'Clear log' })
    vim.keymap.set({ 'n', 'v' }, '<leader>lv', chainsaw.variableLog, { silent = true, desc = 'Log variable' })
    vim.keymap.set('n', '<leader>le', function()
      chainsaw.variableLog()
      vim.cmd('normal! oexit()')
    end, { silent = true, desc = 'Log variable and exit' })
    vim.keymap.set({ 'n', 'v' }, '<leader>lo', chainsaw.objectLog, { silent = true, desc = 'Log object' })
    vim.keymap.set({ 'n', 'v' }, '<leader>lt', chainsaw.typeLog, { silent = true, desc = 'Log type' })
  end,
}
