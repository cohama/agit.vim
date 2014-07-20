let s:assert = themis#helper('assert')
let s:suite = themis#suite('agit#bufwin')

function! s:suite.before_each()
  call agit#bufwin#agit_tabnew()
endfunction

function! s:suite.after_each()
  tabnew
  tabonly!
endfunction

function! s:suite.create_3_windows()
  call s:assert.equals(winnr('$'), 3)
endfunction

function! s:suite.__log_window__()
  let log_win = themis#suite('log window')

  function! log_win.before_each()
    call agit#bufwin#move_to_log()
  endfunction

  function! log_win.has_agit_win_type_as_log()
    call s:assert.equals(w:agit_win_type, 'log')
  endfunction

  function! log_win.has_view_specific_options()
    call s:assert.false(&l:modifiable)
    call s:assert.false(&l:wrap)
    call s:assert.false(&l:number)
    call s:assert.false(&l:relativenumber)
    call s:assert.equals(&l:buftype, 'nofile')
  endfunction
endfunction

function! s:suite.__stat_window__()
  let stat_win = themis#suite('stat window')

  function! stat_win.before_each()
    call agit#bufwin#move_to_stat()
  endfunction

  function! stat_win.has_agit_win_type_as_stat()
    call s:assert.equals(w:agit_win_type, 'stat')
  endfunction

  function! stat_win.has_view_specific_options()
    call s:assert.false(&l:modifiable)
    call s:assert.false(&l:wrap)
    call s:assert.false(&l:number)
    call s:assert.false(&l:relativenumber)
    call s:assert.false(&l:cursorline)
    call s:assert.false(&l:cursorcolumn)
    call s:assert.equals(&l:buftype, 'nofile')
  endfunction
endfunction

function! s:suite__diff_window__()
  let diff_win = themis#suite('diff window')

  function! diff_win.before_each()
    call agit#bufwin#move_to_diff()
  endfunction

  function! diff_win.has_agit_win_type_as_diff()
    call s:assert.false(&l:modifiable)
    call s:assert.false(&l:wrap)
    call s:assert.false(&l:number)
    call s:assert.false(&l:relativenumber)
    call s:assert.false(&l:cursorline)
    call s:assert.false(&l:cursorcolumn)
    call s:assert.equals(&l:buftype, 'nofile')
  endfunction
endfunction

function! s:suite.__broken_window__()
  let broken = themis#suite('broken window')

  function! broken.recreate_windows_if_stat_window_is_lost()
    call agit#bufwin#move_to_stat()
    q
    call agit#bufwin#move_to_stat()
    call s:assert.equals(winnr('$'), 3)
    call s:assert.equals(w:agit_win_type, 'stat')
  endfunction

  function! broken.recreate_windows_if_diff_window_is_lost()
    call agit#bufwin#move_to_diff()
    q
    call agit#bufwin#move_to_diff()
    call s:assert.equals(winnr('$'), 3)
    call s:assert.equals(w:agit_win_type, 'diff')
  endfunction

  function! broken.do_not_recreate_windows_if_log_window_is_lost()
    call agit#bufwin#move_to_log()
    q
    try
      call agit#bufwin#move_to_log()
    catch /Agit: /
      call s:assert.true(1)
      return
    endtry
    call s:assert.fail('Expect to be raised an error but not')
  endfunction

endfunction
