let s:seps = [' ', ' ', '', '']
let s:String = agit#vital().String
let s:List = agit#vital().List

" table: [[String]] 2-dimensional string list
" max_col: Integer if a one log exceeds max_col, be trimmed.
function! agit#aligner#align(table, max_col, ...)
  let column_number = len(a:table[0]) " sampling head's column number

  let maxs = []
  for c in range(column_number)
    let max = 0
    for i in range(min([len(a:table), g:agit_max_log_lines]))
      let log = a:table[i]
      let max = (c < len(log) && strwidth(log[c]) > max) ? strwidth(log[c]) : max
    endfor
    call add(maxs, max)
  endfor

  let ret = []
  let len_maxs = len(maxs)
  let width_without_commit_msg = s:sum(maxs) - maxs[0]
  let seps_width = s:sum(map(copy(s:seps), 'strwidth(v:val)'))
  let commit_msg_column = a:max_col == 0 ? maxs[0] : a:max_col - width_without_commit_msg - seps_width

  for i in range(min([len(a:table), g:agit_max_log_lines]))
    let log = a:table[i]
    let col = []

    call add(col, s:fillncate(log[0], commit_msg_column))

    for c in range(1, len(log) - 1)
      let spacer = repeat(' ', maxs[c] - strwidth(log[c]))
      call add(col, log[c] . spacer)
    endfor

    let line = ''

    for c in range(0, len(col) - 2)
      let line .= col[c] . s:seps[c]
    endfor
    let line .= col[-1]
    call add(ret, s:String.trim(line))
  endfor
  if len(a:table) > g:agit_max_log_lines
    call add(ret, '')
    call add(ret, g:agit#git#nextpage_message)
  endif
  return ret
endfunction

function! agit#aligner#_align_fields(log, maxs, max_col)
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
