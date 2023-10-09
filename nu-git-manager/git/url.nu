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
