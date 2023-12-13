# `nu-git-manager-sugar git gm repo fetch branch`
## Description
fetch a remote branch locally, without pulling down the whole remote



## Parameters
- parameter_name: remote
- parameter_type: positional
- syntax_shape: string
- is_optional: false
- description: the branch to fetch
---
- parameter_name: branch
- parameter_type: positional
- syntax_shape: string
- is_optional: false
- description: the remote to fetch the branch from
---
- parameter_name: strategy
- parameter_type: named
- syntax_shape: string
- is_optional: true
- description: the merge strategy to use
- parameter_default: none

## Signatures
| input | output |
| ----- | ------ |
| `any` | `any`  |
