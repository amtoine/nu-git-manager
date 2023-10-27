use std assert

use ../nu-git-manager/git/url.nu [parse-git-url, get-fetch-push-urls]
use ../nu-git-manager/fs/store.nu [get-repo-store-path, list-repos-in-store]
use ../nu-git-manager/fs/cache.nu [
    get-repo-store-cache-path, check-cache-file, add-to-cache, remove-from-cache, open-cache,
    save-cache, make-cache
]
use ../nu-git-manager/fs/path.nu "path sanitize"

export def path-sanitization [] {
    assert equal ('\foo\bar' | path sanitize) "/foo/bar"
}

export def git-url-parsing [] {
    let cases = [
        [input, host, owner, group, repo];

        ["https://github.com/foo/bar",                  "github.com", "foo", null,      "bar"],
        ["https://github.com/foo/bar.git",              "github.com", "foo", null,      "bar"],
        ["https://github.com/foo/bar/tree/branch/file", "github.com", "foo", null,      "bar"],
        ["ssh://github.com/foo/bar",                    "github.com", "foo", null,      "bar"],
        ["git@github.com:foo/bar",                      "github.com", "foo", null,      "bar"],
        ["https://gitlab.com/foo/bar",                  "gitlab.com", "foo", null,      "bar"],
        ["git@gitlab.com:foo/bar",                      "gitlab.com", "foo", null,      "bar"],
        ["git@gitlab.com:foo/bar/baz/brr",              "gitlab.com", "foo", "bar/baz", "brr"],
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
        [false,   "ssh",      "",        "ssh",          "https"],
        [false,   "ssh",      "ssh",     "ssh",          "ssh"],
        [false,   "ssh",      "https",   "ssh",          "https"],
        [false,   "https",    "",        "https",        "https"],
        [false,   "https",    "ssh",     "https",        "ssh"],
        [false,   "https",    "https",   "https",        "https"],
        [true,    "",         "",        "ssh",          "ssh"],
        [true,    "",         "ssh",     "ssh",          "ssh"],
        [true,    "",         "https",   "ssh",          "https"],
        [true,    "ssh",      "",        "ssh",          "ssh"],
        [true,    "ssh",      "ssh",     "ssh",          "ssh"],
        [true,    "ssh",      "https",   "ssh",          "https"],
        [true,    "https",    "",        "https",        "ssh"],
        [true,    "https",    "ssh",     "https",        "ssh"],
        [true,    "https",    "https",   "https",        "https"],
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
    # NOTE: `$BASE` is a constant, hence the capitalized name, but `path sanitize` is not a
    # parse-time command
    let BASE = (
        $nu.temp-path | path join "nu-git-manager/tests/list-all-repos-in-store" | path sanitize
    )

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
            git init --bare ($BASE | path join $repo.path)
        } else {
            git init ($BASE | path join $repo.path)
        }
    }

    # NOTE: remove the path to BASE so that the test output is easy to read
    let actual = with-env {GIT_REPOS_HOME: $BASE} { list-repos-in-store } | each {
        str replace $BASE '' | str trim --left --char "/"
    }
    let expected = $store | where in_store | get path | each {
        # NOTE: `list-repos-in-store` does not add `/` at the end of the paths
        str trim --right --char "/"
    }

    # NOTE: need to sort the result to make sure the order of the `git init` does not influence the
    # results of the test
    assert equal ($actual | sort) ($expected | sort)

    rm --recursive --verbose --force $BASE
}

export def cache-manipulation [] {
    let CACHE = (
        $nu.temp-path | path join "nu-git-manager/tests" (random uuid) | path sanitize
    )
    let CACHE_DIR = $CACHE | path dirname

    def "assert cache" [cache: list<string>]: nothing -> nothing {
        assert equal (open-cache $CACHE) ($cache | path expand | each { path sanitize })
    }

    assert error { check-cache-file $CACHE }

    make-cache $CACHE
    assert ($CACHE | path dirname | path exists)

    [] | save-cache $CACHE
    assert cache []

    add-to-cache $CACHE "foo"
    assert cache ["foo"]

    add-to-cache $CACHE "bar"
    assert cache ["bar", "foo"]

    add-to-cache $CACHE "baz"
    assert cache ["bar", "baz", "foo"]

    remove-from-cache $CACHE "bar"
    assert cache ["baz", "foo"]

    remove-from-cache $CACHE "brr"
    assert cache ["baz", "foo"]

    rm --recursive --verbose --force $CACHE_DIR
}
