describe 'agit#bufwin'
  describe 'agit#bufwin#move_or_create_window'
    before
      " create new 2 windows before each tests
      " one has variable w:h and the other has w:f
      new
      only
      new
      let w:h = "hoge"
      wincmd p
      let w:f = "fuga"
    end

    it 'moves the focus to the window which the specified variable has the specified value'
      call agit#bufwin#move_or_create_window('h', 'hoge', 'new')
      Expect w:h ==# "hoge"
      Expect winnr('$') == 2
    end

    it 'creates a new window when the specified variable is not found.'
      call agit#bufwin#move_or_create_window('p', 'piyo', 'new')
      Expect w:p ==# 'piyo'
      Expect winnr('$') == 3
    end

    it 'creates new window when the specified value is differnet'
      call agit#bufwin#move_or_create_window('h', 'piyo', 'new')
      Expect w:h ==# 'piyo'
      Expect winnr('$') == 3
    end

    it 'creates new window with the specified open command'
      let orig_height = winheight('.')
      let orig_width = winwidth('.')
      call agit#bufwin#move_or_create_window('h', 'piyo', 'botright vnew')
      Expect winheight('.') > orig_height
      Expect winwidth('.') < orig_width
    end
  end
end
