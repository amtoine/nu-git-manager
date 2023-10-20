use std assert

use ../nu-git-manager/git/url.nu [parse-git-url, get-fetch-push-urls]
use ../nu-git-manager/fs/store.nu get-repo-store-path
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
