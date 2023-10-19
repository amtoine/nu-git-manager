export def parse-git-url []: string -> record<host: string, owner: string, group: path, repo: string> {
    str replace --regex '^git@(.*):' 'ssh://$1/'
        | str replace --regex '\.git$' ''
        | url parse
        | select host path
        | update path {
            str trim --left --right --char '/'
                | str replace --regex '\/tree\/.*' ''
                | path split
                | {
                    owner: ($in | first),
                    group: ($in | range 1..(-2) | if $in != null { path join }),
                    repo: ($in | last)
                }
        }
        | flatten
        | into record
}

export def get-fetch-push-urls [
    repository: record<host: string, owner: string, group: path, repo: string>, # typically from `parse-git-url`
    fetch: string, # one of 'https', 'ssh', or empty
    push: string, # one of 'https', 'ssh', or empty
    ssh: bool,
]: nothing -> record<fetch: string, push: string> {
    let base_url = {
        scheme: null,
        host: $repository.host,
        path: ([$repository.owner $repository.group $repository.repo] | compact | path join | str replace '\' '/')
    }
    let http_url = $base_url | update scheme "https" | url join
    let ssh_url = $base_url | update scheme "ssh" | url join

    let fetch_url = match $fetch {
        "https" => $http_url,
        "ssh" => $ssh_url,
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
