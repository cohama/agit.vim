if exists('g:loaded_agit')
  finish
endif
let g:loaded_agit = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:agit_no_default_mappings')
  let g:agit_no_default_mappings = 0
endif
if !exists('g:agit_enable_auto_show_commit')
  let g:agit_enable_auto_show_commit = 1
endif
if !exists('g:agit_enable_auto_refresh')
  let g:agit_enable_auto_refresh = 0
endif
if !exists('g:agit_max_log_lines')
  let g:agit_max_log_lines = 500
endif
if !exists('g:agit_skip_empty_line')
  let g:agit_skip_empty_line = 1
endif
if !exists('g:agit_localchanges_always_on_top')
  let g:agit_localchanges_always_on_top = 1
endif
if !exists('g:agit_ignore_spaces')
    let g:agit_ignore_spaces = 1
endif
if !exists('g:agit_stat_width')
    let g:agit_stat_width = 80
endif
if !exists('g:agit_reuse_tab')
    let g:agit_reuse_tab = 1
endif

nnoremap <silent> <Plug>(agit-reload)  :<C-u>call agit#reload()<CR>
nnoremap <silent> <Plug>(agit-scrolldown-stat) :<C-u>call agit#remote_scroll('stat', 'down')<CR>
nnoremap <silent> <Plug>(agit-scrollup-stat)   :<C-u>call agit#remote_scroll('stat', 'up')<CR>
nnoremap <silent> <Plug>(agit-scrolldown-diff) :<C-u>call agit#remote_scroll('diff', 'down')<CR>
nnoremap <silent> <Plug>(agit-scrollup-diff)   :<C-u>call agit#remote_scroll('diff', 'up')<CR>

nnoremap <silent> <PLug>(agit-yank-hash) :<C-u>call agit#yank_hash()<CR>
nnoremap <silent> <Plug>(agit-show-commit) :<C-u>call agit#show_commit()<CR>
nnoremap <silent> <Plug>(agit-print-commitmsg) :<C-u>call agit#print_commitmsg()<CR>
nnoremap <silent> <Plug>(agit-diff) :<C-u>AgitDiff<CR>
nnoremap <silent> <Plug>(agit-diff-with-local) :<C-u>AgitDiff <hash><CR>

nnoremap <silent> <Plug>(agit-git-checkout)     :<C-u>AgitGit checkout <branch><CR>
nnoremap <silent> <Plug>(agit-git-checkout-b)   :<C-u>AgitGit checkout -b \%# <hash><CR>
nnoremap <silent> <Plug>(agit-git-branch-d)     :<C-u>AgitGitConfirm branch -d <branch><CR>
nnoremap <silent> <Plug>(agit-git-reset-soft)   :<C-u>AgitGitConfirm reset --soft <hash><CR>
nnoremap <silent> <Plug>(agit-git-reset)        :<C-u>AgitGitConfirm reset <hash><CR>
nnoremap <silent> <Plug>(agit-git-reset-hard)   :<C-u>AgitGitConfirm reset --hard <hash><CR>
nnoremap <silent> <Plug>(agit-git-rebase)       :<C-u>AgitGitConfirm rebase <hash><CR>
nnoremap <silent> <Plug>(agit-git-rebase-i)     :<C-u>AgitGitConfirm! rebase --interactive <hash><CR>
nnoremap <silent> <Plug>(agit-git-bisect-start) :<C-u>AgitGit bisect start HEAD <hash> \%#<CR>
nnoremap <silent> <Plug>(agit-git-bisect-good)  :<C-u>AgitGit bisect good<CR>
nnoremap <silent> <Plug>(agit-git-bisect-bad)   :<C-u>AgitGit bisect bad<CR>
nnoremap <silent> <Plug>(agit-git-bisect-reset) :<C-u>AgitGit bisect reset<CR>
nnoremap <silent> <Plug>(agit-git-cherry-pick)  :<C-u>AgitGit cherry-pick <hash><CR>
nnoremap <silent> <Plug>(agit-git-revert)       :<C-u>AgitGit revert <hash><CR>
nnoremap <silent> <Plug>(agit-exit)             :<C-u>call agit#exit()<CR>

command! -nargs=* -complete=customlist,agit#complete_command Agit call agit#launch(<q-args>)
command! -nargs=* -complete=customlist,agit#complete_command AgitFile Agit file <args>

let &cpo = s:save_cpo
