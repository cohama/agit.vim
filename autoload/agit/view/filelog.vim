let s:filelog = {
\ 'name': 'filelog'
\ }

function! agit#view#filelog#new(git)
  let filelog = extend(agit#view#log#new(a:git), s:filelog)
  return filelog
endfunction

function! s:fill_buffer(str)
  setlocal modifiable
  noautocmd silent! %delete _
  noautocmd silent! 1put= a:str
  noautocmd silent! 1delete _
  setlocal nomodifiable
endfunction

function! s:filelog.render()
  call agit#bufwin#move_to(self.name)
  call s:fill_buffer(self.git.filelog(winwidth(0)))
  call self.emmit()
endfunction
