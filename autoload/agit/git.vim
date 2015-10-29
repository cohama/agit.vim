let s:P = agit#vital().P
let s:String = agit#vital().String
let s:List = agit#vital().List
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
\   'line' : 0,
\ },
\ 'unstaged' : {
\   'stat' : '',
\   'diff' : '',
\   'line' : 0,
\ },
\ 'head' : '',
\ }

function! s:git.log(winwidth) dict
  let gitlog = agit#git#exec('log --all --graph --decorate=full --no-color --date=relative --format=format:"%d %s' . s:sep . '|>%ad<|' . s:sep . '{>%an<}' . s:sep . '[%h]"', self.git_dir)
  " 16 means concealed symbol (4*2 + 2) + hash (7) - right eade margin (1)
  let max_width = a:winwidth + 16
  let gitlog = substitute(gitlog, '\<refs/heads/', '', 'g')
  let gitlog = substitute(gitlog, '\<refs/remotes/', 'r:', 'g')
  let gitlog = substitute(gitlog, '\<refs/tags/', 't:', 'g')
  let log_lines = map(split(gitlog, "\n"), 'split(v:val, s:sep)')

  let aligned_log = agit#aligner#align(log_lines, max_width)
  let self.head = self._head()

  " TODO: strange message will be shown when merge conflicted
  " add staged and unstaged lines
  let self.staged = self._localchanges(1, '')
  let self.unstaged = self._localchanges(0, '')
  let untracked = agit#git#exec('ls-files --others --exclude-standard', self.git_dir)
  if !empty(untracked)
    if self.unstaged.stat !=# ''
      let self.unstaged.stat .= "\n"
    endif
    let untracked2 = join(map(split(untracked, "\n"), "' ' . v:val"), "\n")
    let self.unstaged.stat .= "\n -- untracked files --\n" . untracked2
  endif
  call self._insert_localchanges_loglines(aligned_log)

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

  let self.head = self._head()
  let self.staged = self._localchanges(1, self.relpath)
  let self.unstaged = self._localchanges(0, self.relpath)
  call self._insert_localchanges_loglines(aligned_log)

  return join(aligned_log, "\n")
endfunction

function! s:git._head() dict
  let head = agit#git#exec('rev-parse --short HEAD', self.git_dir)
  return s:String.chomp(head)
endfunction

function! s:git._localchanges(cached, relpath) dict
  let cmd = 'diff --stat=' . g:agit_stat_width . ' -p'
  if a:cached
    let cmd .= ' --cached'
  endif
  if !empty(a:relpath)
    let cmd .= ' -- "' . a:relpath . '"'
  endif
  let diff = agit#git#exec(cmd, self.git_dir)
  let split = s:String.nsplit(diff, 2, '\n\n')
  let ret = {'stat' : '', 'diff' : '', 'line' : 0}
  if len(split) == 2
    let ret.stat = split[0]
    let ret.diff = split[1]
  elseif len(split) == 1
    let ret.diff = split[0]
  endif
  return ret
endfunction

function! s:git._insert_localchanges_loglines(aligned_log) dict
  if g:agit_localchanges_always_on_top
    let head_index = 0
  else
    let head_index = s:List.find_index(a:aligned_log, 'match(v:val, "\\[' . self.head . '\\]") >= 0')
  endif

  if !empty(self.unstaged.diff) || !empty(self.unstaged.stat)
    call insert(a:aligned_log, g:agit#git#unstaged_message, head_index)
    let self.unstaged.line = head_index + 1
    let head_index += 1
  endif
  if !empty(self.staged.diff)
    call insert(a:aligned_log, g:agit#git#staged_message, head_index)
    let self.staged.line = head_index + 1
  endif
endfunction

function! s:git.stat(hash) dict
  if a:hash ==# 'staged'
    let stat = self.staged.stat
  elseif a:hash ==# 'unstaged'
    let stat = self.unstaged.stat
  elseif a:hash ==# 'nextpage'
    let stat = ''
  else
    let ignoresp = g:agit_ignore_spaces ? '-w' : ''
    let stat = agit#git#exec('show --oneline --stat=' . g:agit_stat_width . ' --date=iso --pretty=format: ' . ignoresp . ' ' . a:hash, self.git_dir)
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
    let ignoresp = g:agit_ignore_spaces ? '-w' : ''
    let diff = agit#git#exec('show -p '. ignoresp .' ' . a:hash, self.git_dir)
  endif
  return diff
endfunction

function! s:git.normalizepath(path)
  let path = agit#git#exec('ls-tree --full-name --name-only HEAD ''' . a:path . '''', self.git_dir)
  return s:String.chomp(path)
endfunction

function! s:git.to_abspath(relpath)
  return fnamemodify(self.git_dir, ':h') . '/' . a:relpath
endfunction

function! s:git.catfile(hash, path)
  if a:hash == 'nextpage'
    let catfile = ''
  elseif a:hash == 'unstaged'
    let catfile = join(readfile(self.to_abspath(a:path)), "\n")
  elseif a:hash == 'staged'
    let catfile = agit#git#exec('cat-file -p ":' . a:path . '"', self.git_dir)
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
