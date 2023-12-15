use ../../pkgs/nu-git-manager/nu-git-manager/fs/path.nu ["path sanitize"]

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
