#*
#*                  _    __ _ _
#*   __ _ ___  __ _| |_ / _(_) |___ ___  WEBSITE: https://goatfiles.github.io
#*  / _` / _ \/ _` |  _|  _| | / -_|_-<  REPOS:   https://github.com/goatfiles
#*  \__, \___/\__,_|\__|_| |_|_\___/__/  LICENCE: https://github.com/goatfiles/dotfiles/blob/main/LICENSE
#*  |___/
#*          MAINTAINERS:
#*              AMTOINE: https://github.com/amtoine antoine#1306 7C5EE50BA27B86B7F9D5A7BA37AAE9B486CFF1AB
#*              ATXR:    https://github.com/atxr    atxr#6214    3B25AF716B608D41AB86C3D20E55E4B1DE5B2C8B
#*

use scripts/prompt.nu

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


# TODO
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


# TODO
export def-env goto [
    --clear (-c): bool  # TODO
] {
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


# TODO
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


# TODO
export def remove [] {
    let repo = (pick_repo "Please choose a repo to remove: ")

    let path = ($env.GIT_REPOS_HOME | path join $repo)

    rm --trash --interactive --recursive $path
}


# TODO
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
