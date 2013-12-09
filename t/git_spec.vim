describe 'agit#git'

  describe 'agit#git#align_log'

    it 'aligns messages, dates, commiters and hashes'
      let logs = [
      \ ["* (master, hoge) hoge fuga", "10 days ago", "cohama", "123"],
      \ ["* hoge", "9 days ago", "cohama", "123"],
      \ ["* (fuga) ほげ ふがぴ よ", "1000000 days ago", "cohama", "123"],
      \ ["| * (piyo) hoge fuga", "10 days ago", "cohamacohamacohama", "123"],
      \ ["|/"],
      \ ]
      let aligned = agit#git#align_log(logs, 0)
      let expect = [
      \ "* (master, hoge) hoge fuga 10 days ago      cohama             123",
      \ "* hoge                     9 days ago       cohama             123",
      \ "* (fuga) ほげ ふがぴ よ    1000000 days ago cohama             123",
      \ "| * (piyo) hoge fuga       10 days ago      cohamacohamacohama 123",
      \ "|/",
      \ ]

      Expect aligned == expect
    end

    it 'aligns fields within limited columns'
      let logs = [
      \ ["* (master, hoge) ほげふが", "2013-10-23", "cohama", "123"],
      \ ["* hoge ", "2013-10-22", "cohama", "123"],
      \ ["* (fuga) ほげ ふがぴ よ", "2013-10-21", "cohama", "123"],
      \ ["| * (piyo) hoge fuga", "2013-10-20", "cohamacohamacohama", "123"],
      \ ["|/"],
      \ ]
      let aligned = agit#git#align_log(logs, 56)
      let expect = [
      \ "* (master, hoge) ほ... 2013-10-23 cohama             123",
      \ "* hoge                 2013-10-22 cohama             123",
      \ "* (fuga) ほげ ふが ... 2013-10-21 cohama             123",
      \ "| * (piyo) hoge fuga   2013-10-20 cohamacohamacohama 123",
      \ "|/",
      \ ]

      Expect aligned == expect
  end
end
