local opt = vim.opt

opt.number = true
opt.scrolloff = 8
opt.wildmenu = true
opt.showcmd = true
opt.showmode = false
opt.lazyredraw = true
opt.linebreak = true
opt.laststatus = 2

opt.shada = { '!', "'2000", '<50', 's10', 'h' }
opt.shada:prepend({ 'rterm://', 'rfugitive', 'rman:', 'rhealth:', 'r/mnt/' })

opt.timeoutlen = 500
opt.ttimeoutlen = 0
opt.backspace = 'indent,eol,start'
opt.updatetime = 500
opt.virtualedit = 'all'
opt.wildignore:append({ '*.swp', 'package.json', 'package-lock.json', 'node_modules' })
opt.swapfile = false

if vim.fn.has('mac') == 1 or vim.fn.has('win32') == 1 then
  opt.clipboard = 'unnamed,unnamedplus'
elseif vim.fn.has('unix') == 1 then
  opt.clipboard = 'unnamedplus'
end

vim.g.clipboard = {
  name = 'xsel clipboard',
  copy = {
    ['+'] = { 'clipsy', 'copy' },
    ['*'] = { 'clipsy', 'copy' },
  },
  paste = {
    ['+'] = { 'clipsy', 'paste' },
    ['*'] = { 'clipsy', 'paste' },
  },
  cache_enabled = 1,
}

opt.splitright = true
opt.autochdir = true
opt.mouse = ''
opt.modeline = true
opt.modelines = 5
opt.autoread = true
opt.spellfile = vim.fn.expand('~/git/Notes/Main/en.utf-8.add')
opt.nrformats:remove({ 'octal' })

vim.cmd([[let &t_SI = "\e[6 q"]])
vim.cmd([[let &t_EI = "\e[2 q"]])

opt.autoindent = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 0
opt.expandtab = true
opt.smarttab = true

opt.incsearch = true
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Persistent undo
local undodir = vim.fn.stdpath('cache') .. '/undo'
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, 'p', '0o700')
end
opt.undodir = undodir
opt.undofile = true

opt.termguicolors = true
opt.background = 'dark'

if vim.fn.executable('ag') == 1 then
  opt.grepprg = 'ag --silent --vimgrep --column $*'
  opt.grepformat = '%f:%l:%c:%m'
end

opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldmethod = 'expr'
opt.foldexpr = 'nvim_treesitter#foldexpr()'
opt.showtabline = 2
opt.tabline = "%!v:lua.require'config.tabline'.render()"
opt.foldtext = "v:lua.require'config.folds'.fold_text()"

vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = false,
  underline = true,
  update_in_insert = false,
})

-- Enable project-specific settings
opt.exrc = true
opt.secure = true
