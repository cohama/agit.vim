let s:String = agit#vital().String

let s:sep = '__SEP__'

let g:agit#git#staged_message = '+  Local changes checked in to index but not committed'
let g:agit#git#unstaged_message = '=  Local uncommitted changes, not checked in to index'

let s:git = {
\ 'git_dir' : '',
\ 'staged' : {
\   'stat' : '',
\   'diff' : '',
\ },
\ 'unstaged' : {
\   'stat' : '',
\   'diff' : ''
\ }}

function! s:git.log() dict
  let gitlog = agit#git#exec('log --all --graph --decorate=full --no-color --date=relative --format=format:"%d %s' . s:sep . '|>%ad<|' . s:sep . '{>%an<}' . s:sep . '[%h]"', self.git_dir)
  " 18 means concealed symbol (4*2 + 2) + margin (1) + hash (7)
  let max_width = &columns / 2 + 18
  let gitlog = substitute(gitlog, '\<refs/heads/', '', 'g')
  let gitlog = substitute(gitlog, '\<refs/remotes/', 'r:', 'g')
  let gitlog = substitute(gitlog, '\<refs/tags/', 't:', 'g')
  let log_lines = map(split(gitlog, "\n"), 'split(v:val, s:sep)')

  let aligned_log = agit#aligner#align(log_lines, max_width)

  let head_index = s:find_index(aligned_log, 'match(v:val, "HEAD") >= 0')

  let self.staged = {'stat' : '', 'diff' : ''}
  let self.unstaged = {'stat' : '', 'diff' : ''}
  " add staged line
  let staged = agit#git#exec('diff --stat -p --cached', self.git_dir)
  if !empty(staged)
    call insert(aligned_log, g:agit#git#staged_message, head_index)
    let [stat, diff] = s:String.nsplit(staged, 2, "\n\n")
    let self.staged.stat = stat
    let self.staged.diff = diff
  endif

  " add unstaged line
  let unstaged = agit#git#exec('diff --stat -p', self.git_dir)
  let untracked = agit#git#exec('ls-files --others --exclude-standard', self.git_dir)
  if !empty(unstaged) || !empty(untracked)
    call insert(aligned_log, g:agit#git#unstaged_message, head_index)
    if !empty(unstaged)
      let [stat, diff] = s:String.nsplit(unstaged, 2, "\n\n")
      let self.unstaged.stat = stat
      let self.unstaged.diff = diff
    endif
    if !empty(untracked)
      " let self.unstaged.stat = ''
      " let self.unstaged.diff = ''
    endif
  endif

  return join(aligned_log, "\n")
endfunction

function! s:git.stat(hash) dict
  if a:hash ==# 'staged'
    let stat = self.staged.stat
  elseif a:hash ==# 'unstaged'
    let stat = self.unstaged.stat
  else
    let stat = agit#git#exec('show --oneline --stat --date=iso --pretty=format: '. a:hash, self.git_dir)
  endif
  return stat
endfunction

function! s:git.diff(hash) dict
  if a:hash ==# 'staged'
    let diff = self.staged.diff
  elseif a:hash ==# 'unstaged'
    let diff = self.unstaged.diff
  else
    let diff = agit#git#exec('show -p ' . a:hash, self.git_dir)
  endif
  return diff
endfunction

function! agit#git#new(git_dir)
  return extend(deepcopy(s:git), {'git_dir' : a:git_dir})
endfunction

" Utilities
function! agit#git#exec(command, git_dir)
  let worktree_dir = matchstr(a:git_dir, '^.\+\ze\.git')
  return system('git --no-pager --git-dir=' . a:git_dir . ' --work-tree=' . worktree_dir . ' ' . a:command)
endfunction

function! s:find_index(xs, expr)
  for i in range(0, len(a:xs))
    if eval(substitute(a:expr, 'v:val', string(a:xs[i]), 'g'))
      return i
    endif
  endfor
  for x in a:list
  endfor
  return -1
endfunction
