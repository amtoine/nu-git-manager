def root_dir [] {
    $env.GIT_REPOS_HOME? | default ($nu.home-path | path join "dev")
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

export def-env "gm ungrab" [] {
    # TODO: ungrab should move to a trash folder!
    ls -s (root_dir) | gum choose
}

export def-env "gm grab select" [] {
    let owner = (lsi (root_dir))
    let repo = (lsi $owner)

    cd $repo
}

# TODO: add support for other hosts than github
# TODO: better worktree support

# Clone a repository into a standard location
#
# This place is organised by domain and path.
export def "gm grab" [
    owner: string                 # the name of the owner of the repo.
    repo: string                  # the name of the repo to grab.
    --host: string = "github.com" # the host to grab the repo from.
    --ssh (-s): bool              # use ssh instead of https.
    --bare (-b): bool             # clone as *bare* repo (specific to worktrees).
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
