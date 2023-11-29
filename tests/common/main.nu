export def run-with-env [code: closure, --prepare-cache] {
    let TEST_ENV_BASE = get-random-test-dir

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
