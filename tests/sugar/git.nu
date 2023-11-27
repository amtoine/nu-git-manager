use std assert

use ../../src/nu-git-manager-sugar/ git [
    "gm repo get commit"
    "gm repo goto root"
    "gm repo branches"
    "gm repo is-ancestor"
    "gm repo remote list"
    "gm repo fetch branch"
    "gm repo ls"
    "gm repo branch wipe"
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

def clean [dir: path] {
    cd
    rm --recursive --force $dir
}

def commit [...messages: string]: nothing -> list<string> {
    $messages | each {|msg|
        ^git commit --allow-empty --no-gpg-sign --message $msg
            | parse --regex '\[.* (?<hash>.*)\] .*'
            | get hash.0
    }
}

export def get-commit [] {
    let repo = init-repo-and-cd-into

    commit "init"

    assert equal (gm repo get commit) (^git rev-parse HEAD)

    clean $repo
}

export def goto-root [] {
    let repo = init-repo-and-cd-into

    mkdir bar/baz
    cd bar/baz

    gm repo goto root
    assert equal (pwd | path sanitize) $repo

    clean $repo
}

export def branches [] {
    let repo = init-repo-and-cd-into

    assert equal (gm repo branches) []

    commit "init"

    assert equal (gm repo branches) [{branch: main, remotes: []}]

    clean $repo
}

export def is-ancestor [] {
    let repo = init-repo-and-cd-into

    commit "init" "c1" "c2"

    assert (gm repo is-ancestor HEAD^ HEAD)
    assert not (gm repo is-ancestor HEAD HEAD^)

    clean $repo
}

export def remote-list [] {
    let repo = init-repo-and-cd-into

    assert equal (gm repo remote list) []

    ^git remote add foo foo-url

    assert equal (gm repo remote list) [{remote: foo, fetch: foo-url, push: foo-url}]

    clean $repo
}

def "assert simple-git-tree-equal" [expected: list<string>] {
    let actual = (
        ^git log --oneline --decorate --graph --all | lines | parse "* {hash} {tree}" | get tree
    )
    assert equal $actual $expected
}

export def branch-fetch [] {
    let foo = init-repo-and-cd-into
    let bar = get-random-test-dir

    commit "initial commit"

    ^git clone $"file://($foo)" $bar

    ^git checkout -b foo
    commit "c1" "c2" "c3"

    do {
        cd $bar
        gm repo fetch branch $"file://($foo)" foo

        assert simple-git-tree-equal [
            "(foo) c3",
            "c2",
            "c1",
            "(HEAD -> main, origin/main, origin/HEAD) initial commit",
        ]
    }

    commit "c4" "c5" "c6"

    do {
        cd $bar
        gm repo fetch branch $"file://($foo)" foo

        assert simple-git-tree-equal [
            "(foo) c6",
            "c5",
            "c4",
            "c3",
            "c2",
            "c1",
            "(HEAD -> main, origin/main, origin/HEAD) initial commit",
        ]

        ^git checkout foo
    }

    commit "c7" "c8" "c9"

    do {
        cd $bar
        gm repo fetch branch $"file://($foo)" foo

        assert simple-git-tree-equal [
            "(HEAD -> foo) c9",
            "c8",
            "c7",
            "c6",
            "c5",
            "c4",
            "c3",
            "c2",
            "c1",
            "(origin/main, origin/HEAD, main) initial commit",
        ]
    }

    clean $foo
    clean $bar
}

# ignored: interactive
def branch-interactive-delete [] {
    exit 0
}

# ignored: interactive
def branch-interactive-switch [] {
    exit 1
}

export def list [] {
    let repo = init-repo-and-cd-into

    let BASE_LS = {
        path: $repo,
        name: ($repo | path basename),
        staged: [],
        unstaged: [],
        untracked: [],
        last_commit: null,
        branch: main
    }

    assert equal (gm repo ls) $BASE_LS

    let initial_hash = commit "init"

    let actual = (gm repo ls | update $.last_commit.date null)
    let expected = $BASE_LS | update last_commit {date: null, title: "init", hash: $initial_hash.0}
    assert equal $actual $expected

    touch foo.txt

    let actual = (gm repo ls | update $.last_commit.date null)
    let expected = $BASE_LS
        | update last_commit {date: null, title: "init", hash: $initial_hash.0}
        | update untracked ["foo.txt"]
    assert equal $actual $expected

    ^git add foo.txt

    let actual = (gm repo ls | update $.last_commit.date null)
    let expected = $BASE_LS
        | update last_commit {date: null, title: "init", hash: $initial_hash.0}
        | update staged ["foo.txt"]
    assert equal $actual $expected

    let hash = commit "add foo.txt"

    let actual = (gm repo ls | update $.last_commit.date null)
    let expected = $BASE_LS | update last_commit {date: null, title: "add foo.txt", hash: $hash.0}
    assert equal $actual $expected

    "foo" | save --append foo.txt
    "bar" | save bar.txt
    ^git add bar.txt
    "bar" | save --append bar.txt

    let actual = (gm repo ls | update $.last_commit.date null)
    let expected = $BASE_LS
        | update last_commit {date: null, title: "add foo.txt", hash: $hash.0}
        | update unstaged ["bar.txt", "foo.txt"]
        | update staged ["bar.txt"]
    assert equal $actual $expected

    clean $repo
}

export def branch-wipe [] {
    let foo = init-repo-and-cd-into
    let bar = get-random-test-dir

    commit "initial commit"

    ^git checkout -b foo
    commit "c1" "c2" "c3"
    ^git checkout main

    ^git clone $"file://($foo)" $bar

    assert equal (^git branch | lines | str substring 2..) ["foo", "main"]

    do {
        cd $bar

        ^git branch foo origin/foo

        assert simple-git-tree-equal [
            "(origin/foo, foo) c3",
            "c2",
            "c1",
            "(HEAD -> main, origin/main, origin/HEAD) initial commit",
        ]
        gm repo branch wipe foo origin
        assert simple-git-tree-equal ["(HEAD -> main, origin/main, origin/HEAD) initial commit"]
    }

    assert equal (^git branch | lines | str substring 2..) ["main"]

    clean $foo
    clean $bar
}

export def branch-compare [] {
    exit 1
}
