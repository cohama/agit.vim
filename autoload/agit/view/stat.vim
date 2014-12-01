let s:stat = {
\ 'name': 'stat'
\ }

function! agit#view#stat#new(git)
  let stat = deepcopy(s:stat)
  let stat.git = a:git
  call stat.setlocal()
  call add(a:git.onhashchange, stat)
  return stat
endfunction

function! s:fill_buffer(str)
  setlocal modifiable
  noautocmd silent! %delete _
  noautocmd silent! 1put= a:str
  noautocmd silent! 1delete _
  setlocal nomodifiable
endfunction

function! s:stat.render(hash)
  call agit#bufwin#move_to(self.name)
  call s:fill_buffer(self.git.stat(a:hash))
endfunction

function! s:stat.setlocal()
  call agit#bufwin#move_to(self.name)
  silent file `='[Agit stat] ' . self.git.seq`
  set filetype=agit_stat
  setlocal buftype=nofile nobuflisted bufhidden=delete
  setlocal foldcolumn=0
  setlocal nonumber norelativenumber nowrap
  setlocal nomodifiable
  setlocal nocursorline nocursorcolumn
  setlocal winfixheight
  nmap <buffer> q <Plug>(agit-exit)
endfunction
