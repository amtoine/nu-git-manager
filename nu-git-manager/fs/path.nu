# sanitize a Windows path
export def "path sanitize" []: path -> path {
    str replace --regex '^.:' '' | str replace --all '\' '/'
}
