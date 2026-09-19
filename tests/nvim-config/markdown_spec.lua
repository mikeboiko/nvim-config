describe('nvim-config markdown helpers', function()
  local markdown = require('config.markdown')
  local padding_namespace = vim.api.nvim_create_namespace('nvim-config-markdown-table-padding')

  local function make_table_buffer()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      '| A     |     B |',
      '| ----- | ----: |',
      '| **x** | **1** |',
    })
    vim.bo[bufnr].filetype = 'markdown'
    vim.wo.conceallevel = 2
    vim.wo.concealcursor = 'nc'
    return bufnr
  end

  local function extmarks(bufnr)
    return vim.api.nvim_buf_get_extmarks(bufnr, padding_namespace, 0, -1, { details = true })
  end

  it('pads concealed emphasis in pipe tables when called with buffer 0', function()
    local bufnr = make_table_buffer()

    local count = markdown.refresh(0)

    assert.equal(2, count)
    local marks = extmarks(bufnr)
    assert.equal(2, #marks)

    -- left-aligned cell: padding lands at the cell end so the value stays left
    -- right-aligned cell: padding lands at the cell start so the value stays right
    local positions = {}
    for _, mark in ipairs(marks) do
      positions[mark[2] .. ':' .. mark[3]] = mark[4].virt_text[1][1]
    end
    assert.equal('    ', positions['2:8'])
    assert.equal('    ', positions['2:10'])

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('pads underscore emphasis and inline links in pipe-table cells', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      '| left | right |',
      '| ---- | ----: |',
      '| _x_  | [a](u) |',
    })
    vim.bo[bufnr].filetype = 'markdown'
    vim.wo.conceallevel = 2

    local padding = markdown.compute_padding(bufnr)
    local by_column = {}
    for _, item in ipairs(padding) do
      by_column[item.column] = item.text
    end

    -- `_x_` hides 2 underscores; `[a](u)` hides []() plus the destination
    assert.equal(2, #padding)
    assert.equal('  ', by_column[7])
    assert.equal('     ', by_column[9])

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('does not treat parentheses inside bold as concealed link markup', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      '| label |     n |',
      '| ----- | ----: |',
      '| **x (y)** | **1** |',
    })
    vim.bo[bufnr].filetype = 'markdown'
    vim.wo.conceallevel = 2

    local padding = markdown.compute_padding(bufnr)
    local widths = {}
    for _, item in ipairs(padding) do
      table.insert(widths, #item.text)
    end
    table.sort(widths)

    -- each **...** hides 4 stars, not the parentheses in (y)
    assert.equal(2, #padding)
    assert.same({ 4, 4 }, widths)

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('pads concealed code spans in right-aligned pipe-table cells', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      '| Callback |                        Delta |',
      '| -------- | ---------------------------: |',
      '| Parent   | −92% (already in `679a2b7c`) |',
      '| Harvest  |                         −87% |',
    })
    vim.bo[bufnr].filetype = 'markdown'
    vim.wo.conceallevel = 2
    vim.wo.concealcursor = 'nc'

    local padding = markdown.compute_padding(bufnr)
    assert.equal(1, #padding)
    assert.equal(2, padding[1].row)
    assert.equal('  ', padding[1].text)

    local count = markdown.refresh(bufnr)
    assert.equal(1, count)

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('clears padding when conceal is disabled', function()
    local bufnr = make_table_buffer()
    markdown.refresh(bufnr)
    assert.equal(2, #extmarks(bufnr))

    vim.wo.conceallevel = 0
    local count = markdown.refresh(bufnr)

    assert.equal(0, count)
    assert.equal(0, #extmarks(bufnr))

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)
end)
