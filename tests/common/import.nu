export def "assert imports" [
    module: string, submodule: string, expected: list<string>, --prefix: string = "gm "
] {
    let src = $"
        use ./src/($module)/ ($submodule) *
        scope commands | get name | where \($it | str starts-with '($prefix)'\) | to nuon
    "

    let actual = ^$nu.current-exe --no-config-file --commands $src | from nuon
    assert equal $actual $expected
}
