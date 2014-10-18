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

nnoremap <silent> <Plug>(agit-reload)  :<C-u>call agit#reload()<CR>

nnoremap <silent> <Plug>(agit-smart-j)         :<C-u>call agit#smart_j(v:count1)<CR>
nnoremap <silent> <Plug>(agit-smart-k)         :<C-u>call agit#smart_k(v:count1)<CR>
nnoremap <silent> <Plug>(agit-scrolldown-stat) :<C-u>call agit#remote_scroll('stat', 'down')<CR>
nnoremap <silent> <Plug>(agit-scrollup-stat)   :<C-u>call agit#remote_scroll('stat', 'up')<CR>
nnoremap <silent> <Plug>(agit-scrolldown-diff) :<C-u>call agit#remote_scroll('diff', 'down')<CR>
nnoremap <silent> <Plug>(agit-scrollup-diff)   :<C-u>call agit#remote_scroll('diff', 'up')<CR>

nnoremap <PLug>(agit-yank-hash) :<C-u>call agit#yank_hash()<CR>
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
nnoremap <Plug>(agit-exit)             :<C-u>call agit#exit()<CR>

command! -nargs=* -complete=customlist,agit#complete_command Agit call agit#launch(<q-args>)

let &cpo = s:save_cpo
