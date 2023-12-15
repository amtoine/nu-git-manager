export const GIT_QUERY_TABLES = ["refs", "commits", "diffs", "branches", "tags"]

export def git-query-tables []: nothing -> list<string> {
    $GIT_QUERY_TABLES
}

export const GIT_STRATEGIES = ["merge", "rebase", "none"]

export def get-remotes []: nothing -> list<string> {
    ^git remote --verbose show | lines | parse "{remote}\t{rest}" | get remote | uniq
}

export def get-branches []: nothing -> list<string> {
    ^git branch | lines | str substring 2..
}

export def get-strategies []: nothing -> list<string> {
    $GIT_STRATEGIES
}
