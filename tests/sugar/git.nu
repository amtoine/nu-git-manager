use std assert

use ../../src/nu-git-manager-sugar/ git *
use ../common/setup.nu [get-random-test-dir]

export def get-commit [] {
    assert false
}

export def goto-root [] {
    let repo = get-random-test-dir

    ^git init $repo
    cd $repo

    mkdir foo/bar/baz
    cd foo/bar/baz

    gm repo goto root
    assert equal (pwd) $repo
}

export def branches [] {
    assert false
}

export def is-ancestor [] {
    let repo = get-random-test-dir

    ^git init $repo
    cd $repo

    git commit --allow-empty --no-gpg-sign --message "init"
    git commit --allow-empty --no-gpg-sign --message "c1"
    git commit --allow-empty --no-gpg-sign --message "c2"

    assert (gm repo is-ancestor HEAD^ HEAD)
    assert not (gm repo is-ancestor HEAD HEAD^)
}

export def remote-list [] {
    assert false
}
