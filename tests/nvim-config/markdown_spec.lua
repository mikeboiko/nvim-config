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

    -- left-aligned cell: padding lands after the closing ** of **x** (row 2, col 7)
    -- right-aligned cell: padding lands before the opening ** of **1** (row 2, col 10)
    local positions = {}
    for _, mark in ipairs(marks) do
      positions[mark[2] .. ':' .. mark[3]] = mark[4].virt_text[1][1]
    end
    assert.equal('    ', positions['2:7'])
    assert.equal('    ', positions['2:10'])

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
