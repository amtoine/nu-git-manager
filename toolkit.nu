def pretty-cmd [] {
    let cmd = $in
    $"(ansi -e {fg: default attr: di})($cmd)(ansi reset)"

}

def "nu-complete import-targets" [] {
    ["neovim"]
}

export def "import" [--into: string@"nu-complete import-targets"] {
    if ($into == null) {
        print $"(ansi red_italic)--into is a required argument.(ansi reset)"
        return
    }

    let projects = (match $into {
        "neovim" => { $env.HOME | path join ".local" "share" "nvim" "project_nvim" "project_history" },
        _ => {
            print $"(ansi red) '(ansi red_italic)($into)' is not a valid target.(ansi reset)"
            return
        },
    })

    mkdir ($projects | path dirname)
    touch $projects

    let before = ($projects | open | lines | length)

    $projects | open | lines | append (
        ghq list  # FIXME: do not use `ghq` as the main dependency
        | lines
        | each {|it|
            print $"adding (ansi yellow)($it)(ansi reset) to the projects..."
            ghq root | str trim | path join $it  # FIXME: do not use `ghq` as the main dependency
        }
    ) | uniq
    | save -f $projects

    print $"all ('git' | pretty-cmd) projects (ansi green_bold)successfully imported(ansi reset) into the ($projects | pretty-cmd) list!"
    print $"from ($before) to ($projects | open | lines | length) projects."
}
