let s:spacer = ' '
let s:String = agit#vital().String
let s:List = agit#vital().List

" table: [[String]] 2-dimensional string list
" max_col: Integer if a one log exceeds max_col, be trimmed.
function! agit#aligner#align(table, max_col, ...)
  let column_number = len(a:table[0]) " sampling head's column number

  let maxs = []
  for c in range(column_number)
    let max = 0
    for log in a:table
      let max = (c < len(log) && strwidth(log[c]) > max) ? strwidth(log[c]) : max
    endfor
    call add(maxs, max)
  endfor

  return map(deepcopy(a:table), 'agit#aligner#_align_fields(v:val, maxs, s:spacer, a:max_col)')
endfunction

function! agit#aligner#_align_fields(log, maxs, sep, max_col)
  if len(a:log) == len(a:maxs)
    let [commit_msg, date, committer, hash] = a:log
  else
    let [commit_msg, date, committer, hash] = [a:log[0], '', '', '']
  endif

  let ret = []
  for c in range(len(a:maxs))
    if c < len(a:log)
      let spacer = repeat(' ', a:maxs[c] - strwidth(a:log[c]))
      " truncate commit message
      if c == 0 && a:max_col != 0
        let without_commit_msg = copy(a:maxs)
        call s:List.shift(without_commit_msg)
        let commit_msg_column = a:max_col - s:sum(without_commit_msg) - (strwidth(a:sep) * (len(a:maxs) - 1))
        call add(ret, s:fillncate(a:log[c], commit_msg_column))
      else
        call add(ret, a:log[c] . spacer)
      endif
    else
      let spacer = repeat(' ', a:maxs[c])
      call add(ret, spacer)
    endif
  endfor
  " printf is easy solution but not able to handle muti-byte string
  " TODO printf based on display width
  return s:String.trim(join(ret, a:sep))
endfunction

function! s:sum(xs)
  let ret = 0
  for i in a:xs
    let ret += i
  endfor
  return ret
endfunction

function! s:fillncate(text, width)
  return agit#string#fill_right(agit#string#truncate(a:text, a:width, '...'), a:width)
endfunction
