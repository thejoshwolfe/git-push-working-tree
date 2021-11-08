#!/usr/bin/env bash

echo Creating submodule hell starting here.
read -p "Continue? [Yn] " -r REPLY
case $REPLY in
    [Nn]*) echo 'Aboring!'; exit 1;;
esac

set -ex

export GIT_AUTHOR_DATE="100000000 +0000"
export GIT_COMMITTER_DATE="100000000 +0000"

create-git-dir() {
    rm -rf "$1"
    mkdir -p "$1"
    git -C "$1" init -b main
    git -C "$1" config user.name Nobody
    git -C "$1" config user.email nobody@bogus.invalid
    git -C "$1" commit --allow-empty -m "init $1"
    git -C "$1" tag v0
}

create-git-dir git-hell-1


# add sub
create-git-dir git-hell-2

git -C git-hell-1 submodule add ../git-hell-2 sub
git -C git-hell-1 commit -m "add submodule"
git -C git-hell-1 tag submodule-added


# update sub
echo a > git-hell-2/file.txt
git -C git-hell-2 add -A
git -C git-hell-2 commit -m "create file"

git -C git-hell-1/sub fetch
git -C git-hell-1/sub reset --hard origin/main
git -C git-hell-1 add -A
git -C git-hell-1 commit -m "update submodule"
git -C git-hell-1 tag submodule-updated


# add sub-sub
create-git-dir git-hell-3

echo b > git-hell-3/file.txt
git -C git-hell-3 add -A
git -C git-hell-3 commit -m "create file"

git -C git-hell-2 submodule add ../git-hell-3 sub
git -C git-hell-2 commit -m "add submodule"

git -C git-hell-1/sub fetch
git -C git-hell-1/sub reset --hard origin/main
git -C git-hell-1 add -A
git -C git-hell-1 commit -m "update submodule"
git -C git-hell-1 tag submodule-submodule-added
git -C git-hell-1 submodule update --init --recursive


# update sub-sub
echo c > git-hell-3/file.txt
git -C git-hell-3 add -A
git -C git-hell-3 commit -m "update file"

git -C git-hell-2/sub fetch
git -C git-hell-2/sub reset --hard origin/main
git -C git-hell-2 add -A
git -C git-hell-2 commit -m "update submodule"

git -C git-hell-1/sub fetch
git -C git-hell-1/sub reset --hard origin/main
git -C git-hell-1 add -A
git -C git-hell-1 commit -m "update submodule"
git -C git-hell-1 tag submodule-updated-submodule-updated
git -C git-hell-1 submodule update --init --recursive


# remove sub-sub module
git -C git-hell-2 rm sub
git -C git-hell-2 commit -m "remove submodule"

git -C git-hell-1/sub fetch
git -C git-hell-1/sub reset --hard origin/main
git -C git-hell-1 add -A
git -C git-hell-1 commit -m "update submodule"
git -C git-hell-1 tag submodule-updated-submodule-removed
git -C git-hell-1 submodule foreach --recursive 'git clean -ffd'


# recreate sub-sub module with a different url
create-git-dir git-hell-4

echo d > git-hell-4/file.txt
git -C git-hell-4 add -A
git -C git-hell-4 commit -m "create file"

rm -rf git-hell-2/.git/modules/sub
git -C git-hell-2 submodule add ../git-hell-4 sub
git -C git-hell-2 commit -m "re-add submodule"

git -C git-hell-1/sub fetch
git -C git-hell-1/sub reset --hard origin/main
git -C git-hell-1 add -A
git -C git-hell-1 commit -m "update submodule"
git -C git-hell-1 tag submodule-updated-submodule-readded
git -C git-hell-1/sub config --unset submodule.sub.url
rm -rf git-hell-1/.git/modules/sub/modules/sub
git -C git-hell-1 submodule update --init --recursive


# in place update of submodule to have completely different url and contents
create-git-dir git-hell-5

echo e > git-hell-5/file.txt
git -C git-hell-5 add -A
git -C git-hell-5 commit -m "create file"

git -C git-hell-2 rm sub
rm -rf git-hell-2/.git/modules/sub
git -C git-hell-2 submodule add ../git-hell-5 sub
git -C git-hell-2 commit -m "replace submodule"

git -C git-hell-1/sub fetch --recurse-submodules=no
git -C git-hell-1/sub reset --hard origin/main
git -C git-hell-1 add -A
git -C git-hell-1 commit -m "update submodule"
git -C git-hell-1 tag submodule-updated-submodule-replaced
git -C git-hell-1 submodule sync --recursive
git -C git-hell-1 submodule update --init --recursive
