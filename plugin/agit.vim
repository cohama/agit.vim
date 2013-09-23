if exists('g:loaded_agit')
  finish
endif
let g:loaded_easy_colorcolumn = 1

let s:save_cpo = &cpo
set cpo&vim

augroup agit
  autocmd!
augroup END

call agit#init()

let &cpo = s:save_cpo
