# throw a nice error with a standard format
export def throw-error [
    error: record<msg: string, label: record<text: string, span: record<start: int, end: int>>>
] {
    error make {
        msg: $"(ansi red_bold)($error.msg)(ansi reset)"
        label: {
            text: $error.label.text
            start: $error.label.span.start
            end: $error.label.span.end
        }
    }
}
