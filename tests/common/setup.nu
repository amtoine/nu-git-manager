# NOTE: for the CI to run, the repos need to live inside `HOME`
export def get-random-test-dir [] {
    $nu.home-path | path join ".local/share/nu-git-manager/tests" (random uuid)
}
