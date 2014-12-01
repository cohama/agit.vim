function! agit#bufwin#agit_tabnew(git)
  tabnew
  for v in a:git.views
    call s:run_layout(get(v, 'layout', ''))
    let w:view = agit#view#{v.name}#new(a:git)
  endfor
  call a:git.fire_init()
endfunction

function! agit#bufwin#move_to(name)
  for w in range(1, winnr('$'))
    let win = getwinvar(w, '')
    if has_key(win, 'view') && has_key(win.view, 'name') && win.view.name ==# a:name
      execute w . 'wincmd w'
      return 1
    endif
  endfor
  return 0
endfunction

function! s:run_layout(layout)
  if a:layout !=# ''
    execute substitute(a:layout, "{\\(.\\{-}\\)}", "\\=eval(submatch(1))", "g")
  endif
endfunction
