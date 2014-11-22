if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

command! -bang -nargs=+ -buffer -complete=custom,agit#agit_git_compl AgitGit call agit#agitgit(<q-args>, 0, <bang>0)
command! -bang -nargs=+ -buffer -complete=custom,agit#agit_git_compl AgitGitConfirm call agit#agitgit(<q-args>, 1, <bang>0)

if !g:agit_no_default_mappings
  nmap <silent><buffer> u <PLug>(agit-reload)
  nmap <silent><buffer> J <Plug>(agit-scrolldown-stat)
  nmap <silent><buffer> K <Plug>(agit-scrollup-stat)
  nmap <silent><buffer> <C-j> <Plug>(agit-scrolldown-diff)
  nmap <silent><buffer> <C-k> <Plug>(agit-scrollup-diff)

  nmap <silent><buffer> yh <Plug>(agit-yank-hash)
  nmap <silent><buffer> q <Plug>(agit-exit)
  nmap <silent><buffer> <CR> <Plug>(agit-show-commit)
  nmap <silent><buffer> <C-g> <Plug>(agit-print-commitmsg)

  nmap <silent><buffer> C <Plug>(agit-git-checkout)
  nmap <silent><buffer> cb <Plug>(agit-git-checkout-b)
  nmap <silent><buffer> D <Plug>(agit-git-branch-d)
  nmap <silent><buffer> rs <Plug>(agit-git-reset-soft)
  nmap <silent><buffer> rm <Plug>(agit-git-reset)
  nmap <silent><buffer> rh <Plug>(agit-git-reset-hard)
  nmap <silent><buffer> rb <Plug>(agit-git-rebase)
  nmap <silent><buffer> ri <Plug>(agit-git-rebase-i)
  nmap <silent><buffer> Bs <Plug>(agit-git-bisect-start)
  nmap <silent><buffer> Bg <Plug>(agit-git-bisect-good)
  nmap <silent><buffer> Bb <Plug>(agit-git-bisect-bad)
  nmap <silent><buffer> Br <Plug>(agit-git-bisect-reset)
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
  let curline = getline('.')
  while agit#extract_hash(curline) ==# '' && line('.') !=# 1 && line('.') !=# line('$')
  \ && curline !=# g:agit#git#staged_message && curline !=# g:agit#git#unstaged_message
    if linenr > s:old_linenr
      normal! j
    elseif linenr < s:old_linenr
      normal! k
    else
      return
    endif
    let curline = getline('.')
  endwhile
  let s:old_linenr = line('.')
endfunction

setl conceallevel=2
setl concealcursor=nvc
