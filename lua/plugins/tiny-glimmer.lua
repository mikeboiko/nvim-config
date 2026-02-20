return {
  -- tiny-glimmer.nvim
  'rachartier/tiny-glimmer.nvim',
  event = 'TextYankPost',
  config = function()
    require('tiny-glimmer').setup({
      animations = {
        fade = {
          from_color = 'DiffDelete',
          to_color = 'DiffAdd',
        },
        bounce = {
          from_color = '#ff0000',
          to_color = '#00ff00',
        },
      },
    })
  end,
}
