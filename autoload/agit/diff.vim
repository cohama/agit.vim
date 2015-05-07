function! agit#diff#sidebyside(git, relpath, lhash, rhash) abort
  tabnew
  call s:fill_buffer(a:git, a:relpath, a:lhash)
  botright vnew
  call s:fill_buffer(a:git, a:relpath, a:rhash)
  windo diffthis
endfunction

function! s:fill_buffer(git, relpath, hash) abort
  if a:hash ==# 'unstaged'
    edit! `=a:git.to_abspath(a:relpath)`
  elseif a:hash ==# 'staged' && get(g:, 'loaded_fugitive', 0)
    edit! `='fugitive://' . a:git.git_dir . '//0/' . a:relpath`
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

