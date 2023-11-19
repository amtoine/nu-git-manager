use ../../src/nu-git-manager/fs/path.nu ["path sanitize"]

# return the path to a random test directory
#
# NOTE: for the CI to run, the repos need to live inside `HOME`
#
# /!\ the returned path will be sanitized /!\
export def get-random-test-dir []: nothing -> path {
    $nu.home-path | path join ".local/share/nu-git-manager/tests" (random uuid) | path sanitize
}
