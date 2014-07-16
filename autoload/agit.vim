let s:V = vital#of('agit.vim')
function! agit#init()
  command! Agit call s:launch()
  nnoremap <silent> <Plug>(agit-reload) :<C-u>call <SID>reload(0)<CR>
  nnoremap <silent> <Plug>(agit-refresh) :<C-u>call <SID>reload(1)<CR>
endfunction

function! agit#show_commit()
  let line = getline('.')
  if line ==# g:agit#git#staged_message
    let hash = 'staged'
  elseif line ==# g:agit#git#unstaged_message
    let hash = 'unstaged'
  else
    let hash = s:extract_hash(line)
  endif
  call s:show_commit_stat(hash)
  call s:show_commit_diff(hash)
  call agit#bufwin#move_or_create_window('agit_win_type', 'log', 'vnew')
endfunction

function! s:launch()
  noautocmd tabnew
  call s:show_log()
  call agit#show_commit()
endfunction

function! s:reload(move_to_head)
  call agit#bufwin#move_or_create_window('agit_win_type', 'log', 'vnew')
  let pos = getpos('.')
  setlocal modifiable
  call s:fill_buffer(agit#git#log())
  setlocal nomodifiable
  if a:move_to_head
    1
  else
    call setpos('.', pos)
  endif
endfunction

function! s:set_view_options()
  setlocal buftype=nofile nobuflisted bufhidden=delete
  setlocal nonumber norelativenumber
  setlocal nowrap
  setlocal foldcolumn=0
endfunction

function! s:show_log()
  call s:set_view_options()
  call s:fill_buffer(agit#git#log())
  let w:agit_win_type = 'log'
  setlocal nomodifiable
  setfiletype agit
endfunction

function! s:show_commit_stat(hash)
  call agit#bufwin#move_or_create_window('agit_win_type', 'stat', 'botright vnew')
  setlocal modifiable
  if a:hash ==# 'staged'
    let stat = system('git diff --cached --stat')
  elseif a:hash ==# 'unstaged'
    let stat = system('git diff --stat')
  else
    let stat = system('git show --oneline --stat --date=iso --pretty=format: '. a:hash)
  endif
  call s:fill_buffer(stat)
  noautocmd silent! g/^\s*$/d
  1
  call s:set_view_options()
  setfiletype agit_stat
  setlocal nomodifiable
endfunction

function! s:show_commit_diff(hash)
  let winheight = winheight('.')
  call agit#bufwin#move_or_create_window('agit_win_type', 'diff', 'belowright '. winheight*3/4 . 'new')
  setlocal modifiable
  if a:hash ==# 'staged'
    let diff = system('git diff --cached')
  elseif a:hash ==# 'unstaged'
    let diff = system('git diff')
  else
    let diff = system('git show -p ' . a:hash)
  endif
  call s:fill_buffer(diff)
  call s:set_view_options()
  setlocal foldmethod=syntax
  setlocal foldenable
  setlocal foldlevelstart=1
  setfiletype agit_diff
  setlocal nomodifiable
endfunction

function! s:fill_buffer(str)
  noautocmd silent! %delete _
  noautocmd silent! 1put= a:str
  noautocmd silent! 1delete _
endfunction

function! s:extract_hash(str)
  return matchstr(a:str, '\[\zs\x\{7\}\ze\]$')
endfunction

