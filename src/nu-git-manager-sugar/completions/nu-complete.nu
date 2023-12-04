export const GIT_QUERY_TABLES = ["refs", "commits", "diffs", "branches", "tags"]

export def git-query-tables []: nothing -> list<string> {
    $GIT_QUERY_TABLES
}
