# git-push-working-tree

Like `rsync` for uncommitted git changes. Pushes to an ssh-accessible working tree.

## Description

I have my code editor on one computer, and I need to build+run on a different computer I can ssh to. Both computers have a git repo checkout of the code. This tool lets me effectively `rsync` my code changes in order to build+run them on the other computer without making any (observable) git commits.

Why not just use `rsync`? This program ignores everything in `.gitignore` on both sides of the sync, for example build directories, IDE configuration files, etc. That's really the main reason. Additionally, this program is optimized to use git's indexing rather than rsync's indexing, but the improvement there, if any, is untested.

This is implemented using a secret git commit that is created without modifying "the index" or `HEAD` on the source side, so nothing in `git status` will change (uses `git commit-tree` and other low-level commands.). The secret commit is then pushed to the destination repo as a secret branch named `refs/git-push-working-tree/SYNC_HEAD` (or something similar; see the code.). Note that this branch does not start with `refs/heads/` so it is not a proper "branch" according to git, and it will not show up in any `git branch` listings.

Then the program sshes to the destination and checks out the secret commit. This is the ugliest part of this operation, and it might be improved in a future version to no longer modify "the index" and `HEAD` on the destination side. As a small consolation, `HEAD` is reset back to its original sha1 after the sync, leaving the newly arrived content as uncommitted/untracked changes.

## Status

* [+] Syncs committed, `--cached`, uncommitted, and untracked changes.
* [+] Syncing includes deleting what shouldn't exist.
* [+] Ignores `.gitignore` ignored files on both sides.
* [+] Causes no observable changes to the git state on the source side.
* [+] Causes no lasting observable changes to the git state on the destination side. (TODO: check for observable changes to `--cached` changes on the destination side.)
* [ ] Syncing the initialized/uninitialized state of each submodule from source to dest. (TODO: what does "initialized" even mean for a submodule? What are all the states a submodule can be in?)
* [ ] Syncing changing the commit of a submodule.
* [ ] Syncing working tree changes in a submodule.
* [ ] Syncing addition of a submodule.
* [ ] Syncing removal of a submodule.
* [ ] Syncing url changes to a submodule.
* [ ] Syncing in-place replacement of a submodule with an incompatible repo (not properly supported by git itself, so maybe this will never work).
* [ ] Syncing all the above about submodules recursively in submodules' own submodules.
* [ ] Syncing changes to `.gitignore` in a way that makes sense. (TODO: how should this even work?)

## Usage

See `git-push-working-tree --help` or search the code for `argparse`.
