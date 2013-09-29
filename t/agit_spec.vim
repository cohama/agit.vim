runtime! plugin/agit.vim

describe 'agit'
  describe 'Agit command'
    before
      Agit
    end

    it 'creates 3 windows'
      let win_count = winnr('$')
      Expect win_count == 3
    end
  end
end
