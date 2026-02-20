return {
  -- nvim-chainsaw: logging for all languages
  'chrisgrieser/nvim-chainsaw',
  event = 'VeryLazy',
  opts = {}, -- required even if left empty
  config = function()
    require('chainsaw').setup {
      logStatements = {
        variableLog = {
          javascript = {
            '/* prettier-ignore */ // {{marker}}',
            'console.log("{{marker}} {{var}}:", {{var}});',
          },
        },
      },
    }

    -- Remove logs
    vim.api.nvim_set_keymap(
      'n',
      '<leader>lr',
      ':lua require("chainsaw").removeLogs()<CR>',
      { silent = true, noremap = true }
    )

    -- Clear log
    vim.api.nvim_set_keymap(
      'n',
      '<leader>lc',
      ':lua require("chainsaw").clearLog()<CR>',
      { silent = true, noremap = true }
    )

    -- Log variable
    vim.api.nvim_set_keymap(
      'n',
      '<leader>lv',
      ':lua require("chainsaw").variableLog()<CR>',
      { silent = true, noremap = true }
    )
    vim.api.nvim_set_keymap(
      'v',
      '<leader>lv',
      ':lua require("chainsaw").variableLog()<CR>',
      { silent = true, noremap = true }
    )

    -- Log variable and exit
    vim.api.nvim_set_keymap(
      'n',
      '<leader>le',
      ':lua require("chainsaw").variableLog() vim.cmd("normal! oexit()")<CR>',
      { silent = true, noremap = true }
    )

    -- Log object
    vim.api.nvim_set_keymap(
      'n',
      '<leader>lo',
      ':lua require("chainsaw").objectLog()<CR>',
      { silent = true, noremap = true }
    )
    vim.api.nvim_set_keymap(
      'v',
      '<leader>lo',
      ':lua require("chainsaw").objectLog()<CR>',
      { silent = true, noremap = true }
    )

    -- Log type
    vim.api.nvim_set_keymap(
      'n',
      '<leader>lt',
      ':lua require("chainsaw").typeLog()<CR>',
      { silent = true, noremap = true }
    )
    vim.api.nvim_set_keymap(
      'v',
      '<leader>lt',
      ':lua require("chainsaw").typeLog()<CR>',
      { silent = true, noremap = true }
    )
  end,
}
