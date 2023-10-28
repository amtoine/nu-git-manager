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
