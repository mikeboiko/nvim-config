local api = vim.api

local M = {}

local padding_namespace = api.nvim_create_namespace('nvim-config-markdown-table-padding')
local autocmd_group = api.nvim_create_augroup('nvim-config-markdown-padding', { clear = true })

local emphasis_query
local table_query
local refresh_scheduled = {}

local function get_queries()
  if emphasis_query and table_query then
    return emphasis_query, table_query
  end

  local ok_emphasis, parsed_emphasis = pcall(
    vim.treesitter.query.parse,
    'markdown_inline',
    [[
      [(emphasis) (strong_emphasis) (strikethrough)] @emphasis
    ]]
  )
  local ok_table, parsed_table = pcall(vim.treesitter.query.parse, 'markdown', '(pipe_table) @table')

  if not ok_emphasis or not ok_table then
    return nil
  end

  emphasis_query = parsed_emphasis
  table_query = parsed_table
  return emphasis_query, table_query
end

local function row_cells(row, cell_type)
  local cells = {}

  for child in row:iter_children() do
    if child:type() == cell_type then
      table.insert(cells, child)
    end
  end

  table.sort(cells, function(left, right)
    local _, left_start = left:range()
    local _, right_start = right:range()
    return left_start < right_start
  end)

  return cells
end

local function cell_alignment(cell, bufnr)
  local text = vim.trim(vim.treesitter.get_node_text(cell, bufnr))
  local left_aligned = text:sub(1, 1) == ':'
  local right_aligned = text:sub(-1) == ':'

  if left_aligned and right_aligned then
    return 'center'
  elseif right_aligned then
    return 'right'
  end

  return 'left'
end

local function collect_tables(parser, bufnr, query)
  local tables = {}

  parser:for_each_tree(function(tree, language_tree)
    if language_tree._lang ~= 'markdown' then
      return
    end

    for _, table_node in query:iter_captures(tree:root(), bufnr, 0, -1) do
      local start_row, _, end_row = table_node:range()
      local table_info = {
        start_row = start_row,
        end_row = end_row,
        alignments = {},
        cells_by_row = {},
      }

      for child in table_node:iter_children() do
        local child_type = child:type()
        if child_type == 'pipe_table_delimiter_row' then
          for column, cell in ipairs(row_cells(child, 'pipe_table_delimiter_cell')) do
            table_info.alignments[column] = cell_alignment(cell, bufnr)
          end
        elseif child_type == 'pipe_table_header' or child_type == 'pipe_table_row' then
          local row = child:range()
          table_info.cells_by_row[row] = row_cells(child, 'pipe_table_cell')
        end
      end

      table.insert(tables, table_info)
    end
  end)

  return tables
end

local function find_cell(tables, row, column)
  for _, table in ipairs(tables) do
    if row >= table.start_row and row < table.end_row then
      for index, cell in ipairs(table.cells_by_row[row] or {}) do
        local _, start_column, _, end_column = cell:range()
        if column >= start_column and column < end_column then
          return table.alignments[index] or 'left'
        end
      end
    end
  end

  return nil
end

local function add_padding(padding, row, column, count)
  if count == 0 then
    return
  end

  local key = row .. ':' .. column
  if padding[key] then
    padding[key].text = padding[key].text .. string.rep(' ', count)
  else
    padding[key] = {
      row = row,
      column = column,
      text = string.rep(' ', count),
    }
  end
end

local function collect_padding(parser, bufnr, tables, query)
  local padding = {}

  parser:for_each_tree(function(tree, language_tree)
    if language_tree._lang ~= 'markdown_inline' then
      return
    end

    for _, emphasis in query:iter_captures(tree:root(), bufnr, 0, -1) do
      local start_row, start_column, end_row = emphasis:range()
      if start_row ~= end_row then
        goto continue
      end

      local alignment = find_cell(tables, start_row, start_column)
      if not alignment then
        goto continue
      end

      local delimiters = {}
      for child in emphasis:iter_children() do
        if child:type():find('delimiter', 1, true) then
          table.insert(delimiters, child)
        end
      end

      if #delimiters == 0 then
        goto continue
      end

      local _, first_column = delimiters[1]:range()
      local _, _, _, last_column = delimiters[#delimiters]:range()
      local delimiter_width = 0
      for _, delimiter in ipairs(delimiters) do
        delimiter_width = delimiter_width + vim.fn.strdisplaywidth(vim.treesitter.get_node_text(delimiter, bufnr))
      end

      if alignment == 'right' then
        add_padding(padding, start_row, first_column, delimiter_width)
      elseif alignment == 'center' then
        local before = math.floor(delimiter_width / 2)
        add_padding(padding, start_row, first_column, before)
        add_padding(padding, start_row, last_column, delimiter_width - before)
      else
        add_padding(padding, start_row, last_column, delimiter_width)
      end

      ::continue::
    end
  end)

  local result = {}
  for _, item in pairs(padding) do
    table.insert(result, item)
  end

  table.sort(result, function(left, right)
    if left.row == right.row then
      return left.column < right.column
    end
    return left.row < right.row
  end)

  return result
end

function M.compute_padding(bufnr)
  local emphasis, tables = get_queries()
  if not emphasis or not tables then
    return {}
  end

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, 'markdown')
  if not ok then
    return {}
  end

  parser:parse(true)
  return collect_padding(parser, bufnr, collect_tables(parser, bufnr, tables), emphasis)
end

local function conceal_is_active()
  return vim.wo.conceallevel >= 2
end

function M.refresh(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = api.nvim_get_current_buf()
  end
  if not api.nvim_buf_is_valid(bufnr) then
    return 0
  end

  api.nvim_buf_clear_namespace(bufnr, padding_namespace, 0, -1)
  if vim.bo[bufnr].filetype ~= 'markdown' or api.nvim_get_current_buf() ~= bufnr or not conceal_is_active() then
    return 0
  end

  local padding = M.compute_padding(bufnr)
  for _, item in ipairs(padding) do
    api.nvim_buf_set_extmark(bufnr, padding_namespace, item.row, item.column, {
      right_gravity = false,
      virt_text = { { item.text, 'Conceal' } },
      virt_text_pos = 'inline',
    })
  end

  return #padding
end

function M.schedule_refresh(bufnr)
  if refresh_scheduled[bufnr] then
    return
  end

  refresh_scheduled[bufnr] = true
  vim.schedule(function()
    refresh_scheduled[bufnr] = nil
    if api.nvim_buf_is_valid(bufnr) then
      M.refresh(bufnr)
    end
  end)
end

function M.setup_buffer(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = api.nvim_get_current_buf()
  end
  if vim.b[bufnr].markdown_padding_setup then
    M.schedule_refresh(bufnr)
    return
  end

  vim.b[bufnr].markdown_padding_setup = true
  api.nvim_create_autocmd({
    'BufEnter',
    'BufWinEnter',
    'InsertEnter',
    'InsertLeave',
    'ModeChanged',
    'OptionSet',
    'TextChanged',
    'TextChangedI',
    'WinEnter',
  }, {
    group = autocmd_group,
    buffer = bufnr,
    callback = function(args)
      if args.event == 'OptionSet' and args.match ~= 'conceallevel' and args.match ~= 'concealcursor' then
        return
      end
      M.schedule_refresh(args.buf)
    end,
  })

  M.schedule_refresh(bufnr)
end

return M
