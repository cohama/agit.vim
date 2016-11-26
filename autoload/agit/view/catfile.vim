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
  call s:fill_buffer(self.git.catfile(a:hash, self.git.filepath))
  if exists('w:agit_scrolllock')
    let line = w:agit_scrolllock[0]
    let winline = w:agit_scrolllock[1]
    call setpos('.', [0, line, 1, 0])
    let save_scrolloff = &l:scrolloff
    setlocal scrolloff=0
    normal! zt
    if winline > 1
      execute 'normal! ' . (winline - 1) . "\<C-y>"
    endif
    let &l:scrolloff = save_scrolloff
  endif
endfunction

function! s:catfile.setlocal()
  call agit#bufwin#move_to(self.name)
  silent file `='[Agit catfile] ' . self.git.seq`
  execute 'doautocmd BufNewFile ' . self.git.filepath
  setlocal buftype=nofile nobuflisted bufhidden=delete
  setlocal foldcolumn=0
  setlocal nomodifiable
  setlocal nocursorline nocursorcolumn
  setlocal winfixheight
  setlocal noswapfile
  nmap <buffer> q <Plug>(agit-exit)
  augroup agit-catfile
    autocmd!
    autocmd WinLeave <buffer> call s:saveline()
  augroup END
endfunction

function! s:saveline()
  let w:agit_scrolllock = [line('.'), winline()]
endfunction
