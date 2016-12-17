Agit.vim
========
[![Build Status](https://travis-ci.org/cohama/agit.vim.png?branch=master)](https://travis-ci.org/cohama/agit.vim)

Yet another gitk clone for Vim!

Screen Shots
------------
![Screen Shot](http://i.gyazo.com/d0895f88bcd15e252017325a01fa89bc.gif)

Features
--------
* gitk-like repository viewer
* providing various git commands (e.g. checkout, reset, etc...)
* side by side diff by vimdiff
* No fugitive dependency, but well cooperation if exists.
* Supporting multibyte character

Installation
------------
If you use [NeoBundle](https://github.com/Shougo/neobundle.vim),
```vim
NeoBundle 'cohama/agit.vim'
```

Usage
-----
When you edit a file in git repository, type the below
```vim
:Agit
```

Requirements
------------
- Vim 7.4.52 or later
- Git 1.8.5 or later

License
-------
MIT license

Pull request is always welcome!
