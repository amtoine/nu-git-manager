use git [get-revision, git-action, get-status]
use style.nu [color, simplify-path]

# /!\ the PWD will be sanitized
export def get-left-prompt [duration_threshold: duration]: nothing -> string {
    let is_git_repo = not (
        do --ignore-errors { ^git rev-parse --is-inside-work-tree }
            | complete
            | get stdout
            | is-empty
    )

    # FIXME: use `path sanitize` from `nu-git-manager`
    let pwd = pwd | str replace --regex '^.:' '' | str replace --all '\' '/'
    let pwd = if $is_git_repo {
        # FIXME: use `path sanitize` from `nu-git-manager`
        let repo_root = ^git rev-parse --show-toplevel
            | str replace --regex '^.:' ''
            | str replace --all '\' '/'
        let repo = $repo_root | path basename | color "magenta_bold"
        let sub_dir = $pwd
            | str replace $repo_root '' # FIXME: use `path remove-prefix` from `nu-git-manager`
            | str trim --char '/' # FIXME: use `path remove-trailing-path-sep` from `nu-git-manager`
            | simplify-path

        if $sub_dir != "" {
            [$repo, ($sub_dir | color "magenta_dimmed")]
                | str join (char path_sep | color "magenta_dimmed")
        } else {
            $repo
        }
    } else {
        $pwd | simplify-path | color "green"
    }

    let git_branch_segment = if $is_git_repo {
        let revision = get-revision --short-hash
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

    let git_changes_segment = if $is_git_repo {
        let status = get-status .

        let markers = [
            (if not ($status.staged | is-empty) { "_" }),
            (if not ($status.unstaged | is-empty) { "!" }),
            (if not ($status.untracked | is-empty) { "?" }),
        ]
        let markers = $markers | compact | str join ""

        if $markers == "" {
            null
        } else {
            $"[($markers)]" | color default_dimmed
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

    let cmd_duration = match $env.CMD_DURATION_MS? {
        "0823" | null => -1ms,
        _ => ($env.CMD_DURATION_MS | into int | $in * 1ms),
    }
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
        $git_changes_segment,
        $duration_segment,
        $command_failed_segment,
        $login_segment,
    ]

    $segments | compact | str join " "
}

