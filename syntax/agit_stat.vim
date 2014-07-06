if exists("b:current_syntax")
  finish
endif

syn match agitStatAdded /\%(\d\+\ \)\zs+\+/
syn match agitStatRemoved /-\+$/
syn match agitStatFile    /^\ \f\+\ze\%(\ \+|\)/

hi def link agitStatAdded Identifier
hi def link agitStatRemoved Special
hi def link agitStatFile Constant

let b:current_syntax = "agit_stat"
