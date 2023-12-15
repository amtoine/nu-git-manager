export def git-protocols []: nothing -> table<value: string, description: string> {
    [
        [value, description];

        ["https", "use the HTTP protocol: will require a PAT authentification for private repositories"],
        ["ssh", "use the SSH protocol: will require a passphrase unless setup otherwise"],
        ["git", "use the GIT protocol: useful when cloning a *Suckless* repo"],
    ]
}
