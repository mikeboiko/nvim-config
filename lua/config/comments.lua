-- TODO prompt function

---@param cb function: callback function receiving the todo text
local function todo_prompt(cb)
  local input = require('snacks.input')
  input({
    win = {
      relative = 'cursor',
      row = -3,
      col = 0,
    },
  }, function(text)
    if text and text ~= '' then
      -- prefix with TODO and current date
      local todo = string.format('TODO: %s', text)
      if cb then
        cb(todo)
      end
    end
  end)
end

-- Create command to insert TODO at cursor position
vim.api.nvim_create_user_command('TodoPrompt', function()
  todo_prompt(function(todo)
    local line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
    -- Get indentation of current line
    local current_line = vim.api.nvim_get_current_line()
    local indent = current_line:match('^%s+') or ''
    -- Insert the todo on a new line above current line with proper indentation
    vim.api.nvim_buf_set_lines(0, line_nr, line_nr, false, { indent .. todo })
    -- Comment the newly inserted line
    require('mini.comment').toggle_lines(line_nr + 1, line_nr + 1)
  end)
end, {})

-- Make the function available globally
vim.g.todo_prompt = todo_prompt
vim.keymap.set('n', '<leader>ti', ':TodoPrompt<CR>', { noremap = true, silent = true, desc = 'Insert TODO at cursor' })
