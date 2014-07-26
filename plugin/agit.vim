if exists('g:loaded_agit')
  finish
endif
let g:loaded_agit = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:agit_no_default_mappings')
  let g:agit_no_default_mappings = 0
endif

augroup agit
  autocmd!
augroup END

command! Agit call agit#launch()
nnoremap <silent> <Plug>(agit-reload)  :<C-u>call agit#reload(0)<CR>
nnoremap <silent> <Plug>(agit-refresh) :<C-u>call agit#reload(1)<CR>
nnoremap <silent> <Plug>(agit-scrolldown-stat) :<C-u>call agit#remote_scroll('stat', 'down')<CR>
nnoremap <silent> <Plug>(agit-scrollup-stat)   :<C-u>call agit#remote_scroll('stat', 'up')<CR>
nnoremap <silent> <Plug>(agit-scrolldown-diff) :<C-u>call agit#remote_scroll('diff', 'down')<CR>
nnoremap <silent> <Plug>(agit-scrollup-diff)   :<C-u>call agit#remote_scroll('diff', 'up')<CR>

let &cpo = s:save_cpo
