let s:suite = themis#suite('agit#bufwin')

function! s:suite.before_each()
  call agit#bufwin#agit_tabnew()
endfunction

function! s:suite.create_3_windows()
  call Expect(winnr('$')).to_equal(3)
endfunction

function! s:suite.__log_window__()
  let log_win = themis#suite('log window')

  function! log_win.before_each()
    call agit#bufwin#move_to_log()
  endfunction

  function! log_win.has_agit_win_type_as_log()
    call Expect(w:agit_win_type).to_equal('log')
  endfunction

  function! log_win.has_view_specific_options()
    call Expect(&l:modifiable).to_be_false()
    call Expect(&l:wrap).to_be_false()
    call Expect(&l:number).to_be_false()
    call Expect(&l:relativenumber).to_be_false()
    call Expect(&l:buftype).to_equal('nofile')
  endfunction
endfunction

function! s:suite.__stat_window__()
  let stat_win = themis#suite('stat window')

  function! stat_win.before_each()
    call agit#bufwin#move_to_stat()
  endfunction

  function! stat_win.has_agit_win_type_as_stat()
    call Expect(w:agit_win_type).to_equal('stat')
  endfunction

  function! stat_win.has_view_specific_options()
    call Expect(&l:modifiable).to_be_false()
    call Expect(&l:wrap).to_be_false()
    call Expect(&l:number).to_be_false()
    call Expect(&l:relativenumber).to_be_false()
    call Expect(&l:cursorline).to_be_false()
    call Expect(&l:cursorcolumn).to_be_false()
    call Expect(&l:buftype).to_equal('nofile')
  endfunction
endfunction

function! s:suite__diff_window__()
  let diff_win = themis#suite('diff window')

  function! diff_win.before_each()
    call agit#bufwin#move_to_diff()
  endfunction

  function! diff_win.has_agit_win_type_as_diff()
    call Expect(&l:modifiable).to_be_false()
    call Expect(&l:wrap).to_be_false()
    call Expect(&l:number).to_be_false()
    call Expect(&l:relativenumber).to_be_false()
    call Expect(&l:cursorline).to_be_false()
    call Expect(&l:cursorcolumn).to_be_false()
    call Expect(&l:buftype).to_equal('nofile')
  endfunction
endfunction

function! s:suite.__broken_window__()
  let broken = themis#suite('broken window')

  function! broken.recreate_windows_if_stat_window_is_lost()
    call agit#bufwin#move_to_stat()
    q
    call agit#bufwin#move_to_stat()
    call Expect(winnr('$')).to_equal(3)
    call Expect(w:agit_win_type).to_equal('stat')
  endfunction

  function! broken.recreate_windows_if_diff_window_is_lost()
    call agit#bufwin#move_to_diff()
    q
    call agit#bufwin#move_to_diff()
    call Expect(winnr('$')).to_equal(3)
    call Expect(w:agit_win_type).to_equal('diff')
  endfunction

  function! broken.do_not_recreate_windows_if_log_window_is_lost()
    call agit#bufwin#move_to_log()
    q
    Throws /Agit: / agit#bufwin#move_to_log()
  endfunction

endfunction
