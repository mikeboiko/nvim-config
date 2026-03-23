local M = {}

local function delete_keymap_if_present(mode, lhs)
  if vim.fn.maparg(lhs, mode) ~= '' then
    vim.keymap.del(mode, lhs)
  end
end

function M.set_terminal_keymaps(_buffer)
  vim.keymap.set('t', '<C-g>', '<C-W>:tabp<CR>')
  vim.keymap.set('t', '<C-j>', '<C-W>j')
  vim.keymap.set('t', '<C-k>', '<C-W>k')
  vim.keymap.set('t', '<C-h>', '<C-W>h')
  vim.keymap.set('t', '<C-l>', '<C-W>l')
end

function M.register()
  delete_keymap_if_present('n', '<C-W><C-D>')
  delete_keymap_if_present('n', '<C-W>d')

  vim.keymap.set('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
  vim.keymap.set('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
  vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
  vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

  vim.keymap.set('n', 'qt', function()
    if vim.fn.tabpagenr('$') == 1 then
      vim.cmd('quit')
    else
      vim.cmd('tabclose')
    end
  end, { silent = true })

  vim.keymap.set('n', 'qj', '<C-W>j', { desc = 'Move to window below' })
  vim.keymap.set('n', 'qk', '<C-W>k', { desc = 'Move to window above' })
  vim.keymap.set('n', 'qh', '<C-W>h', { desc = 'Move to left window' })
  vim.keymap.set('n', 'ql', '<C-W>l', { desc = 'Move to right window' })
  vim.keymap.set('n', '<C-h>', '<C-W>h', { desc = 'Move to left window' })
  vim.keymap.set('n', '<C-l>', '<C-W>l', { desc = 'Move to right window' })

  vim.keymap.set({ 'n', 'x', 'o' }, 'gI', 'mm:tabe %<CR>`mgizMzvzz', {
    remap = true,
    desc = 'Open current file in a tab and jump to the last insert position',
  })
  vim.keymap.set({ 'n', 'x', 'o' }, 'gT', 'mm:tabe %<CR>`mgDzMzvzz', {
    remap = true,
    desc = 'Open current file in a tab and jump to the global declaration',
  })
  vim.keymap.set({ 'n', 'x', 'o' }, 'gt', 'mm:tabe %<CR>`mgdzMzvzz', {
    remap = true,
    desc = 'Open current file in a tab and jump to the local declaration',
  })
  vim.keymap.set({ 'n', 'x', 'o' }, 'gs', 'mm:sp %<CR>`mgdzMzvzz', {
    remap = true,
    desc = 'Open current file in a split and jump to the local declaration',
  })
  vim.keymap.set({ 'n', 'x', 'o' }, 'gv', 'mm:vs %<CR>`mgdzMzvzz', {
    remap = true,
    desc = 'Open current file in a vertical split and jump to the local declaration',
  })
  vim.keymap.set('n', '<C-t>', 'mm:tabe <C-r>%<CR>`m', {
    remap = true,
    desc = 'Open current file in a new tab',
  })
  vim.keymap.set('n', '<C-Tab>', ':tabnext<CR>', { silent = true, desc = 'Go to the next tab' })
  vim.keymap.set('n', '<Tab>', ':tabprevious<CR>', { silent = true, desc = 'Go to the previous tab' })

  -- Fix standard Ctrl-i mapping. Not sure which plugin is breaking it.
  vim.keymap.set('n', '<C-i>', '<C-i>')
end

return M
