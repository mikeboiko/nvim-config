local opt = vim.opt

-- Enable persistant undo
UNDODIR = '/home/' .. USER .. '/.cache/nvim/undo//'
if vim.fn.isdirectory(UNDODIR) == 0 then
  vim.fn.mkdir(UNDODIR, 'p', '0o700')
end
opt.undodir = UNDODIR
opt.undofile = true

opt.termguicolors = true
opt.background = 'dark'

-- opt.foldcolumn = '1' -- '0' is not bad
opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldmethod = 'expr'
opt.foldexpr = 'nvim_treesitter#foldexpr()'
