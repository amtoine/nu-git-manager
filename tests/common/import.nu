export def "assert imports" [
    module: string, submodule: string, expected: list<string>
] {
    let before = ^$nu.current-exe --no-config-file --commands "
        scope commands | get name
    | to nuon" | from nuon
    let after = ^$nu.current-exe --no-config-file --commands $"
        use ./($module)/ ($submodule)
        scope commands | get name
    | to nuon" | from nuon

    let imported = $after | where $it not-in $before

    assert equal $imported $expected
}
