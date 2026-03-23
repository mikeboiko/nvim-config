local M = {}
local buffers = require('config.buffers')
local terminal = require('config.terminal')

local function run(command)
  pcall(vim.cmd, 'silent! ' .. command)
end

local function command_exists(name)
  return vim.fn.exists(':' .. name) > 0
end

local function delete_buffers(bufs, force)
  for _, buf in ipairs(bufs) do
    -- Preserve running terminals so CloseAll matches the old interactive behavior.
    if not terminal.is_running(buf) then
      buffers.delete(buf, { force = force })
    end
  end
end

function M.close_all()
  run('lclose')
  run('cclose')
  run('pclose')

  if command_exists('NvimTreeClose') then
    run('NvimTreeClose')
  end

  if command_exists('AerialClose') then
    run('AerialClose')
  end

  local flow_buffers = buffers.collect(terminal.is_flow_terminal)
  delete_buffers(flow_buffers, true)

  local buffer_needles = {
    'fugitive',
    'git/gap',
    'git/Linux/config/mani.yaml',
  }

  local named_buffers = buffers.collect(function(buf)
    if vim.fn.buflisted(buf) == 0 then
      return false
    end

    local name = buffers.get_name(buf)
    for _, needle in ipairs(buffer_needles) do
      if name:find(needle, 1, true) then
        return true
      end
    end

    return false
  end)
  delete_buffers(named_buffers, false)
end

return M
