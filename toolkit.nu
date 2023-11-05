# run the tests of the `nu-git-manager` package
#
# > **Important**  
# > the `toolkit test` command requires [Nupm](https://github.com/nushell/nupm) to be installed
export def "test" [
    --verbose # show the output of each tests
] {
    use nupm

    if $verbose {
        nupm test --show-stdout
    } else {
        nupm test
    }
}

# pull down the list of `refactor` PRs that have been merged and ignore the revisions
#
# > inspired by [*How to exclude commits from git blame*](https://www.stefanjudis.com/today-i-learned/how-to-exclude-commits-from-git-blame/)
export def "update-ignored-revisions" [] {
    const FILE = ".git-blame-ignore-revs"

    let commits = ^gh -R amtoine/nu-git-manager pr list [
            --state merged
            --label refactor
            --json "number,title,mergeCommit,url"
        ]
        | from json
        | select number title mergeCommit.oid url
        | rename --column {mergeCommit_oid: "commit"}
        | reverse
        | each { $"# ($in.title): [#($in.number)]\(($in.url)\)\n($in.commit)" }
        | str join "\n\n"

    [
        "# Run this command to always ignore formatting commits in `git blame`",
        "# ```",
       $"# git config blame.ignoreRevsFile ($FILE)",
        "# ```",
        $commits
    ] | str join "\n" | save --force $FILE

    print $"ignored revisions stored in `($FILE)`"
}
