return {
  { -- nvim-dap-ui {{{1
    'rcarriga/nvim-dap-ui',
    dependencies = { 'mfussenegger/nvim-dap', 'mfussenegger/nvim-dap-python', 'nvim-neotest/nvim-nio' },
    config = function()
      local dap, dapui = require('dap'), require('dapui')

      dapui.setup({
        icons = { expanded = '▾', collapsed = '▸', current_frame = '▸' },
        mappings = {
          -- Use a table to apply multiple mappings
          expand = { 'o', '<2-LeftMouse>' },
          open = '<CR>',
          remove = 'd',
          edit = 'e',
          repl = 'r',
          toggle = 't',
        },
        -- Use this to override mappings for specific elements
        element_mappings = {
          -- stacks = {
          --   open = "<CR>",
          --   expand = "o",
          -- }
        },
        -- Expand lines larger than the window
        -- Requires >= 0.7
        expand_lines = vim.fn.has('nvim-0.7') == 1,
        -- Layouts define sections of the screen to place windows.
        -- The position can be "left", "right", "top" or "bottom".
        -- The size specifies the height/width depending on position. It can be an Int
        -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
        -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
        -- Elements are the elements shown in the layout (in order).
        -- Layouts are opened in order so that earlier layouts take priority in window sizing.
        layouts = {
          {
            elements = {
              -- Elements can be strings or table with id and size keys.
              { id = 'breakpoints', size = 0.25 },
              'watches',
              'scopes',
              'stacks',
            },
            size = 40, -- 40 columns
            position = 'left',
          },
          {
            elements = {
              'repl',
              -- 'console',
            },
            size = 0.25, -- 25% of total lines
            position = 'bottom',
          },
        },
        controls = {
          -- Requires Neovim nightly (or 0.8 when released)
          enabled = true,
          -- Display controls in this element
          element = 'repl',
          icons = {
            pause = '',
            play = '',
            step_into = '',
            step_over = '',
            step_out = '',
            step_back = '',
            run_last = '↻',
            terminate = '□',
          },
        },
        floating = {
          max_height = nil, -- These can be integers or a float between 0 and 1.
          max_width = nil, -- Floats will be treated as percentage of your screen.
          border = 'single', -- Border style. Can be "single", "double" or "rounded"
          mappings = {
            close = { 'q', '<Esc>' },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil, -- Can be integer or nil.
          max_value_lines = 100, -- Can be integer or nil.
        },
      })

      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end

      dap.adapters.netcoredbg = {
        type = 'executable',
        command = '/usr/bin/netcoredbg',
        args = { '--interpreter=vscode' },
      }

      dap.configurations.cs = {
        {
          type = 'netcoredbg',
          name = 'launch - netcoredbg',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
          end,
        },
      }

      -- vim.keymap.set('n', '<leader>dl', function()
      --   require('osv').launch({ port = 8086 })
      -- end, { noremap = true, desc = 'dap: launch neovim lua server' })
      vim.keymap.set('n', '<leader>dc', function()
        vim.cmd('wa')
        dap.continue()
      end, { silent = true })
      vim.keymap.set('n', '<C-e>', function()
        dap.step_over()
      end, { silent = true })
      vim.keymap.set('n', '<C-r>', function()
        dap.step_into()
      end, { silent = true })
      vim.keymap.set('n', '<leader>dsb', function()
        dap.step_back()
      end, { silent = true })
      vim.keymap.set('n', '<leader>dso', function()
        dap.step_out()
      end, { silent = true })
      vim.keymap.set('n', '<leader>ds', function()
        dap.close()
      end, { silent = true })
      vim.keymap.set('n', '<leader>dl', function()
        dap.run_to_cursor()
      end, { silent = true })
      vim.keymap.set('n', '<leader>db', function()
        dap.toggle_breakpoint()
      end, { silent = true })
      vim.keymap.set('n', '<leader>dt', function()
        require('neotest').run.run({ strategy = 'dap' })
      end, { silent = true })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end, { silent = true })
      vim.keymap.set('n', '<leader>lp', function()
        dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
      end, { silent = true })
      vim.keymap.set('n', '<leader>dr', function()
        dap.restart()
      end, { silent = true })
      vim.keymap.set('n', '<leader>dp', function()
        dap.pause()
      end, { silent = true })
      vim.keymap.set('n', '<leader>di', function()
        dapui.eval()
      end, { silent = true })
      vim.keymap.set('n', '<leader>dd', function()
        require('dap').up()
      end, { silent = true })
      vim.keymap.set('n', '<leader>du', function()
        require('dap').down()
      end, { silent = true })
    end,
  }, -- }}}
  -- { -- nvim-dap-cs {{{1
  --   'nicholasmata/nvim-dap-cs',
  --   dependencies = { 'mfussenegger/nvim-dap' },
  --   config = function()
  --     require('dap-cs').setup()
  --   end,
  -- }, -- }}}
  { -- one-small-step-for-vimkind {{{1
    'jbyuki/one-small-step-for-vimkind',
    config = function()
      local dap = require('dap')

      dap.adapters.nlua = function(callback, config)
        callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 })
      end

      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = 'Attach to running Neovim instance',
        },
      }
    end,
  }, -- }}}
  { -- nvim-dap-virtual-text {{{1
    'theHamsta/nvim-dap-virtual-text',
    config = function()
      require('nvim-dap-virtual-text').setup({})
    end,
  }, -- }}}
  { -- neotest {{{1
    'nvim-neotest/neotest',
    dependencies = {
      'Issafalcon/neotest-dotnet',
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('neotest').setup({
        adapters = {
          require('neotest-dotnet'),
        },
      })

      vim.keymap.set('n', '<leader>ts', function()
        require('neotest').summary.toggle()
      end, { silent = true })
    end,
  }, -- }}}
  --   { -- vimspector {{{1
  --     'puremourning/vimspector',
  --     build = function()
  --       local install_cmd = './install_gadget.py'
  --       vim.fn.system(install_cmd .. ' --enable-python')
  --       vim.fn.system(install_cmd .. ' --enable-go --update-gadget-config')
  --       vim.fn.system(install_cmd .. ' --force-enable-csharp --update-gadget-config')
  --       vim.fn.system(install_cmd .. ' --force-enable-node --update-gadget-config')
  --     end,
  --   }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
