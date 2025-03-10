use std repeat
use std log

# NOTE: this will likely get replaced by Nupm workspaces in the future
def list-modules-of-workspace []: nothing -> list<string> {
    open nupm.nuon
        | get workspace
        | each { path join "nupm.nuon" }
        | wrap name
        | insert pkg {|it| open $it.name | get name }
        | each {|it| $it.name | path dirname | path join $it.pkg }
}

# run the tests of the `nu-git-manager` package
#
# > **Important**  
# > the `toolkit test` command requires [Nupm](https://github.com/nushell/nupm) to be installed
export def "test" [
    pattern?: string = "" # the pattern a test name should match to run
    --verbose # show the output of each tests
]: nothing -> nothing {
    let args = if $verbose {
        "--show-stdout"
    } else {
        ""
    }

    # NOTE: this is for the CI to pass without installing Nupm
    ^$nu.current-exe --env-config $nu.env-path --commands $"
        use nupm
        (list-modules-of-workspace) | each {|pkg|
            nupm test ($pattern) ($args) --dir \($pkg | path dirname\)
        }

        null
    "
}

# install `nu-git-manager` with Nupm
export def "install" []: nothing -> nothing {
    # NOTE: this is for the CI to pass without installing Nupm
    ^$nu.current-exe --env-config $nu.env-path --commands $"
        use nupm
        (list-modules-of-workspace) | each {|pkg|
            nupm install --force --path \($pkg | path dirname\)
        }

        null
    "

    let mod = $env.NUPM_HOME | path join "modules" "nu-git-manager" "mod.nu"
    let v = (open pkgs/nu-git-manager/nupm.nuon).version
    let n = ^git describe | parse "{v}-{n}-{r}" | into record | get n? | default 0
    let version_cmd = [
         "# see the version of NGM that is currently installed",
         "#",
         "# # Examples",
         "# ```nushell",
         "# # get the version of NGM",
         "# gm version",
         "# ```",
         "export def \"gm version\" []: nothing -> record<version: string, branch: string, commit: string, date: datetime> {",
         "    {",
        $"        version: \"($v)+($n)\",",
        $"        branch: \"(^git branch --show-current)\",",
        $"        commit: \"(^git rev-parse HEAD)\",",
        $"        date: \((date now | to nuon)\),",
         "    }",
         "}",
    ]

    "\n" | save --append $mod
    $version_cmd | str join "\n" | save --append $mod

    null
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

    if $clean { do {
        if $personal {
            let prompt = $"You are about to (ansi red_bold)clean your personal store of repositories(ansi reset) :o (ansi yellow_bold)Are you sure?(ansi reset)"
            match (["no", "yes"] | input list $prompt) {
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
    } }

    if $interactive {
        let config_file = $GM_ENV.GIT_REPOS_HOME | path dirname | path join "config.nu"
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
            $sugar | each { $"use ./pkgs/nu-git-manager-sugar/nu-git-manager-sugar ($in) *" }
        } else {
            []
        }
        let imports = $sugar_imports
            | prepend "use ./pkgs/nu-git-manager/nu-git-manager *"
            | str join "\n"

        let nu_args = [
            --env-config $env_file
            --config $config_file
        ]

        let res = do { ^$nu.current-exe ...$nu_args --commands $imports } | complete
        if $res.exit_code != 0 {
            print $res.stderr
            error make --unspanned {
                msg: $"`--sugar` \(($sugar)\) contains modules that are not part of `nu-git-manager-sugar`"
            }
        }

        with-env ($gm_env | merge {PROMPT_COMMAND: "NU-GIT-MANAGER"}) {
            ^$nu.current-exe ...$nu_args --execute $imports
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

def run-nu [code: string]: nothing -> any {
    ^$nu.current-exe --no-config-file --commands ($code ++ " | to nuon") | from nuon
}

def rg [root: path, pattern: string]: nothing -> table<file: path, line: int, match: string> {
    ls ($root | path join "**" "*" | into glob)
        | where type == file
        | get name
        | wrap file
        | insert match {|it|
            open $it.file --raw
                | lines
                | enumerate
                | rename line match
                | update line { $in + 1 }
                | find --regex $pattern
        }
        | where not ($it.match | is-empty)
        | flatten --all
}

def document-command [
    args: record<module_name: string, full_module_name_with_leading_path: string, root: path>
]: string -> string {
    let command = $in
    log debug $"documenting command `($command)`"

    let command_file = $command
        | str replace --all ' ' '-'
        | path parse
        | update extension md
        | path join

    let help = run-nu $"
        use ($args.root)/($args.full_module_name_with_leading_path) '($command)'
        scope commands | where name == '($command)' | into record
    "

    let signatures = $help.signatures | transpose | get column1

    let res = rg $args.root $'export def.*"($command)"'
    let res = match ($res | length) {
        0 => { error make --unspanned { msg: $"no match for command `($command)`" } },
        1 => { $res.0 | into record },
        _ => { error make --unspanned { msg: $"too many matches for command `($command)`" } },
    }

    let source = $"https://github.com/amtoine/nu-git-manager/blob/main/($res.file | path relative-to $args.root)#L($res.line)"

    let page = [
        $"# `($command)` from `($args.module_name)` \(see [source]\(($source)\)\)",
        $help.usage,
        "",
        $help.extra_usage,
        "",
        "## Parameters",
        (
            $signatures.0
                | where parameter_type not-in ["input", "output"]
                | each {|p|
                    let opt = if $p.is_optional { "?" } else { "" }
                    let cmp = if $p.custom_completion != "" {
                        $"@($p.custom_completion)"
                    } else {
                        ""
                    }
                    let type = $p.syntax_shape
                        | default ""
                        | str replace --regex '^completable<(.*)>' '$1'
                    let default = if $p.parameter_default != null {
                        $" = `($p.parameter_default)`"
                    } else {
                        ""
                    }
                    let short = if $p.short_flag != null { $" \(`-($p.short_flag)`\)" } else { "" }
                    let name = $p.parameter_name
                    let desc = $p.description

                    match $p.parameter_type {
                        "positional" => $"- `($name)($opt)` <`($type)($cmp)`>($default): ($desc)",
                        "switch" => $"- `--($name)`($short) <`bool($cmp)`>($default): ($desc)",
                        "named" => $"- `--($name)`($short) <`($type)($cmp)`>($default): ($desc)",
                    }
                }
                | to text
        ),
        "",
        $"## Signatures",
        (
            $signatures
                | each {
                    where parameter_type in ["input", "output"]
                        | select parameter_type syntax_shape
                        | transpose --header-row
                }
                | flatten
                | update input { $"`($in)`" }
                | update output { $"`($in)`" }
                | to md --pretty
        ),
    ]

    $page | flatten | str join "\n" | save --force --append $command_file

    $command_file
}

# /!\ will save each command encountered to the main index file as a side effect
def document-module [
    module_path: string, --root: path, --documentation-dir: path
]: nothing -> nothing {
    let main_index = $root | path join $documentation_dir "index.md"

    def aux [
        full_module_name_with_leading_path: string,
        depth?: int = 0,
    ]: record<name: string, commands: list<string>, submodules: list<record>> -> nothing {
        let module = $in
        log debug $"documenting module `($module.name)`"

        mkdir ($module.name | path basename)
        cd ($module.name | path basename)

        let module_name = (
            ($full_module_name_with_leading_path | split row ' ' | get 0 | path basename)
            + ' '
            + ($full_module_name_with_leading_path | split row ' ' | skip 1 | str join ' ')
        )
            | str trim

        let commands = if ($module.commands.name | is-empty) {
            "no commands"
        } else {
            $module.commands.name | each {|command|
                let command_file = $command | document-command {
                    module_name: $module_name,
                    full_module_name_with_leading_path: $full_module_name_with_leading_path,
                    root: $root,
                }

                let full_command_file = (
                    $module_name | str replace --all ' ' '/' | path join $command_file
                )
                $"- [`($command)`]\(($full_command_file)\)\n" | save --force --append $main_index

                $"- [`($command)`]\(($command_file)\)"
            }
        }

        let submodules = if ($module.submodules | is-empty) {
            ""
        } else {
            $module.submodules | each {|submodule|
                $"- [`($submodule.name)`]\(($submodule.name)/index.md\)"
            }
        }

        let page = [
            $"# Module `($module_name)`",
            "## Description",
            $module.usage,
            "",
            $module.extra_usage,
            "",
            "## Commands",
            $commands,
        ]
        let page = if ($submodules | is-empty) {
            $page
        } else {
            $page | append ["", "## Submodules", $submodules]
        }

        $page | flatten | str join "\n" | save --force index.md


        for submodule in $module.submodules {
            $submodule | aux ($full_module_name_with_leading_path + ' ' + $submodule.name) ($depth + 1)
        }
    }

    let module = run-nu $"
        use ($root)/($module_path)
        scope modules | where name == ($module_path | path basename) | into record
    "

    $module | aux $module_path
}

export def doc [--documentation-dir: path = "./docs/"] {
    let modules = list-modules-of-workspace

    let documentation_dir = $documentation_dir | path expand

    rm --force --recursive $documentation_dir
    mkdir $documentation_dir
    cd $documentation_dir

    "## Modules\n" | save --force --append index.md
    for module in ($modules | path basename) {
        $"- [`($module)`]\(./($module)/index.md\)\n" | save --force --append index.md
    }

    "\n" | save --force --append index.md
    "## Commands\n" | save --force --append index.md
    for module in $modules {
        document-module $module --root (pwd | path dirname) --documentation-dir $documentation_dir
    }
}

# pull down the list of `refactor` PRs that have been merged and ignore the revisions
#
# > inspired by [*How to exclude commits from git blame*](https://www.stefanjudis.com/today-i-learned/how-to-exclude-commits-from-git-blame/)
export def "update-ignored-revisions" [] {
    const FILE = ".git-blame-ignore-revs"

    let commits = ^gh -R amtoine/nu-git-manager pr list [
            --state merged
            --label refactor
            --json "number,title,mergeCommit,url"
        ]
        | from json
        | select number title mergeCommit.oid url
        | rename --column {mergeCommit_oid: "commit"}
        | reverse
        | each { $"# ($in.title): [#($in.number)]\(($in.url)\)\n($in.commit)" }
        | str join "\n\n"

    [
        "# Run this command to always ignore formatting commits in `git blame`",
        "# ```",
       $"# git config blame.ignoreRevsFile ($FILE)",
        "# ```",
        $commits
    ] | str join "\n" | save --force $FILE

    print $"ignored revisions stored in `($FILE)`"
}
