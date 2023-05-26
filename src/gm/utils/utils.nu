export def "get root dir" [] {
    $env.GIT_REPOS_HOME? | default (
        $env.XDG_DATA_HOME?
        | default ($env.HOME | path join ".local" "share")
        | path join "nu-git-manager"
    )
}

# Replace all backslashes with forward slashes.
export def "replace slashes" [] {
    str replace --all --string '\' '/'
}

# parse-project <repository URL> -> record<host: string, user: string, project: string>
# parse-project <host>/<user>/<project> -> record<host: string, user: string, project: string>
# parse-project <user>/<project> -> record<user: string, project: string>
# parse-project <project> -> record<project: string>
export def "parse project" [
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

export def "default project" [] {
    default (git config --global user.name) user
    | default "github.com" host
}

export def "list repos" [
    query?: string
    --exact: bool = false
    --full-path: bool = false
    --recursive: bool = false
] {
    let root = (get root dir)
    let repos = (
        ls ($root | if $recursive { path join "**" "*" ".git" } else { path join "*" "*" "*"})
        | get name
        | replace slashes
        | str replace $"^($root | replace slashes)" ""
        | str replace $".git$" ""
        | str trim -l -c '/'
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

export def "pick repo" [
    prompt: string
    query: string
] {
    list repos --exact false --full-path false --recursive false
    | if $query == null {} else { find $query }
    | input list --fuzzy $prompt
}

#[cfg(test)]
export module tests {
    use std "assert equal"
    use std log

    #[test]
    export def parse-project-test [] {
        log debug "testing empty input"
        assert equal (parse project "") {project: ""}

        # normal parsing
        log debug "testing some normal parsing"
        let expected = {host: "host", user: "user", project: "project"}
        assert equal (parse project "/host/user/project") $expected
        assert equal (parse project "host/user/project/") $expected
        assert equal (parse project "host//user/project") $expected
        assert equal (parse project "host/user/project") $expected
        assert equal (parse project "host/user/project.git") $expected
        assert equal (parse project "http://host/user/project") $expected
        assert equal (parse project "https://host/user/project") $expected
        assert equal (parse project "ssh://host/user/project") $expected
        assert equal (parse project "git@host:user/project.git") $expected

        # subgroups?
        log debug "testing parsing of subgroups"
        assert equal (parse project "host/user/group/subgroup/subsubgroup/project") {
            host: "host", user: "user", project: "group/subgroup/subsubgroup/project"
        }

        # default values...
        log debug "testing missing fields"
        assert equal (parse project "user/project") {user: "user", project: "project"}
        assert equal (parse project "project") {project: "project"}

        # ... with subgroups?
        # we cannot parse these properly, that will throw a runtime HTTP error
        log debug "testing imperfect subgroups"
        assert equal (parse project "user/group/subgroup/subsubgroup/project") {
            host: "user", user: "group", project: "subgroup/subsubgroup/project"
        }
        assert equal (parse project "group/subgroup/subsubgroup/project") {
            host: "group", user: "subgroup", project: "subsubgroup/project"
        }

        log debug "testing invalid project name"
        assert equal (parse project "git#host:user/project.git") {
            host: "git#host", user: "user", project: "project"
        }
    }

    def default-project-test-template [] {
        assert equal ($in | default project | columns | sort) ["host" "project" "user"]
    }

    #[test]
    export def default-project-test [] {
        for project in [
            {project: "foo"}
            {project: "foo", user: "bar"}
            {project: "foo", user: "bar", host: "baz"}
        ] {
            $project | default-project-test-template
        }
    }
}
