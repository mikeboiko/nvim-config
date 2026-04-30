return {
  -- roslyn
  'seblyng/roslyn.nvim',
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = {
    extensions = {
      razor = {
        enabled = false,
      },
    },
  },
}
