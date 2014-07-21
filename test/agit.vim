let s:V = vital#of('agit.vim')
let s:String = s:V.import('Data.String')

let s:suite = themis#suite('agit integration test')
let s:assert = themis#helper('assert')

let s:repo_path = expand("<sfile>:p:h") . '/repos/'

set noswapfile nobackup

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
    call s:assert.equals(s:String.trim(getline(1, '$')), '')
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
