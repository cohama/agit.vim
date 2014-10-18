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

augroup agit

  if g:agit_enable_auto_show_commit
    let s:save_ut = &updatetime
    autocmd CursorMoved <buffer> call s:wait_for_show_commit()
    autocmd CursorHold <buffer> call s:show_commit()
    autocmd BufLeave <buffer> call s:cleanup()
  endif

  if exists('##QuitPre')
    autocmd QuitPre <buffer> call s:exit()
  endif

  if g:agit_enable_auto_refresh
    autocmd BufEnter <buffer> call agit#reload()
  endif

  autocmd ShellCmdPost <buffer> call agit#reload()

  if g:agit_skip_empty_line
    let s:old_linenr = line('.')
    autocmd CursorMoved <buffer> call s:skip_empty_line()
  endif

augroup END

function! s:wait_for_show_commit()
  set updatetime=100
endfunction

function! s:show_commit()
  call s:cleanup()
  if agit#show_commit()
    redraw!
  endif
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

function! s:skip_empty_line()
  let linenr = line('.')
  while agit#extract_hash(getline('.')) ==# '' && line('.') !=# 1 && line('.') !=# line('$')
    if linenr > s:old_linenr
      normal! j
    elseif linenr < s:old_linenr
      normal! k
    else
      return
    endif
  endwhile
  let s:old_linenr = line('.')
endfunction

setl conceallevel=2
setl concealcursor=nvc
