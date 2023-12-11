# `nu-git-manager gm status`
## Description
get current status about the repositories managed by `nu-git-manager`

/!\ `$.root.path` and `$.cache.path` will be sanitized /!\

Examples
    getting status when everything is fine
    > gm status | reject missing | flatten | into record
    ╭─────────────────────┬────────────────────────────────────╮
    │ path                │ ~/.local/share/repos               │
    │ exists              │ true                               │
    │ cache_path          │ ~/.cache/nu-git-manager/cache.nuon │
    │ cache_exists        │ true                               │
    │ should_update_cache │ false                              │
    ╰─────────────────────┴────────────────────────────────────╯

    getting status when there is no store
    > gm status | get root
    ╭────────┬──────────────────────╮
    │ path   │ ~/.local/share/repos │
    │ exists │ false                │
    ╰────────┴──────────────────────╯

    getting status when there is no cache
    > gm status | get root
    ╭────────┬────────────────────────────────────╮
    │ path   │ ~/.cache/nu-git-manager/cache.nuon │
    │ exists │ false                              │
    ╰────────┴────────────────────────────────────╯

    getting status when a project is in the cache but is missing on the filesystem
    > gm status | get missing
    ╭──────────────────────────────────────╮
    │ 0 │ ~/.local/share/repos/foo/bar/baz │
    ╰──────────────────────────────────────╯

    update the cache if necessary
    > if (gm status).should_update_cache { gm update-cache }

## Signature
| input     | output                                                                                                                                          |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `nothing` | `record<root: record<path: string, exists: bool>, missing: list<string>, cache: record<path: string, exists: bool>, should_update_cache: bool>` |
