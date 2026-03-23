local opt = vim.opt
local tabline = require('config.tabline')

tabline.register_legacy_functions()

opt.number = true
opt.scrolloff = 8
opt.wildmenu = true
opt.showcmd = true
opt.showmode = false
opt.lazyredraw = true
opt.linebreak = true
opt.laststatus = 2

vim.cmd([[set shada=!,'2000,<50,s10,h]])
vim.cmd([[set shada^=rterm://,rfugitive,rman:,rhealth:,r/mnt/]])

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

-- Enable persistant undo
UNDODIR = '/home/' .. USER .. '/.cache/nvim/undo//'
if vim.fn.isdirectory(UNDODIR) == 0 then
  vim.fn.mkdir(UNDODIR, 'p', '0o700')
end
opt.undodir = UNDODIR
opt.undofile = true

opt.termguicolors = true
opt.background = 'dark'

if vim.fn.executable('ag') == 1 then
  opt.grepprg = 'ag --silent --vimgrep --column $*'
  opt.grepformat = '%f:%l:%c:%m'
end

-- opt.foldcolumn = '1' -- '0' is not bad
opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldmethod = 'expr'
opt.foldexpr = 'nvim_treesitter#foldexpr()'
opt.showtabline = 2
opt.tabline = "%!v:lua.require'config.tabline'.render()"
opt.foldtext = "v:lua.require'config.folds'.fold_text()"

-- -- Show/hide virtual lines for diagnostics
-- local og_virt_text
-- local og_virt_line
-- vim.api.nvim_create_autocmd({ 'CursorMoved', 'DiagnosticChanged' }, {
--   group = vim.api.nvim_create_augroup('diagnostic_only_virtlines', {}),
--   callback = function()
--     if og_virt_line == nil then
--       og_virt_line = vim.diagnostic.config().virtual_lines
--     end

--     -- ignore if virtual_lines.current_line is disabled
--     if not (og_virt_line and og_virt_line.current_line) then
--       if og_virt_text then
--         vim.diagnostic.config({ virtual_text = og_virt_text })
--         og_virt_text = nil
--       end
--       return
--     end

--     if og_virt_text == nil then
--       og_virt_text = vim.diagnostic.config().virtual_text
--     end

--     local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1

--     if vim.tbl_isempty(vim.diagnostic.get(0, { lnum = lnum })) then
--       vim.diagnostic.config({ virtual_text = og_virt_text })
--     else
--       vim.diagnostic.config({ virtual_text = false })
--     end
--   end,
-- })

vim.diagnostic.config({
  virtual_text = true,
  -- virtual_lines = { current_line = true },
  virtual_lines = false,
  underline = true,
  update_in_insert = false,
})

-- Enable project-specific settings
vim.opt.exrc = true
vim.opt.secure = true
