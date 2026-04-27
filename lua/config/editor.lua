local shell = require('config.shell')

local M = {}

function M.run_ex(command)
  vim.cmd(command)
end

function M.replace_m_with_blank()
  shell.replace_m_with_blank()
end

local function echo(message)
  vim.api.nvim_echo({ { message } }, false, {})
end

local function clamp_cursor(cursor)
  local row = math.max(1, math.min(cursor[1], vim.api.nvim_buf_line_count(0)))
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ''
  return { row, math.min(cursor[2], #line) }
end

local function restore_cursor(cursor)
  vim.api.nvim_win_set_cursor(0, clamp_cursor(cursor))
end

local function has_preview_window()
  for _, wininfo in ipairs(vim.fn.getwininfo()) do
    if wininfo.previewwin == 1 then
      return true
    end
  end

  return false
end

local updatable_buftypes = {
  [''] = true,
  acwrite = true,
}

function M.update_before_quit()
  if not updatable_buftypes[vim.bo.buftype] or not vim.bo.modifiable or vim.bo.readonly then
    return false
  end

  vim.cmd('update')
  return true
end

function M.quit()
  if not vim.wo.previewwindow and has_preview_window() then
    vim.cmd('pclose')
  end

  vim.cmd('quit')
end

function M.bufdo(command)
  local current_buffer = vim.api.nvim_get_current_buf()
  local ok, result = xpcall(function()
    vim.cmd('silent! bufdo ' .. command)
  end, debug.traceback)

  if vim.api.nvim_buf_is_valid(current_buffer) then
    vim.api.nvim_set_current_buf(current_buffer)
  end

  if not ok then
    error(result)
  end
end

function M.windo(command, opts)
  opts = opts or {}

  local current_window = vim.api.nvim_get_current_win()
  local prefix = opts.noautocmd and 'noautocmd ' or ''
  local ok, result = xpcall(function()
    vim.cmd(prefix .. 'windo ' .. command)
  end, debug.traceback)

  if vim.api.nvim_win_is_valid(current_window) then
    vim.api.nvim_set_current_win(current_window)
  end

  if not ok then
    error(result)
  end
end

function M.on_save()
  vim.cmd('wshada')
end

function M.reload_with_fileformat(fileformat)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local ok, result = xpcall(function()
    M.run_ex('edit ++ff=' .. fileformat)
    if fileformat == 'unix' then
      M.replace_m_with_blank()
    end
  end, debug.traceback)

  restore_cursor(cursor)

  if not ok then
    error(result)
  end
end

function M.insert_blank_line_below()
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_set_lines(0, cursor[1], cursor[1], false, { '' })
  restore_cursor(cursor)
end

function M.insert_blank_line_above()
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_set_lines(0, cursor[1] - 1, cursor[1] - 1, false, { '' })
  restore_cursor({ cursor[1] + 1, cursor[2] })
end

function M.insert_blank_line_around()
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_set_lines(0, cursor[1] - 1, cursor[1] - 1, false, { '' })
  vim.api.nvim_buf_set_lines(0, cursor[1] + 1, cursor[1] + 1, false, { '' })
  restore_cursor({ cursor[1] + 1, cursor[2] })
end

function M.append_to_current_line(suffix)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  vim.api.nvim_set_current_line(line .. suffix)
  restore_cursor(cursor)
end

function M.adjust_guifont_size(guifont, delta, is_unix)
  local pattern = is_unix and '^(.* )(%d+)$' or '^(.*:h)(%d+)$'
  local prefix, size = guifont:match(pattern)
  if not prefix or not size then
    return nil
  end

  return prefix .. tostring(tonumber(size) + delta)
end

function M.change_guifont_size(delta, opts)
  opts = opts or {}
  local is_unix = opts.is_unix
  if is_unix == nil then
    is_unix = vim.fn.has('unix') == 1
  end

  local updated = M.adjust_guifont_size(vim.o.guifont, delta, is_unix)
  if not updated then
    vim.notify('Unable to adjust guifont size: unsupported guifont format', vim.log.levels.WARN)
    return false
  end

  vim.o.guifont = updated
  return true
end

function M.font_size_plus(opts)
  return M.change_guifont_size(1, opts)
end

function M.font_size_minus(opts)
  return M.change_guifont_size(-1, opts)
end

function M.yank_all()
  local view = vim.fn.winsaveview()
  local ok, result = xpcall(function()
    vim.cmd('silent normal! ggyG')
  end, debug.traceback)

  vim.fn.winrestview(view)

  if not ok then
    error(result)
  end
end

function M.toggle_spell()
  local enabled = not vim.wo.spell
  vim.opt_local.spell = enabled
  echo(enabled and 'Spell-check enabled' or 'Spell-check disabled')
  return enabled
end

return M
