function! agit#diff#revision_list(git)
  " TODO: this function should be unified with agit#revision_list
  let revs = split(agit#git#exec('rev-parse --symbolic --branches --remotes --tags', a:git.git_root), "\n")
        \  + ['HEAD', 'ORIG_HEAD', 'MERGE_HEAD', 'FETCH_HEAD', 'staged', 'unstaged']
  if a:git.hash =~# '^\x\{7,\}$'
    let revs = insert(revs, a:git.hash)
  endif
  return revs
endfunction

let s:revspec_pattern = '\v^(.{-})%((\.{2,3})(.*))?$'

function! agit#diff#complete_revspec(arglead, ...)
  " return revision specification candidates (provide completion for AgitDiff)
  " revision specification patterns are 'R1', 'R1..R2', and 'R1...R2'
  if !exists('t:git')
    return []
  endif
  let matches = matchlist(a:arglead, s:revspec_pattern)
  let [rev1, dots, rev2] = matches[1:3]
  let revs = agit#diff#revision_list(t:git)
  if empty(dots)
    return filter(revs, 'stridx(v:val, rev1) == 0')
  else
    return map(filter(revs, 'stridx(v:val, rev2) == 0'), 'rev1 . dots . v:val')
  endif
endfunction

function! s:replace_keyword(git, rev)
  if a:rev ==# ''
    return 'HEAD'
  elseif a:rev ==# '<hash>'
    if a:git.hash ==# 'nextpage'
      throw 'Agit: Commit is not selected'
    endif
    return a:git.hash
  else
    return a:rev
  endif
endfunction

function! s:get_parent_hash(git, rev)
  if a:rev ==# 'unstaged'
    let rev = 'staged'
  elseif a:rev ==# 'staged'
    let rev = 'HEAD'
  else
    let rev = a:rev . '~'
  endif
  return a:git.get_shorthash(rev)
endfunction

function! agit#diff#get_target_hashes(git, revspec)
  let matches = matchlist(a:revspec, s:revspec_pattern)
  let [rev1, dots, rev2] = matches[1:3]
  if empty(dots)
    if empty(rev1)
      " No revisions specified
      " show changes create by current revision
      let rhash = a:git.get_shorthash(s:replace_keyword(a:git, '<hash>'))
      return [s:get_parent_hash(a:git, rhash), rhash]
    else
      " Single revision specified
      " show changes between specified revision and workingtree
      let rhash = a:git.get_shorthash(s:replace_keyword(a:git, rev1))
      return [rhash, 'unstaged']
    endif
  else
    let rev1 = s:replace_keyword(a:git, rev1)
    let rev2 = s:replace_keyword(a:git, rev2)
    if dots == '..'
      " Two revisions specified with double dots (A..B)
      " show changes between A and B
      return [a:git.get_shorthash(rev1), a:git.get_shorthash(rev2)]
    else
      " Two revisions specified with triple dots (A...B)
      " show changes between merge-base(common ancestor of A and B) and B
      return [a:git.get_mergebase(rev1, rev2), a:git.get_shorthash(rev2)]
    endif
  endif
endfunction

function! agit#diff#sidebyside(git, relpath, revspec) abort
  let [lhash, rhash] = agit#diff#get_target_hashes(a:git, a:revspec)
  if lhash ==# rhash
    throw "Agit: Specified revisions indicate same commit"
  endif
  let hash = (rhash ==# 'unstaged' || rhash ==# 'staged' ? 'HEAD' : rhash)
  if agit#git#exec('ls-tree --name-only "' . hash . '" -- "' . a:git.filepath . '"', a:git.git_root) == ''
    throw "Agit: File not tracked: " . a:relpath
  endif
  tabnew
  call s:fill_buffer(a:git, a:relpath, lhash)
  botright vnew
  call s:fill_buffer(a:git, a:relpath, rhash)
  windo diffthis
endfunction

function! s:fill_buffer(git, relpath, hash) abort
  if a:hash ==# 'unstaged'
    edit! `=a:git.to_abspath(a:relpath)`
  elseif a:hash ==# 'staged' && get(g:, 'loaded_fugitive', 0)
    edit! `='fugitive://' . a:git.git_root . '.git//0/' . a:relpath`
  else
    let content = a:git.catfile(a:hash, a:relpath)
    silent! file `=a:relpath . '(' . a:hash . ')'`
    doautocmd BufNewFile `=a:relpath`
    setlocal noswapfile buftype=nofile bufhidden=delete
    setlocal modifiable
    noautocmd silent! %delete _
    noautocmd silent! 1put= content
    noautocmd silent! 1delete _
    setlocal nomodifiable
  endif
endfunction

