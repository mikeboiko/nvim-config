local M = {}

local gap_path = vim.fn.expand('~/git/Linux/git/gap')

local function get_buffer_name(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return ''
  end

  return vim.api.nvim_buf_get_name(buf)
end

local function get_buffer_var(buf, name)
  local ok, value = pcall(vim.api.nvim_buf_get_var, buf, name)
  if ok then
    return value
  end

  return nil
end

function M.is_gap_terminal(buf)
  return get_buffer_name(buf):find(gap_path, 1, true) ~= nil
end

function M.is_flow_terminal(buf)
  return get_buffer_var(buf, 'nvim_flow_terminal') == 1 or get_buffer_name(buf):find('/tmp/flow', 1, true) ~= nil
end

function M.get_exit_status(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  for index = #lines, 1, -1 do
    local line = lines[index]
    local exit_code = line:match('^%[Process exited (%d+)%]$')

    if exit_code ~= nil then
      return tonumber(exit_code)
    end

    if line ~= '' then
      break
    end
  end

  error('Could not determine exit status for buffer, ' .. get_buffer_name(buf))
end

function M.delete_buffer_if_exit_status_matches(buf, expected_code)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  if M.get_exit_status(buf) == expected_code then
    vim.api.nvim_buf_delete(buf, { force = true })
    return true
  end

  return false
end

function M.on_term_open(buf)
  if M.is_gap_terminal(buf) then
    vim.cmd('startinsert')
  end
end

function M.on_term_close(buf)
  if M.is_gap_terminal(buf) then
    pcall(vim.cmd, 'stopinsert')
  end

  local should_autoclose = M.is_gap_terminal(buf) or (vim.g.term_close == '++close' and M.is_flow_terminal(buf))
  if not should_autoclose then
    return
  end

  -- The '[Process exited N]' marker is appended after TermClose, so defer slightly.
  vim.defer_fn(function()
    M.delete_buffer_if_exit_status_matches(buf, 0)
  end, 20)
end

return M
