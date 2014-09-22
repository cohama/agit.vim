let s:suite = themis#suite('agit#string#truncate')

" function! s:suite['limit < 0']()
function! s:suite.only_3_dots_are_shown_when_limit_is_less_than_0()
  let dots = agit#string#truncate("hogefuga", -1, '...')
  call Expect(dots ).to_equal('...')
endfunction

function! s:suite.only_3_dots_are_shown_when_limit_is_equal_to_1()
  let dots = agit#string#truncate("hogefuga", 1, '...')
  call Expect(dots).to_equal('...')
endfunction

function! s:suite.only_3_dots_are_shown_when_limit_is_equal_to_3()
  let dots = agit#string#truncate("hogefuga", 3, '...')
  call Expect(dots).to_equal('...')
endfunction

function! s:suite.excesive_characters_are_replaced_by_3_dots_when_limit_is_less_than_string_length()
  let truncated = agit#string#truncate("hogefuga", 7, '...')
  call Expect(truncated).to_equal('hoge...')
endfunction

function! s:suite.nothing_happens_when_limit_is_equal_to_string_length()
  let formatted_msg = agit#string#truncate("hogefuga", 8, '...')
  call Expect(formatted_msg).to_equal('hogefuga')
endfunction

function! s:suite.nothing_happens_when_limit_is_greater_than_string_length()
  let formatted_msg = agit#string#truncate("hogefuga", 9, '...')
  call Expect(formatted_msg).to_equal('hogefuga')
endfunction

function! s:suite.excesive_characters_are_replaced_by_3_dots_when_limit_bound_is_on_a_singlebyte_character()
  let formatted_msg = agit#string#truncate("あいabcdef", 8, '...')
  call Expect(formatted_msg).to_equal('あいa...')
endfunction

function! s:suite.excesive_characters_are_replaced_by_a_whitespace_and_3_dots_when_limit_bound_is_on_a_multibyte_character()
  let formatted_msg = agit#string#truncate("あいうabcd", 8, '...')
  call Expect(formatted_msg).to_equal('あい ...')
endfunction

function! s:suite.nothing_happen_when_limit_is_equal_to_multibyte_string_width()
  let formatted_msg = agit#string#truncate("あいうえお", 10, '...')
  call Expect(formatted_msg).to_equal('あいうえお')
endfunction

function! s:suite.nothing_happen_when_limit_is_greater_than_multibyte_string_width()
  let formatted_msg = agit#string#truncate("あいうえお", 12, '...')
  call Expect(formatted_msg).to_equal('あいうえお')
endfunction

let s:suite = themis#suite('agit#string#fill_left')

function! s:suite.nothing_happen_when_filling_length_is_less_than_text_length()
  let text = agit#string#fill_left('hoge', 3)
  call Expect(text).to_equal('hoge')
endfunction

function! s:suite.nothing_happen_when_filling_length_is_equal_to_text_length()
  let text = agit#string#fill_left('hoge', 4)
  call Expect(text).to_equal('hoge')
endfunction

function! s:suite.add_whitespaces_to_the_left_when_filling_length_is_greater_than_text_length()
  let filled = agit#string#fill_left('hoge', 5)
  call Expect(filled).to_equal(' hoge')
  let filled_multibyte = agit#string#fill_left('ほ', 5)
  call Expect(filled_multibyte).to_equal('   ほ')
endfunction

let s:suite = themis#suite('agit#string#fill_right')

function! s:suite.nothing_happen_when_filling_length_is_less_than_text_length()
  let text = agit#string#fill_right('hoge', 3)
  call Expect(text).to_equal('hoge')
endfunction

function! s:suite.nothing_happen_when_filling_length_is_equal_to_text_length()
  let text = agit#string#fill_right('hoge', 4)
  call Expect(text).to_equal('hoge')
endfunction

function! s:suite.add_whitespaces_to_the_right_when_filling_length_is_greater_than_text_length()
  let filled = agit#string#fill_right('hoge', 5)
  call Expect(filled).to_equal('hoge ')
endfunction
