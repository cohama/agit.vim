if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

command! -bang -nargs=+ -buffer -complete=custom,agit#agit_git_compl AgitGit call agit#agitgit(<q-args>, 0, <bang>0)
command! -bang -nargs=+ -buffer -complete=custom,agit#agit_git_compl AgitGitConfirm call agit#agitgit(<q-args>, 1, <bang>0)

if !g:agit_no_default_mappings
  nmap <buffer> u <PLug>(agit-reload)
  nmap <silent><buffer> J <Plug>(agit-scrolldown-stat)
  nmap <silent><buffer> K <Plug>(agit-scrollup-stat)
  nmap <silent><buffer> <C-j> <Plug>(agit-scrolldown-diff)
  nmap <silent><buffer> <C-k> <Plug>(agit-scrollup-diff)

  nmap <buffer> yh <Plug>(agit-yank-hash)
  nmap <buffer> q <Plug>(agit-exit)
  nmap <buffer> <CR> <Plug>(agit-show-commit)

  nmap <buffer> C <Plug>(agit-git-checkout)
  nmap <buffer> cb <Plug>(agit-git-checkout-b)
  nmap <buffer> D <Plug>(agit-git-branch-d)
  nmap <buffer> rs <Plug>(agit-git-reset-soft)
  nmap <buffer> rm <Plug>(agit-git-reset)
  nmap <buffer> rh <Plug>(agit-git-reset-hard)
  nmap <buffer> rb <Plug>(agit-git-rebase)
  nmap <buffer> ri <Plug>(agit-git-rebase-i)
  nmap <buffer> Bs <Plug>(agit-git-bisect-start)
  nmap <buffer> Bg <Plug>(agit-git-bisect-good)
  nmap <buffer> Bb <Plug>(agit-git-bisect-bad)
  nmap <buffer> Br <Plug>(agit-git-bisect-reset)
endif

if g:agit_enable_auto_show_commit
  let s:save_ut = &updatetime
  autocmd CursorMoved <buffer> call s:wait_for_show_commit()
  autocmd CursorHold <buffer> call s:show_commit()
  autocmd BufLeave <buffer> call s:cleanup()
endif

if g:agit_enable_auto_refresh
  autocmd BufEnter <buffer> call agit#reload()
endif

autocmd ShellCmdPost <buffer> call agit#reload()
autocmd QuitPre <buffer> call s:exit()

function! s:wait_for_show_commit()
  set updatetime=100
endfunction

function! s:show_commit()
  call agit#show_commit()
  call s:cleanup()
  redraw!
endfunction

function! s:cleanup()
  let &updatetime = s:save_ut
endfunction

function! s:exit()
  if !exists('t:git')
    return
  endif
  silent! only!
endfunction

setl conceallevel=2
setl concealcursor=nvc
