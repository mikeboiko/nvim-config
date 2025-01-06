" =======================================================================
" === Description ...: Vim Settings
" === Author ........: Mike Boiko
" =======================================================================

setlocal foldmethod=marker

" Pull up help for word under cursor in a new tab
nnoremap <buffer> <expr> <leader>h ":help " . expand("<cword>") . "\n"

" vim: foldmethod=manual:foldlevel=3
