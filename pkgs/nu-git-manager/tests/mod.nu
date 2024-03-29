use std assert

use ../../../pkgs/nu-git-manager/nu-git-manager/git url [
    parse-git-url, get-fetch-push-urls
]
use ../../../pkgs/nu-git-manager/nu-git-manager/git repo [
    is-grafted, get-root-commit, list-remotes
]
use ../../../pkgs/nu-git-manager/nu-git-manager/fs store [
    get-repo-store-path, list-repos-in-store
]
use ../../../pkgs/nu-git-manager/nu-git-manager/fs cache [
    get-repo-store-cache-path, check-cache-file, add-to-cache, remove-from-cache, open-cache,
    save-cache, clean-cache-dir
]
use ../../../pkgs/nu-git-manager/nu-git-manager/fs path [
    "path sanitize", "path remove-prefix", "path remove-trailing-path-sep"
]
use ../../../pkgs/nu-git-manager/nu-git-manager/fs dir [clean-empty-directories-rec]

use ../../../tests/common/setup.nu [get-random-test-dir]

export module gm.nu

export module path {
    export def sanitization [] {
        assert equal ('\foo\bar' | path sanitize) "/foo/bar"
    }

    export def remove-prefix [] {
        assert equal ("/foo/bar" | path remove-prefix "/foo") "bar"
        assert equal ("/foo/bar" | path remove-prefix "/bar") "/foo/bar"
        assert equal ("/foo/bar/baz" | path remove-prefix "/foo") "bar/baz"
        assert equal (["/foo/bar", "/foo/bar/baz"] | path remove-prefix "/foo") ["bar", "bar/baz"]
    }

    export def remove-trailing-path-sep [] {
        assert equal ("/foo/bar/" | path remove-trailing-path-sep) "/foo/bar"
        assert equal ("/foo/bar" | path remove-trailing-path-sep) "/foo/bar"
        assert equal (["/foo/bar", "/foo/bar/"] | path remove-trailing-path-sep) ["/foo/bar", "/foo/bar"]
    }
}

export def git-url-parsing [] {
    let cases = [
        [input, host, owner, group, repo];

        ["https://github.com/foo/bar",                  "github.com", "foo",        "", "bar"],
        ["https://github.com/foo/bar.git",              "github.com", "foo",        "", "bar"],
        ["https://github.com/foo/bar/tree/branch/file", "github.com", "foo",        "", "bar"],
        ["ssh://github.com/foo/bar",                    "github.com", "foo",        "", "bar"],
        ["git@github.com:foo/bar",                      "github.com", "foo",        "", "bar"],
        ["https://gitlab.com/foo/bar",                  "gitlab.com", "foo",        "", "bar"],
        ["git@gitlab.com:foo/bar",                      "gitlab.com", "foo",        "", "bar"],
        ["git@gitlab.com:foo/bar/baz/brr",              "gitlab.com", "foo", "bar/baz", "brr"],
        ["git://git.suckless.org/st",             "git.suckless.org",    "",        "",  "st"],
    ]

    for case in $cases {
        let expected = {
            host: $case.host, owner: $case.owner, group: $case.group, repo: $case.repo
        }
        assert equal ($case.input | parse-git-url) $expected
    }
}

export def fetch-and-push-urls [] {
    let cases = [
        [use_ssh, user_fetch, user_push, fetch_protocol, push_protocol];

        # - if user_fetch is not-empty: fetch_protocol is the same (same for push)
        # - if user_fetch is empty: fetch_protocol is `https` if not `use_ssh` (same for push)
        [false,   "",         "",        "https",        "https"],
        [false,   "",         "ssh",     "https",        "ssh"],
        [false,   "",         "https",   "https",        "https"],
        [false,   "",         "git",     "https",        "git"],
        [false,   "ssh",      "",        "ssh",          "https"],
        [false,   "ssh",      "ssh",     "ssh",          "ssh"],
        [false,   "ssh",      "https",   "ssh",          "https"],
        [false,   "ssh",      "git",     "ssh",          "git"],
        [false,   "git",      "",        "git",          "https"],
        [false,   "git",      "ssh",     "git",          "ssh"],
        [false,   "git",      "https",   "git",          "https"],
        [false,   "git",      "git",     "git",          "git"],
        [false,   "https",    "",        "https",        "https"],
        [false,   "https",    "ssh",     "https",        "ssh"],
        [false,   "https",    "https",   "https",        "https"],
        [false,   "https",    "git",     "https",        "git"],
        [true,    "",         "",        "ssh",          "ssh"],
        [true,    "",         "ssh",     "ssh",          "ssh"],
        [true,    "",         "https",   "ssh",          "https"],
        [true,    "",         "git",     "ssh",          "git"],
        [true,    "ssh",      "",        "ssh",          "ssh"],
        [true,    "ssh",      "ssh",     "ssh",          "ssh"],
        [true,    "ssh",      "https",   "ssh",          "https"],
        [true,    "ssh",      "git",     "ssh",          "git"],
        [true,    "https",    "",        "https",        "ssh"],
        [true,    "https",    "ssh",     "https",        "ssh"],
        [true,    "https",    "https",   "https",        "https"],
        [true,    "git",      "",        "git",          "ssh"],
        [true,    "git",      "ssh",     "git",          "ssh"],
        [true,    "git",      "https",   "git",          "https"],
        [true,    "git",      "git",     "git",          "git"],
    ]

    let repo = {host: "h", owner: "o", group: "", repo: "r"}
    let base_url = {
        scheme: null,
        host: $repo.host,
        path: ([$repo.owner, $repo.group, $repo.repo] | compact | path join | path sanitize)
    }

    for case in $cases {
        let actual = get-fetch-push-urls $repo $case.user_fetch $case.user_push $case.use_ssh
        let expected = {
            fetch: ($base_url | update scheme $case.fetch_protocol | url join)
            push: ($base_url | update scheme $case.push_protocol | url join)
        }
        assert equal $actual $expected $"input: ($case)"
    }
}

export def get-store-root [] {
    let cases = [
        [env,                                                    expected];

        [{GIT_REPOS_HOME: null,         XDG_DATA_HOME: null},    "~/.local/share/repos"],
        [{GIT_REPOS_HOME: "~/my_repos", XDG_DATA_HOME: null},    "~/my_repos"],
        [{GIT_REPOS_HOME: null,         XDG_DATA_HOME: "~/xdg"}, "~/xdg/repos"],
        [{GIT_REPOS_HOME: "~/my_repos", XDG_DATA_HOME: "~/xdg"}, "~/my_repos"],
    ]

    for case in $cases {
        let actual = with-env $case.env { get-repo-store-path }
        assert equal $actual ($case.expected | path expand | path sanitize)
    }
}

export def get-repo-cache [] {
    let cases = [
        [env,                                                      expected];

        [{GIT_REPOS_CACHE: null,         XDG_CACHE_HOME: null},    "~/.cache/nu-git-manager/cache.nuon"],
        [{GIT_REPOS_CACHE: "~/my_cache", XDG_CACHE_HOME: null},    "~/my_cache"],
        [{GIT_REPOS_CACHE: null,         XDG_CACHE_HOME: "~/xdg"}, "~/xdg/nu-git-manager/cache.nuon"],
        [{GIT_REPOS_CACHE: "~/my_cache", XDG_CACHE_HOME: "~/xdg"}, "~/my_cache"],
    ]

    for case in $cases {
        let actual = with-env $case.env { get-repo-store-cache-path }
        assert equal $actual ($case.expected | path expand | path sanitize)
    }
}

export def list-all-repos-in-store [] {
    let BASE = get-random-test-dir

    assert length (with-env {GIT_REPOS_HOME: $BASE} { list-repos-in-store }) 0

    if ($BASE | path exists) {
        rm --recursive --verbose --force $BASE
    }
    mkdir $BASE

    let store = [
        [is_bare, in_store, path];

        [false,   true,     "a/normal/"],
        [true,    true,     "a/bare/"],
        [false,   true,     "b/c/d/normal/"],
        [true,    true,     "b/c/d/bare/"],
        [false,   false,    "a/normal/b/nested/"],
        [false,   false,    "a/normal/.git/modules/foo/"],
        [false,   true,     "a/normal.but.more.complex/"],
    ]

    for repo in $store {
        if $repo.is_bare {
            ^git init --bare ($BASE | path join $repo.path)
        } else {
            ^git init ($BASE | path join $repo.path)
        }
    }

    # NOTE: remove the path to BASE so that the test output is easy to read
    let actual = with-env {GIT_REPOS_HOME: $BASE} { list-repos-in-store } | path remove-prefix $BASE
    # NOTE: `list-repos-in-store` does not add `/` at the end of the paths
    let expected = $store | where in_store | get path | path remove-trailing-path-sep

    # NOTE: need to sort the result to make sure the order of the `git init` does not influence the
    # results of the test
    assert equal ($actual | sort) ($expected | sort)

    rm --recursive --verbose --force $BASE
}

export def cache-manipulation [] {
    let CACHE_DIR = get-random-test-dir
    let CACHE = $CACHE_DIR | path join "cache"

    const BASE_REPO = {
        path: null,
        grafted: false,
        root_hash: "",
    }

    def "assert cache" [cache: list<any>]: nothing -> nothing {
        let actual = open-cache $CACHE | update path { path remove-prefix (pwd | path sanitize) }
        let expected = $cache
            | each {|it|
                $BASE_REPO | update path {
                    $it | path expand | path sanitize | path remove-prefix (pwd | path sanitize)
                }
            }
        assert equal $actual $expected
    }

    # NOTE: full error
    # ```
    # Error:   × cache_not_found:
    #   │ please run `gm update-cache` to create the cache
    # ```
    assert error { check-cache-file $CACHE }

    clean-cache-dir $CACHE
    assert ($CACHE | path dirname | path exists)

    [] | save-cache $CACHE
    assert cache []

    check-cache-file $CACHE

    add-to-cache $CACHE ($BASE_REPO | update path { "foo" | path expand | path sanitize })
    assert cache ["foo"]

    add-to-cache $CACHE ($BASE_REPO | update path { "bar" | path expand | path sanitize })
    assert cache ["bar", "foo"]

    add-to-cache $CACHE ($BASE_REPO | update path { "baz" | path expand | path sanitize })
    assert cache ["bar", "baz", "foo"]

    remove-from-cache $CACHE ("bar" | path expand | path sanitize)
    assert cache ["baz", "foo"]

    remove-from-cache $CACHE ("brr" | path expand | path sanitize)
    assert cache ["baz", "foo"]

    rm --recursive --verbose --force $CACHE_DIR
}

export def install-package [] {
    # FIXME: is there a way to not rely on hardcoded paths here?
    use ~/.local/share/nupm/modules/nupm

    with-env {NUPM_HOME: (get-random-test-dir)} {
        nupm install --no-confirm --path .

        assert (not ($env.NUPM_HOME | path join "scripts" | path exists))
        assert equal (ls ($env.NUPM_HOME | path join "modules") --short-names | get name) [nu-git-manager]

        rm --recursive --force --verbose $env.NUPM_HOME
    }
}

export def detect-grafting [] {
    let BASE = get-random-test-dir --no-sanitize
    if ($BASE | path exists) {
        rm --recursive --verbose --force $BASE
    }
    mkdir $BASE

    do {
        cd $BASE

        ^git init base

        [c1, c2, c3] | each {
            ^git -C base commit --allow-empty --no-verify --no-gpg-sign --message $in
        }

        ^git clone $"file://($BASE)/base" graft_1 --depth 1
        ^git clone $"file://($BASE)/base" graft_3 --depth 3
        ^git clone $"file://($BASE)/base" no_graft
    }

    assert not (is-grafted ($BASE | path join "base"))
    assert not (is-grafted ($BASE | path join "no_graft"))
    assert (is-grafted ($BASE | path join "graft_1"))
    assert (is-grafted ($BASE | path join "graft_3"))

    rm --recursive --force --verbose $BASE
}

export def root-commit [] {
    let repo = get-random-test-dir
    ^git clone https://github.com/amtoine/nu-git-manager $repo

    let actual = get-root-commit $repo
    let expected = "2ed2d875d80505d78423328c6b2a60522715fcdf"
    assert equal $actual $expected

    rm --recursive --force $repo
}

export def remote-listing [] {
    let repo = get-random-test-dir

    ^git init $repo
    ^git -C $repo remote add 0 0-default
    ^git -C $repo remote add 1 1-fetch
    ^git -C $repo remote set-url 1 --push 1-push
    ^git -C $repo remote add 2 2-fetch
    ^git -C $repo remote set-url 2 --push 2-push

    let expected = [
        [remote, fetch, push];

        ["0", "0-default", "0-default"],
        ["1", "1-fetch", "1-push"],
        ["2", "2-fetch", "2-push"],
    ]
    assert equal (list-remotes $repo) $expected

    rm --recursive --force $repo
}

export def store-cleaning [] {
    with-env {GIT_REPOS_HOME: (get-random-test-dir --no-sanitize)} {
        mkdir $env.GIT_REPOS_HOME
        # NOTE: this is to make sure the root of the test is not empty
        # we don't want the test to go remove empty directories outside...
        touch ($env.GIT_REPOS_HOME | path join ".lock")

        let empty_directories = [
            foo/bar/
            bar/
            baz/foo/bar/
        ]

        let actual = $empty_directories
            | each {|it|
                let path = $env.GIT_REPOS_HOME | path join $it | path sanitize

                print $"making `($path)`"
                mkdir $path

                $path
            }
            | clean-empty-directories-rec
            | path remove-prefix ($env.GIT_REPOS_HOME | path sanitize)
            | path remove-trailing-path-sep
        let expected = [
            "foo/bar",
            "bar",
            "baz/foo/bar",
            "foo",
            "baz/foo",
            "baz",
            ($env.GIT_REPOS_HOME | path sanitize),
        ]

        assert equal $actual $expected

        rm --recursive --verbose --force $env.GIT_REPOS_HOME
    }
}
