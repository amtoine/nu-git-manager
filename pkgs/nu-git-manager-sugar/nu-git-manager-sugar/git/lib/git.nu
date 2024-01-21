use style.nu [color]

# give the revision of the repo you're in
#
# in the output, $.type is guaranteed to be one of
# - "branch"
# - "tag"
# - "detached"
#
# # Examples
#     when on a branch
#     > get-revision # would show the same even if the current branch commit is tagged
#     ╭──────┬──────────────────────────────────────────╮
#     │ name │ main                                     │
#     │ hash │ fa3c06510b3250f4a901db2e9a026a45c971b518 │
#     │ type │ branch                                   │
#     ╰──────┴──────────────────────────────────────────╯
#
#     when on a tag
#     > get-revision
#     ╭──────┬──────────────────────────────────────────╮
#     │ name │ 1.2.3                                    │
#     │ hash │ fa3c06510b3250f4a901db2e9a026a45c971b518 │
#     │ type │ tag                                      │
#     ╰──────┴──────────────────────────────────────────╯
#
#     when the HEAD is detached
#     > get-revision
#     ╭──────┬──────────────────────────────────────────╮
#     │ name │                                          │
#     │ hash │ fa3c06510b3250f4a901db2e9a026a45c971b518 │
#     │ type │ detached                                 │
#     ╰──────┴──────────────────────────────────────────╯
#
#     when the HEAD is detached (short-version)
#     > get-revision --short-hash
#     ╭──────┬──────────╮
#     │ name │          │
#     │ hash │ fa3c0651 │
#     │ type │ detached │
#     ╰──────┴──────────╯
export def get-revision [
    --short-hash  # print the hash of a detached HEAD in short format
]: nothing -> record<name: string, hash: string, type: string> {
    let tag = do -i {
        ^git describe HEAD --tags
    } | complete
    let is_tag = $tag.exit_code == 0 and (
        $tag.stdout
            | str trim
            | parse --regex '(?<tag>.*)-(?<n>\d+)-(?<hash>[0-9a-fg]+)'
            | is-empty
    )

    let branch = ^git branch --show-current
    let hash = if $short_hash {
        (^git rev-parse --short HEAD)
    } else {
        (^git rev-parse HEAD)
    }

    if not ($branch | is-empty) {
        {name: $branch, hash: $hash, type: "branch"}
    } else if $is_tag {
        {name: ($tag.stdout | str trim), hash: $hash, type: "tag"}
    } else {
        {name: null, hash: $hash, type: "detached"}
    }
}

# https://stackoverflow.com/questions/59603312/git-how-can-i-easily-tell-if-im-in-the-middle-of-a-rebase
export def git-action []: nothing -> string {
    let git_dir = ^git rev-parse --git-dir | path expand

    def test-dir [target: string]: nothing -> bool {
        ($git_dir | path join $target | path type) == "dir"
    }

    def test-file [target: string]: nothing -> bool {
        ($git_dir | path join $target | path type) == "file"
    }

    if (test-dir "rebase-merge") {
        if (test-file "rebase-merge/interactive") {
            "REBASE-i" | color blue
        } else {
            "REBASE-m" | color magenta
        }
    } else {
        if (test-dir "rebase-apply") {
            if (test-file "rebase-apply/rebasing") {
                "REBASE" | color cyan
            } else if (test-file "rebase-apply/applying") {
                "AM" | color cyan
            } else {
                "AM/REBASE" | color cyan
            }
        } else if (test-file "MERGE_HEAD") {
            "MERGING" | color dark_gray
        } else if (test-file "CHERRY_PICK_HEAD") {
            "CHERRY-PICKING" | color green
        } else if (test-file "REVERT_HEAD") {
            "REVERTING" | color red
        } else if (test-file "BISECT_LOG") {
            "BISECTING" | color yellow
        } else {
            null
        }
    }
}

export def get-status [
    repo: path, # the path to the repo
]: nothing -> record<staged: list<string>, unstaged: list<string>, untracked: list<string>> {
    let status = ^git -C $repo status --short | lines
    {
        staged: ($status | parse --regex '^\w. (?<file>.*)' | get file),
        unstaged: ($status | parse --regex '^.\w (?<file>.*)' | get file),
        untracked: ($status | parse --regex '^\?\? (?<file>.*)' | get file),
    }
}

