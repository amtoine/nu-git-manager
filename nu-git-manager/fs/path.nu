# sanitize a Windows path
export def "path sanitize" []: path -> path {
    str replace --all '\' '/'
}
