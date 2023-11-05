use std assert

use ../src/nu-git-manager/ *

def run-with-env [code: closure, --prepare-cache] {
    # NOTE: for the CI to run, the repos need to live inside `HOME`
    let TEST_ENV_BASE = ($nu.home-path | path join ".local/share/nu-git-manager/tests" (random uuid))

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

export def clone [] {
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

        gm clone https://github.com/amtoine/nu-git-manager --depth 1
        assert equal (gm list) ["github.com/amtoine/nu-git-manager"]

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

    run-with-env --prepare-cache {
        gm clone https://github.com/amtoine/nu-git-manager

        let repo = $env.GIT_REPOS_HOME | path join "github.com/amtoine/nu-git-manager"

        let actual = git -C $repo rev-list HEAD | lines | last
        let expected = "2ed2d875d80505d78423328c6b2a60522715fcdf"
        assert equal $actual $expected
    }
}

export def status [] {
    run-with-env {
        let BASE_STATUS = {
            root: {
                path: $env.GIT_REPOS_HOME,
                exists: false
            },
            missing: null,
            cache: {
                path: $env.GIT_REPOS_CACHE,
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

        rm ($env.GIT_REPOS_HOME | path join "github.com/amtoine/nu-git-manager") --recursive

        let actual = gm status
        let expected = $BASE_STATUS
            | update missing [($env.GIT_REPOS_HOME | path join "github.com/amtoine/nu-git-manager")]
            | update root.exists true
            | update cache.exists true
            | update should_update_cache true
        assert equal $actual $expected
    }
}
