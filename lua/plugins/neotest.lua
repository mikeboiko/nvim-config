return {
  -- neotest
  'nvim-neotest/neotest',
  dependencies = {
    -- 'nsidorenco/neotest-vstest',
    'Issafalcon/neotest-dotnet',
    'nvim-neotest/nvim-nio',
    'nvim-neotest/neotest-python',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('neotest').setup({
      adapters = {
        require('neotest-dotnet'),
        require('neotest-python')({
          dap = {
            justMyCode = true,
            env = { PYTEST_ADDOPTS = '-n 0' },
          },
        }),
        -- require('neotest-vstest')({
        --   sdk_path = '/usr/share/dotnet/sdk/8.0.115/',
        -- }),
      },
    })

    vim.keymap.set('n', '<leader>ts', function()
      require('neotest').summary.toggle()
    end, { silent = true })
  end,
}
