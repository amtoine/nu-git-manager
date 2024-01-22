use ../../pkgs/nu-git-manager/nu-git-manager/fs path ["path sanitize"]
use ../../pkgs/nu-git-manager/nu-git-manager/ [ "gm update-cache" ]

# return the path to a random test directory
#
# NOTE: for the CI to run, the repos need to live inside `HOME`
#
# /!\ the returned path will be sanitized, unless `--no-sanitize` is used /!\
export def get-random-test-dir [--no-sanitize]: nothing -> path {
    let test_dir = $nu.home-path | path join ".local/share/nu-git-manager/tests" (random uuid)

    if not $no_sanitize {
        $test_dir | path sanitize
    } else {
        $test_dir
    }
}

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
