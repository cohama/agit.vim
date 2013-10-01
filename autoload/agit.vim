let s:V = vital#of('agit.vim')
function agit#init()
  command! Agit call <SID>launch()
  silent nnoremap <Plug>(agit-show-commit-stat) :<C-u>call <SID>show_commit_stat()<CR>
endfunction

function! s:launch()
  call s:initialize_buffer()
  call s:define_mappings()
endfunction

function! s:initialize_buffer()
  tabnew
  setlocal buftype=nofile
  setlocal nonumber
  setlocal norelativenumber
  setlocal nowrap
  let result = system('git log --graph --decorate=full --no-color --date=iso --format=format:"%d %s %ad %an %H"')
  silent! 0put =result
  silent! $delete
  1
  let w:agit_win_type = 'log'
  call s:show_commit_stat()
  setlocal nomodifiable
  setfiletype agit
endfunction

function! s:define_mappings()
  silent nmap <buffer> <CR> <Plug>(agit-show-commit-stat)
endfunction

function! s:set_view_options()
  setlocal buftype=nofile
  setlocal nonumber norelativenumber
  setlocal nowrap
endfunction

function! s:set_diff_view_options()
  setlocal foldmethod=syntax
  setlocal foldenable
  setlocal foldlevelstart=1
endfunction

function! s:show_commit_stat()
  only
  let hash = s:extract_hash(getline('.'))
  call agit#bufwin#move_or_create_window('agit_win_type', 'stat', 'botright vnew')
  setlocal modifiable
  let result = system('git show --oneline --stat --date=iso '. hash)
  silent! %delete
  silent! 0put =result
  %s/\n^$//e
  1delete
  call s:set_view_options()
  setlocal nomodifiable
  setfiletype git
  call s:show_diff(hash)
  call agit#bufwin#move_or_create_window('agit_win_type', 'log', 'vnew')
endfunction

function! s:show_diff(hash)
  let winheight = winheight('.')
  call agit#bufwin#move_or_create_window('agit_win_type', 'diff', 'belowright '. winheight*3/4 . 'new')
  let result = system('git show -p ' . a:hash)
  setlocal modifiable
  silent! %delete
  silent! 0put =result
  call s:set_view_options()
  call s:set_diff_view_options()
  setlocal nomodifiable
  setfiletype git
  call agit#bufwin#move_or_create_window('agit_win_type', 'log', 'vnew')
endfunction

function! s:extract_hash(str)
  return matchstr(a:str, '\x\{40\}$')
endfunction

