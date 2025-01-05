" Functions {{{1

" FoldText {{{2
function! FormatFoldString(lineNum) " {{{3
    " Format fold string so it looks neat
    " Get the line string of the current fold and remove special chars
    let line = getline(a:lineNum)
    " Remove programming language specific words
    let line = RemoveFiletypeSpecific(line)
    " Remove special (comment related) characters and extra spaces
    let line = RemoveSpecialCharacters(line)
    return line
endfunction

function! RemoveSpecialCharacters(line) " {{{3
    " Remove special (comment related) characters and extra spaces
    " Characters: " # ; /* */ // <!-- --> g:fold_marker_string
    " Remove fold marker
    let text = substitute(a:line, g:fold_marker_string.'\d\=', '', 'g')
    " let text = substitute(a:line, g:fold_marker_string.'\d\=\|'.substitute(GetCommentString(), '%s', '', '').'\d\=\|', '', 'g')
    let text = substitute(text, substitute(GetCommentString(), '%s', '', ''), '', 'g')
    " let text = substitute(text, substitute('# %s', '%s', '', ''), '', 'g')
    " Replace 2 or more spaces with a single space
    let text = substitute(text, ' \{2,}', ' ', 'g')
    " Remove leading and trailing spaces
    let text = substitute(text, '^\s*\|\s*$', '', 'g')
    " Remove text between () in functions
    let text = substitute(text, '(\(.*\)', '()', 'g')
    " Add nice padding
    return " ".text." "
endfunction

function! RemoveFiletypeSpecific(line) " {{{3
    " Remove programming language specific words
    let text = a:line
    if (&ft=='python')
        let text = substitute(a:line, '\<def\>\|\<class\>', '', 'g')
    elseif  (&ft=='cs')
        let text = substitute(a:line, '\<static\>\|\<int\>\|\<float\>\|\<void\>\|\<string\>\|\<bool\>\|\<private\>\|\<public\>\s', '', 'g')
    elseif  (&ft=='vim')
        let text = substitute(a:line, '\<function\>!\s', '', 'g')
    elseif  (&ft=='markdown')
        let text = substitute(a:line, '#', '', 'g')
    elseif  (&ft=='javascript')
        let text = substitute(a:line, '=\|{\s', '', 'g')
    elseif  (&ft=='yaml')
        let text = substitute(a:line, ':', '', 'g')
    endif
    return text
endfunction
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

" Quit {{{2

" Close location list, preview window and quit
function! Quit()
    if (&buftype != "quickfix")
        lclose
    endif
    if (!&previewwindow)
        pclose
    endif
    quit
endf

function! BufDo(command) " {{{2
    " Just like bufdo, but restore the current buffer when done.
    let currBuff=bufnr('%')
    silent! execute 'bufdo ' . a:command
    silent! execute 'buffer ' . currBuff
endfunction

function! CloseAll() " {{{2
    " Close all loc lists, qf, preview and terminal windows
    lclose
    cclose
    pclose
    NvimTreeClose
    " CopilotChatClose
    for bufname in ['^fugitive', '/tmp/flow', 'git/gap', '~/git/Linux/config/mani.yaml', 'dotnet-test.sh']
      let buffers = join(filter(range(1, bufnr('$')), 'buflisted(v:val) && bufname(v:val) =~# bufname'), ' ')
      if trim(buffers) !=? ''
        silent! exe 'bdelete '. buffers
      endif
    endfor
endf

function! CloseQuickFixWindow() " {{{2
    " If the window is quickfix, proceed
    if &buftype=="quickfix"
        " If this window is last on screen quit without warning
        if winbufnr(2) == -1
            quit!
        endif
    endif
endfunction

function! CommentYank() "{{{2
  normal! mz
  let line = substitute(getline('.'), '\n$', '', '')
  silent put!=line
  lua require('mini.comment').toggle_lines(vim.fn.line('.'), vim.fn.line('.'))
  normal! `z
endfunction

function! EditCommonFile(filename) " {{{2
    " Open file in new teb
    let current_filename = expand('%:t')
    let openfilestring = 'tabedit ' . a:filename
    silent exec openfilestring
endfunction

function! Figlet(...) " {{{2
    " Print ascii art comment

    " Read figlet output into list
    let lines = systemlist('figlet ' . a:1)

    " Add comments to each lines
    call map(lines, {index, val -> trim(substitute(GetCommentString(), '%s', '', '') . val)})
    " call writefile(lines, expand("/tmp/figlet.txt"))

    " Dump list on screen
    put=lines

endfunction

function! GetBufferList() " {{{2
    " load all current buffers into a list
    redir =>buflist
    silent! ls!
    redir END
    return buflist
endfunction

function! GetCommentString() "{{{2
  let commentstring = luaeval("require('ts_context_commentstring').calculate_commentstring()")
  " ts_context_commentstring only works for html/js/vue
  if commentstring == v:null
    let commentstring = &commentstring
  endif
  return commentstring
endfunction

function! GetCurrentGitRepo() " {{{2
    let result = system('basename "$(git -C ' . expand('%:h') . ' rev-parse --show-toplevel)"')
    if v:shell_error || stridx(result, 'fatal') != -1
        return ''
    else
        return substitute(result, '\n', '', 'g')
    endif
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

function! GitAddCommitPush() abort " {{{2
    " Git - add all, commit and push

    if g:vira_active_issue ==? 'none' || get(g:, 'vira_commit_text_enable', '') ==? ''
      let commit_text=''
    else
      let commit_text=g:vira_active_issue . ':'
    endif

    if has('unix') " Linux
        if has('nvim')
            exe 'sp term://bash ~/git/Linux/git/gap'
        else
            exe 'term ++close bash --login -c "export TERM=tmux-256color; '.$HOME.'/git/Linux/git/gap '.commit_text.'"'
        endif
    else " Windows
        exe '!"C:\Program Files\Git\usr\bin\bash.exe" ~/git/Linux/git/gap '.commit_text
    endif
    redraw!

endfunction

function! GitDeleteBranch() abort " {{{2
    " Delete branch for active vira issue

    if g:vira_active_issue ==? 'none'
      echom 'Please select issue first'
      return
    endif
    if g:vira_active_issue ==# FugitiveHead()
      echom 'Change branch first'
      return
    endif

    execute('Git branch -d ' . g:vira_active_issue)
    execute('Git push origin --delete ' . g:vira_active_issue)

endfunction

function! GitMerge() abort " {{{2
    " Merge active vira issue branch into dev

    if g:vira_active_issue !=# FugitiveHead()
      echom 'Issue and branch dont match'
      return
    endif

    " Hacky method to merge into dev if it exists, otherwise merge into master
    Git checkout master
    Git checkout dev

    " Merge message is like: 'VIRA-123: merge"
    execute('Git merge -m "'. g:vira_active_issue . ': merge" ' . ' --no-ff ' . g:vira_active_issue)
    Git push

endfunction

function! GitNewBranch() abort " {{{2
    " Create new git branch based on active vira issue

    if g:vira_active_issue ==? 'none'
      echom 'Please select issue first'
      return
    endif
    execute('Git checkout -b ' . g:vira_active_issue)
    Git push -u

endfunction

function! InsertInlineComment(fold_marker) "{{{2
  execute 'normal! A ' . substitute(GetCommentString(), '%s', g:fold_marker_string . a:fold_marker, '')
endfunction

function! InstallVimspectorGadgets(info) " {{{2
  if a:info.status == 'installed' || a:info.force
    !./install_gadget.py --enable-python
    !./install_gadget.py --enable-go --update-gadget-config
    !./install_gadget.py --force-enable-csharp --update-gadget-config
    !./install_gadget.py --force-enable-node --update-gadget-config
  endif
endfunction

function! MyTabLabel(n) " {{{2
  " The tab label looks better as file name only - without entire path
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let buf = bufname(buflist[winnr - 1])
  return fnamemodify(buf, ':t')
endfunction

function! MyTabLine() " {{{2
  let tabstring = ''

  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let tabstring .= '%#TabLineSel#'
    else
      let tabstring .= '%#TabLine#'
    endif
    " set the tab page number (for mouse clicks)
    let tabstring .= '%' . (i + 1) . 'T'
    " the label is made by MyTabLabel()
    let tabstring .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let tabstring .= '%#TabLineFill#%T'

  " " right-align the label to close the current tab page
  " if tabpagenr('$') > 1
    " let tabstring .= '%=%#TabLine#%999Xclose'
  " endif

  return tabstring
endfunction

function! OnSave() " {{{2
  wshada
endfunction

function! PasteClipboard() abort " {{{2
  " See https://github.com/ferrine/md-img-paste.vim
  let targets = filter(
        \ systemlist('xclip -selection clipboard -t TARGETS -o'),
        \ 'v:val =~# ''application/x-qt-image''')

  " Paste regular text if not an image
  if empty(targets)
    normal! o
    normal! ==
    normal! P
    return
  endif

  " Paste image into markdown document
  call mdip#MarkdownClipboardImage()

endfunction

function! PromptAndComment(inline_comment, prompt_text, comment_prefix) " {{{2
    " Add inline comment and align with other inline comments

    " Prompt user for comment text
    let prompt = UserInput(a:prompt_text)

    " Abort the rest of the function if the user hit escape
    if (prompt == '') | return | endif

    " Temporarily disable auto-pairs wrapping so the comment delimiter doesn't repeat
    let b:autopairs_enabled = 0

    " Either inline comment or comment above current line
    let insert_command = (a:inline_comment) ? 'A ' : 'O'

    " Prepare execution script for adding commented line
    let exe_string = 'normal ' . insert_command . substitute(GetCommentString(), '%s', a:comment_prefix . prompt, '')

    " Add commented line to document
    exe exe_string

    " Re-enable auto-pairs
    let b:autopairs_enabled = 1

endfunction

function! SetCurrentWorkingDirectory() " {{{2
    " A standalone function to set the working directory to the project's root, or
    " to the parent directory of the current file if a root can't be found:
    let cph = expand('%:p:h', 1)
    if cph =~ '^.\+://' | retu | en
    for mkr in ['.git/', '.hg/', '.svn/', '.bzr/', '_darcs/', '.vimprojects']
        let wd = call('find'.(mkr =~ '/$' ? 'dir' : 'file'), [mkr, cph.';'])
        if wd != '' | let &acd = 0 | brea | en
    endfo
    exe 'lc!' fnameescape(wd == '' ? cph : substitute(wd, mkr.'$', '.', ''))
endfunction

function! ToggleList(bufname, pfx) " {{{2
    " Toggle QuickFix/Location List, don't change focus
    let buflist = GetBufferList()
    for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
        if bufwinnr(bufnum) != -1
            " exec('quit')
            exec(a:pfx.'close')
            return
        endif
    endfor

    " Location List
    if a:pfx ==# 'l'
        " Nicer error message than original
        if len(getloclist(0)) == 0
            echohl ErrorMsg
            echo 'Location List is Empty.'
            return
        endif
        " Open window with minimum height
        top lopen
        " QuickFix List
    elseif a:pfx ==# 'c'
        copen
    endif

endfunction

function! UserInput(prompt) " {{{2
    " Get a string input from the user
    " Get input from user
    call inputsave()
    let reply=input(a:prompt)
    call inputrestore()
    " Return the user's reply
    return l:reply
endfunction

function! WinDo(command) " {{{2
    " Just like windo, but restore the current window when done.
    let currwin=winnr()
    execute 'windo ' . a:command
    execute currwin . 'wincmd w'
endfunction

function! s:getExitStatus() abort " {{{2
  " Get the exit status from a terminal buffer by looking for a line near the end
  " of the buffer with the format, '[Process exited ?]'.
  let ln = line('$')
  " The terminal buffer includes several empty lines after the 'Process exited'
  " line that need to be skipped over.
  while ln >= 1
    let l = getline(ln)
    let ln -= 1
    let exitCode = substitute(l, '^\[Process exited \([0-9]\+\)\]$', '\1', '')
    if l != '' && l == exitCode
      " The pattern did not match, and the line was not empty. It looks like
      " there is no process exit message in this buffer.
      break
    elseif exitCode != ''
      return str2nr(exitCode)
    endif
  endwhile
  throw 'Could not determine exit status for buffer, ' . expand('%')
endfunc

function! s:afterTermClose(...) abort
  " a:0 -> number of arguments
  " a:1 -> expected name of buffer (with Process exited message)
  " a:2 -> expected exit code (default is 0)
  " This is a hack to easily handle the situation where I switched focus away
  " from the terminal window
  if bufname('%') !~# a:1
    call CloseAll()
    return
  endif

  if a:0 > 1
    let expected_code = a:2
  else
    let expected_code = 0
  end
  if s:getExitStatus() == expected_code
    bdelete!
  endif
endfunc

function! s:VimspectorDotNet(i) abort
  " Run vimspector debugger if DotNet build/test script succeeded
  let i = a:i + 1

  " Read file into memory and check if it contains the string: "Process Id:"
  let filepath = '/tmp/dotnet-test.log'
  let file = readfile(filepath)
  let found = 0
  for line in file
    if line =~# 'Process Id:'
      let found = 1
      break
    endif
  endfor

  if found
    " Launch vimspector debugger
    echo 'VimspectorDotNet passed'
    call timer_start(20, { -> vimspector#Launch() })
    return
  else
    " Keep retrying for 20 seconds
    if i > 40
      echo 'VimspectorDotNet failed'
      return
    endif
    call timer_start(500, {-> s:VimspectorDotNet(i)})
  endif

endfunc

augroup MyNeoterm
  autocmd!
  " The line '[Process exited ?]' is appended to the terminal buffer after the
  " `TermClose` event. So we use a timer to wait a few milliseconds to read the
  " exit status. Setting the timer to 0 or 1 ms is not sufficient; 20 ms seems to work for me.
  autocmd TermClose * if (g:term_close == '++close') | call timer_start(20, { -> s:afterTermClose('/tmp/flow') }) | endif
  autocmd TermClose *bash\ ~/git/Linux/git/gap call timer_start(20, { -> s:afterTermClose('/git/Linux/git/gap') })
  " autocmd TermClose *bash\ ~/git/Linux/git/gap call timer_start(20, { -> s:afterTermClose('/git/Linux/git/gap', 1) })
augroup END
