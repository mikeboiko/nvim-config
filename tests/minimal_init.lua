local source = debug.getinfo(1, 'S').source:sub(2)
local root = vim.fn.fnamemodify(source, ':p:h:h')

vim.opt.runtimepath:prepend(root)

local plenary_path = os.getenv('PLENARY_PATH') or (vim.fn.stdpath('data') .. '/lazy/plenary.nvim')
if (vim.uv or vim.loop).fs_stat(plenary_path) then
  vim.opt.runtimepath:prepend(plenary_path)
end

vim.g.mapleader = ' '
vim.g.init_debug = false
vim.g.nvim_config_test = true
vim.opt.swapfile = false
vim.cmd('filetype plugin on')

vim.opt.clipboard = 'unnamedplus'

local test_clipboard = vim.fn.tempname()
vim.fn.writefile({}, test_clipboard)

local function clipboard_command(command)
  return { 'sh', '-c', command, 'nvim-test-clipboard', test_clipboard }
end

vim.g.clipboard = {
  name = 'file-backed test clipboard',
  copy = {
    ['+'] = clipboard_command('cat > "$1"'),
    ['*'] = clipboard_command('cat > "$1"'),
  },
  paste = {
    ['+'] = clipboard_command('cat "$1"'),
    ['*'] = clipboard_command('cat "$1"'),
  },
  cache_enabled = 0,
}

vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    os.remove(test_clipboard)
  end,
})
