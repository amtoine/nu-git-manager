# nu-git-manager
A collection of `nushell` tools to manage `git` repositories.

## installation
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
use nu-git-manager/mod.nu *                # loads the main `gm` module

# the following are non-essential modules
use nu-git-manager/sugar/git.nu            # load `git` tool extensions
use nu-git-manager/sugar/gh.nu             # load commands to interact with *GitHub*
use nu-git-manager/sugar/gist.nu           # load commands to interact with *GitHub* gists
use nu-git-manager/sugar/completions.nu *  # load some `git` completion
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
