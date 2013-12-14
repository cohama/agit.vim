if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

if !exists('g:agit_no_default_mappings')
  let g:agit_no_default_mappings = 0
endif

if !g:agit_no_default_mappings
  silent nmap <silent><buffer> <CR> <Plug>(agit-show-commit)
  silent nmap <silent><buffer> j j<Plug>(agit-show-commit)
  silent nmap <silent><buffer> k k<Plug>(agit-show-commit)
endif

setl conceallevel=2
setl concealcursor=nvc
