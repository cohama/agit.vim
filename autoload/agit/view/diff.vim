let s:diff = {
\ 'name': 'diff'
\ }

function! agit#view#diff#new(git)
  let diff = deepcopy(s:diff)
  let diff.git = a:git
  call diff.setlocal()
  call add(a:git.onhashchange, diff)
  return diff
endfunction

function! s:fill_buffer(str)
  setlocal modifiable
  noautocmd silent! %delete _
  noautocmd silent! 1put= a:str
  noautocmd silent! 1delete _
  setlocal nomodifiable
endfunction

function! s:diff.render(hash)
  call agit#bufwin#move_to(self.name)
  call s:fill_buffer(self.git.diff(a:hash))
  setlocal modifiable
  silent %s/^\s\+$//ge
  silent %s/\r$//ge
  setlocal nomodifiable
  1
endfunction

function! s:diff.setlocal()
  call agit#bufwin#move_to(self.name)
  silent file `='[Agit diff] ' . self.git.seq`
  setlocal buftype=nofile nobuflisted bufhidden=delete
  setlocal foldcolumn=0
  setlocal nonumber norelativenumber nowrap
  setlocal nomodifiable
  setlocal nocursorline nocursorcolumn
  setlocal winfixheight
  setlocal noswapfile

  if !g:agit_no_default_mappings
    nmap <silent><buffer> u <PLug>(agit-reload)
    nmap <silent><buffer> J <Plug>(agit-scrolldown-stat)
    nmap <silent><buffer> K <Plug>(agit-scrollup-stat)

    nmap <silent><buffer> q <Plug>(agit-exit)
  endif


  set filetype=agit_diff
endfunction
