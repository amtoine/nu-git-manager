use std assert

use ../common/import.nu ["assert imports"]

const MODULE = "nu-git-manager-sugar"

export module imports {
    export def extra [] {
        assert imports $MODULE "extra" [ "gm report" ]
    }

    export def git [] {
        assert imports $MODULE "git" [
            "gm repo branch interactive-delete",
            "gm repo branch wipe",
            "gm repo branches",
            "gm repo compare",
            "gm repo fetch branch",
            "gm repo get commit",
            "gm repo goto root",
            "gm repo is-ancestor",
            "gm repo ls",
            "gm repo query",
            "gm repo remote list",
            "gm repo switch",
            "prompt setup",
        ]
    }

    export def github [] {
        assert imports $MODULE "github" [
            "gm gh pr checkout",
            "gm gh query-api",
            "gm gh query-releases",
            "gm gh query-user",
        ]
    }
}

# ignored: `nu_plugin_gstat` is required
def report [] {
    exit 1
}
