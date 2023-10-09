use std assert

use ../nu-git-manager/git/url.nu [parse-git-url, get-fetch-push-urls]

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
        [host, owner, group, repo, fetch_protocol, push_protocol, use_ssh, fetch_url, push_url];
        ["host", "foo", "", "bar", "", "", false, "https://host/foo/bar", "https://host/foo/bar"],
        ["host", "foo", "", "bar", "", "", false, "https://host/foo/bar", "https://host/foo/bar"],
    ]

    for case in $cases {
        let repo = {host: $case.host, owner: $case.owner, group: $case.group, repo: $case.repo}

        let actual = get-fetch-push-urls $repo $case.fetch_protocol $case.push_protocol $case.use_ssh
        let expected = {fetch: $case.fetch_url, push: $case.push_url}
        assert equal $actual $expected
    }
}
