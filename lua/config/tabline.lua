local M = {}

function M.label(tabnr)
  local buffers = vim.fn.tabpagebuflist(tabnr)
  local window_number = vim.fn.tabpagewinnr(tabnr)
  local buffer_name = vim.fn.bufname(buffers[window_number])

  return vim.fn.fnamemodify(buffer_name, ':t')
end

function M.render()
  local parts = {}
  local current_tab = vim.fn.tabpagenr()
  local last_tab = vim.fn.tabpagenr('$')

  for tabnr = 1, last_tab do
    table.insert(parts, tabnr == current_tab and '%#TabLineSel#' or '%#TabLine#')
    table.insert(parts, '%' .. tabnr .. 'T')
    table.insert(parts, ' ' .. M.label(tabnr) .. ' ')
  end

  table.insert(parts, '%#TabLineFill#%T')

  return table.concat(parts)
end

function M.register_legacy_functions()
  _G.nvim_config_tab_label_legacy = function(tabnr)
    return M.label(tabnr)
  end

  _G.nvim_config_tabline_legacy = function()
    return M.render()
  end

  vim.cmd([[
function! MyTabLabel(n) abort
  return v:lua.nvim_config_tab_label_legacy(a:n)
endfunction

function! MyTabLine() abort
  return v:lua.nvim_config_tabline_legacy()
endfunction
]])
end

return M
