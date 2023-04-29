use scripts/context.nu


# TODO
export def fzf_ask [
    prompt: string
    preview: string = ""
] {
    let choice = (
        $in |
        to text |
        fzf --prompt $prompt --ansi --color --preview $preview |
        str trim
    )

    if ($choice | is-empty) {
        error make (context user_choose_to_exit)
    }

    $choice
}
