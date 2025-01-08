return {
  { -- mini.comment {{{1
    'echasnovski/mini.comment',
    version = false,
    config = function()
      require('mini.comment').setup({
        -- Options which control module behavior
        options = {
          -- Function to compute custom 'commentstring' (optional)
          custom_commentstring = function()
            return require('ts_context_commentstring').calculate_commentstring() or vim.bo.commentstring
          end,

          -- Whether to ignore blank lines when commenting
          ignore_blank_line = true,

          -- Whether to force single space inner padding for comment parts
          pad_comment_parts = true,
        },

        -- Module mappings. Use `''` (empty string) to disable one.
        mappings = {
          -- Toggle comment (like `gcip` - comment inner paragraph) for both
          -- Normal and Visual modes
          comment = 'gc',

          -- Toggle comment on current line
          comment_line = 'cl',

          -- Toggle comment on visual selection
          comment_visual = 'cl',

          -- Define 'comment' textobject (like `dgc` - delete whole comment block)
          -- Works also in Visual mode if mapping differs from `comment_visual`
          textobject = 'gc',
        },
      })
    end,
  }, -- }}}
  { -- mini.indentscope {{{1
    'echasnovski/mini.indentscope',
    version = false,
    config = function()
      require('mini.indentscope').setup()
    end,
  }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
