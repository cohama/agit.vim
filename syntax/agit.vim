if exists("b:current_syntax")
  finish
endif

syn cluster agitLogFields contains=agitDate,agitAuthor,agitHash
syn cluster agitRefs contains=agitHead,agitBranch,agitRemote,agitTag

syn match agitTree /^[|/\\* _\-.]\+/ nextgroup=agitRef,agitLog
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

hi def link agitTree Constant
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

let b:current_syntax = "agit"
