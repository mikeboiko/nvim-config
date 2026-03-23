local source = debug.getinfo(1, 'S').source:sub(2)
local root = vim.fn.fnamemodify(source, ':p:h:h:h')
local kql_ftdetect = root .. '/after/ftdetect/kql.lua'
local sebol_ftdetect = root .. '/after/ftdetect/sebol.lua'
local filetypes = require('config.filetypes')

local function write_file(path, contents)
  local fh = assert(io.open(path, 'w'))
  fh:write(contents)
  fh:close()
end

describe('nvim-config custom filetypes', function()
  it('detects sebol files and applies local tab settings', function()
    dofile(sebol_ftdetect)

    local file = vim.fn.tempname() .. '.sebol'
    write_file(file, 'PRINT "hello"\n')

    vim.cmd('edit ' .. vim.fn.fnameescape(file))

    assert.are.equal('sebol', vim.bo.filetype)
    assert.are.equal('!%s', vim.bo.commentstring)
    assert.are.equal(6, vim.bo.tabstop)
    assert.are.equal(6, vim.bo.softtabstop)
    assert.are.equal(1, vim.fn.hlexists('sebolComment'))

    vim.cmd('bwipe!')
    vim.fn.delete(file)
  end)

  it('applies migrated commentstrings for custom filetypes', function()
    dofile(kql_ftdetect)

    local file = vim.fn.tempname() .. '.kql'
    write_file(file, 'StormEvents\n')

    vim.cmd('edit ' .. vim.fn.fnameescape(file))
    assert.are.equal('kusto', vim.bo.filetype)
    assert.are.equal('//%s', vim.bo.commentstring)
    vim.cmd('bwipe!')
    vim.fn.delete(file)

    vim.cmd('enew')
    vim.cmd('setfiletype autohotkey')
    assert.are.equal(';%s', vim.bo.commentstring)
    assert.are.equal('autohotkey', vim.b.current_syntax)
    vim.cmd('bwipe!')

    vim.cmd('enew')
    vim.cmd('setfiletype vader')
    assert.are.equal('#%s', vim.bo.commentstring)
    vim.cmd('bwipe!')
  end)

  it('applies migrated help lookup maps for help and vim buffers', function()
    vim.cmd('help help')
    local help_buffer = vim.api.nvim_get_current_buf()
    local help_map = vim.fn.maparg('<Space>h', 'n', false, true)

    assert.are.equal('help', vim.bo.filetype)
    assert.are.equal('<Space>h', help_map.lhs)
    assert.are.equal(1, help_map.expr)
    assert.are.equal(1, help_map.buffer)

    vim.cmd('helpclose')
    if vim.api.nvim_buf_is_valid(help_buffer) then
      vim.api.nvim_buf_delete(help_buffer, { force = true })
    end

    local file = vim.fn.tempname() .. '.vim'
    write_file(file, 'set number\n')

    vim.cmd('edit ' .. vim.fn.fnameescape(file))
    local vim_buffer = vim.api.nvim_get_current_buf()
    local vim_map = vim.fn.maparg('<Space>h', 'n', false, true)

    assert.are.equal('vim', vim.bo.filetype)
    assert.are.equal('marker', vim.wo.foldmethod)
    assert.are.equal('<Space>h', vim_map.lhs)
    assert.are.equal(1, vim_map.expr)
    assert.are.equal(1, vim_map.buffer)

    vim.cmd('bwipe!')
    vim.fn.delete(file)

    if vim.api.nvim_buf_is_valid(vim_buffer) then
      vim.api.nvim_buf_delete(vim_buffer, { force = true })
    end
  end)

  it('applies migrated markdown buffer behavior and fenced-code helper', function()
    local original_register = vim.fn.getreg('"')
    local original_register_type = vim.fn.getregtype('"')
    local file = vim.fn.tempname() .. '.md'

    write_file(file, table.concat({
      'Before',
      '',
      'alpha',
      'beta',
      '',
      'After',
    }, '\n') .. '\n')

    vim.cmd('edit ' .. vim.fn.fnameescape(file))
    assert.are.equal('markdown', vim.bo.filetype)
    assert.is_true(vim.wo.spell)
    assert.are.equal(1, vim.fn.hlexists('markdownError'))

    local markdown_map = vim.fn.maparg('ys`', 'n', false, true)
    assert.are.equal('ys`', markdown_map.lhs)
    assert.are.equal(1, markdown_map.buffer)

    vim.fn.setreg('"', 'saved register text')
    vim.api.nvim_win_set_cursor(0, { 3, 1 })

    assert.is_true(filetypes.surround_markdown_paragraph_with_backticks())
    assert.are.same({
      'Before',
      '',
      '```',
      'alpha',
      'beta',
      '```',
      '',
      'After',
    }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    assert.are.equal('saved register text', vim.fn.getreg('"'))
    assert.are.same({ 4, 1 }, vim.api.nvim_win_get_cursor(0))

    vim.fn.setreg('"', original_register, original_register_type)
    vim.cmd('bwipe!')
    vim.fn.delete(file)
  end)
end)
