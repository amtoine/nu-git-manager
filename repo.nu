def FZF_PICK_PREVIEW [] { return "
    path=$(ghq root)/$(echo {} | sed 's/: /.com\\//')
    echo "TREE:"
    git -C $path --no-pager log --graph --branches --remotes --tags --oneline --decorate --simplify-by-decoration -n 10 --color=always
    echo ""
    echo "STATUS:"
    git -C $path --no-pager status --short
    echo ""
    echo "STASHES:"
    git -C $path --no-pager stash list
    echo ""
    echo "FILES:"
    ls -la --color=always $path | awk '{print $1,$9}'
"}

def "context user_choose_to_exit" [] {
    {msg: "User choose to exit...", label: {text: "User choose to exit..."}}
}

def "prompt fzf_ask" [
    prompt: string
    preview: string = ""
] {
    let choice = (
        $in |
        to text |
        fzf --prompt $prompt --ansi --color --preview $preview |
        str trim
    )

    if ($choice | is-empty) {
        error make (context user_choose_to_exit)
    }

    $choice
}

def pick_repo [
    prompt: string
] {
    let choice = (
        ghq list |
        lines |
        str replace ".com/" ": " |
        sort --ignore-case |
        prompt fzf_ask $prompt (FZF_PICK_PREVIEW) |
        str replace ": " ".com/"
    )

    $choice
}

# jump to any repo registered with ghq.
#
# the function will:
#   - (1) do nothing and abort when selecting no repo.
#   - (2) jump to the selected repo and print the content of the repo.
#
# dependencies:
#   - ghq
#   - fzf
#
export def-env goto [
    --clear (-c): bool
] {
    let choice = (pick_repo "Please choose a repo to jump to: ")

    # compute the directory to jump to.
    let path = (
        ghq root
           | str trim
           | path join $choice
        )
    cd $path

    if ($clear) {
        clear
    }
}

export def pull [
    owner?: string
] {
    let owner = (if ($owner | is-empty) {
        git config --get user.name | str trim
    } else { $owner })

    let choice = (
        gh repo list $owner --json name |
        from json |
        get name |
        sort --ignore-case |
        uniq |
        prompt fzf_ask $"Please choose a repo to pull from https://github.com/($owner): "
    )

    let repository = ([$owner $choice] | str join "/")

    ghq get -p $repository
}

export def remove [] {
    let repo = (pick_repo "Please choose a repo to remove: ")

    let path = ($env.GIT_REPOS_HOME | path join $repo)

    rm --trash --interactive --recursive $path
}

export def "get any" [
    repo: string
    --method: string = "https"
    --host: string = "github.com"
] {
    let prefix = if ($method == "ssh") {
        "ssh://git@"
    } else {
        "https://"
    }

    let upstream = ([$prefix $host "/" $repo ".git"] | str join)

    git clone $upstream ($env.GIT_REPOS_HOME | path join $host $repo)
}
