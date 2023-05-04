use std ['log debug', 'log warning']

def root_dir [] {
    $env.GIT_REPOS_HOME? | default (
        $env.XDG_DATA_HOME?
        | default ($env.HOME | path join ".local" "share")
        | path join "nu-git-manager"
    )
}

# TODO: support cancel
def lsi [path: string = "."] {(
    ls $path
    | get name
    | to text
    | gum choose --no-limit
    | lines
    | get 1 | str trim    # hack to suppress the errors
)}

export def-env "gm ungrab" [] {
    # TODO: ungrab should move to a trash folder!
    ls -s (root_dir) | gum choose
}

export def-env "gm grab select" [] {
    let owner = (lsi (root_dir))
    let repo = (lsi $owner)

    cd $repo
}

# parse-project <repository URL> -> record<host: string, user: string, project: string>
# parse-project <host>/<user>/<project> -> record<host: string, user: string, project: string>
# parse-project <user>/<project> -> record<user: string, project: string>
# parse-project <project> -> record<project: string>
def parse-project [
    project: string  # <repository URL>|<host>/<user>/<project>|<user>/<project>|<project>
] {
    let project = (
        $project
        | str replace '.git$' ''
        | str replace '^http://' ''
        | str replace '^https://' ''
        | str replace '^ssh://' ''
        | str replace '^git@' ''
        | str replace --all ':' '/'
        | str replace --all '\/+' '/'
        | str trim -c '/'
    )

    let hup = ($project | parse "{host}/{user}/{project}")
    if not ($hup | is-empty) {
        return ($hup | into record)
    }

    let up = ($project | parse "{user}/{project}")
    if not ($up | is-empty) {
        return ($up | into record)
    }

    {project: $project}
}

def default-project [] {
    default (git config --global user.name) user
    | default "github.com" host
}

# TODO: add support for other hosts than github
# TODO: better worktree support

# Clone a repository into a standard location
#
# This place is organised by domain and path.
export def "gm grab" [
    project: string               # <repository URL>|<host>/<user>/<project>|<user>/<project>|<project>
    --ssh (-p): bool              # use ssh instead of https.
    --bare (-b): bool             # clone as *bare* repo (specific to worktrees).
    --update (-u): bool           # not supported
    --shallow (-s): bool          # not supported
    --branch: bool                # not supported
    --no-recursive: bool          # not supported
    --look: bool                  # not supported
    --silent: bool                # not supported
    --vcs (-v): bool              # not supported
] {
    # TODO: implement `--update` option
    if $update {
        log warning "`--update` option for `gm grab` COMING SOON"
    }
    # TODO: implement `--shallow` option
    if $shallow {
        log warning "`--shallow` option for `gm grab` COMING SOON"
    }
    # TODO: implement `--branch` option
    if $branch {
        log warning "`--branch` option for `gm grab` COMING SOON"
    }
    # TODO: implement `--look` option
    if $look {
        log warning "`--look` option for `gm grab` COMING SOON"
    }
    # TODO: implement `--silent` option
    if $silent {
        log warning "`--silent` option for `gm grab` COMING SOON"
    }
    # TODO: implement `--no-recursive` option
    if $no_recursive {
        log warning "`--no-recursive` option for `gm grab` COMING SOON"
    }
    if $vcs {
        log debug "`--vcs` option is NOT SUPPORTED in `gm grab`"
    }

    let project = (
        parse-project $project
        | default-project
        | update project { str replace --all '\/' '-'}
    )

    let url = (if $ssh {
        $"git@($project.host):($project.user)/($project.project).git"
    } else {
        $"https://($project.host)/($project.user)/($project.project).git"
    })

    let local = (root_dir | path join $project.host $project.user $project.project)

    if $bare {
        git clone --bare --recurse-submodules $url $local
    } else {
        git clone --recurse-submodules $url $local
    }
}

# list locally-cloned repositories
export def "gm list repos" [
    query?: string          # return only repositories matching the query
    --exact (-e): bool      # force the match to be exact, i.e. the query equals to project, user/project or host/user/project
    --full-path (-p): bool  # return the full paths instead of path relative to the `gm` root
    --recursive: bool
] {
    let root = (root_dir)
    let repos = (
        ls ($root | if $recursive { path join "**" "*" ".git" } else { path join "*" "*" "*"})
        | get name
        | str replace $"^($root)" ""
        | str replace $".git$" ""
        | str trim -l -c (char path_sep)
        | parse "{host}/{user}/{project}"
        | insert user-project {|it| [$it.user $it.project] | path join}
        | insert host-user-project {|it| [$it.host $it.user $it.project] | path join}
    )

    let repos = ($repos | if $query != null {
        if $exact {
            where {|it| (
                ($it.project == $query) or
                ($it.user-project == $query) or
                ($it.host-user-project == $query)
            )}
        } else {
            find $query
        }
    } else {})

    $repos | get host-user-project | if $full_path {
        each {|repo| $root | path join $repo}
    } else {}
}

# print the root of the repositories
export def "gm root" [
    --all (-a): bool  # not supported
] {
    if $all {
        log debug "`--all` option is NOT SUPPORTED in `gm root`"
    }

    root_dir
}

# create a new repository
export def "gm create" [
    repository: string
    --vcs (-v): bool  # not supported
] {
    if $vcs {
        log debug "`--vcs` option is NOT SUPPORTED in `gm create`"
    }

    # TODO: implement `gm create`
    log warning "COMING SOON"
}

# the `nu-[g]it-[m]anager`, a WIP to manage any `git` repo in a centralized store, with sugar on top
export def gm [] { help gm }

# run the tests with
# ```nu
# use mod.nu; mod tests
# ```
#
#[cfg(test)]
export def tests [] {
    use std "assert equal"
    use std ["log info" "log debug"]

    #[test]
    def parse-project-test [] {
        log debug "testing empty input"
        assert equal (parse-project "") {project: ""}

        # normal parsing
        log debug "testing some normal parsing"
        let expected = {host: "host", user: "user", project: "project"}
        assert equal (parse-project "/host/user/project") $expected
        assert equal (parse-project "host/user/project/") $expected
        assert equal (parse-project "host//user/project") $expected
        assert equal (parse-project "host/user/project") $expected
        assert equal (parse-project "host/user/project.git") $expected
        assert equal (parse-project "http://host/user/project") $expected
        assert equal (parse-project "https://host/user/project") $expected
        assert equal (parse-project "ssh://host/user/project") $expected
        assert equal (parse-project "git@host:user/project.git") $expected

        # subgroups?
        log debug "testing parsing of subgroups"
        assert equal (parse-project "host/user/group/subgroup/subsubgroup/project") {
            host: "host", user: "user", project: "group/subgroup/subsubgroup/project"
        }

        # default values...
        log debug "testing missing fields"
        assert equal (parse-project "user/project") {user: "user", project: "project"}
        assert equal (parse-project "project") {project: "project"}

        # ... with subgroups?
        # we cannot parse these properly, that will throw a runtime HTTP error
        log debug "testing imperfect subgroups"
        assert equal (parse-project "user/group/subgroup/subsubgroup/project") {
            host: "user", user: "group", project: "subgroup/subsubgroup/project"
        }
        assert equal (parse-project "group/subgroup/subsubgroup/project") {
            host: "group", user: "subgroup", project: "subsubgroup/project"
        }

        log debug "testing invalid project name"
        assert equal (parse-project "git#host:user/project.git") {
            host: "git#host", user: "user", project: "project"
        }
    }

    def default-project-test-template [] {
        assert equal ($in | default-project | columns | sort) ["host" "project" "user"]
    }

    #[test]
    def default-project-test [] {
        for project in [
            {project: "foo"}
            {project: "foo", user: "bar"}
            {project: "foo", user: "bar", host: "baz"}
        ] {
            $project | default-project-test-template
        }
    }

    parse-project-test
    default-project-test
}
