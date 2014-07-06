let s:V = vital#of('agit.vim')
function! agit#init()
  command! Agit call s:launch()
endfunction

function! agit#show_commit()
  let hash = s:extract_hash(getline('.'))
  call s:show_commit_stat(hash)
  call s:show_commit_diff(hash)
  call agit#bufwin#move_or_create_window('agit_win_type', 'log', 'vnew')
endfunction

function! s:launch()
  noautocmd tabnew
  call s:show_log()
  call agit#show_commit()
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
  call s:fill_buffer(system('git show --oneline --stat --date=iso '. a:hash))
  noautocmd %s/\n^$//e
  noautocmd 1 delete _
  call s:set_view_options()
  setlocal nomodifiable
endfunction

function! s:show_commit_diff(hash)
  let winheight = winheight('.')
  call agit#bufwin#move_or_create_window('agit_win_type', 'diff', 'belowright '. winheight*3/4 . 'new')
  setlocal modifiable
  call s:fill_buffer(system('git show -p ' . a:hash))
  call s:set_view_options()
  setlocal foldmethod=syntax
  setlocal foldenable
  setlocal foldlevelstart=1
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

