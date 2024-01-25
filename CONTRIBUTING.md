# how to contribute to NGM
this page is a very simple document with some notions about NGM and things to
follow when willing to contribute.
nothing too fancy, just to set the bar of the project :wink:

## structure of the project
NGM ships two Nushell packages
- `nu-git-manager`: the main package that defines the `gm` command and most
  important subcommands
```
pkgs/
`-- nu-git-manager
    |-- nu-git-manager
    |   |   ...              # any internal or public module should go there
    |   `-- mod.nu
    |-- nupm.nuon
    `-- tests
        |   ...              # test modules should go there
        `-- mod.nu
```
- `nu-git-manager-sugar`: an optional package that ships additional `gm`
  subcommands or other Git-related modules
```
pkgs/
`-- nu-git-manager-sugar
    |-- nu-git-manager-sugar
    |   |   ...              # any internal or public module should go there
    |   `-- mod.nu
    |-- nupm.nuon
    `-- tests
        |   ...              # test modules should go there
        `-- mod.nu
```

## conventions
- all commands should be named as a subcommand of `gm`, e.g. `gm foo bar my-super-cmd`
- command names should be put inside quotes (`"`), e.g. `def "foo"` instead of `def foo`
