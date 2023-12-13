# `gm remove` (`nu-git-manager`)
remove one of the repositories from your local store

## Examples
```nushell
# remove any repository by fuzzy-finding the whole store
gm remove --fuzzy
```
---
```nushell
# restrict the search to any one of my repositories
gm remove amtoine
```
---
```nushell
# remove a precise repo by giving its full name, a name collision is unlikely
gm remove amtoine/nu-git-manager
```
---
```nushell
# remove a precise repo without confirmation
gm remove amtoine/nu-git-manager --no-confirm
```

## Parameters
- parameter_name: pattern
- parameter_type: positional
- syntax_shape: string
- is_optional: true
- description: a pattern to restrict the choices
---
- parameter_name: fuzzy
- parameter_type: switch
- is_optional: true
- description: remove after fuzzy-finding the repo(s) to clean
---
- parameter_name: no-confirm
- parameter_type: switch
- is_optional: true
- description: do not ask for confirmation: useful in scripts but requires a single match

## Signatures
| input     | output    |
| --------- | --------- |
| `nothing` | `nothing` |
