#!/bin/bash
cd $(dirname $0)

COMMIT_MSG=(1st 2nd 3rd 4th)

[[ -d repos ]] && rm -rf repos

mkdir repos
cd $_
mkdir clean
cd $_
echo "aaa" > a
git -c user.name=agit -c user.email=agit@example.com init
git -c user.name=agit -c user.email=agit@example.com add -A
git -c user.name=agit -c user.email=agit@example.com commit -m"${COMMIT_MSG[0]}"
echo "bbbb" > b
git -c user.name=agit -c user.email=agit@example.com add -A
git -c user.name=agit -c user.email=agit@example.com commit -m"${COMMIT_MSG[1]}"
git branch develop HEAD~
cd ..

cp -a clean execute
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
git -c user.name=agit -c user.email=agit@example.com add b
cd ..

cp -a staged mixed
cd $_
echo "aa" >> a
echo "bb" >> b
cd ..

cp -a clean branched
cd $_
echo "ccc" >> c
git -c user.name=agit -c user.email=agit@example.com add -A
git -c user.name=agit -c user.email=agit@example.com commit -m"${COMMIT_MSG[2]}"
git -c user.name=agit -c user.email=agit@example.com checkout develop
echo "ddd" >> d
git -c user.name=agit -c user.email=agit@example.com add -A
git -c user.name=agit -c user.email=agit@example.com commit -m"${COMMIT_MSG[3]}"
git -c user.name=agit -c user.email=agit@example.com checkout master
git -c user.name=agit -c user.email=agit@example.com merge develop --no-edit
