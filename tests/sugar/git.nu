use std assert

use ../../src/nu-git-manager-sugar/ git *
use ../common/setup.nu [get-random-test-dir]

def --env init-repo-and-cd-into []: nothing -> path {
    let repo = get-random-test-dir

    ^git init $repo
    cd $repo

    $repo
}

export def get-commit [] {
    assert false
}

export def goto-root [] {
    let repo = init-repo-and-cd-into

    mkdir init-repo-and-cd-into/bar/baz
    cd init-repo-and-cd-into/bar/baz

    gm repo goto root
    assert equal (pwd) $repo
}

export def branches [] {
    init-repo-and-cd-into

    assert equal (gm repo branches) []

    git checkout --orphan foo
    git commit --allow-empty --no-gpg-sign --message "init"

    assert equal (gm repo branches) [{branch: foo, remotes: []}]
}

export def is-ancestor [] {
    init-repo-and-cd-into

    git commit --allow-empty --no-gpg-sign --message "init"
    git commit --allow-empty --no-gpg-sign --message "c1"
    git commit --allow-empty --no-gpg-sign --message "c2"

    assert (gm repo is-ancestor HEAD^ HEAD)
    assert not (gm repo is-ancestor HEAD HEAD^)
}

export def remote-list [] {
    init-repo-and-cd-into

    assert equal (gm repo remote list) []

    ^git remote add foo foo-url

    assert equal (gm repo remote list) [{remote: foo, fetch: foo-url, push: foo-url}]
}
