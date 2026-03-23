describe('nvim-config workspace helpers', function()
  local workspace

  before_each(function()
    workspace = require('config.workspace')
  end)

  after_each(function()
    pcall(vim.cmd, 'tabonly!')
  end)

  local function write_file(path, contents)
    local file = assert(io.open(path, 'w'))
    file:write(contents)
    file:close()
  end

  it('opens a file in a new tab', function()
    local file = vim.fn.tempname() .. '.txt'
    write_file(file, 'hello\n')
    local initial_tab_count = vim.fn.tabpagenr('$')

    workspace.edit_common_file(file)

    assert.are.equal(initial_tab_count + 1, vim.fn.tabpagenr('$'))
    assert.are.equal(file, vim.api.nvim_buf_get_name(0))

    vim.fn.delete(file)
  end)

  it('returns a string listing all open buffers', function()
    local file_one = vim.fn.tempname() .. '-one.txt'
    local file_two = vim.fn.tempname() .. '-two.txt'
    write_file(file_one, 'one\n')
    write_file(file_two, 'two\n')

    vim.cmd('edit ' .. vim.fn.fnameescape(file_one))
    vim.cmd('tabnew ' .. vim.fn.fnameescape(file_two))

    local buffer_list = workspace.get_buffer_list()
    assert.is_true(buffer_list:find(file_one, 1, true) ~= nil)
    assert.is_true(buffer_list:find(file_two, 1, true) ~= nil)

    vim.fn.delete(file_one)
    vim.fn.delete(file_two)
  end)

  it('searches for TODOs and restores wildignore', function()
    local original_run_ex = workspace.run_ex
    local original_wildignore = vim.opt.wildignore:get()
    local calls = {}

    workspace.run_ex = function(command)
      table.insert(calls, command)
    end

    vim.opt.wildignore = { '*.tmp' }
    workspace.get_todos()

    assert.are.same({ [[vimgrep /TODO-MB \[\d\{6}]/ **/* **/.* | cw 5]] }, calls)
    assert.are.same({ '*.tmp' }, vim.opt.wildignore:get())

    workspace.run_ex = original_run_ex
    vim.opt.wildignore = original_wildignore
  end)
end)
