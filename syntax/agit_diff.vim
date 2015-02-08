if exists("b:current_syntax")
  finish
endif

syn case ignore
syn sync minlines=50

syn region agitHeader start=/\%^/ end=/^$/ contains=agitHeaderLabel
syn match agitHeaderLabel /^\w\+:/ contained display
syn match agitHeaderLabel /^commit/ contained display

syn region agitDiff start=/^diff --git/ end=/^\%(^diff --git\)\@=\|\%$/ contains=agitDiffHeader,agitDiffFileName,agitDiffIndex,agitDiffAdd,agitDiffRemove
syn region agitDiffMerge start=/^diff --cc/ end=/^\%(^diff --cc\)\@=\|\%$/ contains=agitDiffHeader,agitDiffFileName,agitDiffIndex,agitDiffRemoveMerge,agitDiffAddMerge
syn match agitDiffAdd /^+.*/ display
syn match agitDiffRemove /^-.*/ display
syn match agitDiffHeader /^diff --\%(git\|cc\).*$/ display contained
syn match agitDiffRemoveMerge /^\%( -\|- \|--\).*/ display contained
syn match agitDiffAddMerge /^\%( +\|+ \|++\).*/ display contained
syn match agitDiffFileName /^\%(+++\|---\) .*$/ display contained
syn match agitDiffIndex /^index.*$/ display contained
syn match agitDiffLine /^@@ -.\{-}@@.*$/ display contained contains=agitDiffSubname
syn match agitDiffSubname /^\%(@@ -.\{-}@@\)\zs.*$/ display contained

hi def link agitDiffAdd Identifier
hi def link agitDiffAddMerge Identifier
hi def link agitDiffRemove Special
hi def link agitDiffRemoveMerge Special
hi def link agitDiffHeader Type
hi def link agitHeaderLabel Label
hi def link agitDiffFileName Comment
hi def link agitDiffIndex Comment
hi def link agitDiffLine Comment
hi def link agitDiffSubname PreProc

let b:current_syntax = "agit_diff"
