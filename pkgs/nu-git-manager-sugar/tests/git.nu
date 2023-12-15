use std assert

use ../../../pkgs/nu-git-manager-sugar/nu-git-manager-sugar/ git [
    "gm repo get commit"
    "gm repo goto root"
    "gm repo branches"
    "gm repo is-ancestor"
    "gm repo remote list"
    "gm repo fetch branch"
    "gm repo ls"
    "gm repo branch wipe"
    "gm repo compare"
]
use ../../../pkgs/nu-git-manager/nu-git-manager/fs/path.nu ["path sanitize"]
use ../../../tests/common/setup.nu [get-random-test-dir]

export module git

def --env init-repo-and-cd-into []: nothing -> path {
    let repo = get-random-test-dir --no-sanitize

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
    let repo = init-repo-and-cd-into | path sanitize

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

export def branches-checked-out [] {
    let repo = init-repo-and-cd-into

    commit "init"

    ^git branch bar
    ^git branch foo
    ^git checkout bar

    gm repo branches --clean
    assert equal (gm repo branches) [{branch: bar, remotes: []}, ]

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

def "assert simple-git-tree-equal" [expected: list<string>, --extra-revs: list<string> = []] {
    let actual = ^git log --oneline --decorate --graph --all $extra_revs
        | lines
        | parse "* {hash} {tree}"
        | get tree
    assert equal $actual $expected
}

export def branch-fetch [] {
    let foo = init-repo-and-cd-into
    let bar = get-random-test-dir

    commit "initial commit"

    ^git clone $"file://($foo)" $bar

    ^git checkout -b foo
    commit "c1" "c2"

    do {
        cd $bar
        gm repo fetch branch $"file://($foo)" foo

        assert simple-git-tree-equal [
            "(foo) c2",
            "c1",
            "(HEAD -> main, origin/main, origin/HEAD) initial commit",
        ]
    }

    commit "c3" "c4"

    do {
        cd $bar
        gm repo fetch branch $"file://($foo)" foo

        assert simple-git-tree-equal [
            "(foo) c4",
            "c3",
            "c2",
            "c1",
            "(HEAD -> main, origin/main, origin/HEAD) initial commit",
        ]

        ^git checkout foo
    }

    commit "c5" "c6"

    do {
        cd $bar
        gm repo fetch branch $"file://($foo)" foo

        assert simple-git-tree-equal --extra-revs ["FETCH_HEAD"] [
            "c6",
            "c5",
            "(HEAD -> foo) c4",
            "c3",
            "c2",
            "c1",
            "(origin/main, origin/HEAD, main) initial commit",
        ]
    }

    do {
        cd $bar
        gm repo fetch branch $"file://($foo)" foo --strategy "rebase"

        assert simple-git-tree-equal [
            "(HEAD -> foo) c6",
            "c5",
            "c4",
            "c3",
            "c2",
            "c1",
            "(origin/main, origin/HEAD, main) initial commit",
        ]
    }

    commit "c7" "c8"

    do {
        cd $bar
        gm repo fetch branch $"file://($foo)" foo --strategy "merge"

        assert simple-git-tree-equal [
            "(HEAD -> foo) c8",
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

    assert error { gm repo fetch branch $"file://($foo)" foo --strategy "" }

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
    let repo = init-repo-and-cd-into | path sanitize

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
    let foo = init-repo-and-cd-into

    commit "initial commit"

    assert equal (gm repo compare main --head main) ""
    assert equal (gm repo compare HEAD --head HEAD) ""

    ^git checkout -b foo
    "foo" | save foo.txt
    ^git add foo.txt
    commit "c1"

    let expected = [
        "diff --git a/foo.txt b/foo.txt",
        "new file mode 100644",
        "index 0000000..1910281",
        "--- /dev/null",
        "+++ b/foo.txt",
        "@@ -0,0 +1 @@",
        "+foo",
        "\\ No newline at end of file"
        "",
    ]
    assert equal (gm repo compare main) ($expected | str join "\n")
    assert equal (gm repo compare main --head HEAD) ($expected | str join "\n")

    ^git checkout main
    "bar" | save --append foo.txt
    ^git add foo.txt
    commit "c2"

    assert equal (gm repo compare main --head foo) ($expected | str join "\n")

    clean $foo
}

export module prompt {
    use ../../../pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/lib/lib.nu [
        get-revision, git-action
    ]
    use ../../../pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/lib/prompt.nu [
        get-left-prompt
    ]
    use ../../../pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/lib/style.nu [
        simplify-path
    ]

    def "assert revision" [expected: record] {
        let actual = get-revision --short-hash true
        assert equal $actual $expected
    }

    def "assert prompt" [expected: string] {
        let actual = get-left-prompt 10hr | ansi strip

        let admin_segment = if $nu.os-info.name == "windows" {
            "!!"
        } else {
            null
        }

        assert equal $actual ($admin_segment | append $expected | compact | str join " ")
    }

    export def repo-revision [] {
        let repo = init-repo-and-cd-into
        ^git config tag.gpgSign false

        assert revision {name: "main", hash: "", type: "branch"}

        let hashes = commit c1 c2 c3
        assert revision {name: "main", hash: ($hashes | last), type: "branch"}

        ^git checkout $hashes.1
        assert revision {name: null, hash: $hashes.1, type: "detached"}

        ^git tag foo --annotate --message ""
        assert revision {name: "foo", hash: $hashes.1, type: "tag"}

        ^git checkout main
        ^git tag bar --annotate --message ""
        assert revision {name: "main", hash: ($hashes | last), type: "branch"}

        ^git checkout bar
        assert revision {name: "bar", hash: ($hashes | last), type: "tag"}

        clean $repo
    }

    export def repo-current-action [] {
        let repo = init-repo-and-cd-into

        assert equal (git-action) null

        commit init
        assert equal (git-action) null

        ^git checkout -b some main
        "foo" | save --force file.txt
        ^git add file.txt
        commit foo

        ^git checkout -b other main
        "bar" | save --force file.txt
        ^git add file.txt
        commit bar

        do --ignore-errors { ^git merge some }
        assert equal (git-action | ansi strip) $"MERGING"

        ^git merge --abort
        do --ignore-errors { ^git rebase some }
        assert equal (git-action | ansi strip) $"REBASE-i"

        ^git rebase --abort
        do --ignore-errors { ^git cherry-pick some }
        assert equal (git-action | ansi strip) $"CHERRY-PICKING"

        ^git cherry-pick --abort
        assert equal (git-action) null

        clean $repo
    }

    export def build-left-prompt [] {
        let repo = init-repo-and-cd-into

        assert prompt $"($repo | path basename) \(main:\) "

        let hash = commit init | get 0
        assert prompt $"($repo | path basename) \(main:($hash)\) "

        mkdir foo
        cd foo
        let pwd = $repo | path basename | append foo | str join (char path_sep)
        assert prompt $"($pwd) \(main:($hash)\) "

        cd ..
        ^git checkout $hash
        assert prompt $"($repo | path basename) \(_:($hash)\) "

        cd ..
        # FIXME: use `path sanitize` from `nu-git-manager`
        let expected_pwd = $repo
            | path dirname
            | str replace --regex '^.:' ''
            | str replace --all '\' '/'
            | simplify-path
        assert prompt $"($expected_pwd) "

        clean $repo
    }
}
