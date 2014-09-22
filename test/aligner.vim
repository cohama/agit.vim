let s:suite = themis#suite('agit#git#align_log')

function! s:suite.align_messages_date_commiter_hash()
  let logs = [
  \ ["* (master, hoge) hoge fuga", "10 days ago", "cohama", "123"],
  \ ["* hoge", "9 days ago", "cohama", "123"],
  \ ["* (fuga) ほげ ふがぴ よ", "1000000 days ago", "cohama", "123"],
  \ ["| * (piyo) hoge fuga", "10 days ago", "cohamacohamacohama", "123"],
  \ ["|/"],
  \ ]
  let aligned = agit#aligner#align(logs, 0)
  let expect = [
  \ "* (master, hoge) hoge fuga 10 days ago      cohama            123",
  \ "* hoge                     9 days ago       cohama            123",
  \ "* (fuga) ほげ ふがぴ よ    1000000 days ago cohama            123",
  \ "| * (piyo) hoge fuga       10 days ago      cohamacohamacohama123",
  \ "|/",
  \ ]
  call Expect(aligned).to_equal(expect)
endfunction

function! s:suite.aligns_fields_within_limited_columns()
  let logs = [
  \ ["* (master, hoge) ほげふが", "2013-10-23", "cohama", "123"],
  \ ["* hoge ", "2013-10-22", "cohama", "123"],
  \ ["* (fuga) ほげ ふがぴ よ", "2013-10-21", "cohama", "123"],
  \ ["| * (piyo) hoge fuga", "2013-10-20", "cohamacohamacohama", "123"],
  \ ["|/"],
  \ ]
  let aligned = agit#aligner#align(logs, 56)
  let expect = [
  \ "* (master, hoge) ほ ... 2013-10-23 cohama            123",
  \ "* hoge                  2013-10-22 cohama            123",
  \ "* (fuga) ほげ ふがぴ よ 2013-10-21 cohama            123",
  \ "| * (piyo) hoge fuga    2013-10-20 cohamacohamacohama123",
  \ "|/",
  \ ]
  call Expect(aligned).to_equal(expect)
endfunction
