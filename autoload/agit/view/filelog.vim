let s:filelog = {
\ 'name': 'filelog'
\ }

function! agit#view#filelog#new(git)
  let filelog = extend(agit#view#log#new(a:git), s:filelog)
  command! -buffer -nargs=? -complete=customlist,agit#diff#complete_revspec AgitDiff call agit#diff(<q-args>)
  if !g:agit_no_default_mappings
    nmap <silent><buffer> di <Plug>(agit-diff)
    nmap <silent><buffer> dl <Plug>(agit-diff-with-local)
  endif
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
  call self.renderwith('filelog')
endfunction
