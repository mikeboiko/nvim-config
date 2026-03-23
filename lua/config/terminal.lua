local M = {}
local buffers = require('config.buffers')

local gap_path = vim.fn.expand('~/git/Linux/git/gap')

function M.is_terminal(buf)
  return buffers.is_valid(buf) and vim.bo[buf].buftype == 'terminal'
end

function M.is_gap_terminal(buf)
  return buffers.get_name(buf):find(gap_path, 1, true) ~= nil
end

function M.is_flow_terminal(buf)
  return buffers.get_var(buf, 'nvim_flow_terminal', 0) == 1 or buffers.get_name(buf):find('/tmp/flow', 1, true) ~= nil
end

function M.is_running(buf)
  if not M.is_terminal(buf) then
    return false
  end

  local job_id = buffers.get_var(buf, 'terminal_job_id')
  if job_id == nil then
    return false
  end

  local ok, status = pcall(vim.fn.jobwait, { job_id }, 0)
  return ok and type(status) == 'table' and status[1] == -1
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

  error('Could not determine exit status for buffer, ' .. buffers.get_name(buf))
end

function M.delete_buffer_if_exit_status_matches(buf, expected_code)
  if not buffers.is_valid(buf) then
    return false
  end

  if M.get_exit_status(buf) == expected_code then
    return buffers.delete(buf, { force = true })
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
