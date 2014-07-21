if exists("b:current_syntax")
  finish
endif

syn match agitStatAdded /\%(\d\+\ \)\zs+\+/
syn match agitStatRemoved /-\+$/
syn match agitStatFile    /^\ \f\+\ze\%(\ \+|\)/
syn match agitStatMessage /^\ \d\+\ files\?\ changed.*$/
syn match agitUntrackedTitle /^ -- untracked files --$/
syn match agitUntrackedFile /^ \f\+$/

hi def link agitStatAdded Identifier
hi def link agitStatRemoved Special
hi def link agitStatFile Constant
hi def link agitStatMessage Title
hi def link agitUntrackedTitle Structure
hi def link agitUntrackedFile Constant

let b:current_syntax = "agit_stat"
