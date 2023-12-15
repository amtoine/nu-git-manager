# /!\ requires the input path to be sanitized /!\
export def simplify-path []: path -> string {
    let input = $in

    # FIXME: use `path sanitize` from `nu-git-manager`
    let home = $nu.home-path | str replace --regex '^.:' '' | str replace --all '\' '/'
    $input | str replace $home "~" | str replace --regex '^/' "!/"
}

export def color [color]: string -> string {
    $"(ansi $color)($in)(ansi reset)"
}
