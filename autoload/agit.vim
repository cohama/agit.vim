let s:V = vital#of('agit.vim')
let s:String = s:V.import('Data.String')
let s:List = s:V.import('Data.List')

let s:agit_vital = {
\ 'V' : s:V,
\ 'String' : s:String,
\ 'List' : s:List
\ }

let s:fugitive_enabled = get(g:, 'loaded_fugitive', 0)

function! agit#vital()
  return s:agit_vital
endfunction

function! agit#init()
  command! Agit call s:launch()
  nnoremap <silent> <Plug>(agit-reload)  :<C-u>call <SID>reload(0)<CR>
  nnoremap <silent> <Plug>(agit-refresh) :<C-u>call <SID>reload(1)<CR>
  nnoremap <silent> <Plug>(agit-scrolldown-stat) :<C-u>call <SID>remote_scroll('stat', 'down')<CR>
  nnoremap <silent> <Plug>(agit-scrollup-stat)   :<C-u>call <SID>remote_scroll('stat', 'up')<CR>
  nnoremap <silent> <Plug>(agit-scrolldown-diff) :<C-u>call <SID>remote_scroll('diff', 'down')<CR>
  nnoremap <silent> <Plug>(agit-scrollup-diff)   :<C-u>call <SID>remote_scroll('diff', 'up')<CR>
endfunction

let s:old_hash = ''
function! agit#show_commit()
  let line = getline('.')
  if line ==# g:agit#git#staged_message
    let hash = 'staged'
  elseif line ==# g:agit#git#unstaged_message
    let hash = 'unstaged'
  else
    let hash = s:extract_hash(line)
  endif
  if hash == ''
    call agit#bufwin#set_to_stat('')
    call agit#bufwin#set_to_diff('')
  elseif s:old_hash !=# hash
    call agit#bufwin#set_to_stat(t:git.stat(hash))
    call agit#bufwin#set_to_diff(t:git.diff(hash))
  endif
  let s:old_hash = hash
endfunction

function! s:remote_scroll(win_type, direction)
  if a:win_type ==# 'stat'
    call agit#bufwin#move_to_stat()
  elseif a:win_type ==# 'diff'
    call agit#bufwin#move_to_diff()
  endif
  if a:direction ==# 'down'
    execute "normal! \<C-d>"
  elseif a:direction ==# 'up'
    execute "normal! \<C-u>"
  endif
  call agit#bufwin#move_to_log()
endfunction

function! s:launch()
  let s:old_hash = ''
  try
    let git_dir = s:get_git_dir()
    call agit#bufwin#agit_tabnew()
    let t:git = agit#git#new(git_dir)
    call agit#bufwin#set_to_log(t:git.log())
    call agit#show_commit()
    if s:fugitive_enabled
      let b:git_dir = git_dir " for fugitive commands
      silent doautocmd User Fugitive
    endif
  catch
    echomsg v:exception
  endtry
endfunction

function! s:reload(move_to_head)
  call agit#bufwin#move_to_log()
  wincmd =
  let pos = getpos('.')
  call agit#bufwin#set_to_log(t:git.log())
  if a:move_to_head
    1
  else
    call setpos('.', pos)
  endif
  let s:old_hash = ''
  call agit#show_commit()
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

function! s:extract_hash(str)
  return matchstr(a:str, '\[\zs\x\{7\}\ze\]$')
endfunction
