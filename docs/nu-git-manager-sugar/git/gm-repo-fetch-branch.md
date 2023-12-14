# `gm repo fetch branch` (`nu-git-manager-sugar git`)
fetch a remote branch locally, without pulling down the whole remote



## Parameters
- parameter_name: remote
- parameter_type: positional
- syntax_shape: completable<string>
- is_optional: false
- description: the branch to fetch
- custom_completion: get-remotes
---
- parameter_name: branch
- parameter_type: positional
- syntax_shape: completable<string>
- is_optional: false
- description: the remote to fetch the branch from
- custom_completion: get-branches
---
- parameter_name: strategy
- parameter_type: named
- syntax_shape: completable<string>
- is_optional: true
- description: the merge strategy to use
- custom_completion: get-strategies
- parameter_default: none

## Signatures
| input     | output    |
| --------- | --------- |
| `nothing` | `nothing` |
