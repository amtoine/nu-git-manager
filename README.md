# nu-git-manager
A collection of `nushell` tools to manage `git` repositories.

## installation
> **Warning**
> `gm` requires the use of `nushell` after [nushell/nushell#9066]
> e.g. from any branch / commit based on [`a2a346e39`].
>
> alternatively, you can use any revision of `nu-git-manager`
> before #21.

one way to install `nu-git-manager` right now is the following
- clone the repo to a location you want it to be
```nu
# env.nu
let-env NU_LIB_PATH = "/path/to/libs"
```
```nu
git clone https://github.com/amtoine/nu-git-manager.git ($env.NU_LIB_PATH | path join "nu-git-manager")
```
- make it loadable in your `NU_LIB_DIRS`
```nu
let-env NU_LIB_DIRS = ($env.NU_LIB_DIRS | append $env.NU_LIB_PATH)
```
- update it sometimes to have the latest
```nu
git -C ($env.NU_LIB_PATH | path join "nu-git-manager") pull
```

## usage
in your `config.nu` you can add the following to load `nu-git-manager` modules:
```nu
# config.nu

# load the main `gm` module
use nu-git-manager/gm

# the following are non-essential modules
use nu-git-manager/sugar/git.nu                # load `git` tool extensions
use nu-git-manager/sugar/gh.nu                 # load commands to interact with *GitHub*
use nu-git-manager/sugar/gist.nu               # load commands to interact with *GitHub* gists
use nu-git-manager/sugar/completions/git.nu *  # load some `git` completion
```

then you have access to the whole `nu-git-manager` suite :partying:

do not hesitate to run one of the following to have more information about what `nu-git-manager` has to offer :thumbsup:
```nu
help gm
# or
gm
```
```nu
help modules git
```
```nu
help modules gh
```
```nu
help modules gist
# or
gist
```

[nushell/nushell#9066]: https://github.com/nushell/nushell/pull/9066
[`a2a346e39`]: https://github.com/nushell/nushell/commit/a2a346e39c53e386b97d8d7f9a05ed58298e8789
