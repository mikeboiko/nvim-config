local source = debug.getinfo(1, 'S').source:sub(2)
local root = vim.fn.fnamemodify(source, ':p:h:h:h')
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
    assert.are.equal(6, vim.bo.tabstop)
    assert.are.equal(6, vim.bo.softtabstop)

    vim.cmd('bwipe!')
    vim.fn.delete(file)
  end)
end)
