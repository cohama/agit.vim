let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('agit')
let s:P = s:V.import('Prelude')
let s:String = s:V.import('Data.String')
let s:List = s:V.import('Data.List')
let s:Process = s:V.import('Process')
let s:OptionParser = s:V.import('OptionParser')

let s:agit_vital = {
\ 'V' : s:V,
\ 'P' : s:P,
\ 'String' : s:String,
\ 'List' : s:List,
\ 'Process' : s:Process,
\ 'OptionParser' : s:OptionParser,
\ }

let s:agit_preset_views = get(g:, 'agit_preset_views', {
\ 'default': [
\   {'name': 'log'},
\   {'name': 'stat',
\    'layout': 'botright vnew'},
\   {'name': 'diff',
\    'layout': 'belowright {winheight(".") * 3 / 4}new'}
\ ],
\ 'file': [
\   {'name': 'filelog'},
\   {'name': 'catfile',
\    'layout': 'botright vnew'},
\ ]})
let s:fugitive_enabled = get(g:, 'loaded_fugitive', 0)

let s:parser = s:OptionParser.new()
call s:parser.on('--dir=VALUE', 'Launch Agit on the specified directory instead of the buffer direcotry.',
\ {'completion' : 'file', 'default': ''})
call s:parser.on('--file=VALUE', 'Specify file name traced by Agit file. (Available on Agit file)',
\ {'completion' : 'file', 'default': '%'})

function! agit#complete_command(arglead, cmdline, cursorpos)
  return s:parser.complete_greedily(a:arglead, a:cmdline, a:cursorpos)
endfunction

function! agit#vital()
  return s:agit_vital
endfunction

function! agit#launch(args)
  try
    let parsed_args = s:parse_args(a:args)
    if has_key(parsed_args, 'help')
      call s:parser.help()
      return
    endif
    let git_root = s:get_git_root(parsed_args.dir)
    let git = agit#git#new(git_root)
    let filepath = fnamemodify(expand(parsed_args.file), ':p')
    if parsed_args.presetname ==# 'file' && !filereadable(filepath)
      throw "Agit: File not found: " . parsed_args.file
    endif
    if parsed_args.presetname ==# 'file' && agit#git#exec('ls-files "' . filepath . '"', git.git_root) ==# ''
      throw "Agit: File not tracked: " . parsed_args.file
    endif
    let git.filepath = filepath
    let git.views = parsed_args.preset
    if g:agit_reuse_tab
      for t in range(1, tabpagenr('$'))
        let tabgit = gettabvar(t, 'git', {})
        if tabgit != {} && git.git_root ==# tabgit.git_root
        \ && git.views == tabgit.views && (git.views[0].name !=# 'filelog' || git.filepath == tabgit.filepath)
          execute 'tabnext ' . t
          call agit#reload()
          return
        endif
      endfor
    endif
    call agit#bufwin#agit_tabnew(git)
    let t:git = git
    if s:fugitive_enabled
      call fugitive#detect(git_root . '/.git')
    endif
  catch /Agit: /
    echohl ErrorMsg | echomsg v:exception | echohl None
  endtry
endfunction

function! s:parse_args(args)
  try
    let parse_result = s:parser.parse(a:args)
    if empty(parse_result.__unknown_args__)
      let parse_result.preset = s:agit_preset_views.default
      let parse_result.presetname = ''
    elseif has_key(s:agit_preset_views, parse_result.__unknown_args__[0])
      let parse_result.presetname = parse_result.__unknown_args__[0]
      let parse_result.preset = s:agit_preset_views[parse_result.presetname]
    else
      throw 'vital: OptionParser: Unknown option was specified: ' . parse_result.__unknown_args__[0]
    endif
    return parse_result
  catch /vital: OptionParser: /
    let msg = matchstr(v:exception, 'vital: OptionParser: \zs.*')
    throw 'Agit: ' . msg
  endtry
endfunction

function! agit#print_commitmsg()
  let hash = agit#extract_hash(getline('.'))
  if hash != ''
    echo t:git.commitmsg(hash)
  else
    echo
  endif
endfunction

function! agit#remote_scroll(win_type, direction)
  if !exists('w:view')
    return
  endif
  let win_save = w:view.name
  if !agit#bufwin#move_to(a:win_type)
    return
  endif
  if a:direction ==# 'down'
    execute "normal! \<C-d>"
  elseif a:direction ==# 'up'
    execute "normal! \<C-u>"
  endif
  call agit#bufwin#move_to(win_save)
endfunction

function! agit#yank_hash()
  call setreg(v:register, agit#extract_hash(getline('.')))
  echo 'yanked ' . getreg(v:register)
endfunction

function! agit#exit()
  if !exists('t:git')
    return
  endif
  if tabpagenr('$') == 1
    tabnew
    silent! tabclose! 1
  else
    silent! tabclose!
  endif
endfunction

function! agit#show_commit()
  if has_key(w:, 'view') && has_key(w:view, 'emmit')
    call w:view.emmit()
  endif
endfunction

function! agit#reload() abort
  if !exists('t:git')
    return
  endif
  try
    let w:tracer = getpos('.')
    call t:git.fire_init()
  finally
    for w in range(1, winnr('$'))
      let win = getwinvar(w, '')
      if has_key(win, 'tracer')
        let pos = win.tracer
        unlet win.tracer
        execute 'noautocmd ' . w . 'wincmd w'
        call setpos('.', pos)
        break
      endif
    endfor
  endtry
endfunction

function! agit#diff(args) abort
  try
    if !exists('t:git')
      return
    endif
    if &filetype ==# 'agit'
      let filepath = t:git.relpath()
    else
      let filepath = expand('<cfile>')
    endif
    call agit#diff#sidebyside(t:git, filepath, a:args)
  catch /Agit: /
    echohl ErrorMsg | echomsg v:exception | echohl None
  endtry
endfunction

function s:get_git_root(basedir)
  if empty(a:basedir)
    " if fugitive exists
    if s:fugitive_enabled && exists('b:git_dir')
      return matchstr(b:git_dir, '^.\+\ze\.git')
    else
      let current_path = expand('%:p:h')
    endif
  else
    let current_path = a:basedir
  endif
  let cdcmd = haslocaldir() ? 'lcd ' : 'cd '
  let cwd = getcwd()
  execute cdcmd . current_path
  if s:Process.has_vimproc()
    let toplevel_path = vimproc#system('git --no-pager rev-parse --show-toplevel')
    let has_error = vimproc#get_last_status() != 0
  else
    let toplevel_path = system('git --no-pager rev-parse --show-toplevel')
    let has_error = v:shell_error != 0
  endif
  execute cdcmd . cwd
  if has_error
    throw 'Agit: Not a git repository.'
  endif
  return s:String.chomp(toplevel_path)
endfunction

function! s:get_git_dir(basedir)
  if empty(a:basedir)
    " if fugitive exists
    if s:fugitive_enabled && exists('b:git_dir')
      return b:git_dir
    else
      let current_path = expand('%:p:h')
    endif
  else
    let current_path = a:basedir
  endif
  let cdcmd = haslocaldir() ? 'lcd ' : 'cd '
  let cwd = getcwd()
  execute cdcmd . current_path
  if s:Process.has_vimproc()
    let toplevel_path = vimproc#system('git --no-pager rev-parse --show-toplevel')
    let has_error = vimproc#get_last_status() != 0
  else
    let toplevel_path = system('git --no-pager rev-parse --show-toplevel')
    let has_error = v:shell_error != 0
  endif
  execute cdcmd . cwd
  if has_error
    throw 'Agit: Not a git repository.'
  endif
  return s:String.chomp(toplevel_path) . '/.git'
endfunction

function! agit#extract_hash(str)
  return matchstr(a:str, '\[\zs\x\{7,\}\ze\]$')
endfunction

function! agit#agitgit(arg, confirm, bang)
  let arg = substitute(a:arg, '\c<hash>', agit#extract_hash(getline('.')), 'g')
  if match(arg, '\c<branch>') >= 0
    let cword = expand('<cword>')
    silent let branch = agit#git#exec('rev-parse --symbolic ' . cword, t:git.git_root)
    let branch = substitute(branch, '\n\+$', '', '')
    if agit#git#get_last_status() != 0
      echomsg 'Not a branch name: ' . cword
      return
    endif
    let arg = substitute(arg, '\c<branch>', branch, 'g')
  endif
  let curpos = stridx(arg, '\%#')
  if curpos >= 0
    let arg = substitute(arg, '\\%#', '', 'g')
    call feedkeys(':AgitGit ' . arg . "\<C-r>=setcmdpos(" . (curpos + 9) . ")?'':''\<CR>", 'n')
    " This function will be recursively called without \%#.
  else
    if a:confirm
      echon "'git " . s:String.chomp(arg) . "' ? [y/N]"
      let yn = nr2char(getchar())
      if yn !=? 'y'
        return
      endif
    endif
    echo agit#git#exec(arg, t:git.git_root, a:bang)
    call agit#reload()
  endif
endfunction

function! agit#agitgit_confirm(arg)
endfunction

function! agit#agit_git_compl(arglead, cmdline, cursorpos)
  if a:cmdline =~# '^AgitGit!\?\s\+\w*$'
    return join(split('add bisect branch checkout push pull rebase reset fetch commit cherry-pick remote merge reflog show stash', ' '), "\n")
  else
    return agit#revision_list()
  endif
endfunction

function! agit#revision_list()
  let revs = agit#git#exec('rev-parse --symbolic --branches --remotes --tags', t:git.git_root)
  \ . join(['HEAD', 'ORIG_HEAD', 'MERGE_HEAD', 'FETCH_HEAD'], "\n")
  let hash = agit#extract_hash(getline('.'))
  if hash != ''
    return hash . "\n" . revs
  else
    return revs
  endif
endfunction

function! s:git_checkout(branch_name)
  echo agit#git#exec('checkout ' . a:branch_name, t:git.git_root)
  call agit#reload()
endfunction

function! s:git_checkout_b()
  let branch_name = input('git checkout -b ')
  echo ''
  echo agit#git#exec('checkout -b ' . branch_name, t:git.git_root)
  call agit#reload()
endfunction

function! s:git_branch_d(branch_name)
  echon "Are you sure you want to delete branch '" . a:branch_name . "' [y/N]"
  if nr2char(getchar()) ==# 'y'
    echo agit#git#exec('branch -D ' . a:branch_name, t:git.git_root)
    call agit#reload()
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
