export def "git operations" [] {
    git log $"(git merge-base FETCH_HEAD main)..HEAD" -M5 --summary
    | rg -e 'rename.*=>|delete mode'
    | lines
    | str trim
    | parse '{operation} {file}'
    | sort-by operation
}
