# `gm status` from `nu-git-manager` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager/nu-git-manager/mod.nu#L292))
get current status about the repositories managed by NGM

**/!\\** `$.root.path` and `$.cache.path` will be sanitized **/!\\**

## Examples
```nushell
# getting status when everything is fine
gm status | reject missing | flatten | into record
```
```
╭─────────────────────┬────────────────────────────────────╮
│ path                │ ~/.local/share/repos               │
│ exists              │ true                               │
│ cache_path          │ ~/.cache/nu-git-manager/cache.nuon │
│ cache_exists        │ true                               │
│ should_update_cache │ false                              │
╰─────────────────────┴────────────────────────────────────╯
```
---
```nushell
# getting status when there is no store
gm status | get root
```
```
╭────────┬──────────────────────╮
│ path   │ ~/.local/share/repos │
│ exists │ false                │
╰────────┴──────────────────────╯
```
---
```nushell
# getting status when there is no cache
gm status | get root
```
```
╭────────┬────────────────────────────────────╮
│ path   │ ~/.cache/nu-git-manager/cache.nuon │
│ exists │ false                              │
╰────────┴────────────────────────────────────╯
```
---
```nushell
# getting status when a project is in the cache but is missing on the filesystem
gm status | get missing
```
```
╭──────────────────────────────────────╮
│ 0 │ ~/.local/share/repos/foo/bar/baz │
╰──────────────────────────────────────╯
```
---
```nushell
# update the cache if necessary
if (gm status).should_update_cache { gm update-cache }
```

## Parameters


## Signatures
| input     | output                                                                                                                                          |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `nothing` | `record<root: record<path: string, exists: bool>, missing: list<string>, cache: record<path: string, exists: bool>, should_update_cache: bool>` |
