let s:V = vital#of('agit')
let s:String = s:V.import('Data.String')

let s:suite = themis#suite('agit integration test')

let s:repo_path = expand("<sfile>:p:h") . '/repos'

cd `=expand("<sfile>:p:h")`

function! s:suite.__in_clean_repo__()

  let clean = themis#suite('in clean repo')
  let s:clean_repo_path = s:repo_path . '/clean'

  function! clean.before()
    tabnew
    tabonly!
    edit `=s:clean_repo_path . '/a'`
    AgitFile
  endfunction

  function! clean.create_2_windows()
    call Expect(winnr('$')).to_equal(2)
  endfunction

  function! clean.appear_only_commits_on_filelog_window()
    call agit#bufwin#move_to('filelog')
    let head_hash = s:String.chomp(agit#git#exec('rev-parse --short HEAD~', s:clean_repo_path))
    call Expect(getline(1)).to_match(head_hash)
  endfunction

  function! clean.show_file_content_on_catfile_window()
    call agit#bufwin#move_to('catfile')
    let viewcontent = getline(1, '$')
    let filecontent = readfile(s:clean_repo_path . '/a')
    call Expect(viewcontent).to_equal(filecontent)
  endfunction

endfunction
