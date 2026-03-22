local source = debug.getinfo(1, 'S').source:sub(2)
local root = vim.fn.fnamemodify(source, ':p:h:h:h')
local kql_ftdetect = root .. '/after/ftdetect/kql.lua'
local sebol_ftdetect = root .. '/after/ftdetect/sebol.lua'

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
    vim.cmd('bwipe!')

    vim.cmd('enew')
    vim.cmd('setfiletype vader')
    assert.are.equal('#%s', vim.bo.commentstring)
    vim.cmd('bwipe!')
  end)
end)
