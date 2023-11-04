use ../error/error.nu [throw-error]

# tell if a local repository has been grafted
#
# > see more about grafted commits
# > [here](https://stackoverflow.com/questions/27296188/what-exactly-is-a-grafted-commit-in-a-shallow-clone)
export def is-grafted [
    repo?: path, # the path to the repository to check (defaults to `pwd`)
]: nothing -> bool {
    let repo = $repo | default (pwd)

    let root_commit = ^git -C $repo rev-list HEAD | lines | last
    not (
        ^git -C $repo log --oneline --decorate $root_commit
            | parse --regex '[0-9a-f]+ \(grafted.*'
            | is-empty
    )
}
