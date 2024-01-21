use ../fs path "path sanitize"

# parse the URL of a Git repo
#
# this command will isolate
# - the host, e.g. `github.com`
# - the owner, e.g. `amtoine`
# - the group, e.g. GitLab repos can be stored in subgroups, which can either be seen as subfields
#   to the owner or superfields of the repo
# - the repo, e.g. `nu-git-manager`
export def parse-git-url []: string -> record<host: string, owner: string, group: path, repo: string> {
    str replace --regex '^git@(.*):' 'ssh://$1/'
        | str replace --regex '\.git$' ''
        | url parse
        | select host path
        | update path {
            let tokens = $in
                | str trim --left --right --char '/'
                | str replace --regex '\/tree\/.*' ''
                | path split

            let owner = if ($tokens | length) > 1 {
                $tokens | first
            }

            let group = if ($tokens | length) > 1 {
                $tokens | range 1..(-2) | if $in != null { path join | path sanitize }
            }

            {
                owner: ($owner | default ""),
                group: ($group | default ""),
                repo: ($tokens | last)
            }
        }
        | flatten
        | into record
}

# compute the FETCH and PUSH remote URLs for a parsed repository, based on user input
export def get-fetch-push-urls [
    repository: record<host: string, owner: string, group: path, repo: string>, # the parsed repository (typically from `parse-git-url`)
    fetch: string, # user input: one of 'https', 'ssh', 'git', or empty (typically from `gm clone --fetch`)
    push: string, # user input: one of 'https', 'ssh', 'git', or empty (typically from `gm clone --push`)
    ssh: bool, # user input (typically from `gm clone --ssh`)
]: nothing -> record<fetch: string, push: string> {
    let base_url = {
        scheme: null,
        host: $repository.host,
        path: (
            [$repository.owner $repository.group $repository.repo]
                | compact
                | path join
                | path sanitize
        )
    }
    let http_url = $base_url | update scheme "https" | url join
    let ssh_url = $base_url | update scheme "ssh" | url join
    let git_url = $base_url | update scheme "git" | url join

    let fetch_url = match $fetch {
        "https" => $http_url,
        "ssh" => $ssh_url,
        "git" => $git_url,
        _ => {
            if $ssh {
                $ssh_url
            } else {
                $http_url
            }
        },
    }

    let push_url = match $push {
        "https" => $http_url,
        "ssh" => $ssh_url,
        "git" => $git_url,
        _ => {
            if $ssh {
                $ssh_url
            } else {
                $http_url
            }
        },
    }

    {fetch: $fetch_url, push: $push_url}
}
