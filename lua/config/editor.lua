local M = {}

local function echo(message)
  vim.api.nvim_echo({ { message } }, false, {})
end

local function has_preview_window()
  for _, wininfo in ipairs(vim.fn.getwininfo()) do
    if wininfo.previewwin == 1 then
      return true
    end
  end

  return false
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

function M.toggle_spell()
  local enabled = not vim.wo.spell
  vim.opt_local.spell = enabled
  echo(enabled and 'Spell-check enabled' or 'Spell-check disabled')
  return enabled
end

function M.register_legacy_functions()
  _G.nvim_config_editor_quit_legacy = function()
    M.quit()
  end

  _G.nvim_config_editor_bufdo_legacy = function(command)
    M.bufdo(command)
  end

  _G.nvim_config_editor_windo_legacy = function(command, noautocmd)
    M.windo(command, { noautocmd = noautocmd == 1 or noautocmd == true })
  end

  _G.nvim_config_editor_on_save_legacy = function()
    M.on_save()
  end

  vim.cmd([[
function! Quit() abort
  call v:lua.nvim_config_editor_quit_legacy()
endfunction

function! BufDo(command) abort
  call v:lua.nvim_config_editor_bufdo_legacy(a:command)
endfunction

function! WinDo(command) abort
  call v:lua.nvim_config_editor_windo_legacy(a:command, 0)
endfunction

function! OnSave() abort
  call v:lua.nvim_config_editor_on_save_legacy()
endfunction
]])
end

return M
