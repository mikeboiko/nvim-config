local M = {}

local command_sets = {
  c = { next = 'cnext', prev = 'cprev', first = 'cfirst', last = 'clast' },
  l = { next = 'lnext', prev = 'lprev', first = 'lfirst', last = 'llast' },
}

local function echo_error(message)
  vim.api.nvim_echo({ { message, 'ErrorMsg' } }, false, {})
end

local function list_is_open(prefix)
  if prefix == 'c' then
    return vim.fn.getqflist({ winid = 0 }).winid ~= 0
  end

  if prefix == 'l' then
    return vim.fn.getloclist(0, { winid = 0 }).winid ~= 0
  end

  error('Unsupported quickfix prefix: ' .. prefix)
end

function M.toggle_list(prefix)
  if prefix == 'c' then
    if list_is_open(prefix) then
      vim.cmd('cclose')
    else
      vim.cmd('copen')
    end
    return
  end

  if prefix == 'l' then
    if list_is_open(prefix) then
      vim.cmd('lclose')
      return
    end

    if #vim.fn.getloclist(0) == 0 then
      echo_error('Location List is Empty.')
      return
    end

    vim.cmd('top lopen')
    return
  end

  error('Unsupported quickfix prefix: ' .. prefix)
end

function M.cycle(prefix, direction)
  local commands = command_sets[prefix]
  if not commands then
    error('Unsupported quickfix prefix: ' .. prefix)
  end

  local primary
  local fallback

  if direction == 'next' then
    primary = commands.next
    fallback = commands.first
  elseif direction == 'prev' then
    primary = commands.prev
    fallback = commands.last
  else
    error('Unsupported quickfix direction: ' .. direction)
  end

  local ok = pcall(vim.cmd, primary)
  if not ok then
    pcall(vim.cmd, fallback)
  end
end

function M.close_window_if_last()
  if vim.bo.buftype == 'quickfix' and vim.fn.winbufnr(2) == -1 then
    vim.cmd('quit!')
  end
end

return M
