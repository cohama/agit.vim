" move to a window or create new one which the specified predicate will be true
function agit#bufwin#move_or_create_window(winvarname, winvarval, cmd)
  let found = 0
  for w in range(1, winnr('$'))
    if getwinvar(w, a:winvarname) ==# a:winvarval
      let found = 1
      break
    endif
  endfor
  if found
    noautocmd execute w . 'wincmd w'
  else
    noautocmd execute a:cmd
    let w:{a:winvarname} = a:winvarval
  endif
endfunction
