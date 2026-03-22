local M = {}

local function run(command)
  pcall(vim.cmd, 'silent! ' .. command)
end

local function command_exists(name)
  return vim.fn.exists(':' .. name) > 0
end

local function get_buffer_var(buf, name)
  local ok, value = pcall(vim.api.nvim_buf_get_var, buf, name)
  if ok then
    return value
  end

  return nil
end

local function collect_buffers(predicate)
  local matched = {}

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and predicate(buf) then
      table.insert(matched, buf)
    end
  end

  return matched
end

local function delete_buffers(buffers, force)
  local command = force and 'bdelete!' or 'bdelete'

  for _, buf in ipairs(buffers) do
    run(command .. ' ' .. buf)
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

  local flow_buffers = collect_buffers(function(buf)
    return get_buffer_var(buf, 'nvim_flow_terminal') == 1
  end)
  delete_buffers(flow_buffers, true)

  local buffer_needles = {
    'fugitive',
    'git/gap',
    'git/Linux/config/mani.yaml',
  }

  local named_buffers = collect_buffers(function(buf)
    if vim.fn.buflisted(buf) == 0 then
      return false
    end

    local name = vim.api.nvim_buf_get_name(buf)
    for _, needle in ipairs(buffer_needles) do
      if name:find(needle, 1, true) then
        return true
      end
    end

    return false
  end)
  delete_buffers(named_buffers, false)
end

function M.register_legacy_functions()
  vim.cmd([[
function! CloseAll() abort
  lua require('config.windows').close_all()
endfunction
]])
end

return M
