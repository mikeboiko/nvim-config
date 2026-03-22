local M = {}

local function get_commentstring()
  return require('config.comments').get_commentstring()
end

local function has_loaded_script(needle)
  local scriptnames = vim.fn.execute('scriptnames')
  return scriptnames:lower():find(needle:lower(), 1, true) ~= nil
end

local function get_fold_marker_string()
  return vim.g.fold_marker_string or '{{{'
end

local function fold_level(line_num)
  return vim.fn.foldlevel(line_num)
end

function M.open_current_fold()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local ok = pcall(vim.cmd, 'silent foldopen!')

  if not ok then
    vim.api.nvim_win_set_cursor(0, cursor)
  end
end

function M.find_fold_start(line_num, level)
  local current_line = line_num or vim.fn.line('.')
  local target_level = level or fold_level(current_line)

  if target_level <= 0 then
    return current_line
  end

  local start_line = current_line
  while start_line > 1 and fold_level(start_line - 1) >= target_level do
    start_line = start_line - 1
  end

  return start_line
end

function M.remove_filetype_specific(line)
  local text = line
  local filetype = vim.bo.filetype

  if filetype == 'python' then
    text = vim.fn.substitute(text, [[\<def\>\|\<class\>]], '', 'g')
  elseif filetype == 'cs' then
    text = vim.fn.substitute(
      text,
      [[\<static\>\|\<int\>\|\<float\>\|\<void\>\|\<string\>\|\<bool\>\|\<private\>\|\<public\>\s]],
      '',
      'g'
    )
  elseif filetype == 'vim' then
    text = vim.fn.substitute(text, [[\<function\>!\s]], '', 'g')
  elseif filetype == 'markdown' then
    text = vim.fn.substitute(text, '#', '', 'g')
  elseif filetype == 'javascript' then
    text = vim.fn.substitute(text, [[=\|{\s]], '', 'g')
  elseif filetype == 'yaml' then
    text = vim.fn.substitute(text, ':', '', 'g')
  end

  return text
end

function M.remove_special_characters(line)
  local text = line
  local comment_prefix = vim.fn.substitute(get_commentstring(), '%s', '', '')

  text = vim.fn.substitute(text, get_fold_marker_string() .. [[\d\=]], '', 'g')
  text = vim.fn.substitute(text, '{', '', 'g')

  if comment_prefix ~= '' then
    text = vim.fn.substitute(text, comment_prefix, '', 'g')
  end

  text = vim.fn.substitute(text, [[ \{2,}]], ' ', 'g')
  text = vim.fn.substitute(text, [[^\s*\|\s*$]], '', 'g')
  text = vim.fn.substitute(text, [[(\(.*\)]], '()', 'g')

  return ' ' .. text .. ' '
end

function M.format_fold_string(line_num)
  local line = vim.fn.getline(line_num)
  line = M.remove_filetype_specific(line)
  line = M.remove_special_characters(line)
  return line
end

function M.get_fold_strings(line_num)
  local current_line = line_num or vim.fn.line('.')
  local level = fold_level(current_line)

  if level <= 0 then
    return '|'
  end

  local parts = {}
  for current_level = 1, level do
    table.insert(parts, M.format_fold_string(M.find_fold_start(current_line, current_level)))
  end

  return '|' .. table.concat(parts, '|') .. '|'
end

function M.get_last_fold_string(line_num)
  local current_line = line_num or vim.fn.line('.')
  local filetype = vim.bo.filetype
  local include_context = filetype == 'markdown'
    or filetype == 'vim'
    or (filetype == 'python' and has_loaded_script('vim-coiled-snake'))

  if not include_context or fold_level(current_line) <= 0 then
    return ''
  end

  return M.format_fold_string(M.find_fold_start(current_line)) .. '|$}{$'
end

function M.fold_text()
  return vim.v.folddashes .. M.format_fold_string(vim.v.foldstart)
end

function M.find_local(pattern)
  local found_line = vim.fn.search(pattern)
  if found_line ~= 0 then
    M.open_current_fold()
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local items = {}

  for line_num, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    local col = vim.fn.match(line, pattern)

    if col >= 0 then
      table.insert(items, {
        bufnr = bufnr,
        lnum = line_num,
        col = col + 1,
        text = M.get_last_fold_string(line_num) .. line,
      })
    end
  end

  vim.fn.setloclist(0, {}, 'r', {
    title = 'FindLocal ' .. pattern,
    items = items,
  })
  vim.cmd('silent top lopen')
end

return M
