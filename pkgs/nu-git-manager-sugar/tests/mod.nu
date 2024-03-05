use std assert

use ../../../tests/common/import.nu ["assert imports"]
use ../../../tests/common/setup.nu [get-random-test-dir]

export module git.nu

const MODULE = "nu-git-manager-sugar"

export module imports {
    export def extra [] {
        assert imports $MODULE "extra *" [ "gm report" ]
    }

    export def git [] {
        assert imports $MODULE "git *" [
            "gm repo bisect",
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
        assert imports $MODULE "github *" [
            "gm gh pr checkout",
            "gm gh query-api",
            "gm gh query-releases",
            "gm gh query-user",
        ]
    }

    export def gm [] {
        assert imports $MODULE "gm" [
            "gm cfg",
            "gm cfg edit",
            "gm gh pr checkout",
            "gm gh query-api",
            "gm gh query-releases",
            "gm gh query-user",
            "gm repo bisect",
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
            "gm report",
        ]
    }

    export def repo [] {
        assert imports $MODULE "gm repo" [
            "repo bisect",
            "repo branch interactive-delete",
            "repo branch wipe",
            "repo branches",
            "repo compare",
            "repo fetch branch",
            "repo get commit",
            "repo goto root",
            "repo is-ancestor",
            "repo ls",
            "repo query",
            "repo remote list",
            "repo switch",
        ]
    }

    export def gh [] {
        assert imports $MODULE "gm gh" [
            "gh pr checkout",
            "gh query-api",
            "gh query-releases",
            "gh query-user",
        ]
    }

    export def cfg [] {
        assert imports $MODULE "gm cfg" [
            "cfg",
            "cfg edit",
        ]
    }
}

# ignored: `nu_plugin_gstat` is required
def report [] {
    exit 1
}

export def install-package [] {
    # FIXME: is there a way to not rely on hardcoded paths here?
    use ~/.local/share/nupm/modules/nupm

    with-env {NUPM_HOME: (get-random-test-dir)} {
        nupm install --no-confirm --path .

        assert (not ($env.NUPM_HOME | path join "scripts" | path exists))
        assert equal (ls ($env.NUPM_HOME | path join "modules") --short-names | get name) [nu-git-manager-sugar]

        rm --recursive --force --verbose $env.NUPM_HOME
    }
}
