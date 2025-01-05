vim.opt.termguicolors = true
vim.o.background = 'dark'

-- TODO-MB [250104] - This isn't working yet
vim.opt.foldtext = vim.fn.join({ vim.v.folddashes, vim.fn.FormatFoldString(vim.v.foldstart) }, '')

-- Enable persistant undo
UNDODIR = '/home/' .. USER .. '/.cache/nvim/undo//'
if vim.fn.isdirectory(UNDODIR) == 0 then
  vim.fn.mkdir(UNDODIR, 'p', '0o700')
end
vim.opt.undodir = UNDODIR
vim.opt.undofile = true
