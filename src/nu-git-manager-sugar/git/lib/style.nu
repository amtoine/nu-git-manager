export def simplify-path []: path -> string {
    str replace $nu.home-path "~" | str replace --regex '^/' "!/"
}

export def color [color]: string -> string {
    $"(ansi $color)($in)(ansi reset)"
}
