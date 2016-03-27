let s:String = agit#vital().String
let s:List = agit#vital().List

function! agit#string#truncate(text, max_width, ellipsis)
  let ellipsis_width = strdisplaywidth(a:ellipsis)
  let text_width = strdisplaywidth(a:text)
  if a:max_width < ellipsis_width
    return a:ellipsis
  elseif text_width > a:max_width
    let truncated = s:String.strwidthpart(a:text, a:max_width - ellipsis_width)
    " for double width string
    if strdisplaywidth(truncated) != a:max_width - ellipsis_width
      let truncated .= ' '
    endif
    return truncated . a:ellipsis
  else
    return a:text
  endif
endfunction

function! agit#string#fill_left(text, max_length)
  let text_width = strdisplaywidth(a:text)
  if text_width >= a:max_length
    return a:text
  else
    return repeat(' ', a:max_length - text_width) . a:text
  endif
endfunction

function! agit#string#fill_right(text, max_length)
  let text_width = strdisplaywidth(a:text)
  if text_width >= a:max_length
    return a:text
  else
    return a:text . repeat(' ', a:max_length - text_width)
  endif
endfunction

function! s:fillncate(text, width)
  return agit#string#fill_left(agit#string#truncate(a:text, a:width, '...'), a:width)
endfunction

function! s:sum(xs)
  let ret = 0
  for i in a:xs
    let ret += i
  endfor
  return ret
endfunction

" logs: List[String] result of `git log`
" max_col: Integer if a one log exceeds max_col, be trimmed.
function! agit#string#format_commit_logs(logs, max_col)
  let log_list = map(copy(a:logs), 'split(v:val, "__SEP__")')
  let column_number = len(log_list[0]) " sampling head's column number

  let maxs = []
  for c in range(column_number)
    let max = 0
    for log in log_list
      let max = (c < len(log) && strwidth(log[c]) > max) ? strwidth(log[c]) : max
    endfor
    call add(maxs, max)
  endfor

  let sep = ' |'
  return map(log_list, 'agit#string#_align_fields(v:val, maxs, sep, a:max_col)')
endfunction

function! agit#string#_align_fields(log, maxs, sep, max_col)
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
      " heuristic search of a date column
      " TODO need any info for padding?
      elseif a:log[c] =~# '^\d.*ago$'
        call add(ret, spacer . a:log[c])
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

function! agit#string#align_column(text, format_option)
  let default_option = {
  \ 'width' : strdisplaywidth(a:text),
  \ 'truncate' : 0,
  \ 'align' : 'left'
  \ }
  let option = extend(default_option, a:format_option)
  if option.truncate
    let truncated = agit#string#truncate(a:text, option.width, '...')
  else
    let truncated = a:text
  endif
  if option.align ==# 'right'
    return agit#string#fill_right(truncated, option.width)
  else
    return agit#string#fill_left(truncated, option.width)
  endif
endfunction
