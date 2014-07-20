let s:V = vital#of('agit.vim')
let s:String = s:V.import('Data.String')

function! agit#init()
  command! Agit call s:launch()
  nnoremap <silent> <Plug>(agit-reload) :<C-u>call <SID>reload(0)<CR>
  nnoremap <silent> <Plug>(agit-refresh) :<C-u>call <SID>reload(1)<CR>
endfunction

let s:old_hash = ''
function! agit#show_commit(git_dir)
  let line = getline('.')
  if line ==# g:agit#git#staged_message
    let hash = 'staged'
  elseif line ==# g:agit#git#unstaged_message
    let hash = 'unstaged'
  else
    let hash = s:extract_hash(line)
  endif
  if s:old_hash !=# hash
    call s:show_commit_stat(hash, a:git_dir)
    call s:show_commit_diff(hash, a:git_dir)
    call agit#bufwin#move_or_create_window('agit_win_type', 'log', 'vnew')
  endif
  let s:old_hash = hash
endfunction

function! agit#remote_scroll(win_type, direction)
  noautocmd call agit#bufwin#move_or_create_window('agit_win_type', a:win_type, 'botright vnew')
  if a:direction ==# 'down'
    execute "normal! \<C-d>"
  elseif a:direction ==# 'up'
    execute "normal! \<C-u>"
  endif
  noautocmd call agit#bufwin#move_or_create_window('agit_win_type', 'log', 'vnew')
endfunction

function! s:launch()
  let s:old_hash = ''
  try
    let git_dir = s:get_git_dir()
    noautocmd tabnew
    call s:show_log(git_dir)
    call agit#show_commit(git_dir)
    let b:git_dir = git_dir
  catch
    echomsg v:exception
  endtry
endfunction

function! s:get_git_dir()
  " if fugitive exists
  if exists('b:git_dir')
    return b:git_dir
  endif
  let current_path = expand('%:p:h')
  let toplevel_path = s:String.chomp(system('git --no-pager -C ' . current_path . ' rev-parse --show-toplevel')) . '/.git'
  if v:shell_error != 0
    throw 'Not a git repository.'
  endif
  return toplevel_path
endfunction

function! s:reload(move_to_head)
  call agit#bufwin#move_or_create_window('agit_win_type', 'log', 'vnew')
  let pos = getpos('.')
  setlocal modifiable
  call s:fill_buffer(agit#git#log(b:git_dir))
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

function! s:show_log(git_dir)
  call s:set_view_options()
  call s:fill_buffer(agit#git#log(a:git_dir))
  let w:agit_win_type = 'log'
  setlocal nomodifiable
  setfiletype agit
endfunction

function! s:show_commit_stat(hash, git_dir)
  call agit#bufwin#move_or_create_window('agit_win_type', 'stat', 'botright vnew')
  setlocal modifiable
  if a:hash ==# 'staged'
    let stat = agit#git#exec('diff --cached --stat', a:git_dir)
  elseif a:hash ==# 'unstaged'
    let stat = agit#git#exec('diff --stat', a:git_dir)
  else
    let stat = agit#git#exec('show --oneline --stat --date=iso --pretty=format: '. a:hash, a:git_dir)
  endif
  call s:fill_buffer(stat)
  noautocmd silent! g/^\s*$/d
  1
  call s:set_view_options()
  setlocal nocursorline nocursorcolumn
  setfiletype agit_stat
  setlocal nomodifiable
endfunction

function! s:show_commit_diff(hash, git_dir)
  let winheight = winheight('.')
  call agit#bufwin#move_or_create_window('agit_win_type', 'diff', 'belowright '. winheight*3/4 . 'new')
  setlocal modifiable
  if a:hash ==# 'staged'
    let diff = agit#git#exec('diff --cached', a:git_dir)
  elseif a:hash ==# 'unstaged'
    let diff = agit#git#exec('diff', a:git_dir)
  else
    let diff = agit#git#exec('show -p ' . a:hash, a:git_dir)
  endif
  call s:fill_buffer(diff)
  call s:set_view_options()
  setlocal nocursorline nocursorcolumn
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

