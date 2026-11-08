return {
  -- csvview
  'hat0uma/csvview.nvim',
  ft = { 'csv' },
  config = function()
    local win_overlay = require('csvview.win_overlay')
    local statuscolumn = win_overlay.statuscolumn

    win_overlay.statuscolumn = function(winid)
      if not vim.api.nvim_win_is_valid(winid) then
        return ''
      end

      -- The sticky-header overlay can request a line outside the source buffer during redraw.
      local lnum = vim.v.lnum
      local bufnr = vim.api.nvim_win_get_buf(winid)
      if lnum < 1 or lnum > vim.api.nvim_buf_line_count(bufnr) then
        return ''
      end

      return statuscolumn(winid)
    end

    require('csvview').setup()
  end,
}
