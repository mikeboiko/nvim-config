local M = {}

local function display_width(text)
  return vim.fn.strdisplaywidth(text)
end

local function max_label_width()
  return math.max(6, math.min(28, vim.o.columns - 10))
end

local function truncate_label(label, width)
  if display_width(label) <= width then
    return label
  end

  if width <= 3 then
    return vim.fn.strcharpart(label, 0, width)
  end

  return vim.fn.strcharpart(label, 0, width - 3) .. '...'
end

local function build_tab_items(last_tab)
  local items = {}
  local width = max_label_width()

  for tabnr = 1, last_tab do
    local text = ' ' .. truncate_label(M.label(tabnr), width) .. ' '
    items[tabnr] = {
      tabnr = tabnr,
      text = text,
      width = display_width(text),
    }
  end

  return items
end

local function select_visible_range(items, current_tab, max_width)
  local item_count = #items
  local overflow_width = display_width(' < ')
  local prefix_widths = { 0 }
  local best

  for index, item in ipairs(items) do
    prefix_widths[index + 1] = prefix_widths[index] + item.width
  end

  for left = 1, current_tab do
    for right = current_tab, item_count do
      local total_width = prefix_widths[right + 1] - prefix_widths[left]

      if left > 1 then
        total_width = total_width + overflow_width
      end

      if right < item_count then
        total_width = total_width + overflow_width
      end

      if total_width <= max_width then
        local candidate = {
          left = left,
          right = right,
          visible_count = right - left + 1,
          center_offset = math.abs(((left + right) / 2) - current_tab),
        }

        if
          best == nil
          or candidate.visible_count > best.visible_count
          or (candidate.visible_count == best.visible_count and candidate.center_offset < best.center_offset)
          or (
            candidate.visible_count == best.visible_count
            and candidate.center_offset == best.center_offset
            and left < best.left
          )
        then
          best = candidate
        end
      end
    end
  end

  if best == nil then
    return current_tab, current_tab
  end

  return best.left, best.right
end

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
  local items = build_tab_items(last_tab)
  local first_visible, last_visible = select_visible_range(items, current_tab, vim.o.columns)

  table.insert(parts, '%<')

  if first_visible > 1 then
    table.insert(parts, '%#TabLineFill#%T')
    table.insert(parts, ' < ')
  end

  for tabnr = first_visible, last_visible do
    table.insert(parts, tabnr == current_tab and '%#TabLineSel#' or '%#TabLine#')
    table.insert(parts, '%' .. tabnr .. 'T')
    table.insert(parts, items[tabnr].text)
  end

  if last_visible < last_tab then
    table.insert(parts, '%#TabLineFill#%T')
    table.insert(parts, ' > ')
  end

  table.insert(parts, '%#TabLineFill#%T')

  return table.concat(parts)
end

return M
