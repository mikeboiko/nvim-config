local M = {}

function M.label(tabnr)
  local buffers = vim.fn.tabpagebuflist(tabnr)
  local window_number = vim.fn.tabpagewinnr(tabnr)
  local buffer_name = vim.fn.bufname(buffers[window_number])

  local tail = vim.fn.fnamemodify(buffer_name, ':t')
  return tail ~= '' and tail or '[No Name]'
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

return M
