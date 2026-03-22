" Constants {{{1

let $CODE='$HOME/git'

" Fold marker string used through vimrc file without messing up folding
let g:fold_marker_string = '{'. '{'. '{'

" By default, don't close term after <leader>rr
" This can be toggled
let g:term_close = ''

" Vim home directory
if has("unix")
    let vimHomeDir = $HOME . '/.vim'
else
    let vimHomeDir = $HOME . '/vimfiles'
endif

" Functions {{{1

" FontSize() {{{2
if has("unix")
    function! FontSizePlus ()
        let l:gf_size_whole = matchstr(&guifont, '\( \)\@<=\d\+$')
        let l:gf_size_whole = l:gf_size_whole + 1
        let l:new_font_size = ' '.l:gf_size_whole
        let &guifont = substitute(&guifont, ' \d\+$', l:new_font_size, '')
    endfunction

    function! FontSizeMinus ()
        let l:gf_size_whole = matchstr(&guifont, '\( \)\@<=\d\+$')
        let l:gf_size_whole = l:gf_size_whole - 1
        let l:new_font_size = ' '.l:gf_size_whole
        let &guifont = substitute(&guifont, ' \d\+$', l:new_font_size, '')
    endfunction
else
    function! FontSizePlus ()
        let l:gf_size_whole = matchstr(&guifont, '\(:h\)\@<=\d\+$')
        let l:gf_size_whole = l:gf_size_whole + 1
        let l:new_font_size = ':h'.l:gf_size_whole
        let &guifont = substitute(&guifont, ':h\d\+$', l:new_font_size, '')
    endfunction

    function! FontSizeMinus ()
        let l:gf_size_whole = matchstr(&guifont, '\(:h\)\@<=\d\+$')
        let l:gf_size_whole = l:gf_size_whole - 1
        let l:new_font_size = ':h'.l:gf_size_whole
        let &guifont = substitute(&guifont, ':h\d\+$', l:new_font_size, '')
    endfunction
endif

function! EditCommonFile(filename) " {{{2
    " Open file in new teb
    let current_filename = expand('%:t')
    let openfilestring = 'tabedit ' . a:filename
    silent exec openfilestring
endfunction

function! GetBufferList() " {{{2
    " load all current buffers into a list
    redir =>buflist
    silent! ls!
    redir END
    return buflist
endfunction

function! GetCommentString() "{{{2
  return luaeval("require('config.comments').get_commentstring()")
endfunction

function! GetTODOs() " {{{2
    " TODO [171103] - Add current file ONLY option
    " Binary files that can be ignored
    set wildignore+=*.jpg,*.docx,*.xlsm,*.mp4
    " Seacrch the CWD to find all of your current TODOs
    vimgrep /TODO-MB \[\d\{6}]/ **/* **/.* | cw 5
    " Un-ignore the binary files
    set wildignore-=*.jpg,*.docx,*.xlsm,*.mp4
endfunction
" Commands {{{1
" Figlet {{{2
" Draw ascii art comments
"

" Bufdo {{{2

" Just like bufdo, but restore the current buffer when done.
"

" Windo {{{2

" Just like windo, but restore the current window when done.
"

" CloseToggle {{{2
command! CloseToggle if (g:term_close == '') | let g:term_close = '++close' | echo 'Term will close' | else | let g:term_close = '' | echo 'Term will not close' | endif

" FindLocal {{{2
" Search for string in current file and put results in Location window
" \| try | silent call FindFunc(<q-args>, 'next') | catch | endtry | set hls

" FoldOpen {{{2

" Suppress errors when no fold exists
" The catch part of the command prevents an error that would move the cursor when there are no folds in the file

" Grep {{{2
" Use ag to grep and put results quickfix list
"
" Optionally, add the following flags
" Show hidden files: --hidden
" Show git ignore files: --skip-vcs-ignores

" QuickFix/Location List Next {{{2
" Wrap around after hitting first/last record

" Replace ^M Line endings {{{2

" Useful when converting from DOS to Unix line endings
"

" Useful when converting from DOS to Unix line endings
"

" Mani {{{2

"

" SpellToggle {{{2
"

" StartAsyncNeoVim {{{2

"

" Plugins{{{1
" Plugin Setup {{{2

" fugitive {{{2

augroup CustomFugitive
  autocmd!
  autocmd FileType gitcommit autocmd! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
augroup end

" vimwiki {{{2

" let g:vimwiki_list = [{'path': '~/vimwiki/',
                      " \ 'syntax': 'markdown', 'ext': '.md'}]

" Editor Settings {{{1
" Display{{{2

" Display line number for current line
set number

" Display relative line number along the left hand side
" set relativenumber

" Start scrolling <x> lines before window border
set scrolloff=8

" Visual auto complete for command menu
set wildmenu

" Show command in bottom bar
set showcmd

" Don't show Insert/Normal Mode status on last line
set noshowmode

" Do not redraw during operations such as macro
set lazyredraw

" Don't wrap/line break in the middle of a word
set linebreak

" Always display the status line even if only one window is displayed
set laststatus=2

" Display hidden char
let g:display_hidden = "hidden"

" Functionality {{{2
" Vim Start {{{3

" Save last file when exiting vim
" autocmd VimLeave * nested if (!isdirectory(vimHomeDir)) |
            " \ call mkdir(vimHomeDir) |
            " \ endif |
            " \ execute "mksession! " . vimHomeDir . "/Session.vim"

" " Go to last file(s) if invoked without arguments.
" autocmd VimEnter * nested if argc() == 0 &&
            " \ filereadable(vimHomeDir . "/Session.vim") |
            " \ try |
            " \ execute "source " . vimHomeDir . "/Session.vim"
            " \ | catch | endtry

" Have Vim jump to the last position when reopening a file
augroup CustomLastPosition
  autocmd!
  autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
              \| exe "normal! g'\"" | endif
augroup end

" General{{{3

" Optimize GVim
if has('GUI')
    " Disable annoying error bell sounds
    autocmd GUIEnter * set vb t_vb=

    " Open GVim in Maximized mode
    if has("unix")
        autocmd GUIEnter * call system('wmctrl -i -b add,maximized_vert,maximized_horz -r '.v:windowid)
    else
        autocmd GUIEnter * simalt ~x
    endif

    " Remove Menubar and Toolbar from GVIM
    set guioptions -=m
    set guioptions -=T
endif

" Increase number of oldfiles. Original is 100.
if has('nvim')
  set shada=!,'2000,<50,s10,h
  " Exclude files beginning with r<name>
  set shada^=rterm://,rfugitive,rman:,rhealth:,r/mnt/
endif

" General settings required for highlighting
" I removed this line because it was giving me an error for =bg
" syntax on

" Enable plug-ins for indentation
filetype plugin indent on

" Eliminate command windows escape delay
set timeoutlen=500 ttimeoutlen=0

" Backspace over auto indent, line breaks, start of insert
set backspace=indent,eol,start

" Remove vi compatibility
set nocompatible

" Update when idle for x ms (default is 4000 msec)
set updatetime=500

" Virtual editing, position cursor where there is are no characters (all modes)
set virtualedit=all

" Ignore file patterns globally
set wildignore+=*.swp
set wildignore+=package.json,package-lock.json,node_modules

" Standard Encoding
set encoding=utf8

" No .swp backup files
set noswapfile

" Use linux shard clipboard in VIM
if has('mac') || has('win32')
    set clipboard=unnamed,unnamedplus
elseif has('unix')
    set clipboard=unnamedplus
endif

" https://github.com/neovim/neovim/blob/master/runtime/autoload/provider/clipboard.vim#L88
let g:clipboard = {
      \   'name': 'xsel clipboard',
      \   'copy': {
      \      '+': ['clipsy', 'copy'],
      \      '*': ['clipsy', 'copy'],
      \    },
      \   'paste': {
      \      '+': ['clipsy', 'paste'],
      \      '*': ['clipsy', 'paste'],
      \   },
      \   'cache_enabled': 1,
      \ }

" Vertical splits open on the right instead of the default of left
set splitright

" Automatically change current directory when new file is opened
set autochdir

" This diables tmux mouse features while inside vim
set mouse=a

" Enable Vim to check for modelines throughout your files
" best practice to keep them at the top or the bottom of the file
set modeline
" Number of modelines to be checked, if set to zero then modeline checking
" will be disabled
set modelines=5

set autoread

augroup CustomOptions
  autocmd!
  " Don't add comment automatically on new line
  autocmd FileType * setlocal formatoptions-=cro
  " Preview Window
  autocmd WinEnter * if &previewwindow | setlocal foldmethod=manual | endif
  " Enable spelling for these buffers
  autocmd BufWinEnter,BufEnter COMMIT_EDITMSG setlocal spell
augroup end

" Spelling
set spellfile=$HOME/git/Notes/Main/en.utf-8.add

" Change error format for custom FindFunc() usage
" set efm+=%f:%l:%m

" Without this ctrl+a skips 8s and 9s when incrementing
set nrformats-=octal

" Cursor changes from block to line in insert mode
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" Indenting/Tabs{{{3
" Do smart auto indenting when starting a new line
set autoindent
" set smartindent

" Set tab width
set tabstop=4
set softtabstop=4
set shiftwidth=0

" Use spaces instead of tabs
set expandtab
" Delete spaces like tabs
set smarttab

" Searching{{{3
" Search as characters are entered
set incsearch
" Highlight search
set hlsearch
" Ignore case of given search term
set ignorecase
" Only search for matching capitals when they are used
set smartcase

" Undo Files {{{3
" Let's save undo info!
if !isdirectory(vimHomeDir)
    call mkdir(vimHomeDir, "", 0770)
endif
if !isdirectory(vimHomeDir . "/undo-dir")
    call mkdir(vimHomeDir."/undo-dir", "", 0700)
endif
set undodir=~/.vim/undo-dir
set undofile

" Language/Project Specific{{{1
" Comma/Pipe/Tab Seperated Values{{{2
" autocmd BufReadPost *.tsv,*.csv,*.psv execute 'Tabularize /,'
augroup CustomFileTypes
  autocmd!
  autocmd BufReadPost *.csv setlocal nowrap
  autocmd BufReadPost *.psv setlocal nowrap
  autocmd BufReadPost *.tsv setlocal nowrap
  " autocmd BufReadPost *.csv 1sp
  " autocmd BufReadPost *.psv 1sp
  " autocmd BufReadPost *.tsv 1sp
  " HTML/js/css/etc
  autocmd FileType html,javascript,json,vue,css,scss,yml,yaml,markdown,vim,javascriptreact,typescriptreact setlocal tabstop=2 shiftwidth=2 softtabstop=2
  " Markdown -Fix the syntax highlighting that randomly stops
  " autocmd FileType markdown set foldexpr=NestedMarkdownFolds()
augroup end

" Mappings{{{1
" Leader key {{{2
let mapleader="\<space>"

" Add char to EOL {{{2

" Colon
" inoremap :: <esc>mzA:<esc>`z
nnoremap <leader>a: mzA:<esc>`z

" Comma
" inoremap ,, <esc>mzA,<esc>`z
nnoremap <leader>a, mzA,<esc>`z

" Period
nnoremap <leader>a. mzA.<esc>`z

" Semi-Colon
" inoremap ;; <esc>mzA;<esc>`z
nnoremap <leader>a; mzA;<esc>`z

" Clipboard {{{2

nnoremap <leader>cfp :let @+ = expand("%:p:~")<CR>
nnoremap <leader>cwd :let @+ = expand("%:p:~:h")<CR>

" Close Toggle {{{2
" Toggle between ++close and ++noclose when running term <leader>rr
nnoremap <leader>ct :CloseToggle<CR>

" Close all location lists {{{2

nnoremap <leader>ca :call CloseAll()<CR>

" Commands {{{2

" Rerun last command
nnoremap qr @:

" Get into command history
nnoremap q; q:

" Comment {{{2

" Main Comment Mappings
nnoremap cp :normal mzgcap<CR>`z

" Copilot {{{2

" nnoremap <leader>ag :CopilotChatCommit<CR>

nnoremap <leader>ac :CopilotChatToggle<CR>
nnoremap <leader>af :CopilotChatFixDiagnostic<CR>
nnoremap <leader>aq :silent lua vim.g.CopilotQuickChat("Buffer")<CR>
nnoremap <leader>at :CopilotChatTests<CR>
vnoremap <leader>ac :<C-u>CopilotChatToggle<CR>
vnoremap <leader>ad :CopilotChatDocs<CR>
vnoremap <leader>ae :CopilotChatExplainBrief<CR>
vnoremap <leader>af :CopilotChatFix<CR>
vnoremap <leader>ao :CopilotChatOptimize<CR>
vnoremap <leader>aq :<C-u>silent lua vim.g.CopilotQuickChat("Visual")<CR>
vnoremap <leader>ar :CopilotChatReview<CR>

" Conflicts {{{2

" This is to fix a <C-r> conflict
nmap <leader>redo <Plug>(RepeatRedo)

" Convert Line Endings {{{2

" Convert to Dos
nnoremap <leader>ctd mz:e ++ff=dos<CR>`z

" Convert to Mac
nnoremap <leader>ctm mz:e ++ff=mac<CR>`z

" Convert to Unix
nnoremap <leader>ctu mz:e ++ff=unix<CR>:ReplaceMwithBlank<CR>`z

" End/Beginning of Line {{{2
nnoremap <silent> H ^
nnoremap <silent> L $
vnoremap <silent> H ^
vnoremap <silent> L $
omap H ^
omap L $

" Folding {{{2

" Fold Everything except for the current section
nnoremap zx zMzvzz

" Font Size Bigger/Smaller {{{2

" Font Hotkeys
if has("gui_running")
    nmap <S-F6> :call FontSizeMinus()<CR>
    nmap <F6> :call FontSizePlus()<CR>
endif

" Git {{{2

" Fugitive remappings
nnoremap <leader>gd :Gvdiffsplit!<Space>
nnoremap <leader>gdt :Git difftool -y --diff-filter=ACMRTUXB<Space>
nnoremap <leader>gs :Git<CR>

" Display git diff in terminal
nnoremap <leader>rd :terminal git --no-pager diff<CR>

" Mani commands
nnoremap <leader>ms :Mani run git-status --parallel --tags-expr '$MANI_EXPR'<cr>
nnoremap <leader>mu :Mani run git-up --parallel --tags-expr '$MANI_EXPR'<cr>

" Go to Definition{{{2

map gI mm:tabe %<CR>`mgizMzvzz
map gT mm:tabe %<CR>`mgDzMzvzz
map gt mm:tabe %<CR>`mgdzMzvzz
map gs mm:sp %<CR>`mgdzMzvzz
map gv mm:vs %<CR>`mgdzMzvzz

" Grep with ag {{{2

" Search code
nnoremap <leader>fc :Grep --<c-r>=&filetype<CR> ~/git<s-left><space><left>

" Search notes
nnoremap <leader>fn :Grep --md ~/git<s-left><space><left>

" Search git repo
nnoremap <leader>fg :let @q = system('git rev-parse --show-toplevel')[:-2]<CR>:Grep "<c-r>q"<home><s-right><space>

" Search for word under cursor in git repo
map <leader>gw "xyiw:let @q = system('git rev-parse --show-toplevel')[:-2]<CR>:Grep <c-r>x "<c-r>q"<cr>

" Find string in current file
" nnoremap <leader>fl :FindLocal<space>
nnoremap <leader>fl :Grep %<home><s-right><space>

" Find word under cursor in current file
map <leader>fw "xyiw:Grep <c-r>x %<cr>

" Marks {{{2
" Jump to proper column when using marks
nnoremap ' `

" Mouse {{{2

set mouse-=a

" " Disable mouse clicks but not scrolling
" nmap <LeftMouse> <nop>
" imap <LeftMouse> <nop>
" vmap <LeftMouse> <nop>

" Navigation {{{2
" Do not automatically adjust for line wrapping
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'

" Go back to the last file
nnoremap <BS> <C-^>

" NeoVim {{{2

" New line {{{2

" Add blank line after current line
nnoremap <leader>aj :<CR>mzo<Esc>`z:<CR>

" Add blank line before current line
nnoremap <leader>ak :<CR>mzO<Esc>`z:<CR>

" Add blank line before and after current line
nnoremap <leader>al :<CR>mzO<Esc>jo<Esc>`z:<CR>

" Restore Enter key functionality for command history window
" autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>

" Open File/Folder {{{2

" Explorer
nnoremap <leader>oe :silent !explorer.exe .<CR>:redraw!<CR>

" Browser
nnoremap <leader>ob :MarkdownPreview<CR>

" Double Commander
nnoremap <leader>od :Start -wait=never "C:\Program Files\Double Commander\doublecmd.exe" %:p:h<CR>:redraw!<CR>

" QuickFix/Location Lists {{{2

" I put this at the end of the mapping section because of some conflicts with <c-r>

" Go to next/previous search result
" nnoremap <leader>zf zMzvzz

" Plugins {{{2

" Quit {{{2

" Close extra windows then quit
"

" Close without saving
nnoremap Q :q!<CR>

" A hack to close the Fugitive Plugin window with <c-w>
nmap gf gf

"

" Rename Word {{{2

nnoremap <silent> <leader>rw :silent lua vim.g.FancyPromptRename("RenameWord", "New Word")<CR>
vnoremap <silent> <leader>rw :<C-u>silent lua vim.g.FancyPromptRename("RenameWord", "New Word", 1)<CR>

" Reports {{{2

if has('nvim')
  nnoremap <leader>tp :tabe term://cd ~/git/Tables; uv run finances balances print_balances<CR>:$<CR>
  nnoremap <leader>cw :tabe term://curl wttr.in/Calgary?m"<CR>
else
  nnoremap <leader>cw :tabe<CR>:terminal ++curwin bash -c "curl wttr.in/Calgary"<CR>
endif

" Save Buffer {{{2

nnoremap qw :w<CR>
nnoremap <c-s> :w<CR>
inoremap <c-s> <esc>:w<CR>

" Scrolling{{{2

" Scroll Up
nnoremap K 5k
vnoremap K 5k

" Scroll Down
nnoremap J 5j
vnoremap J 5j

" Search {{{2
" Search for multiple terms
nnoremap <leader>/ /\v<c-r>/\|

" Decided to disable this so it's not confusing when I use other applications with vi mode such as tmux
" Search forward and backwards consistently
" nnoremap <expr> n 'Nn'[v:searchforward]
" nnoremap <expr> N 'nN'[v:searchforward]

" Sorting {{{2
" Sort paragraph
nnoremap <leader>so vip:sort<CR>

" Source {{{2
nnoremap <leader>sv :w<CR>:so $HOME/.vimrc<CR>

" Spell Toggle {{{2
" Toggle the spelling on/off
"

" Suspend {{{2

" Don't suspend!
noremap <c-z> <nop>
" noremap <c-z>c :Start! ~/clipboard.sh --write<CR>
" noremap <c-z>v :Start! ~/clipboard.sh --read<CR>

" Tabs {{{2

" Open current file in new tab
nnoremap <c-t> mm:tabe <c-r>%<CR>`m

" Toggle tabs
nnoremap <silent> <C-Tab> :tabnext<CR>
nnoremap <silent> <Tab> :tabprevious<CR>

" Windows Style Commands {{{2

" Redo
nnoremap <c-y> <c-r>
inoremap <c-y> <Esc><C-r>

" Windows {{{2

" Move between windows/panes
nnoremap qj <C-W>j
nnoremap qk <C-W>k
nnoremap qh <C-W>h
nnoremap ql <C-W>l
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

tnoremap <C-g> <C-W>:tabp<CR>
tnoremap <C-j> <C-W>j
tnoremap <C-k> <C-W>k
tnoremap <C-h> <C-W>h
tnoremap <C-l> <C-W>l

" Yank {{{2
" Yank till the end of the line
nnoremap Y y$

" Yank all
nnoremap <leader>ya mzggyG`z
