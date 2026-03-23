describe('nvim-config keymap helpers', function()
  local keymaps

  before_each(function()
    package.loaded['config.keymaps'] = nil
    keymaps = require('config.keymaps')
  end)

  it('calls named global callbacks when present', function()
    local received

    vim.g.nvim_config_test_callback = function(arg_one, arg_two)
      received = { arg_one, arg_two }
    end

    assert.is_true(keymaps.call_global('nvim_config_test_callback', 'alpha', 2))
    assert.are.same({ 'alpha', 2 }, received)

    vim.g.nvim_config_test_callback = nil
  end)

  it('notifies when a named global callback is missing', function()
    local original_notify = vim.notify
    local notified

    vim.notify = function(message, level)
      notified = { message, level }
    end

    assert.is_false(keymaps.call_global('nvim_config_missing_callback'))
    assert.are.same({ 'Missing global callback: nvim_config_missing_callback', vim.log.levels.ERROR }, notified)

    vim.notify = original_notify
  end)

  it('routes rename prompts through functions.fancy_prompt_rename', function()
    local functions = require('config.functions')
    local original_fancy = functions.fancy_prompt_rename
    local normal_call
    local visual_call

    functions.fancy_prompt_rename = function(func, prompt, visual)
      if visual then
        visual_call = { func = func, prompt = prompt, visual = visual }
      else
        normal_call = { func = func, prompt = prompt, visual = visual }
      end
    end

    keymaps.prompt_rename(false)
    keymaps.prompt_rename(true)

    assert.are.equal(functions.rename_word, normal_call.func)
    assert.are.equal('New Word', normal_call.prompt)
    assert.is_nil(normal_call.visual)
    assert.are.equal(functions.rename_word, visual_call.func)
    assert.are.equal('New Word', visual_call.prompt)
    assert.are.equal(true, visual_call.visual)

    functions.fancy_prompt_rename = original_fancy
  end)

  it('sets terminal keymaps buffer-locally', function()
    vim.cmd('enew')
    local terminal_buffer = vim.api.nvim_get_current_buf()

    keymaps.set_terminal_keymaps(terminal_buffer)

    local terminal_map = vim.fn.maparg('<C-g>', 't', false, true)
    assert.are.equal('<C-G>', terminal_map.lhs)
    assert.are.equal('<C-W>:tabp<CR>', terminal_map.rhs)
    assert.are.equal(1, terminal_map.buffer)

    vim.cmd('enew')
    local other_map = vim.fn.maparg('<C-g>', 't', false, true)
    assert.is_true(vim.tbl_isempty(other_map))

    vim.cmd('bwipe!')
    vim.api.nvim_buf_delete(terminal_buffer, { force = true })
  end)

  it('opens a tab and jumps to the last insert position for gI', function()
    local file = vim.fn.tempname() .. '.txt'
    local fh = assert(io.open(file, 'w'))
    fh:write('alpha\nbeta\n')
    fh:close()

    vim.cmd('edit ' .. vim.fn.fnameescape(file))
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.cmd('normal! Axyz')
    vim.cmd('stopinsert')
    vim.cmd('normal! gg0')

    vim.cmd('normal gI')

    assert.are.equal(2, vim.fn.tabpagenr('$'))
    assert.are.equal('n', vim.api.nvim_get_mode().mode)
    assert.are.same({ 1, 7 }, vim.api.nvim_win_get_cursor(0))

    vim.cmd('tabonly!')
    vim.cmd('bwipe!')
    vim.fn.delete(file)
  end)
end)
