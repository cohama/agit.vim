function! agit#bufwin#agit_tabnew()
  tabnew
  let seq = s:create_log_bufwin()
  call s:create_stat_bufwin(seq)
  call s:create_diff_bufwin(seq)
  call agit#bufwin#move_to_log()
endfunction

function! agit#bufwin#set_to_log(str)
  call agit#bufwin#move_to_log()
  call s:fill_buffer(a:str)
endfunction

function! agit#bufwin#set_to_stat(str)
  call agit#bufwin#move_to_stat()
  call s:fill_buffer(a:str)
  1
  noautocmd wincmd p
endfunction

function! agit#bufwin#set_to_diff(str)
  call agit#bufwin#move_to_diff()
  call s:fill_buffer(a:str)
  setlocal modifiable
  silent %s/^\s\+$//ge
  silent %s/\r$//ge
  setlocal nomodifiable
  1
  noautocmd wincmd p
endfunction

function! agit#bufwin#move_to_log()
  for w in range(1, winnr('$'))
    let wintype = getwinvar(w, 'agit_win_type')
    if wintype ==# 'log'
      noautocmd execute w . 'wincmd w'
      return
    endif
  endfor
  throw 'Agit: Cannot recreate a log window.'
endfunction

function! agit#bufwin#move_to_stat()
  for w in range(1, winnr('$'))
    let wintype = getwinvar(w, 'agit_win_type')
    if wintype ==# 'stat'
      noautocmd execute w . 'wincmd w'
      return
    endif
  endfor
  call s:reconstruct()
  call agit#bufwin#move_to_stat()
endfunction

function! agit#bufwin#move_to_diff()
  for w in range(1, winnr('$'))
    let wintype = getwinvar(w, 'agit_win_type')
    if wintype ==# 'diff'
      noautocmd execute w . 'wincmd w'
      return
    endif
  endfor
  call s:reconstruct()
  call agit#bufwin#move_to_diff()
endfunction

function! s:is_valid_window_allocation()
  return winnr('$') == 3 && getwinvar(1, 'agit_win_type') ==# 'log'
  \                      && getwinvar(2, 'agit_win_type') ==# 'stat'
  \                      && getwinvar(3, 'agit_win_type') ==# 'diff'
endfunction

let s:seq = ''
function! s:create_log_bufwin()
  let w:agit_win_type = 'log'
  silent file `='[Agit log] ' . s:seq`
  call s:set_view_options()
  setlocal iskeyword+=/,-,.
  setfiletype agit
  setlocal nomodifiable
  let b:git_seq = s:seq
  let s:seq += 1
  return b:git_seq
endfunction

function! s:create_stat_bufwin(seq)
  botright vnew
  let w:agit_win_type = 'stat'
  silent file `='[Agit stat] ' . a:seq`
  call s:set_view_options()
  setlocal nocursorline nocursorcolumn
  setlocal winfixheight
  setfiletype agit_stat
  setlocal nomodifiable
endfunction

function! s:create_diff_bufwin(seq)
  let winheight = winheight('.')
  execute 'belowright ' . winheight*3/4 . 'new'
  let w:agit_win_type = 'diff'
  silent file `='[Agit diff] ' . a:seq`
  call s:set_view_options()
  setlocal nocursorline nocursorcolumn
  setlocal winfixheight
  setfiletype agit_diff
  setlocal nomodifiable
endfunction

function! s:reconstruct()
  for w in range(1, winnr('$'))
    if getwinvar(w, 'agit_win_type') ==# 'log'
      break
    endif
  endfor
  execute w . 'wincmd w'
  noautocmd only!
  let seq = b:git_seq
  call s:create_stat_bufwin(seq)
  call s:create_diff_bufwin(seq)
  call agit#bufwin#move_to_log()
endfunction

function! s:fill_buffer(str)
  setlocal modifiable
  noautocmd silent! %delete _
  noautocmd silent! 1put= a:str
  noautocmd silent! 1delete _
  setlocal nomodifiable
endfunction

function! s:set_view_options()
  setlocal buftype=nofile nobuflisted bufhidden=delete
  setlocal nonumber norelativenumber
  setlocal nowrap
  setlocal foldcolumn=0
endfunction
