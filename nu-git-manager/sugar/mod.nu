# TODO: documentation
export def "gm branch wipe" [
    branch: string, # TODO: documentation
    remote: string, # TODO: documentation
] {
    git branch --delete --force $branch
    git push $remote --delete $branch
}
