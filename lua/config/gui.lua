local M = {}

function M.run_command(command)
  vim.cmd(command)
end

function M.run_system(command)
  return vim.fn.system(command)
end

function M.is_available()
  return vim.fn.has('gui_running') == 1 or vim.fn.has('gui') == 1
end

function M.apply_options()
  pcall(function()
    vim.opt.guioptions:remove({ 'm', 'T' })
  end)
end

function M.on_gui_enter(opts)
  opts = opts or {}
  local is_unix = opts.is_unix
  if is_unix == nil then
    is_unix = vim.fn.has('unix') == 1
  end

  M.run_command('set vb t_vb=')

  if is_unix then
    local windowid = opts.windowid or vim.v.windowid
    M.run_system('wmctrl -i -b add,maximized_vert,maximized_horz -r ' .. windowid)
    return 'wmctrl'
  end

  M.run_command('simalt ~x')
  return 'simalt'
end

return M
