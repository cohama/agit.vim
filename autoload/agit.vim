let s:V = vital#of('agit.vim')
function agit#init()
  command! Agit call <SID>launch()
  nnoremap <silent> <Plug>(agit-show-commit) :<C-u>call <SID>show_commit()<CR>
endfunction

function! s:launch()
  tabnew
  call s:show_log()
  call s:show_commit()
endfunction

function! s:define_mappings()
  silent nmap <silent><buffer> <CR> <Plug>(agit-show-commit)
endfunction

function! s:set_view_options()
  setlocal buftype=nofile
  setlocal nonumber norelativenumber
  setlocal nowrap
  setlocal foldcolumn=0
endfunction

function! s:show_log()
  call s:set_view_options()
  let result = system('git log --graph --decorate=full --no-color --date=iso --format=format:"%d %s %ad %an %H"')
  silent! 0put =result
  silent! $delete
  1
  let w:agit_win_type = 'log'
  setlocal nomodifiable
  setfiletype agit
  call s:define_mappings()
endfunction

function! s:show_commit()
  silent! only
  let hash = s:extract_hash(getline('.'))
  call s:show_commit_stat(hash)
  call s:show_commit_diff(hash)
  call agit#bufwin#move_or_create_window('agit_win_type', 'log', 'vnew')
endfunction

function! s:show_commit_stat(hash)
  call agit#bufwin#move_or_create_window('agit_win_type', 'stat', 'botright vnew')
  setlocal modifiable
  let result = system('git show --oneline --stat --date=iso '. a:hash)
  silent! %delete
  silent! 0put =result
  %s/\n^$//e
  1delete
  call s:set_view_options()
  setlocal nomodifiable
  setfiletype git
endfunction

function! s:show_commit_diff(hash)
  let winheight = winheight('.')
  call agit#bufwin#move_or_create_window('agit_win_type', 'diff', 'belowright '. winheight*3/4 . 'new')
  let result = system('git show -p ' . a:hash)
  setlocal modifiable
  silent! %delete
  silent! 0put =result
  1
  call s:set_view_options()
  setlocal foldmethod=syntax
  setlocal foldenable
  setlocal foldlevelstart=1
  setlocal nomodifiable
  setfiletype git
endfunction

function! s:extract_hash(str)
  return matchstr(a:str, '\x\{40\}$')
endfunction

