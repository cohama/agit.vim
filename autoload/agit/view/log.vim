let s:log = {
\ 'name': 'log',
\ }

function! agit#view#log#new(git)
  let log = deepcopy(s:log)
  let log.git = a:git
  call log.setlocal()
  call add(a:git.oninit, log)
  return log
endfunction

function! s:fill_buffer(str)
  setlocal modifiable
  noautocmd silent! %delete _
  noautocmd silent! 1put= a:str
  noautocmd silent! 1delete _
  setlocal nomodifiable
endfunction

function! s:log.render()
  call self.renderwith('log')
endfunction

function! s:log.renderwith(funcname)
  let save = {
        \ 'hash': self.git.hash,
        \ 'head': self.git.head,
        \ 'staged' : self.git.staged.line > 0,
        \ 'unstaged' : self.git.unstaged.line > 0
        \ }
  call agit#bufwin#move_to(self.name)
  call s:fill_buffer(self.git[a:funcname](winwidth(0)))
  if empty(save.hash)
    call self.emmit(1)
  else
    if save.hash == 'unstaged'
      let candidates = ['unstaged', 'staged', self.git.head]
    elseif save.hash == 'staged'
      let candidates = ['staged', self.git.head]
    elseif save.hash == save.head
      if !save.staged && !save.unstaged
        let candidates = ['unstaged', 'staged', self.git.head]
      else
        let candidates = [self.git.head]
      endif
    else
      let candidates = [save.hash]
    endif
    call self.goto(candidates, 1)
  endif
endfunction

function! s:log.setlocal()
  call agit#bufwin#move_to(self.name)
  silent file `='[Agit log] ' . self.git.seq`
  setlocal buftype=nofile nobuflisted bufhidden=delete
  setlocal foldcolumn=0
  setlocal nonumber norelativenumber nowrap
  setlocal iskeyword+=/,-,.
  setlocal nomodifiable
  setlocal conceallevel=2 concealcursor=nvc
  setlocal noswapfile

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

    let s:save_ut = &updatetime
    autocmd CursorMoved <buffer> if g:agit_enable_auto_show_commit | call s:wait_for_show_commit() | endif
    autocmd CursorHold <buffer> if g:agit_enable_auto_show_commit | call s:show_commit() | endif
    autocmd BufLeave <buffer> if g:agit_enable_auto_show_commit | call s:cleanup() | endif

    if exists('##QuitPre')
      autocmd QuitPre <buffer> call s:exit()
    endif

    autocmd BufEnter <buffer> if g:agit_enable_auto_refresh | call agit#reload() | endif

    autocmd ShellCmdPost <buffer> call agit#reload()

    let s:old_linenr = line('.')
    autocmd CursorMoved <buffer> if g:agit_skip_empty_line | call s:skip_empty_line() | endif

  augroup END

  function! s:wait_for_show_commit()
    set updatetime=100
  endfunction

  function! s:show_commit()
    call s:cleanup()
    if s:emmit(0)
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

  set filetype=agit
endfunction

function! s:emmit(force)
  call w:view.emmit(a:force)
endfunction

function! s:log.emmit(...)
  " optional argument 1: force=0
  let force = get(a:, 1, 0)
  let line = getline('.')
  let hash = matchstr(line, '\[\zs\x\{7,\}\ze\]$')
  if hash ==# ''
    if line ==# g:agit#git#staged_message
      let hash = 'staged'
    elseif line ==# g:agit#git#unstaged_message
      let hash = 'unstaged'
    elseif line ==# g:agit#git#nextpage_message
      let hash = 'nextpage'
    endif
  endif
  call self.git.sethash(hash, force)
  call agit#bufwin#move_to(self.name)
endfunction

function! s:log.goto(candidates, force)
  let line = 0
  for hash in a:candidates
    if hash ==# 'staged' || hash ==# 'unstaged'
      let line = self.git[hash].line
    elseif hash ==# 'nextpage'
      let line = line('$')
    elseif hash ==# ''
      let line = 0
    else
      let line = search('\[' . hash . '\]$', 'nw')
    endif
    if line > 0
      break
    endif
  endfor
  if line == 0
    let line = 1
  endif
  noautocmd call setpos('.', [0, line, 0, 0])
  call self.git.sethash(hash, a:force)
  call agit#bufwin#move_to(self.name)
endfunction
