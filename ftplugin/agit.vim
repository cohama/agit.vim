if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

if !exists('g:agit_no_default_mappings')
  let g:agit_no_default_mappings = 0
endif

if !g:agit_no_default_mappings
  nmap <buffer> u <PLug>(agit-reload)
  nmap <buffer> U <PLug>(agit-refresh)
  nnoremap <silent><buffer> J :<C-u>call agit#remote_scroll('stat', 'down')<CR>
  nnoremap <silent><buffer> K :<C-u>call agit#remote_scroll('stat', 'up')<CR>
  nnoremap <silent><buffer> <C-j> :<C-u>call agit#remote_scroll('diff', 'down')<CR>
  nnoremap <silent><buffer> <C-k> :<C-u>call agit#remote_scroll('diff', 'up')<CR>
endif

autocmd CursorMoved <buffer> call s:wait_for_show_commit()
autocmd CursorHold <buffer> call s:show_commit()
autocmd BufLeave <buffer> call s:cleanup()

let s:save_ut = &updatetime

function! s:wait_for_show_commit()
  set updatetime=100
endfunction

function! s:show_commit()
  call agit#show_commit()
  call s:cleanup()
endfunction

function! s:cleanup()
  let &updatetime = s:save_ut
endfunction

setl conceallevel=2
setl concealcursor=nvc
