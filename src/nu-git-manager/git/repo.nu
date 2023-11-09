use ../error/error.nu [throw-error]

# tell if a local repository has been grafted
#
# > see more about grafted commits
# > [here](https://stackoverflow.com/questions/27296188/what-exactly-is-a-grafted-commit-in-a-shallow-clone)
export def is-grafted [
    repo?: path, # the path to the repository to check (defaults to `pwd`)
]: nothing -> bool {
    let repo = $repo | default (pwd)

    not (
        ^git -C $repo log --oneline --decorate (get-root-commit $repo)
            | parse --regex '[0-9a-f]+ \(grafted.*'
            | is-empty
    )
}

# compute the hash of the root commit of a repository
export def get-root-commit [
    repo?: path, # the path to the repository to check (defaults to `pwd`)
]: nothing -> string {
    let repo = $repo | default (pwd)

    $"(^git -C $repo rev-list HEAD | lines | last)"
}

# wrapper around `git remote --verbose show` to list the remotes of a repository
export def list-remotes [
    repo?: path, # the path to the repository to check (defaults to `pwd`)
]: nothing -> table<remote: string, fetch: string, push: string> {
    ^git -C ($repo | default (pwd)) remote --verbose show
        | detect columns --no-headers
        | str trim
        | rename remote url mode
        | group-by remote
        | transpose k v
        | update v { reject remote | select mode url | transpose --header-row | into record }
        | flatten
        | rename remote fetch push
}
