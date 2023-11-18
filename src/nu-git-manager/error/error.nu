# throw a nice error with a standard format
export def throw-error [
    error: record<msg: string, label: record<text: string, span: record<start: int, end: int>>>
] {
    error make {
        msg: $"(ansi red_bold)($error.msg)(ansi reset)"
        label: {
            text: $error.label.text
            span: $error.label.span
        }
    }
}

# throw a nice warning with a standard format
export def throw-warning [
    warning: record<msg: string, label: record<text: string, span: record<start: int, end: int>>>
] {
    # FIXME: would be cool to have a proper way to do that :thinking:
    # ^$nu.current-exe --commands $"error make {
    #     msg: $'\(ansi yellow_bold\)($warning.msg)\(ansi reset\)'
    #     label: {
    #         text: '($warning.label.text)'
    #         start: ($warning.label.span.start)
    #         end: ($warning.label.span.end)
    #     }
    # }"
    print $"Warning:   (char -u 26a0) (ansi yellow_bold)($warning.msg)(ansi reset)"
    print ($warning.label.text | lines | each { $"| ($in)" } | str join "\n")
}
