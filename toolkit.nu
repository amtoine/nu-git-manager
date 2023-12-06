# run the tests of the `nu-git-manager` package
#
# > **Important**  
# > the `toolkit test` command requires [Nupm](https://github.com/nushell/nupm) to be installed
export def "test" [
    pattern?: string = "" # the pattern a test name should match to run
    --verbose # show the output of each tests
]: nothing -> nothing {
    use nupm

    if $verbose {
        nupm test $pattern --show-stdout
    } else {
        nupm test $pattern
    }
}

# install `nu-git-manager` with Nupm
export def "install" []: nothing -> nothing {
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
#
#     run gm commands in an interactive shell
#     > toolkit run --interactive
#
#     include more sugar commands in the interactive shell, e.g. Git and extra gm
#     > toolkit run --interactive --sugar ["git", "extra"]
export def "run" [
    code?: closure, # the code to run in the environment (required without `--interactive`)
    --clean, # raise this to clean the environment before running the code
    --interactive, # run interactively
    --personal, # run in the personal store
    --sugar: list<string>, # additional `sugar` modules to import
]: nothing -> nothing {
    const GM_ENV = {
        GIT_REPOS_HOME: ($nu.temp-path | path join "nu-git-manager/repos/"),
        GIT_REPOS_CACHE: ($nu.temp-path | path join "nu-git-manager/repos.cache"),
    }

    let gm_env = if $personal {
        {}
    } else {
        $GM_ENV
    }

    if $clean {
        if $personal {
            let prompt = $"You are about to (ansi red_bold)clean your personal store of repositories(ansi reset) :o (ansi yellow_bold)Are you sure?(ansi reset)"
            match (["no", "yes"] | input  list $prompt) {
                null | "no" => { return },
                "yes" => {},
            }
        }
        with-env $gm_env {
            gm status | select root.path cache.path | values | each {
                if ($in | path exists) {
                    rm --recursive --force --verbose $in
                }
            }
        }
    }

    if $interactive {
        let config_file = $env.GIT_REPOS_HOME | path dirname | path join "config.nu"
        let env_file = if $personal {
            $nu.env-path
        } else {
            $gm_env.GIT_REPOS_HOME | path dirname | path join "env.nu"
        }

        mkdir ($config_file | path dirname)

        "$env.config = {show_banner: false}" | save --force $config_file
        if not $personal {
            "" | save --force $env_file
        }

        let sugar_imports = if $sugar != null {
            $sugar | each { $"use ./src/nu-git-manager-sugar ($in) *" }
        } else {
            []
        }
        let imports = $sugar_imports | prepend "use ./src/nu-git-manager *" | str join "\n"

        let nu_args = [
            --env-config $env_file
            --config $config_file
        ]

        let res = do { ^$nu.current-exe $nu_args --commands $imports } | complete
        if $res.exit_code != 0 {
            print $res.stderr
            error make --unspanned {
                msg: $"`--sugar` \(($sugar)\) contains modules that are not part of `nu-git-manager-sugar`"
            }
        }

        with-env ($gm_env | merge {PROMPT_COMMAND: "NU-GIT-MANAGER"}) {
            ^$nu.current-exe $nu_args --execute $imports
        }
    } else {
        if $code == null {
            error make --unspanned {
                msg: "`toolkit.nu run requires a `$code` when `--interactive` is not used"
            }
        }
        with-env $gm_env $code
    }
}

# will give a report about all the tests that are currently ignored
export def get-ignored-tests []: nothing -> table<file: string, test: string, reason: string> {
    ^rg '^# ignored: ' tests/ -A 1
        | lines
        | split list "--"
        | each {|it|
            let reason = $it.0 | parse "{file}:# ignored: {reason}" | get reason.0
            $it.1 | parse "{file}-def {test} [{rest}" | reject rest | insert reason $reason | first
        }
}
