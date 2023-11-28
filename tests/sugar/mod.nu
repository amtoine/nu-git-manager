use std assert

module imports {
    def "assert imports" [module: string, expected: list<string>] {
        let src = $"
            use ./src/nu-git-manager-sugar/ ($module) *
            scope commands | get name | where \($it | str starts-with 'gm '\) | to nuon
        "

        let actual = ^$nu.current-exe --no-config-file --commands $src | from nuon
        assert equal $actual $expected
    }

    export def main [] {
        assert imports "" []
    }

    export def extra [] {
        assert imports "extra" [ "gm report" ]
    }

    export def git [] {
        assert imports "git" [
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
    }

    export def github [] {
        assert imports "github" [
            "gm gh pr checkout",
            "gm gh query-api",
            "gm gh query-releases",
            "gm gh query-user",
        ]
    }
}

export use imports

# ignored: `nu_plugin_gstat` is required
def report [] {
    exit 1
}
