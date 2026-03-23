describe('nvim-config workspace helpers', function()
  local workspace

  before_each(function()
    workspace = require('config.workspace')
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
