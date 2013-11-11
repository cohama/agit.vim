runtime! plugin/agit.vim

describe 'agit'
  describe 'Agit command'
    before
      Agit
    end

    it 'creates 3 windows with id variables'
      let win_count = winnr('$')
      Expect win_count == 3
    end

    describe 'log window'
      before
        1wincmd w
      end

      it 'has agit_win_type as "log"'
        Expect w:agit_win_type ==# 'log'
      end

      it 'has view specific options'
        Expect &l:modifiable == 0
        Expect &l:wrap == 0
        Expect &l:number == 0
        Expect &l:relativenumber == 0
        Expect &l:buftype == 'nofile'
      end
    end

    describe 'stat window'
      before
        2wincmd w
      end

      it 'has agit_win_type as "stat"'
        Expect w:agit_win_type ==# 'stat'
      end

      it 'has view specific options'
        Expect &l:modifiable == 0
        Expect &l:wrap == 0
        Expect &l:number == 0
        Expect &l:relativenumber == 0
        Expect &l:buftype == 'nofile'
      end

      it 'does not have empty line'
        let found = search('^$')
        Expect found == 0
      end
    end

    describe 'diff window'
      before
        3wincmd w
      end

      it 'has agit_win_type as "diff"'
        Expect w:agit_win_type ==# 'diff'
      end

      it 'has view specific options'
        Expect &l:modifiable == 0
        Expect &l:wrap == 0
        Expect &l:number == 0
        Expect &l:relativenumber == 0
        Expect &l:buftype == 'nofile'
      end
    end
  end
end
