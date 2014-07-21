let s:seq = ''

function! agit#bufwin#agit_tabnew()
  tabnew
  call s:create_log_bufwin()
  call s:create_stat_bufwin()
  call s:create_diff_bufwin()
  let s:seq += 1
endfunction

function! agit#bufwin#set_to_log(str)
  call agit#bufwin#move_to_log()
  call s:fill_buffer(a:str)
endfunction

function! agit#bufwin#set_to_stat(str)
  call agit#bufwin#move_to_stat()
  call s:fill_buffer(a:str)
  setlocal modifiable
  noautocmd silent! g/^$/d _
  1
  setlocal nomodifiable
  wincmd p
endfunction

function! agit#bufwin#set_to_diff(str)
  call agit#bufwin#move_to_diff()
  call s:fill_buffer(a:str)
  wincmd p
endfunction

function! agit#bufwin#move_to_log()
  noautocmd 1wincmd w
  if !s:is_valid_window_allocation()
    throw 'Agit: Cannot recreate a log window.'
  endif
endfunction

function! agit#bufwin#move_to_stat()
  noautocmd 2wincmd w
  if !s:is_valid_window_allocation()
    call s:reconstruct()
    noautocmd 2wincmd w
  endif
endfunction

function! agit#bufwin#move_to_diff()
  noautocmd 3wincmd w
  if !s:is_valid_window_allocation()
    call s:reconstruct()
    noautocmd 3wincmd w
  endif
endfunction

function! s:is_valid_window_allocation()
  return winnr('$') == 3 && getwinvar(1, 'agit_win_type') ==# 'log'
  \                      && getwinvar(2, 'agit_win_type') ==# 'stat'
  \                      && getwinvar(3, 'agit_win_type') ==# 'diff'
endfunction

function! s:create_log_bufwin()
  let w:agit_win_type = 'log'
  silent file `='[Agit log] ' . s:seq`
  call s:set_view_options()
  setfiletype agit
  setlocal nomodifiable
endfunction

function! s:create_stat_bufwin()
  botright vnew
  let w:agit_win_type = 'stat'
  silent file `='[Agit stat] ' . s:seq`
  call s:set_view_options()
  setlocal nocursorline nocursorcolumn
  setlocal winfixheight
  setfiletype agit_stat
  setlocal nomodifiable
endfunction

function! s:create_diff_bufwin()
  let winheight = winheight('.')
  execute 'belowright ' . winheight*3/4 . 'new'
  let w:agit_win_type = 'diff'
  silent file `='[Agit diff] ' . s:seq`
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
  call s:create_stat_bufwin()
  call s:create_diff_bufwin()
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
