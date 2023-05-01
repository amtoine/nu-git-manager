def log_success [message: string] {
    print $"(ansi green)($message)(ansi reset)"
}

def log_warning [message: string] {
    print $"(ansi yellow)($message)(ansi reset)"
}

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

# Clone a github repository into a standard location organised by domain and path.
export def-env "git grab" [
    owner,          # Either the owner, your repo name, or "owner/repo"
    repo?: string,  # the repo name
    --ssh           # use ssh instead of https
    --bare(-b)      # use a bare repo (specific to worktrees)
] {
    let username = (git config user.username | str trim)

    let info = (
        if ($repo == null) {
            let inf = ($owner | split row '/' )
            if ($inf | length) == 1 {
                { owner:$username, repo: ($inf.0) }
            } else {
                { owner:($inf.0), repo: ($inf.1) }
            }
        } else {
            { owner: $owner, repo: $repo }
        }
    )

    let dir = (root_dir $info.owner)
    let repo_path = ($dir | path join $info.repo)

    let repo_path = if $bare { $"($repo_path).git" } else { $repo_path }

    if ($repo_path | path exists) {
        log_warning "Found an existing repo, we will cd to it."
        cd $repo_path
        return
    }

    log_success $"Cloning into ($repo_path)"

    mkdir $dir
    cd $dir

    let url = if ($ssh) {
        $"git@github.com:($info.owner)/($info.repo).git"
    } else {
        $"https://github.com/($info.owner)/($info.repo).git"
    }

    if $bare {
        git clone --bare --recurse-submodules $url
        cd $repo_path

        log_success "Setting up worktrees"

        mkdir .bare
        mv * .bare
        "gitdir: ./.bare" | save .git
    } else {
        git clone --recurse-submodules $url
        cd $repo_path
    }

    log_success "Done"
}

export def clone [
    owner: string
    repo: string
    --host: string = "github.com"
    --protocol: string = "https"
] {(
    git clone --recurse-submodules
        ({
            scheme: $protocol,
            host: $host,
            path: $"/($owner)/($repo)",
        } | url join)
        (root_dir $owner | path join $repo)
)}
