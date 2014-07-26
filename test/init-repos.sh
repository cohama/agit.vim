#!/bin/bash
cd $(dirname $0)

COMMIT_MSG=(1st 2nd 3rd 4th)

[[ -d repos ]] && rm -rf repos

mkdir repos
cd $_
mkdir clean
cd $_
echo "aaa" > a
git -c user.name=agit init
git -c user.name=agit add -A
git -c user.name=agit commit -m"${COMMIT_MSG[0]}"
echo "bbbb" > b
git -c user.name=agit add -A
git -c user.name=agit commit -m"${COMMIT_MSG[1]}"
cd ..
cp -a clean untracked
cd $_
echo "ccccc" > c
echo "ccc" >> c
cd ..
cp -a clean unstaged
cd $_
echo "bbb" >> b
cd ..
cp -a unstaged staged
cd $_
git -c user.name=agit add b
cd ..
cp -a staged mixed
cd $_
echo "aa" >> a
echo "bb" >> b
