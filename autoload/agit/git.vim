let s:P = agit#vital().P
let s:String = agit#vital().String
let s:Process = agit#vital().Process

let s:sep = '__SEP__'

let g:agit#git#staged_message = '+  Local changes checked in to index but not committed'
let g:agit#git#unstaged_message = '=  Local uncommitted changes, not checked in to index'
let g:agit#git#nextpage_message = '(too many logs)'

let s:git = {
\ 'git_dir' : '',
\ 'hash': '',
\ 'oninit': [],
\ 'onhashchange': [],
\ 'staged' : {
\   'stat' : '',
\   'diff' : '',
\ },
\ 'unstaged' : {
\   'stat' : '',
\   'diff' : ''
\ }}

function! s:git.log(winwidth) dict
  let gitlog = agit#git#exec('log --all --graph --decorate=full --no-color --date=relative --format=format:"%d %s' . s:sep . '|>%ad<|' . s:sep . '{>%an<}' . s:sep . '[%h]"', self.git_dir)
  " 16 means concealed symbol (4*2 + 2) + hash (7) - right eade margin (1)
  let max_width = a:winwidth + 16
  let gitlog = substitute(gitlog, '\<refs/heads/', '', 'g')
  let gitlog = substitute(gitlog, '\<refs/remotes/', 'r:', 'g')
  let gitlog = substitute(gitlog, '\<refs/tags/', 't:', 'g')
  let log_lines = map(split(gitlog, "\n"), 'split(v:val, s:sep)')

  let aligned_log = agit#aligner#align(log_lines, max_width)

  let head_hash = agit#git#exec('rev-parse --short HEAD', self.git_dir)
  let head_index = s:find_index(aligned_log, 'match(v:val, "[' . head_hash . ']") >= 0')

  let self.staged = {'stat' : '', 'diff' : ''}
  let self.unstaged = {'stat' : '', 'diff' : ''}

  " TODO: strange message will be shown when merge conflicted
  " add staged line
  let staged = agit#git#exec('diff --stat -p --cached', self.git_dir)
  if !empty(staged)
    call insert(aligned_log, g:agit#git#staged_message, head_index)
    let split = s:String.nsplit(staged, 2, '\n\n')
    if len(split) == 2
      let self.staged.stat = split[0]
      let self.staged.diff = split[1]
    elseif len(split) == 1
      let self.staged.stat = ''
      let self.staged.diff = split[0]
    else
      let self.staged.diff = ''
      let self.staged.stat = ''
    endif
  endif

  " add unstaged line
  let unstaged = agit#git#exec('diff --stat -p', self.git_dir)
  let untracked = agit#git#exec('ls-files --others --exclude-standard', self.git_dir)
  if !empty(unstaged) || !empty(untracked)
    call insert(aligned_log, g:agit#git#unstaged_message, head_index)
    if !empty(unstaged)
      let split = s:String.nsplit(unstaged, 2, '\n\n')
      if len(split) == 2
        let self.unstaged.stat = split[0]
        let self.unstaged.diff = split[1]
      elseif len(split) == 1
        let self.unstaged.stat = ''
        let self.unstaged.diff = split[0]
      else
        let self.unstaged.diff = ''
        let self.unstaged.stat = ''
      endif
    endif
    if !empty(untracked)
      if self.unstaged.stat !=# ''
        let self.unstaged.stat .= "\n"
      endif
      let untracked2 = join(map(split(untracked, "\n"), "' ' . v:val"), "\n")
      let self.unstaged.stat .= "\n -- untracked files --\n" . untracked2
    endif
  endif

  return join(aligned_log, "\n")
endfunction

function! s:git.filelog(winwidth)
  let gitlog = agit#git#exec('log --all --graph --decorate=full --no-color --date=relative --format=format:"%d %s' . s:sep . '|>%ad<|' . s:sep . '{>%an<}' . s:sep . '[%h]" -- "' . self.abspath . '"', self.git_dir)
  " 16 means concealed symbol (4*2 + 2) + hash (7) - right eade margin (1)
  let max_width = a:winwidth + 16
  let gitlog = substitute(gitlog, '\<refs/heads/', '', 'g')
  let gitlog = substitute(gitlog, '\<refs/remotes/', 'r:', 'g')
  let gitlog = substitute(gitlog, '\<refs/tags/', 't:', 'g')
  let log_lines = map(split(gitlog, "\n"), 'split(v:val, s:sep)')

  let aligned_log = agit#aligner#align(log_lines, max_width)

  let self.staged = {'stat' : '', 'diff' : ''}
  let self.unstaged = {'stat' : '', 'diff' : ''}

  return join(aligned_log, "\n")
endfunction

function! s:git.stat(hash) dict
  if a:hash ==# 'staged'
    let stat = self.staged.stat
  elseif a:hash ==# 'unstaged'
    let stat = self.unstaged.stat
  elseif a:hash ==# 'nextpage'
    let stat = ''
  else
    let stat = agit#git#exec('show --oneline --stat --date=iso --pretty=format: '. a:hash, self.git_dir)
    let stat = substitute(stat, '^[\n\r]\+', '', '')
  endif
  return stat
endfunction

function! s:git.diff(hash) dict
  if a:hash ==# 'staged'
    let diff = self.staged.diff
  elseif a:hash ==# 'unstaged'
    let diff = self.unstaged.diff
  elseif a:hash ==# 'nextpage'
    let diff = ''
  else
    let diff = agit#git#exec('show -p ' . a:hash, self.git_dir)
  endif
  return diff
endfunction

function! s:git.normalizepath(path)
  let path = agit#git#exec('ls-tree --full-name --name-only HEAD "' . a:path . '"', self.git_dir)
  return s:String.chomp(path)
endfunction

function! s:git.catfile(hash, path)
  if a:hash == 'nextpage'
    let catfile = ''
  else
    let catfile = agit#git#exec('cat-file -p "' . a:hash . ':' . a:path . '"', self.git_dir)
  endif
  return catfile
endfunction

function! s:git.commitmsg(hash) dict
  return agit#git#exec('show -s --format=format:%s ' . a:hash, self.git_dir)
endfunction

let s:seq = ''
function! agit#git#new(git_dir)
  let git = extend(deepcopy(s:git), {'git_dir' : a:git_dir, 'seq': s:seq})
  let s:seq += 1
  return git
endfunction

" Utilities
let s:last_status = 0
let s:is_cp932 = &enc == 'cp932'
function! agit#git#exec(command, git_dir, ...)
  let worktree_dir = matchstr(a:git_dir, '^.\+\ze\.git')
  let cmd = 'git --no-pager --git-dir="' . a:git_dir . '" --work-tree="' . worktree_dir . '" ' . a:command
  if a:0 > 0 && a:1 == 1
    execute '!' . cmd
  else
    if s:Process.has_vimproc() && s:P.is_windows()
      let ret = vimproc#system(cmd)
      let s:last_status = vimproc#get_last_status()
    else
      let ret = system(cmd)
      let s:last_status = v:shell_error
    endif
    if s:is_cp932
      let ret = iconv(ret, 'utf-8', 'cp932')
    endif
    return ret
  endif
endfunction

function! agit#git#get_last_status()
  return s:last_status
endfunction

function! s:find_index(xs, expr)
  for i in range(0, len(a:xs) - 1)
    if eval(substitute(a:expr, 'v:val', string(a:xs[i]), 'g'))
      return i
    endif
  endfor
  return -1
endfunction

function! s:git.fire_init()
  for view in self.oninit
    call view.render()
  endfor
endfunction

function! s:git.sethash(hash, force)
  if self.hash !=# a:hash || a:force
    let self.hash = a:hash
    for view in self.onhashchange
      call view.render(a:hash)
    endfor
  endif
endfunction
