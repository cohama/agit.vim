let s:save_cpo = &cpo
set cpo&vim

nnoremap <silent> <Plug>(agit-reload)  :<C-u>call agit#reload()<CR>
nnoremap <silent> <Plug>(agit-scrolldown-stat) :<C-u>call <SID>remote_scroll('stat', 'down')<CR>
nnoremap <silent> <Plug>(agit-scrollup-stat)   :<C-u>call <SID>remote_scroll('stat', 'up')<CR>
nnoremap <silent> <Plug>(agit-scrolldown-diff) :<C-u>call <SID>remote_scroll('diff', 'down')<CR>
nnoremap <silent> <Plug>(agit-scrollup-diff)   :<C-u>call <SID>remote_scroll('diff', 'up')<CR>

nnoremap <PLug>(agit-yank-hash) :<C-u>call <SID>yank_hash()<CR>
nnoremap <Plug>(agit-show-commit) :<C-u>call agit#show_commit()<CR>

nnoremap <Plug>(agit-git-checkout)     :<C-u>AgitGit checkout <branch><CR>
nnoremap <Plug>(agit-git-checkout-b)   :<C-u>AgitGit checkout -b \%# <hash><CR>
nnoremap <Plug>(agit-git-branch-d)     :<C-u>AgitGitConfirm branch -d <branch><CR>
nnoremap <Plug>(agit-git-reset-soft)   :<C-u>AgitGitConfirm reset --soft <hash><CR>
nnoremap <Plug>(agit-git-reset)        :<C-u>AgitGitConfirm reset <hash><CR>
nnoremap <Plug>(agit-git-reset-hard)   :<C-u>AgitGitConfirm reset --hard <hash><CR>
nnoremap <Plug>(agit-git-rebase)       :<C-u>AgitGitConfirm rebase <hash><CR>
nnoremap <Plug>(agit-git-rebase-i)     :<C-u>AgitGitConfirm! rebase --interactive <hash><CR>
nnoremap <Plug>(agit-git-bisect-start) :<C-u>AgitGit bisect start HEAD <hash> \%#<CR>
nnoremap <Plug>(agit-git-bisect-good)  :<C-u>AgitGit bisect good<CR>
nnoremap <Plug>(agit-git-bisect-bad)   :<C-u>AgitGit bisect bad<CR>
nnoremap <Plug>(agit-git-bisect-reset) :<C-u>AgitGit bisect reset<CR>
nnoremap <Plug>(agit-git-cherry-pick)  :<C-u>AgitGit cherry-pick <hash><CR>
nnoremap <Plug>(agit-git-revert)       :<C-u>AgitGit revert <hash><CR>
nnoremap <Plug>(agit-exit)             :<C-u>call <SID>agit_exit()<CR>

let s:V = vital#of('agit')
let s:P = s:V.import('Prelude')
let s:String = s:V.import('Data.String')
let s:List = s:V.import('Data.List')
let s:Process = s:V.import('Process')

let s:agit_vital = {
\ 'V' : s:V,
\ 'P' : s:P,
\ 'String' : s:String,
\ 'List' : s:List,
\ 'Process' : s:Process
\ }

let s:fugitive_enabled = get(g:, 'loaded_fugitive', 0)

function! agit#vital()
  return s:agit_vital
endfunction

function! agit#launch()
  let s:old_hash = ''
  try
    let git_dir = s:get_git_dir()
    call agit#bufwin#agit_tabnew()
    let t:git = agit#git#new(git_dir)
    call agit#bufwin#set_to_log(t:git.log(winwidth(agit#bufwin#log_winnr())))
    call agit#show_commit()
    if s:fugitive_enabled
      let b:git_dir = git_dir " for fugitive commands
      silent doautocmd User Fugitive
    endif
  catch
    echomsg v:exception
  endtry
endfunction

let s:old_hash = ''
function! agit#show_commit()
  let line = getline('.')
  if line ==# g:agit#git#staged_message
    let hash = 'staged'
  elseif line ==# g:agit#git#unstaged_message
    let hash = 'unstaged'
  else
    let hash = agit#extract_hash(line)
  endif
  if hash == ''
    call agit#bufwin#set_to_stat('')
    call agit#bufwin#set_to_diff('')
  elseif s:old_hash !=# hash
    call agit#bufwin#set_to_stat(t:git.stat(hash))
    call agit#bufwin#set_to_diff(t:git.diff(hash))
  endif
  let s:old_hash = hash
endfunction

function! s:remote_scroll(win_type, direction)
  if a:win_type ==# 'stat'
    call agit#bufwin#move_to_stat()
  elseif a:win_type ==# 'diff'
    call agit#bufwin#move_to_diff()
  endif
  if a:direction ==# 'down'
    execute "normal! \<C-d>"
  elseif a:direction ==# 'up'
    execute "normal! \<C-u>"
  endif
  call agit#bufwin#move_to_log()
endfunction

function! s:yank_hash()
  call setreg(v:register, agit#extract_hash(getline('.')))
  echo 'yanked ' . getreg(v:register)
endfunction

function! s:agit_exit()
  if !exists('t:git')
    return
  endif
  silent! tabclose!
endfunction

function! agit#reload() abort
  if !exists('t:git')
    return
  endif
  call agit#bufwin#move_to_log()
  wincmd =
  let pos = getpos('.')
  call agit#bufwin#set_to_log(t:git.log(winwidth(agit#bufwin#log_winnr())))
  noautocmd call setpos('.', pos)
  call agit#show_commit()
  let s:old_hash = ''
endfunction

function! s:get_git_dir()
  " if fugitive exists
  if exists('b:git_dir')
    return b:git_dir
  endif
  let cdcmd = haslocaldir() ? 'lcd ' : 'cd '
  let current_path = expand('%:p:h')
  let cwd = getcwd()
  execute cdcmd . current_path
  if s:Process.has_vimproc() && s:P.is_windows()
    let toplevel_path = vimproc#system('git --no-pager rev-parse --show-toplevel')
    let has_error = vimproc#get_last_status() != 0
  else
    let toplevel_path = system('git --no-pager rev-parse --show-toplevel')
    let has_error = v:shell_error != 0
  endif
  execute cdcmd . cwd
  if has_error
    throw 'Not a git repository.'
  endif
  return s:String.chomp(toplevel_path) . '/.git'
endfunction

function! agit#extract_hash(str)
  return matchstr(a:str, '\[\zs\x\{7\}\ze\]$')
endfunction

function! agit#agitgit(arg, confirm, bang)
  let arg = substitute(a:arg, '\c<hash>', agit#extract_hash(getline('.')), 'g')
  if match(arg, '\c<branch>') >= 0
    let cword = expand('<cword>')
    silent let branch = agit#git#exec('rev-parse --symbolic ' . cword, t:git.git_dir)
    if v:shell_error != 0
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
    echo agit#git#exec(arg, t:git.git_dir, a:bang)
    call agit#reload()
  endif
endfunction

function! agit#agitgit_confirm(arg)
endfunction

function! agit#agit_git_compl(arglead, cmdline, cursorpos)
  if a:cmdline =~# '^AgitGit\s\+\w*$'
    return join(split('add bisect branch checkout push pull rebase reset fetch commit cherry-pick remote merge reflog show stash', ' '), "\n")
  else
    return agit#revision_list()
  endif
endfunction

function! agit#revision_list()
  return agit#git#exec('rev-parse --symbolic --branches --remotes --tags', t:git.git_dir)
  \ . join(['HEAD', 'ORIG_HEAD', 'MERGE_HEAD', 'FETCH_HEAD'], "\n")
endfunction

function! s:git_checkout(branch_name)
  echo agit#git#exec('checkout ' . a:branch_name, t:git.git_dir)
  call agit#reload()
endfunction

function! s:git_checkout_b()
  let branch_name = input('git checkout -b ')
  echo ''
  echo agit#git#exec('checkout -b ' . branch_name, t:git.git_dir)
  call agit#reload()
endfunction

function! s:git_branch_d(branch_name)
  echon "Are you sure you want to delete branch '" . a:branch_name . "' [y/N]"
  if nr2char(getchar()) ==# 'y'
    echo agit#git#exec('branch -D ' . a:branch_name, t:git.git_dir)
    call agit#reload()
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
