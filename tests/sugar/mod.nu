use std assert

use ../../src/nu-git-manager-sugar extra ["gm for-each"]

use ../common/import.nu ["assert imports"]
use ../common/main.nu [run-with-env]

const MODULE = "nu-git-manager-sugar"

module imports {
    export def main [] {
         assert imports $MODULE "" []
    }

    export def extra [] {
         assert imports $MODULE "extra" [ "gm for-each", "gm report" ]
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
            "gm repo remote list",
            "gm repo switch",
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

export use imports

# ignored: `nu_plugin_gstat` is required
def report [] {
    exit 1
}

export def for-each [] {
    use ../../src/nu-git-manager ["gm clone", "gm list", "gm status"]

    run-with-env --prepare-cache {
        gm clone https://github.com/amtoine/nu-git-manager --depth 1

        assert equal (gm for-each { pwd }) (gm list)
    }
}
