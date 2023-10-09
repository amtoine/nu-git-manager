use ../nu-git-manager/git/url.nu parse-git-url

export def git-url-parsing [] {
    use std assert

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
