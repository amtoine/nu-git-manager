def root_dir [owner?: string] {
    $env.GIT_REPOS_HOME?
    | default ($nu.home-path | path join "dev")
    | if ($owner != null) { path join $owner } else {}
}

# TODO: support cancel
def lsi [path: string = "."] {(
    ls $path
    | get name
    | to text
    | gum choose --no-limit
    | lines
    | get 1 | str trim    # hack to suppress the errors
)}

export def-env "git ungrab" [] {
    # TODO: ungrab should move to a trash folder!
    ls -s (root_dir) | gum choose
}

export def-env "git grab select" [] {
    let owner = (lsi (root_dir))
    let repo = (lsi $owner)

    cd $repo
}

# TODO: add support for other hosts than github
# TODO: better worktree support

export def "git grab" [
    owner: string
    repo: string
    --host: string = "github.com"
    --ssh (-s): bool
    --bare (-b): bool
] {
    let url = (if $ssh {
        $"git@($host):($owner)/($repo).git"
    } else {
        $"https://($host)/($owner)/($repo).git"
    })

    let local = (root_dir | path join $host $owner $repo)

    if $bare {
        git clone --bare --recurse-submodules $url $local
    } else {
        git clone --recurse-submodules $url $local
    }
}
