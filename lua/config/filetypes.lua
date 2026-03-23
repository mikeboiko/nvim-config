local M = {}

local function get_current_syntax()
  local ok, current_syntax = pcall(vim.api.nvim_buf_get_var, 0, 'current_syntax')
  if ok then
    return current_syntax
  end

  return nil
end

local function set_current_syntax(name)
  vim.api.nvim_buf_set_var(0, 'current_syntax', name)
end

function M.apply_autohotkey_syntax()
  if get_current_syntax() == 'autohotkey' then
    return false
  end

  vim.cmd([=[
  syntax case ignore
  syntax keyword autohotkeyConditional if else
  syntax keyword autohotkeyRepeat loop while for break continue until
  syntax keyword autohotkeyCommand return send run gosub msgbox
  syntax keyword autohotkeyBoolean true false
  syntax keyword autohotkeyTodo contained TODO FIXME XXX NOTE
  syntax match autohotkeyComment ";.*$" contains=autohotkeyTodo
  syntax match autohotkeyDirective "^\s*#\w\+"
  syntax match autohotkeyVariable "%\w\+%"
  syntax match autohotkeyHotkey "^\s*[^;[:space:]].*::"
  syntax region autohotkeyString start=+"+ skip=+\\\\\|\\"+ end=+"+
  syntax region autohotkeyString start=+'+ skip=+\\\\\|\\'+ end=+'+
  hi def link autohotkeyBoolean Boolean
  hi def link autohotkeyComment Comment
  hi def link autohotkeyCommand Statement
  hi def link autohotkeyConditional Conditional
  hi def link autohotkeyDirective PreProc
  hi def link autohotkeyHotkey Identifier
  hi def link autohotkeyRepeat Repeat
  hi def link autohotkeyString String
  hi def link autohotkeyTodo Todo
  hi def link autohotkeyVariable Identifier
  ]=])

  set_current_syntax('autohotkey')
  return true
end

function M.apply_sebol_syntax()
  if get_current_syntax() == 'sebol' then
    return false
  end

  vim.cmd([[
syntax keyword basicLanguageKeywords PRINT OPEN IF
syntax keyword statusChangeKeywords exit signal qsigcancel isigmask isigunmask semlock semunlock
syntax keyword sebolTodo contained TODO FIXME XXX NOTE
syntax match sebolComment "!.*$" contains=sebolTodo
syntax match sebolComment "\*.*$" contains=sebolTodo
syntax region sebolString start=+"+ end=+"+ contained
hi def link sebolTodo Todo
hi def link sebolComment Comment
hi def link sebolBlockCmd Statement
hi def link sebolHip Type
hi def link sebolString Constant
hi def link sebolDesc PreProc
  hi def link sebolNumber Constant
  ]])

  set_current_syntax('sebol')
  return true
end

function M.surround_markdown_paragraph_with_backticks()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = vim.api.nvim_get_current_line()
  if current_line:match('^%s*$') then
    return false
  end

  local line_count = vim.api.nvim_buf_line_count(0)
  local start_line = cursor[1]
  while start_line > 1 do
    local previous_line = vim.api.nvim_buf_get_lines(0, start_line - 2, start_line - 1, false)[1] or ''
    if previous_line:match('^%s*$') then
      break
    end
    start_line = start_line - 1
  end

  local end_line = cursor[1]
  while end_line < line_count do
    local next_line = vim.api.nvim_buf_get_lines(0, end_line, end_line + 1, false)[1] or ''
    if next_line:match('^%s*$') then
      break
    end
    end_line = end_line + 1
  end

  local original_register = vim.fn.getreg('"')
  local original_register_type = vim.fn.getregtype('"')

  vim.api.nvim_buf_set_lines(0, start_line - 1, start_line - 1, false, { '```' })
  vim.api.nvim_buf_set_lines(0, end_line + 1, end_line + 1, false, { '```' })
  vim.api.nvim_win_set_cursor(0, { cursor[1] + 1, cursor[2] })
  vim.fn.setreg('"', original_register, original_register_type)

  return true
end

return M
