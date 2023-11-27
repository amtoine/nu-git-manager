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
    code?: closure, # the code to run in the environment (required without `--interactive`)
    --clean, # raise this to clean the environment before running the code
    --interactive, # run interactively
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

    if $interactive {
        const CONFIG_FILE = ($GM_ENV.GIT_REPOS_HOME | path dirname | path join "config.nu")
        const ENV_FILE = ($GM_ENV.GIT_REPOS_HOME | path dirname | path join "env.nu")

        "$env.config = {show_banner: false}" | save --force $CONFIG_FILE
        "" | save --force $ENV_FILE

        with-env ($GM_ENV | merge {PROMPT_COMMAND: "NU-GIT-MANAGER"}) {
            ^$nu.current-exe [
                --env-config $ENV_FILE
                --config $CONFIG_FILE
                --execute "use ./src/nu-git-manager *"
            ]
        }
    } else {
        if $code == null {
            error make --unspanned {
                msg: "`toolkit.nu run requires a `$code` when `--interactive` is not used"
            }
        }
        with-env $GM_ENV $code
    }
}

# TODO: documentation
export def get-ignored-tests []: nothing -> table<file: string, test: string, reason: string> {
    ^rg '^# ignored: ' tests/ -A 1
        | lines
        | split list "--"
        | each {|it|
            let reason = $it.0 | parse "{file}:# ignored: {reason}" | get reason.0
            $it.1 | parse "{file}-def {test} [{rest}" | reject rest | insert reason $reason | first
        }
}
