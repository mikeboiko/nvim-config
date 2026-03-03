return {
  'mikeboiko/nvim-flow',
  dir = '~/git/OpenSource/nvim-flow',
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = { 'FlowRun', 'FlowDebug', 'FlowToggleLock', 'FlowPreview', 'FlowQuickfix' },
  opts = {
    config_file = '.flow.yml',
    terminal_height = 15,
    terminal_position = 'top',
    stop_at_home = true,
    show_command = true,
    keymaps = {
      run = '<CR>',
      debug = '<leader>df',
      toggle_lock = '<leader>fl',
      preview = '<leader>fp',
      quickfix = '<leader>fq',
    },
  },
}
