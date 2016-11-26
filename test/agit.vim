let s:V = vital#of('agit')
let s:String = s:V.import('Data.String')

let s:suite = themis#suite('agit integration test')

let s:repo_path = expand("<sfile>:p:h") . '/repos/'

cd `=expand("<sfile>:p:h")`

function! s:suite.__in_clean_repo__()

  let clean = themis#suite('in clean repo')
  let s:clean_repo_path = s:repo_path . 'clean/'

  function! clean.before()
    tabnew
    tabonly!
    edit `=s:repo_path . 'clean/a'`
    Agit
  endfunction

  function! clean.create_3_windows()
    call Expect(winnr('$')).to_equal(3)
  endfunction

  function! clean.appear_only_commits_at_log_window()
    call agit#bufwin#move_to('log')
    let head_hash = s:String.chomp(agit#git#exec('rev-parse --short HEAD', s:clean_repo_path))
    call Expect(getline(1)).to_match(head_hash)
  endfunction

  function! clean.show_diff_stat_result_at_stat_window()
    call agit#bufwin#move_to('stat')
    let stat_msg = s:String.trim(s:String.chomp(agit#git#exec('diff --shortstat HEAD~', s:clean_repo_path)))
    call Expect(s:String.trim(getline('$'))).to_equal(stat_msg)
  endfunction

endfunction

function! s:suite.__in_clean_repo_with_empty_buffer__()

  let clean = themis#suite('in clean repo with empty buffer')
  let s:clean_repo_path = s:repo_path . 'clean/'

  function! clean.before()
    tabnew
    tabonly!
    let s:save_cwd = getcwd()
    cd `=s:repo_path . 'clean'`
    Agit
  endfunction

  function! clean.after()
    cd `s:save_cwd`
  endfunction

  function! clean.create_3_windows()
    call Expect(winnr('$')).to_equal(3)
  endfunction

  function! clean.appear_only_commits_at_log_window()
    call agit#bufwin#move_to('log')
    let head_hash = s:String.chomp(agit#git#exec('rev-parse --short HEAD', s:clean_repo_path))
    call Expect(getline(1)).to_match(head_hash)
  endfunction

  function! clean.show_diff_stat_result_at_stat_window()
    call agit#bufwin#move_to('stat')
    let stat_msg = s:String.trim(s:String.chomp(agit#git#exec('diff --shortstat HEAD~', s:clean_repo_path)))
    call Expect(s:String.trim(getline('$'))).to_equal(stat_msg)
  endfunction

endfunction

function! s:suite.__in_unstaged_repo__()

  let unstaged = themis#suite('in unstaged repo')
  let s:unstaged_repo_path = s:repo_path . 'unstaged/'

  function! unstaged.before()
    tabnew
    edit `=s:repo_path . 'unstaged/a'`
    Agit
  endfunction

  function! unstaged.create_3_windows()
    call Expect(winnr('$')).to_equal(3)
  endfunction

  function! unstaged.appear_only_commits_at_first_line_log_window()
    call agit#bufwin#move_to('log')
    let head_msg = g:agit#git#unstaged_message
    call Expect(getline(1)).to_match(head_msg)
  endfunction

  function! unstaged.appear_commit_mesesage_at_second_line_log_window()
    call agit#bufwin#move_to('log')
    let head_hash = s:String.chomp(agit#git#exec('rev-parse --short HEAD', s:unstaged_repo_path))
    call Expect(getline(2)).to_match(head_hash)
  endfunction

  function! unstaged.show_diff_stat_result_at_stat_window()
    call agit#bufwin#move_to('stat')
    let stat_msg = s:String.trim(s:String.chomp(agit#git#exec('diff --shortstat', s:unstaged_repo_path)))
    call Expect(s:String.trim(getline('$'))).to_equal(stat_msg)
  endfunction

endfunction

function! s:suite.__in_untracked_repo__()

  let untracked = themis#suite('in untracked repo')
  let s:untracked_repo_path = s:repo_path . 'untracked/'

  function! untracked.before()
    tabnew
    edit `=s:repo_path . 'untracked/a'`
    Agit
  endfunction

  function! untracked.create_3_windows()
    call Expect(winnr('$')).to_equal(3)
  endfunction

  function! untracked.appear_only_commits_at_first_line_log_window()
    call agit#bufwin#move_to('log')
    let head_msg = g:agit#git#unstaged_message
    call Expect(getline(1)).to_match(head_msg)
  endfunction

  function! untracked.appear_commit_mesesage_at_second_line_log_window()
    call agit#bufwin#move_to('log')
    let head_hash = s:String.chomp(agit#git#exec('rev-parse --short HEAD', s:untracked_repo_path))
    call Expect(getline(2)).to_match(head_hash)
  endfunction

  function! untracked.show_diff_stat_result_at_stat_window()
    call agit#bufwin#move_to('stat')
    let untracked_files = s:String.chomp(agit#git#exec('ls-files --others --exclude-standard', s:untracked_repo_path))
    call Expect(s:String.trim(getline('$'))).to_equal(untracked_files)
  endfunction

  function! untracked.show_empty_diff_result_at_diff_window()
    call agit#bufwin#move_to('diff')
    call Expect(s:String.trim(getline(1, '$'))).to_equal('')
  endfunction

endfunction

function! s:suite.__in_staged_repo__()

  let staged = themis#suite('in staged repo')
  let s:staged_repo_path = s:repo_path . 'staged/'

  function! staged.before()
    tabnew
    edit `=s:repo_path . 'staged/a'`
    Agit
  endfunction

  function! staged.create_3_windows()
    call Expect(winnr('$')).to_equal(3)
  endfunction

  function! staged.appear_only_commits_at_first_line_log_window()
    call agit#bufwin#move_to('log')
    let head_msg = g:agit#git#staged_message
    call Expect(getline(1)).to_match(head_msg)
  endfunction

  function! staged.appear_commit_mesesage_at_second_line_log_window()
    call agit#bufwin#move_to('log')
    let head_hash = s:String.chomp(agit#git#exec('rev-parse --short HEAD', s:staged_repo_path))
    call Expect(getline(2)).to_match(head_hash)
  endfunction

  function! staged.show_diff_stat_result_at_stat_window()
    call agit#bufwin#move_to('stat')
    let stat_msg = s:String.trim(s:String.chomp(agit#git#exec('diff --cached --shortstat', s:staged_repo_path)))
    call Expect(s:String.trim(getline('$'))).to_equal(stat_msg)
  endfunction

endfunction

function! s:suite.__in_mixed_repo__()

  let mixed = themis#suite('in mixed repo')
  let s:mixed_repo_path = s:repo_path . 'mixed/'

  function! mixed.before()
    tabnew
    edit `=s:repo_path . 'mixed/a'`
    Agit
  endfunction

  function! mixed.create_3_windows()
    call Expect(winnr('$')).to_equal(3)
  endfunction

  function! mixed.show_unstaged_message_at_first_line_log_window()
    call agit#bufwin#move_to('log')
    let head_msg = g:agit#git#unstaged_message
    call Expect(getline(1)).to_match(head_msg)
  endfunction

  function! mixed.show_staged_message_at_second_line_log_window()
    call agit#bufwin#move_to('log')
    let head_msg = g:agit#git#staged_message
    call Expect(getline(2)).to_match(head_msg)
  endfunction

  function! mixed.show_commit_mesesage_at_third_line_log_window()
    call agit#bufwin#move_to('log')
    let head_hash = s:String.chomp(agit#git#exec('rev-parse --short HEAD', s:mixed_repo_path))
    call Expect(getline(3)).to_match(head_hash)
  endfunction

  function! mixed.show_unstaged_diff_stat_result_at_stat_window()
    call agit#bufwin#move_to('stat')
    let stat_msg = s:String.trim(s:String.chomp(agit#git#exec('diff --shortstat', s:mixed_repo_path)))
    call Expect(s:String.trim(getline('$'))).to_equal(stat_msg)
  endfunction

  function! mixed.show_staged_diff_stat_result_at_stat_window()
    call agit#bufwin#move_to('log')
    2
    call agit#show_commit()
    call agit#bufwin#move_to('stat')
    let stat_msg = s:String.trim(s:String.chomp(agit#git#exec('diff --cached --shortstat', s:mixed_repo_path)))
    call Expect(s:String.trim(getline('$'))).to_equal(stat_msg)
  endfunction

endfunction

function! s:suite.__reload_test__()

  let reload = themis#suite('reload test')

  function! reload.before_each()
    tabnew
    tabonly!
    tabedit `=s:repo_path . 'clean/a'`
    Agit
    call writefile(["reload test"], s:repo_path . 'clean/x')
    call agit#bufwin#move_to('log')
  endfunction

  function! reload.after()
    let g:agit_enable_auto_refresh = 0
  endfunction

  function! reload.after_each()
    call delete(s:repo_path . 'clean/x')
    call agit#git#exec('reset', t:git.git_root)
  endfunction

  function! reload.on_log_window()
    call Expect(getline(1)).not.to_match(g:agit#git#unstaged_message)
    call agit#reload()
    call Expect(getline(1)).to_match(g:agit#git#unstaged_message)
  endfunction

  function! reload.on_stat_window()
    call Expect(getline(1)).not.to_match(g:agit#git#unstaged_message)
    call agit#bufwin#move_to('stat')
    call agit#reload()
    call Expect(w:view.name).to_equal('stat')
    call agit#bufwin#move_to('log')
    call Expect(getline(1)).to_match(g:agit#git#unstaged_message)
  endfunction

  function! reload.on_diff_window()
    call Expect(getline(1)).not.to_match(g:agit#git#unstaged_message)
    call agit#bufwin#move_to('diff')
    call agit#reload()
    call Expect(w:view.name).to_equal('diff')
    call agit#bufwin#move_to('log')
    call Expect(getline(1)).to_match(g:agit#git#unstaged_message)
  endfunction

  function! reload.when_extra_window_exists()
    call Expect(getline(1)).not.to_match(g:agit#git#unstaged_message)
    vnew
    call agit#reload()
    call agit#bufwin#move_to('log')
    call Expect(w:view.name).to_equal('log')
    call Expect(getline(1)).to_match(g:agit#git#unstaged_message)
  endfunction

  function! reload.when_bufenter()
    call Expect(getline(1)).not.to_match(g:agit#git#unstaged_message)
    let g:agit_enable_auto_refresh = 1
    call Expect(winnr('$')).to_equal(3)
    new
    wincmd p
    call Expect(w:view.name).to_equal('log')
    call Expect(getline(1)).to_match(g:agit#git#unstaged_message)
    let g:agit_enable_auto_refresh = 0
  endfunction

endfunction

function! s:suite.__in_execute_repo__()

  let execute = themis#suite('in execute repo')
  let s:execute_repo_path = s:repo_path . 'execute/'

  function! execute.before()
    tabnew
    tabonly!
    edit `=s:repo_path . 'execute/a'`
    Agit
  endfunction

  function! execute.git_checkout()
    call agit#bufwin#move_to('log')
    call search('develop', 'wc')
    execute 'AgitGit checkout ' . expand('<cword>')
    let current_branch = s:String.chomp(agit#git#exec('rev-parse --abbrev-ref HEAD', s:execute_repo_path))
    call Expect(current_branch).to_equal('develop')
    call search('master', 'wc')
    execute 'AgitGit checkout ' . expand('<cword>')
    let current_branch = s:String.chomp(agit#git#exec('rev-parse --abbrev-ref HEAD', s:execute_repo_path))
    call Expect(current_branch).to_equal('master')
  endfunction

  function! execute.git_create_b()
    execute 'AgitGit checkout -b new ' . agit#extract_hash(getline(2))
    let current_branch = s:String.chomp(agit#git#exec('rev-parse --abbrev-ref HEAD', s:execute_repo_path))
    call Expect(current_branch).to_equal('new')
    call Expect(getline(2)).to_match('(HEAD\(,\| ->\) new')
  endfunction

  function! execute.git_branch_d()
    call search('master', 'wc')
    execute "normal \<Plug>(agit-git-checkout)"
    call search('new', 'wc')
    execute 'AgitGit branch -d ' . expand("<cword>")
    let current_branches = s:String.chomp(agit#git#exec('branch', s:execute_repo_path))
    call Expect(current_branches).to_equal("  develop\n* master")
  endfunction

endfunction

function! s:suite.__in_branched_repo__()

  let branched = themis#suite('in branched repo')

  function! branched.before()
    tabnew
    tabonly!
    edit `=s:repo_path . 'branched/a'`
    Agit
  endfunction

  function! branched.skip_empty_line()
    normal! gg
    normal! j
    doautocmd CursorMoved
    call Expect(line('.')).to_equal(3)
    call Expect(agit#extract_hash(getline('.'))).not.to_equal('')
  endfunction

  function! branched.normal_move()
    normal! gg
    normal! 3j
    doautocmd CursorMoved
    call Expect(line('.')).to_equal(4)
    call Expect(agit#extract_hash(getline('.'))).not.to_equal('')
  endfunction

  function! branched.skip_empty_line_upper()
    normal! G
    doautocmd CursorMoved
    normal! k
    doautocmd CursorMoved
    call Expect(line('.')).to_equal(line('$')-2)
    call Expect(agit#extract_hash(getline('.'))).not.to_equal('')
  endfunction

  function! branched.normal_move_upper()
    normal! G
    normal! 3k
    doautocmd CursorMoved
    call Expect(line('.')).to_equal(line('$')-3)
    call Expect(agit#extract_hash(getline('.'))).not.to_equal('')
  endfunction

endfunction

function! s:suite.__agit_exitting__()
  let exit = themis#suite('agit exitting')

  function! exit.before()
    tabonly!
    new
    only!
  endfunction

  function! exit.before_each()
    edit `=s:repo_path . 'clean/a'`
    Agit
  endfunction

  function! exit.with_q()
    let pretabnr = tabpagenr('$')
    normal q
    call Expect(tabpagenr('$')).to_equal(pretabnr - 1)
  endfunction

  function! exit.with_ex_q()
    if !exists('##QuitPre')
      Skip 'QuitPre event is not supported in this version.'
    endif
    let pretabnr = tabpagenr('$')
    q
    call Expect(tabpagenr('$')).to_equal(pretabnr - 1)
  endfunction

endfunction

function! s:suite.__option_dir__()
  let option_dir = themis#suite('option dir')

  function! option_dir.before_each()
    edit `=s:repo_path . 'clean/a'`
  endfunction

  function! option_dir.open_agit_on_specified_directory()
    Agit
    let head_msg = g:agit#git#unstaged_message
    call Expect(getline(1)).not.to_equal(head_msg)
    normal q
    execute 'Agit --dir=' . s:repo_path . 'unstaged'
    call Expect(getline(1)).to_equal(head_msg)
  endfunction
endfunction

function! s:suite.__option_file__()
  let option_file = themis#suite('option file')

  function! option_file.before_each()
    edit `=s:repo_path . 'clean/a'`
  endfunction

  function! option_file.open_not_found_path()
    redir => message
      AgitFile --file=this_file_does_not_exist
    redir END
    call Expect(message).to_match("File not found: this_file_does_not_exist")
  endfunction
endfunction
