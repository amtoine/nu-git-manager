# `nu-git-manager-sugar git gm repo compare`
## Description
compare the changes between two revisions, from a target to the "head"



## Parameters
- parameter_name: target
- parameter_type: positional
- syntax_shape: string
- is_optional: false
- description: the target to compare from
---
- parameter_name: head
- parameter_type: named
- syntax_shape: string
- is_optional: true
- description: the "head" to use for the comparison
- parameter_default: HEAD

## Signatures
| input | output |
| ----- | ------ |
| `any` | `any`  |
