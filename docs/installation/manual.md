one way to install `nu-git-manager` right now is the following manual process

> **Note**  
> let's say you have defined the following environment variable
> ```nu
> # in `$nu.env-path`
> $env.NU_LIB_PATH = "/path/to/libs"
> ```

- clone the repo to a location you want it to be
```nu
git clone https://github.com/amtoine/nu-git-manager.git ($env.NU_LIB_PATH | path join "nu-git-manager")
```
- make it loadable in your `NU_LIB_DIRS`
```nu
# in `$nu.env-path`
$env.NU_LIB_DIRS = ($env.NU_LIB_DIRS | append $env.NU_LIB_PATH)
```
- update it regularly to have the latest version
```nu
git -C ($env.NU_LIB_PATH | path join "nu-git-manager") pull
```
