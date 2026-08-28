return {
  'bytehound-labs/nvim-flow',
  dir = '~/git/nvim-flow',
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = { 'FlowRun', 'FlowDebug', 'FlowEdit', 'FlowToggleLock', 'FlowPreview', 'FlowQuickfix' },
  opts = {
    config_file = '.flow.yml',
    terminal_height = 15,
    terminal_position = 'top',
    edit_open_command = 'tabedit',
    -- output_mode = 'terminal',
    stop_at_home = true,
    show_command = true,
    keymaps = {
      run = '<CR>',
      debug = '<leader>df',
      edit = '<leader>fe',
      preview = '<leader>fp',
      quickfix = '<leader>fq',
    },
  },
}
