use std assert

module imports {
    export def git [] {
        let src = "
            use ./src/nu-git-manager-sugar/ git *
            scope commands | get name | where ($it | str starts-with 'gm ') | to nuon
        "

        let actual = ^$nu.current-exe --no-config-file --commands $src | from nuon
        let expected = [
            "gm repo branches",
            "gm repo get commit",
            "gm repo goto root",
            "gm repo is-ancestor",
            "gm repo remote list",
        ]

        assert equal $actual $expected
    }
}

export use imports

# ignored: `nu_plugin_gstat` is required
def report [] {
    exit 1
}
