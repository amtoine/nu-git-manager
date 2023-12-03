use ../git/lib/lib.nu [get-revision, git-action]

const DEFAULT_PROMPT_INDICATORS = {
    plain: "> ",
    vi: {insert: ": ", normal: "> "}
}

# TODO: write a test
def simplify-path []: path -> string {
    str replace $nu.home-path "~" | str replace --regex '^/' "!/"
}

def color [color]: string -> string {
    $"(ansi $color)($in)(ansi reset)"
}

# TODO: write a test
def get-left-prompt [duration_threshold: duration]: nothing -> string {
    let is_git_repo = not (
        do --ignore-errors { ^git rev-parse --is-inside-work-tree } | is-empty
    )

    let pwd = if $is_git_repo {
        let repo_root = (
            ^git rev-parse --show-toplevel
        )
        let repo = $repo_root | path basename | color "magenta_bold"
        let sub_dir = pwd
            | str replace $repo_root ''
            | str trim --char (char path_sep)
            | simplify-path

        if $sub_dir != "" {
            [$repo, ($sub_dir | color "magenta_dimmed")]
                | str join (char path_sep | color "magenta_dimmed")
        } else {
            $repo
        }
    } else {
        pwd | simplify-path | color "green"
    }

    let git_branch_segment = if $is_git_repo {
        let revision = get-revision --short-hash true
        let pretty_branch_tokens = match $revision.type {
            "branch" => [
                ($revision.name | color {fg: "yellow", attr: "ub"}),
                ($revision.hash | color "yellow_dimmed")
            ],
            "tag" => [
                ($revision.name | color {fg: "blue", attr: "ub"}),
                ($revision.hash | color "blue_dimmed")
            ],
            "detached" => ["_", ($revision.hash | color "default_dimmed")]
        }

        $"\(($pretty_branch_tokens | str join ":")\)"
    } else {
        null
    }

    let git_action_segment = if $is_git_repo {
        let action = git-action
        if $action != null {
            $"\(($action)\)"
        } else {
            null
        }
    } else {
        null
    }

    let admin_segment = if (is-admin) {
        "!!" | color "red_bold"
    } else {
        null
    }

    let command_failed_segment = if $env.LAST_EXIT_CODE != 0 {
        $env.LAST_EXIT_CODE | color "red_bold"
    } else {
        null
    }

    let cmd_duration = $env.CMD_DURATION_MS | into int | $in * 1ms
    let duration_segment = if $cmd_duration > $duration_threshold {
        $cmd_duration | color "light_yellow"
    } else {
        null
    }

    let login_segment = if $nu.is-login {
        "l" | color "cyan"
    } else {
        ""
    }

    let segments = [
        $admin_segment,
        $pwd,
        $git_branch_segment,
        $git_action_segment,
        $duration_segment,
        $command_failed_segment,
        $login_segment,
    ]

    $segments | compact | str join " "
}

# setup the Git prompt of NGM
#
# the different sections of the prompt are the following, in order and separated by a single space:
# - "admin_segment": shows if you are an admin of the session
# - "pwd": shows the current working directory, in long form outside of a repo or with only the
#     basename if inside a Git repo
# - "git_branch_segment": if inside a Git repo, will show the current branch, the tag or the
#     detached revision
# - "git_action_segment": if inside a Git repo and performing a Git action, such as a MERGE or a
#     REBASE, the prompt will show the stage of the action
# - "duration_segment": if the last command took longer than the `--duration-threshold`, the prompt
#     will show the exact duration
# - "command_failed_segment": if the last command failed, the exit code will be shown
# - "login_segment": shows if you are in a login session
#
# # Examples
#     setup the prompt with 10sec of command duration and `> ` as the Vi indicator
#     > export-env {
#           use nu-git-manager-sugar git-prompt setup
#           setup --duration-threshold 10sec --indicators {
#               vi: {
#                   insert: "> "
#                   normal: "> "
#               }
#           }
#       }
export def --env setup [
    --indicators = $DEFAULT_PROMPT_INDICATORS,
    --duration-threshold: duration = 1sec  # the threshold above which the command duration is shown
] {
    $env.PROMPT_COMMAND = { get-left-prompt $duration_threshold }
    $env.PROMPT_COMMAND_RIGHT = ""

    let indicators = $DEFAULT_PROMPT_INDICATORS | merge $indicators
    $env.PROMPT_INDICATOR = $indicators.plain
    $env.PROMPT_INDICATOR_VI_INSERT = $indicators.vi.insert
    $env.PROMPT_INDICATOR_VI_NORMAL = $indicators.vi.normal
}
