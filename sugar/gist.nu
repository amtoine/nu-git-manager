# give `~/.gists/` as a default value for the GIST home
def default-gist-home [] {
    default ($env.HOME | path join ".gists")
}

# get the true GIST home, possibly with default value
def gist-home [] {
    $env.GIST_HOME? | default-gist-home
}

# list the first 100 gists of a given user
#
# returns a
# ```
# table<
#    id: string
#    description: string
#    files: record<any>
#    updated_at: string
#    url: string
# >
def list-gists [user: string] {
    http get ({
        scheme: https,
        username: "",
        password: "",
        host: api.github.com,
        port: "",
        path: $"/users/($user)/gists",
        fragment: "",
        params: {
            sort: updated,
            per_page: 100,
            page: 1
        }
    } | url join)
    | select id description files updated_at url
}

# give the lists of known users
def "nu-complete list-known-users" [] {
    $env.KNOWN_GITHUB_USERS? | default []
}

# list all locally stored gists, i.e. directories under `GIST_HOME` containing a `.git/`
def list-local-gists [] {
    ls (gist-home | path join "**" "*" ".git")
}

# list the gists of a *GitHub* user or all the gists stored locally
export def list [
    user?: string@"nu-complete list-known-users"  # the *GitHub* to list the repositories of
    --local: bool  # only list gists stored locally
] {
    if $local { return (
        try {
            list-local-gists
        } catch { return "no local gist found" }
        | get name
        | each {||
            path parse | get parent | split row (char path_sep) | last 2 | str join ":"
        }
        | parse "{user}:{gist}"
    )}

    if ($user | is-empty) {
        let span = (metadata $user | get span)
        error make {
            msg: $"(ansi red)gist::no_user_given(ansi reset)"
            label: {
                text: "no user given"
                start: $span.start
                end: $span.end
            }
        }
    }

    list-gists $user
    | update files {|| get files | transpose | get column1}
    | reject files.raw_url
}

# list the gists of a user for completion
#
# the name of the user is extracted from the context of the command
def "nu-complete list-gists" [context: string] {
    let user = ($context | str replace 'gist\s*clone\s*' "" | split row " " | get 0)
    list-gists $user | select id description | rename value
}

# clone a gist of a *GitHub* user into the local `GIT_HOME`
export def clone [
    user: string@"nu-complete list-known-users"  # a *GitHub* user to clone a gist from
    gist: string@"nu-complete list-gists"  # the gist ID to clone
] {
    git clone ({
        scheme: https,
        host: gists.github.com,
        path: $"/($user)/($gist)",
    } | url join) (
        gist-home | path join $user $gist
    )
}

# list all local gist in a completion-friendly format
def "nu-complete list-local-gists" [] {
    ls (gist-home | path join "**" "*" ".git")
    | update name {|| get name | path dirname}
    | upsert description {|it| try {
        $it.name | path join "README.md" | open | lines | first 1 | get 0
    }}
    | select name description
    | update name {||
        get name | str replace (gist-home) "" | str trim -c (char path_sep)
    }
    | rename value
}

# jump to a gist in the `GIST_HOME`
export def-env goto [
    gist: string@"nu-complete list-local-gists"  # the gist to jump to
] {
    cd (gist-home | path join $gist)
}

# *GitHub* gists
#
# > :bulb: **Note**
# > this module uses the `GIST_HOME` environment variable and defaults its value
# > to `~/.gists/`.
#
# > :bulb: **Note**
# > the `gist` module also uses the `KNOWN_GITHUB_USERS` to propose some known
# > users in completion.
# > this list defaults to the empty list.
export def main [] { help gist }
