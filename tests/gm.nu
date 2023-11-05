use std assert

use ../src/nu-git-manager/ *

def run-with-env [code: closure, --prepare-cache] {
    # NOTE: for the CI to run, the repos need to live inside `HOME`
    let TEST_ENV_BASE = ($nu.home-path | path join ".local/share/nu-git-manager/tests" (random uuid))

    let TEST_ENV = {
        GIT_REPOS_HOME: ($TEST_ENV_BASE | path join "repos/"),
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
        gm clone https://github.com/amtoine/nu-git-manager --depth 1
        assert equal (gm list) ["github.com/amtoine/nu-git-manager"]
    }
}
