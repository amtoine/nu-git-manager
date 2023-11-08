# run the tests of the `nu-git-manager` package
#
# > **Important**  
# > the `toolkit test` command requires [Nupm](https://github.com/nushell/nupm) to be installed
export def "test" [
    pattern?: string = "" # the pattern a test name should match to run
    --verbose # show the output of each tests
] {
    use nupm

    if $verbose {
        nupm test $pattern --show-stdout
    } else {
        nupm test $pattern
    }
}

# install `nu-git-manager` with Nupm
export def "install" [] {
    use nupm
    nupm install --force --path (^git rev-parse --show-toplevel)
}

# run some code inside an isolated environment
#
# Examples
#     run some code
#     > toolkit run { gm list }
#
#     get the status of the environment
#     > toolkit run { gm status } | table --expand
#
#     clean the environment before running the code
#     > toolkit run --clean { gm clone https://github.com/amtoine/nu-git-manager --depth 1 }
export def "run" [
    code: closure, # the code to run in the environment
    --clean, # raise this to clean the environment before running the code
] {
    const GM_ENV = {
        GIT_REPOS_HOME: ($nu.temp-path | path join "nu-git-manager/repos/"),
        GIT_REPOS_CACHE: ($nu.temp-path | path join "nu-git-manager/repos.cache"),
    }

    if $clean {
        with-env $GM_ENV {
            gm status | select root.path cache.path | values | each {
                if ($in | path exists) {
                    rm --recursive --force --verbose $in
                }
            }
        }
    }

    with-env $GM_ENV $code
}
