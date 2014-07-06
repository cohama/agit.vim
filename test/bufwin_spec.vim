let s:assert = themis#helper('assert')
let s:suite = themis#suite('agit#bufwin#move_or_create_window')
function! s:suite.before_each()
  " create new 2 windows before each tests
  " one has variable w:h and the other has w:f
  new
  only
  new
  let w:h = "hoge"
  wincmd p
  let w:f = "fuga"
endfunction

function! s:suite.focus_to_the_window_which_the_specified_variable_has_the_specified_value()
  call agit#bufwin#move_or_create_window('h', 'hoge', 'new')
  call s:assert.equals(w:h, "hoge")
  call s:assert.equals(winnr('$'), 2)
endfunction

function! s:suite.creates_a_new_window_when_the_specified_variable_is_not_found()
  call agit#bufwin#move_or_create_window('p', 'piyo', 'new')
  call s:assert.equals(w:p, 'piyo')
  call s:assert.equals(winnr('$'), 3)
endfunction

function! s:suite.creates_new_window_when_the_specified_value_is_differnet()
  call agit#bufwin#move_or_create_window('h', 'piyo', 'new')
  call s:assert.equals(w:h, 'piyo')
  call s:assert.equals(winnr('$'), 3)
endfunction

function! s:suite.creates_new_window_with_the_specified_open_command()
  let orig_height = winheight('.')
  let orig_width = winwidth('.')
  call agit#bufwin#move_or_create_window('h', 'piyo', 'botright vnew')
  call s:assert.compare(winheight('.'), '>', orig_height)
  call s:assert.compare(winwidth('.'), '<', orig_width)
endfunction
