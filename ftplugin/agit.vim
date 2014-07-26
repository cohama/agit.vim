if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

if !g:agit_no_default_mappings
  nmap <buffer> u <PLug>(agit-reload)
  nmap <buffer> U <PLug>(agit-refresh)
  nmap <silent><buffer> J <Plug>(agit-scrolldown-stat)
  nmap <silent><buffer> K <Plug>(agit-scrollup-stat)
  nmap <silent><buffer> <C-j> <Plug>(agit-scrolldown-diff)
  nmap <silent><buffer> <C-k> <Plug>(agit-scrollup-diff)
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
