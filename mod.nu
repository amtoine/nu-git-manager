export def-env "git ungrab" [] {
    let dir = (root_dir)
    ls -s $dir | gum choose
}

def root_dir [owner?:string] {
    let owner = if $owner == null {
        ''
    } else {
        $owner
    }
    $nu.home-path | path join "dev" $owner
}

# TODO: support cancel
def lsi [path:string="."] {
    # the last part (from lines) is a hack to suppress the errors
    (ls $path | get name | to text | gum choose --no-limit | lines | get 1 | str trim)
}

export def-env "git grab select" [] {
    let owner = (lsi (root_dir))
    # $dest
    let repo = (lsi $owner)
    
    cd $repo
    # cd $dest
    # lsi
}


# Clone a github repository into a standard location organised by domain and path.
export def-env "git grab" [
    owner, # Either the owner, your repo name, or "owner/repo"
    repo?: string, # the repo name
    --ssh # use ssh instead of https
    --bare(-b) # use a bare repo (specific to worktrees)
    ] {
    let username = (git config user.username | str trim)

    let info = (
        if ($repo == null) {
            let inf = ($owner | split row '/' )
            if ($inf | length) == 1 {
                {owner:$username, repo: ($inf.0) }
            } else {
                {owner:($inf.0), repo: ($inf.1) }
            }
        } else {
            {owner: $owner, repo: $repo}
        }
    )

    let dir = (root_dir $info.owner)
    let repo_path = ($dir | path join $info.repo)

    let repo_path = if $bare { $"($repo_path).git" } else { $repo_path}

    if ($repo_path | path exists) {
        print $"(ansi yellow)Found an existing repo, we will cd to it.(ansi reset)"
        cd $repo_path
        return
    }
    echo $"(ansi green)Cloning into ($repo_path)(ansi reset)"

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
        echo $"(ansi green)Setting up worktrees(ansi reset)"

        mkdir .bare
        mv * .bare
        echo "gitdir: ./.bare" | save .git
    } else {

        git clone --recurse-submodules $url
        cd $repo_path
    }

    print $"(ansi green)Done(ansi reset)"
}
