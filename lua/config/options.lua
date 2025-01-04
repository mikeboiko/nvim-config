vim.opt.termguicolors = true
vim.o.background = 'dark'

-- Enable persistant undo
UNDODIR = '/home/' .. USER .. '/.cache/nvim/undo//'
if vim.fn.isdirectory(UNDODIR) == 0 then
  vim.fn.mkdir(UNDODIR, 'p', '0o700')
end
vim.opt.undodir = UNDODIR
vim.opt.undofile = true
