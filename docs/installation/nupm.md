i like to use the `nupm` package manager for Nushell :yum:

- first install the package manager [here](https://github.com/amtoine/nupm/tree/main#recycle-installation)
- then install `nu-git-manager` with a simple
```nu
nupm install https://github.com/amtoine/nu-git-manager.git
```
- finally you can activate commands and modules with something like
```nu
nupm activate nu-git-manager gm
nupm activate nu-git-manager sugar git
nupm activate nu-git-manager sugar gh
nupm activate nu-git-manager sugar gist
nupm activate nu-git-manager sugar completions git *
nupm activate nu-git-manager sugar dotfiles
```
