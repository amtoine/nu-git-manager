# `nu-git-manager gm clean`
## Description
clean the store
this command will mainly remove empty directory recursively.

/!\ this command will return sanitized paths. /!\

Examples
    clean the store
    > gm clean

    list the leaves of the store that would have to be cleaned
    > gm clean --list

## Signature
| input   | output       |
| ------- | ------------ |
| nothing | list<string> |
