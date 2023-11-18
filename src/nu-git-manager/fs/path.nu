# sanitize a Windows path
export def "path sanitize" []: path -> path {
    str replace --regex '^.:' '' | str replace --all '\' '/'
}

# remove a prefix from a path or a list of paths
#
# /!\ paths need to be sanitized /!\
export def "path remove-prefix" [prefix: path]: [path -> string, list<path> -> list<string>] {
    str replace $prefix '' | str trim --left --char "/"
}
