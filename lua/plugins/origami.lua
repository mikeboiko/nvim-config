return {
  -- nvim-origami folding
  'chrisgrieser/nvim-origami',
  event = 'VeryLazy',
  opts = {}, -- needed even when using default config

  -- recommended: disable vim's auto-folding
  config = function()
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
    require('origami').setup {
      foldKeymaps = {
        setup = false, -- modifies `h`, `l`, `^`, and `$`
      },
      autoFold = {
        enabled = false,
      },
      foldtext = {
        -- disabled: neither gitsigns.nvim nor mini.diff is installed, and origami
        -- crashes in its foldtext decoration provider when this is on without either
        gitsignsCount = false,
      },
    }
  end,
}
