if exists('g:loaded_agit')
  finish
endif
let g:loaded_agit = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:agit_no_default_mappings')
  let g:agit_no_default_mappings = 0
endif
if !exists('g:agit_enable_auto_refresh')
  let g:agit_enable_auto_refresh = 0
endif
if !exists('g:agit_max_log_lines')
  let g:agit_max_log_lines = 500
endif

command! Agit call agit#launch()

let &cpo = s:save_cpo
