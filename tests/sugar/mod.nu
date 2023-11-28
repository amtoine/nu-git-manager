use std assert

module imports {
    export def main [] {
        let src = "
            use ./src/nu-git-manager-sugar/ *
            scope commands | get name | where ($it | str starts-with 'gm ') | to nuon
        "

        let actual = ^$nu.current-exe --no-config-file --commands $src | from nuon
        let expected = []

        assert equal $actual $expected
    }

    export def git [] {
        let src = "
            use ./src/nu-git-manager-sugar/ git *
            scope commands | get name | where ($it | str starts-with 'gm ') | to nuon
        "

        let actual = ^$nu.current-exe --no-config-file --commands $src | from nuon
        let expected = [
            "gm repo branch interactive-delete",
            "gm repo branch wipe",
            "gm repo branches",
            "gm repo compare",
            "gm repo fetch branch",
            "gm repo get commit",
            "gm repo goto root",
            "gm repo is-ancestor",
            "gm repo ls",
            "gm repo remote list",
            "gm repo switch",
        ]

        assert equal $actual $expected
    }
}

export use imports

# ignored: `nu_plugin_gstat` is required
def report [] {
    exit 1
}
