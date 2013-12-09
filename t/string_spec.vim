describe 'agit#string'

  describe 'agit#string#truncate'

    it 'limit < 0'
      let formatted_msg = agit#string#truncate("hogefuga", -1, '...')
      Expect formatted_msg ==# '...'
    end

    it 'limit = 1'
      let formatted_msg = agit#string#truncate("hogefuga", 1, '...')
      Expect formatted_msg ==# '...'
    end

    it 'limit = 3'
      let formatted_msg = agit#string#truncate("hogefuga", 3, '...')
      Expect formatted_msg ==# '...'
    end

    it 'limit < string length'
      let formatted_msg = agit#string#truncate("hogefuga", 7, '...')
      Expect formatted_msg ==# 'hoge...'
    end

    it 'limit = string length'
      let formatted_msg = agit#string#truncate("hogefuga", 8, '...')
      Expect formatted_msg ==# 'hogefuga'
    end

    it 'limit > string length'
      let formatted_msg = agit#string#truncate("hogefuga", 9, '...')
      Expect formatted_msg ==# 'hogefuga'
    end

    it 'limit < multi-byte string width'
      let formatted_msg = agit#string#truncate("あいabcdef", 8, '...')
      Expect formatted_msg ==# 'あいa...'
    end

    it 'limit = multi-byte string width'
      let formatted_msg = agit#string#truncate("あいうえお", 10, '...')
      Expect formatted_msg ==# 'あいうえお'
    end

    it 'limit > multi-byte string width'
      let formatted_msg = agit#string#truncate("あいうえお", 12, '...')
      Expect formatted_msg ==# 'あいうえお'
    end

  end

  describe 'agit#string#fill_left'

    it 'text length < max length'
      let text = agit#string#fill_left('hoge', 3)
      Expect text ==# 'hoge'
    end

    it 'text length = max length'
      let text = agit#string#fill_left('hoge', 4)
      Expect text ==# 'hoge'
    end

    it 'text length > max length'
      let text = agit#string#fill_left('hoge', 5)
      Expect text ==# 'hoge '
    end

    it 'multibyte text length > max length'
      let text = agit#string#fill_left('ほげ', 7)
      Expect text ==# 'ほげ   '
    end

  end

  describe 'agit#string#fill_right'

    it 'text length < max length'
      let text = agit#string#fill_right('hoge', 3)
      Expect text ==# 'hoge'
    end

    it 'text length = max length'
      let text = agit#string#fill_right('hoge', 4)
      Expect text ==# 'hoge'
    end

    it 'text length > max length'
      let text = agit#string#fill_right('hoge', 5)
      Expect text ==# ' hoge'
    end

    it 'multibyte text length > max length'
      let text = agit#string#fill_right('ほげ', 7)
      Expect text ==# '   ほげ'
    end

  end

end
