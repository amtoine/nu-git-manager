    "gm repo ls"
    "gm repo branch wipe"
    "gm repo compare"
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