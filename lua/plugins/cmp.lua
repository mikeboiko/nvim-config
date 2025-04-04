return {
  { -- nvim-cmp {{{1
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    config = function()
      local cmp = require('cmp')

      local has_words_before = function()
        if vim.bo.buftype == 'prompt' then
          return false
        end
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match('^%s*$') == nil
      end

      cmp.setup({
        sources = {
          -- Copilot Source
          { name = 'copilot', group_index = 2 },
          -- Other Sources
          { name = 'nvim_lsp', group_index = 2 },
          { name = 'path', group_index = 2 },
          -- { name = "luasnip", group_index = 2 },
        },

        mapping = {
          ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
          ['<Tab>'] = vim.schedule_wrap(function(fallback)
            if cmp.visible() and has_words_before() then
              -- cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end),
          ['<S-Tab>'] = vim.schedule_wrap(function(fallback)
            if cmp.visible() and has_words_before() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end),
        },
      })
    end,
  }, -- }}}
}
-- vim: foldmethod=marker:foldlevel=1
