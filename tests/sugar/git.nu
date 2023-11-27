use std assert

use ../../src/nu-git-manager-sugar/ git [
    "gm repo get commit"
    "gm repo goto root"
    "gm repo branches"
    "gm repo is-ancestor"
    "gm repo remote list"
]
use ../../src/nu-git-manager/fs/path.nu ["path sanitize"]
use ../common/setup.nu [get-random-test-dir]

def --env init-repo-and-cd-into []: nothing -> path {
    let repo = get-random-test-dir

    ^git init $repo
    cd $repo
    ^git checkout --orphan main

    $repo
}

export def get-commit [] {
    init-repo-and-cd-into

    ^git commit --allow-empty --no-gpg-sign --message "init"

    assert equal (gm repo get commit) (^git rev-parse HEAD)
}

export def goto-root [] {
    let repo = init-repo-and-cd-into

    mkdir bar/baz
    cd bar/baz

    gm repo goto root
    assert equal (pwd | path sanitize) $repo
}

export def branches [] {
    init-repo-and-cd-into

    assert equal (gm repo branches) []

    ^git commit --allow-empty --no-gpg-sign --message "init"

    assert equal (gm repo branches) [{branch: main, remotes: []}]
}

export def is-ancestor [] {
    init-repo-and-cd-into

    ^git commit --allow-empty --no-gpg-sign --message "init"
    ^git commit --allow-empty --no-gpg-sign --message "c1"
    ^git commit --allow-empty --no-gpg-sign --message "c2"

    assert (gm repo is-ancestor HEAD^ HEAD)
    assert not (gm repo is-ancestor HEAD HEAD^)
}

export def remote-list [] {
    init-repo-and-cd-into

    assert equal (gm repo remote list) []

    ^git remote add foo foo-url

    assert equal (gm repo remote list) [{remote: foo, fetch: foo-url, push: foo-url}]
}

export def branch-fetch [] {
    exit 1
}

# ignored
def branch-interactive-delete [] {
    exit 0
}

export def branch-switch [] {
    exit 1
}

export def list [] {
    exit 1
}

export def branch-wipe [] {
    exit 1
}

export def branch-compare [] {
    exit 1
}
