use ../git/lib/lib.nu [get-revision, git-action]
use ../git/lib/prompt.nu [get-left-prompt]

const DEFAULT_PROMPT_INDICATORS = {
    plain: "> ",
    vi: {insert: ": ", normal: "> "}
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
