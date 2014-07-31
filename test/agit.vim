let s:V = vital#of('agit.vim')
let s:String = s:V.import('Data.String')

let s:suite = themis#suite('agit integration test')
let s:assert = themis#helper('assert')

let s:repo_path = expand("<sfile>:p:h") . '/repos/'

set noswapfile nobackup
filetype plugin indent on
set columns=400

function! s:suite.__in_clean_repo__()

  let clean = themis#suite('in clean repo')
  let s:clean_repo_path = s:repo_path . 'clean/.git'

  function! clean.before()
    tabnew
    tabonly!
    edit `=s:repo_path . 'clean/a'`
    Agit
  endfunction

  function! clean.create_3_windows()
    call s:assert.equals(winnr('$'), 3)
  endfunction

  function! clean.appear_only_commits_at_log_window()
    call agit#bufwin#move_to_log()
    let head_msg = s:String.chomp(agit#git#exec('log --format=format:%s -1', s:clean_repo_path))
    call s:assert.match(getline(1), '(HEAD, master) ' . head_msg)
  endfunction

  function! clean.show_diff_stat_result_at_stat_window()
    call agit#bufwin#move_to_stat()
    let stat_msg = s:String.trim(s:String.chomp(agit#git#exec('diff --shortstat HEAD~', s:clean_repo_path)))
    call s:assert.equals(s:String.trim(getline('$')), stat_msg)
  endfunction

endfunction

function! s:suite.__in_unstaged_repo__()

  let unstaged = themis#suite('in unstaged repo')
  let s:unstaged_repo_path = s:repo_path . 'unstaged/.git'

  function! unstaged.before()
    tabnew
    edit `=s:repo_path . 'unstaged/a'`
    Agit
  endfunction

  function! unstaged.create_3_windows()
    call s:assert.equals(winnr('$'), 3)
  endfunction

  function! unstaged.appear_only_commits_at_first_line_log_window()
    call agit#bufwin#move_to_log()
    let head_msg = g:agit#git#unstaged_message
    call s:assert.match(getline(1), head_msg)
  endfunction

  function! unstaged.appear_commit_mesesage_at_second_line_log_window()
    call agit#bufwin#move_to_log()
    let head_msg = s:String.chomp(agit#git#exec('log --format=format:%s -1', s:unstaged_repo_path))
    call s:assert.match(getline(2), '(HEAD, master) ' . head_msg)
  endfunction

  function! unstaged.show_diff_stat_result_at_stat_window()
    call agit#bufwin#move_to_stat()
    let stat_msg = s:String.trim(s:String.chomp(agit#git#exec('diff --shortstat', s:unstaged_repo_path)))
    call s:assert.equals(s:String.trim(getline('$')), stat_msg)
  endfunction

endfunction

function! s:suite.__in_untracked_repo__()

  let untracked = themis#suite('in untracked repo')
  let s:untracked_repo_path = s:repo_path . 'untracked/.git'

  function! untracked.before()
    tabnew
    edit `=s:repo_path . 'untracked/a'`
    Agit
  endfunction

  function! untracked.create_3_windows()
    call s:assert.equals(winnr('$'), 3)
  endfunction

  function! untracked.appear_only_commits_at_first_line_log_window()
    call agit#bufwin#move_to_log()
    let head_msg = g:agit#git#unstaged_message
    call s:assert.match(getline(1), head_msg)
  endfunction

  function! untracked.appear_commit_mesesage_at_second_line_log_window()
    call agit#bufwin#move_to_log()
    let head_msg = s:String.chomp(agit#git#exec('log --format=format:%s -1', s:untracked_repo_path))
    call s:assert.match(getline(2), '(HEAD, master) ' . head_msg)
  endfunction

  function! untracked.show_diff_stat_result_at_stat_window()
    call agit#bufwin#move_to_stat()
    let untracked_files = s:String.chomp(agit#git#exec('ls-files --others --exclude-standard', s:untracked_repo_path))
    call s:assert.equals(s:String.trim(getline('$')), untracked_files)
  endfunction

  function! untracked.show_empty_diff_result_at_diff_window()
    call agit#bufwin#move_to_diff()
    call s:assert.equals(s:String.trim(getline(1, '$')), '')
  endfunction

endfunction

function! s:suite.__in_staged_repo__()

  let staged = themis#suite('in staged repo')
  let s:staged_repo_path = s:repo_path . 'staged/.git'

  function! staged.before()
    tabnew
    edit `=s:repo_path . 'staged/a'`
    Agit
  endfunction

  function! staged.create_3_windows()
    call s:assert.equals(winnr('$'), 3)
  endfunction

  function! staged.appear_only_commits_at_first_line_log_window()
    call agit#bufwin#move_to_log()
    let head_msg = g:agit#git#staged_message
    call s:assert.match(getline(1), head_msg)
  endfunction

  function! staged.appear_commit_mesesage_at_second_line_log_window()
    call agit#bufwin#move_to_log()
    let head_msg = s:String.chomp(agit#git#exec('log --format=format:%s -1', s:staged_repo_path))
    call s:assert.match(getline(2), '(HEAD, master) ' . head_msg)
  endfunction

  function! staged.show_diff_stat_result_at_stat_window()
    call agit#bufwin#move_to_stat()
    let stat_msg = s:String.trim(s:String.chomp(agit#git#exec('diff --cached --shortstat', s:staged_repo_path)))
    call s:assert.equals(s:String.trim(getline('$')), stat_msg)
  endfunction

endfunction

function! s:suite.__in_mixed_repo__()

  let mixed = themis#suite('in mixed repo')
  let s:mixed_repo_path = s:repo_path . 'mixed/.git'

  function! mixed.before()
    tabnew
    edit `=s:repo_path . 'mixed/a'`
    Agit
  endfunction

  function! mixed.create_3_windows()
    call s:assert.equals(winnr('$'), 3)
  endfunction

  function! mixed.show_unstaged_message_at_first_line_log_window()
    call agit#bufwin#move_to_log()
    let head_msg = g:agit#git#unstaged_message
    call s:assert.match(getline(1), head_msg)
  endfunction

  function! mixed.show_staged_message_at_second_line_log_window()
    call agit#bufwin#move_to_log()
    let head_msg = g:agit#git#staged_message
    call s:assert.match(getline(2), head_msg)
  endfunction

  function! mixed.show_commit_mesesage_at_third_line_log_window()
    call agit#bufwin#move_to_log()
    let head_msg = s:String.chomp(agit#git#exec('log --format=format:%s -1', s:mixed_repo_path))
    call s:assert.match(getline(3), '(HEAD, master) ' . head_msg)
  endfunction

  function! mixed.show_unstaged_diff_stat_result_at_stat_window()
    call agit#bufwin#move_to_stat()
    let stat_msg = s:String.trim(s:String.chomp(agit#git#exec('diff --shortstat', s:mixed_repo_path)))
    call s:assert.equals(s:String.trim(getline('$')), stat_msg)
  endfunction

  function! mixed.show_staged_diff_stat_result_at_stat_window()
    call agit#bufwin#move_to_log()
    2
    call agit#show_commit()
    call agit#bufwin#move_to_stat()
    let stat_msg = s:String.trim(s:String.chomp(agit#git#exec('diff --cached --shortstat', s:mixed_repo_path)))
    call s:assert.equals(s:String.trim(getline('$')), stat_msg)
  endfunction

endfunction

function! s:suite.__reload_test()

  let reload = themis#suite('reload test')

  function! reload.before_each()
    tabedit `=s:repo_path . 'clean/a'`
    Agit
    call system('!echo "reload test" > ' . s:repo_path . 'clean/x')
    call agit#bufwin#move_to_log()
    let g:agit_enable_auto_refresh = 1
  endfunction

  function! reload.after()
    let g:agit_enable_auto_refresh = 0
  endfunction

  function! reload.after_each()
    call delete(s:repo_path . 'clean/x')
    call agit#git#exec('reset', t:git.git_dir)
  endfunction

  function! reload.on_log_window()
    call s:assert.match(getline(1), '(HEAD, master)')
    call agit#reload()
    call s:assert.match(getline(1), g:agit#git#unstaged_message)
  endfunction

  function! reload.on_stat_window()
    call s:assert.match(getline(1), '(HEAD, master)')
    call agit#bufwin#move_to_stat()
    call agit#reload()
    call s:assert.equals(w:agit_win_type, 'log')
    call s:assert.match(getline(1), g:agit#git#unstaged_message)
  endfunction

  function! reload.on_diff_window()
    call s:assert.match(getline(1), '(HEAD, master)')
    call agit#bufwin#move_to_diff()
    call agit#reload()
    call s:assert.equals(w:agit_win_type, 'log')
    call s:assert.match(getline(1), g:agit#git#unstaged_message)
  endfunction

  function! reload.when_extra_window_exists()
    call s:assert.match(getline(1), '(HEAD, master)')
    vnew
    call agit#reload()
    call agit#bufwin#move_to_log()
    call s:assert.equals(w:agit_win_type, 'log')
    call s:assert.match(getline(1), g:agit#git#unstaged_message)
  endfunction

  function! reload.and_recreate_stat_window()
    call s:assert.match(getline(1), '(HEAD, master)')
    call agit#bufwin#move_to_stat()
    q
    call agit#reload()
    call s:assert.equals(winnr('$'), 3)
    call s:assert.equals(w:agit_win_type, 'log')
    call s:assert.match(getline(1), g:agit#git#unstaged_message)
  endfunction

  function! reload.and_recreate_diff_window()
    call s:assert.equals(winnr('$'), 3)
    call s:assert.match(getline(1), '(HEAD, master)')
    call agit#bufwin#move_to_diff()
    q
    call agit#reload()
    call s:assert.equals(winnr('$'), 3)
    call s:assert.equals(w:agit_win_type, 'log')
    call s:assert.match(getline(1), g:agit#git#unstaged_message)
  endfunction

  function! reload.and_recreate_stat_and_diff_window()
    call s:assert.equals(winnr('$'), 3)
    call s:assert.match(getline(1), '(HEAD, master)')
    only
    call agit#reload()
    call s:assert.equals(winnr('$'), 3)
    call s:assert.equals(w:agit_win_type, 'log')
    call s:assert.match(getline(1), g:agit#git#unstaged_message)
  endfunction

  function! reload.when_bufenter()
    let g:agit_enable_auto_refresh = 1
    call s:assert.equals(winnr('$'), 3)
    call s:assert.match(getline(1), '(HEAD, master)')
    new
    wincmd p
    call s:assert.equals(w:agit_win_type, 'log')
    call s:assert.match(getline(1), g:agit#git#unstaged_message)
    let g:agit_enable_auto_refresh = 0
  endfunction

endfunction

function! s:suite.__in_execute_repo__()

  let execute = themis#suite('in execute repo')
  let s:execute_repo_path = s:repo_path . 'execute/.git'

  function! execute.before()
    tabnew
    tabonly!
    edit `=s:repo_path . 'execute/a'`
    Agit
  endfunction

  function! execute.git_checkout()
    call agit#bufwin#move_to_log()
    call search('develop', 'wc')
    execute 'AgitGit checkout ' . expand('<cword>')
    let current_branch = s:String.chomp(agit#git#exec('rev-parse --abbrev-ref HEAD', s:execute_repo_path))
    call s:assert.equals(current_branch, 'develop')
    call search('master', 'wc')
    execute 'AgitGit checkout ' . expand('<cword>')
    let current_branch = s:String.chomp(agit#git#exec('rev-parse --abbrev-ref HEAD', s:execute_repo_path))
    call s:assert.equals(current_branch, 'master')
  endfunction

  function! execute.git_create_b()
    " feedkeys() does not work.
    execute 'AgitGit checkout -b new ' . agit#extract_hash(getline(2))
    let current_branch = s:String.chomp(agit#git#exec('rev-parse --abbrev-ref HEAD', s:execute_repo_path))
    call s:assert.equals(current_branch, 'new')
    call s:assert.match(getline(2), '(HEAD, new')
  endfunction

  function! execute.git_branch_d()
    call search('master', 'wc')
    execute "normal \<Plug>(agit-git-checkout)"
    call search('new', 'wc')
    execute 'AgitGit branch -d ' . expand("<cword>")
    let current_branches = s:String.chomp(agit#git#exec('branch', s:execute_repo_path))
    call s:assert.equals(current_branches, "  develop\n* master")
  endfunction

endfunction
