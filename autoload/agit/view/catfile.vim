let s:catfile = {
\ 'name': 'catfile'
\ }

function! agit#view#catfile#new(git)
  let catfile = deepcopy(s:catfile)
  let catfile.git = a:git
  call catfile.setlocal()
  call add(a:git.onhashchange, catfile)
  " call add(a:git.onpathchange, catfile)
  return catfile
endfunction

function! s:fill_buffer(str)
  setlocal modifiable
  noautocmd silent! %delete _
  noautocmd silent! 1put= a:str
  noautocmd silent! 1delete _
  setlocal nomodifiable
endfunction

function! s:catfile.render(hash)
  call agit#bufwin#move_to(self.name)
  call s:fill_buffer(self.git.catfile(a:hash, self.git.relpath))
endfunction

function! s:catfile.setlocal()
  call agit#bufwin#move_to(self.name)
  silent file `='[Agit catfile] ' . self.git.seq`
  execute 'doautocmd BufNewFile ' . self.git.path
  setlocal buftype=nofile nobuflisted bufhidden=delete
  setlocal foldcolumn=0
  setlocal nonumber norelativenumber nowrap
  setlocal nomodifiable
  setlocal nocursorline nocursorcolumn
  setlocal winfixheight
  nmap <buffer> q <Plug>(agit-exit)
endfunction
