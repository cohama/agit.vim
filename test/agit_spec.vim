let s:assert = themis#helper('assert')
let s:suite = themis#suite(':Agit command')

function! s:suite.before()
  Agit
endfunction

function! s:suite.create_3_windows_with_id_variables()
  call s:assert.equals(winnr('$'), 3)
endfunction

function! s:suite.__log_window__()
  let log_win = themis#suite('log window')

  function! log_win.before()
    1wincmd w
  endfunction

  function! log_win.has_agit_win_type_as_log()
    call s:assert.equals(w:agit_win_type, 'log')
  endfunction

  function! log_win.has_view_specific_options()
    call s:assert.equals(&l:modifiable, 0)
    call s:assert.equals(&l:wrap, 0)
    call s:assert.equals(&l:number, 0)
    call s:assert.equals(&l:relativenumber, 0)
    call s:assert.equals(&l:buftype, 'nofile')
  endfunction
endfunction

function! s:suite.__stat_window__()
  let stat_win = themis#suite('stat window')

  function! stat_win.before()
    2wincmd w
  endfunction

  function! stat_win.has_agit_win_type_as_stat()
    call s:assert.equals(w:agit_win_type, 'stat')
  endfunction

  function! stat_win.has_view_specific_options()
    call s:assert.equals(&l:modifiable, 0)
    call s:assert.equals(&l:wrap, 0)
    call s:assert.equals(&l:number, 0)
    call s:assert.equals(&l:relativenumber, 0)
    call s:assert.equals(&l:buftype, 'nofile')
  endfunction

  function! stat_win.does_not_have_empty_line()
    let found = search('^$')
    call s:assert.equals(found, 0)
  endfunction
endfunction

function! s:suite__diff_window__()
  let diff_win = themis#suite('diff window')

  function! diff_win.before()
    3wincmd w
  endfunction

  function! diff_win.has_agit_win_type_as_diff()
    call s:assert.equals(&l:modifiable, 0)
    call s:assert.equals(&l:wrap, 0)
    call s:assert.equals(&l:number, 0)
    call s:assert.equals(&l:relativenumber, 0)
    call s:assert.equals(&l:buftype, 'nofile')
  endfunction
endfunction
