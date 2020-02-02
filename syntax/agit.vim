if exists("b:current_syntax")
  finish
endif

syn cluster agitLogFields contains=agitDate,agitAuthor,agitHash
syn cluster agitRefs contains=agitHead,agitBranch,agitRemote,agitTag

hi def link agitTree0 Constant
syn match agitLog /.*/ contained contains=@agitLogFields

syn region agitRef start="(" end=")" end="\.\.\." contained contains=@agitRefs nextgroup=agitLog keepend
syn keyword agitHead HEAD contained
syn match agitRemote /r:[^, :)]\+/ contained
syn match agitTag /t:[^, :)]\+/ contained
syn match agitDate /|>[a-zA-Z0-9, ]\+<|/ contained contains=agitDateMark
syn match agitAuthor /{>[^}]\+<}/ contained contains=agitAuthorMark
syn match agitHash  /\[\x\{7,\}]/ contained conceal

syn match agitDateMark /|>/ contained conceal
syn match agitDateMark /<|/ contained conceal
syn match agitAuthorMark /{>/ contained conceal
syn match agitAuthorMark /<}/ contained conceal

let s:tree_chars = '|/\\*_\-.'
let s:tree_pat = '/['. s:tree_chars .']\{-}\zs[ '. s:tree_chars .']/'
exe 'syn match agitTree9' s:tree_pat 'nextgroup=agitTree0,agitRef,agitLog skipwhite'
exe 'syn match agitTree8' s:tree_pat 'nextgroup=agitTree9,agitRef,agitLog skipwhite'
exe 'syn match agitTree7' s:tree_pat 'nextgroup=agitTree8,agitRef,agitLog skipwhite'
exe 'syn match agitTree6' s:tree_pat 'nextgroup=agitTree7,agitRef,agitLog skipwhite'
exe 'syn match agitTree5' s:tree_pat 'nextgroup=agitTree6,agitRef,agitLog skipwhite'
exe 'syn match agitTree4' s:tree_pat 'nextgroup=agitTree5,agitRef,agitLog skipwhite'
exe 'syn match agitTree3' s:tree_pat 'nextgroup=agitTree4,agitRef,agitLog skipwhite'
exe 'syn match agitTree2' s:tree_pat 'nextgroup=agitTree3,agitRef,agitLog skipwhite'
exe 'syn match agitTree1' s:tree_pat 'nextgroup=agitTree2,agitRef,agitLog skipwhite'
exe 'syn match agitTree0' s:tree_pat 'nextgroup=agitTree1,agitRef,agitLog skipwhite'

hi def link agitLog Normal
hi def link agitHead Special
hi def link agitRef Directory
hi def link agitRemote Statement
hi def link agitTag String
hi def link agitDate Statement
hi def link agitAuthor Type
hi def link agitHash Ignore
hi def link agitDateMark Ignore
hi def link agitAuthorMark Ignore

if &background == "dark"
  highlight default agitTree1 ctermfg=magenta     guifg=green1
  highlight default agitTree2 ctermfg=green       guifg=yellow1
  highlight default agitTree3 ctermfg=yellow      guifg=orange1
  highlight default agitTree4 ctermfg=cyan        guifg=greenyellow
  highlight default agitTree5 ctermfg=red         guifg=springgreen1
  highlight default agitTree6 ctermfg=yellow      guifg=cyan1
  highlight default agitTree7 ctermfg=green       guifg=slateblue1
  highlight default agitTree8 ctermfg=cyan        guifg=magenta1
  highlight default agitTree9 ctermfg=magenta     guifg=purple1
else
  highlight default agitTree1 ctermfg=darkyellow  guifg=orangered3
  highlight default agitTree2 ctermfg=darkgreen   guifg=orange2
  highlight default agitTree3 ctermfg=blue        guifg=yellow3
  highlight default agitTree4 ctermfg=darkmagenta guifg=olivedrab4
  highlight default agitTree5 ctermfg=red         guifg=green4
  highlight default agitTree6 ctermfg=darkyellow  guifg=paleturquoise3
  highlight default agitTree7 ctermfg=darkgreen   guifg=deepskyblue4
  highlight default agitTree8 ctermfg=blue        guifg=darkslateblue
  highlight default agitTree9 ctermfg=darkmagenta guifg=darkviolet
endif

let b:current_syntax = "agit"
