use std assert

use ../src/nu-git-manager/fs/path.nu ["path sanitize"]
use ../src/nu-git-manager/ *

def run-with-env [code: closure, --prepare-cache] {
    # NOTE: for the CI to run, the repos need to live inside `HOME`
    let TEST_ENV_BASE = $nu.home-path | path join ".local/share/nu-git-manager/tests" (random uuid)

    let TEST_ENV = {
        GIT_REPOS_HOME: ($TEST_ENV_BASE | path join "repos"),
        GIT_REPOS_CACHE: ($TEST_ENV_BASE | path join "repos.cache"),
    }

    if $prepare_cache {
        with-env $TEST_ENV { gm update-cache }
    }

    with-env $TEST_ENV $code

    rm --recursive --force --verbose $TEST_ENV_BASE
}

export def error-with-empty-store [] {
    run-with-env {
        # NOTE: the full error:
        # ```
        # Error:   × cache_not_found:
        #   │ please run `gm update-cache` to create the cache
        # ```
        assert error { gm list }
    }
}

export def cache-update [] {
    run-with-env {
        gm update-cache
        assert equal (gm list) []
    }
}

export def clone-invalid-depth [] {
    run-with-env --prepare-cache {
        # NOTE: full error
        # ```
        # Error:   × invalid_clone_depth
        #    ╭─[entry #5:1:1]
        #  1 │ gm clone https://github.com/amtoine/nu-git-manager --depth 0
        #    ·                                                            ┬
        #    ·                                                            ╰── clone depth should be strictly positive, found 0
        #    ╰────
        # ```
        assert error { gm clone https://github.com/amtoine/nu-git-manager --depth 0 }
    }
}

export def clone-depth-1 [] {
    run-with-env --prepare-cache {
        gm clone https://github.com/amtoine/nu-git-manager --depth 1
        assert (
            $env.GIT_REPOS_HOME
                | path join "github.com/amtoine/nu-git-manager"
                | path sanitize
                | path exists
        )
        assert equal (gm list) ["github.com/amtoine/nu-git-manager"]
    }
}

export def clone-twice [] {
    run-with-env --prepare-cache {
        gm clone https://github.com/amtoine/nu-git-manager --depth 1
        # NOTE: full error
        # ```
        # Error:   × repository_already_in_store
        #    ╭─[entry #2:1:1]
        #  1 │ gm clone https://github.com/amtoine/nu-git-manager
        #    ·          ────────────────────┬────────────────────
        #    ·                              ╰── this repository has already been cloned by gm
        #    ╰────
        # ```
        assert error { gm clone https://github.com/amtoine/nu-git-manager }
    }
}

export def clone-full-repo [] {
    run-with-env --prepare-cache {
        gm clone https://github.com/amtoine/nu-git-manager

        let repo = (
            $env.GIT_REPOS_HOME | path join "github.com/amtoine/nu-git-manager" | path sanitize
        )

        let actual = git -C $repo rev-list HEAD | lines | last
        let expected = "2ed2d875d80505d78423328c6b2a60522715fcdf"
        assert equal $actual $expected
    }
}

export def clone-bare [] {
    run-with-env --prepare-cache {
        gm clone https://github.com/amtoine/nu-git-manager --bare

        let repo = $env.GIT_REPOS_HOME | path join "github.com/amtoine/nu-git-manager"

        assert ($repo | path join "HEAD" | path sanitize | path exists)
    }
}

export def clone-set-remote [] {
    run-with-env --prepare-cache {
        let url = "https://github.com/amtoine/nu-git-manager"
        gm clone $url --remote test-remote-name --fetch https --push ssh

        let repo = (
            $env.GIT_REPOS_HOME | path join "github.com/amtoine/nu-git-manager" | path sanitize
        )

        let actual = git -C $repo remote --verbose
            | lines
            | parse --regex '(?<remote>[-_\w]+)\s+(?<url>.*) \((?<mode>\w+)\)'
            | str trim
        let expected = [
            [remote, url, mode];

            [test-remote-name, "https://github.com/amtoine/nu-git-manager", fetch],
            [test-remote-name, "ssh://github.com/amtoine/nu-git-manager", push]
        ]
        assert equal $actual $expected
    }
}

export def status [] {
    run-with-env {
        let BASE_STATUS = {
            root: {
                path: ($env.GIT_REPOS_HOME | path sanitize),
                exists: false
            },
            missing: null,
            cache: {
                path: ($env.GIT_REPOS_CACHE | path sanitize),
                exists: false
            },
            should_update_cache: false
        }

        let actual = gm status
        let expected = $BASE_STATUS | update should_update_cache true
        assert equal $actual $expected

        gm update-cache

        let actual = gm status
        let expected = $BASE_STATUS | update missing [] | update cache.exists true
        assert equal $actual $expected

        gm clone https://github.com/amtoine/nu-git-manager --depth 1

        let actual = gm status
        let expected = $BASE_STATUS
            | update missing []
            | update root.exists true
            | update cache.exists true
        assert equal $actual $expected

        let repo = (
            $env.GIT_REPOS_HOME | path join "github.com/amtoine/nu-git-manager" | path sanitize
        )
        rm $repo --recursive

        let actual = gm status
        let expected = $BASE_STATUS
            | update missing [$repo]
            | update root.exists true
            | update cache.exists true
            | update should_update_cache true
        assert equal $actual $expected
    }
}

export def remove [] {
    run-with-env --prepare-cache {
        gm clone https://github.com/amtoine/nu-git-manager --depth 1
        gm clone https://github.com/nushell/nupm --depth 1

        assert equal (gm list) ["github.com/amtoine/nu-git-manager", "github.com/nushell/nupm"]

        # NOTE: true error
        # ```
        # Error:   × no_matching_repository
        #    ╭─[entry #8:1:1]
        #  1 │ gm remove "foo"
        #    ·           ──┬──
        #    ·             ╰── no repository matching this in .../repos
        #    ╰────
        # ```
        assert error { gm remove "not-in-store" --no-confirm }

        # NOTE: true error
        # ```
        # Error:   × invalid_arguments_and_options:
        #   │ no search pattern will match all projects and `--no-confirm` won't remove multiple directories
        # ```
        assert error { gm remove --no-confirm }

        # NOTE: true error
        # ```
        # Error:   × invalid_arguments_and_options
        #    ╭─[entry #3:1:1]
        #  1 │ gm remove github --no-confirm
        #    ·           ───┬──
        #    ·              ╰── this pattern is too broad, multiple repos won't be removed by `--no-confirm`
        #    ╰────
        # ```
        assert error { gm remove "github" --no-confirm }

        gm remove "github.com/amtoine/nu-git-manager" --no-confirm
        assert not (
            $env.GIT_REPOS_HOME
            | path join "github.com/amtoine/nu-git-manager"
            | path sanitize
            | path exists
        )
        assert equal (gm list) ["github.com/nushell/nupm"]

        gm remove "github.com/nushell/nupm" --no-confirm
        assert not (
            $env.GIT_REPOS_HOME | path join "github.com/nushell/nupm" | path sanitize | path exists
        )
        assert equal (gm list) []
    }
}

export def store-cleaning [] {
    run-with-env --prepare-cache {
        gm clone https://github.com/amtoine/nu-git-manager --depth 1
        gm remove "github.com/amtoine/nu-git-manager" --no-confirm

        # NOTE: the root should not exist anymore because there was only one repo in it and it's
        # been cleaned
        assert not ($env.GIT_REPOS_HOME | path exists)
    }
}
