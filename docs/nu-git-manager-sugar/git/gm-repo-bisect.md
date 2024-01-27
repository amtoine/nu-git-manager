# `gm repo bisect` from `nu-git-manager-sugar git` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/mod.nu#L384))
bisect a worktree by running a piece of code repeatedly

# Examples
```nushell
# find a bug that was introduced in Nushell in `nushell/nushell
gm repo bisect --good 0.89.0 --bad 4458aae {
    cargo run -- -n -c "def foo [x: list<string>] { $x }; foo []"
}
```
```
724818030dd1de392c54788eab5030074d694ecd
```
---
```nushell
# avoid running the test twice more if it is expensive and you're sure
# `--good` and `--bad` are indeed "good" and "bad"
gm repo bisect --good $good --bad $bad --no-check $test
```

## Parameters
- `test` <`closure()`>: the code to run to check a given revision, should return a non-zero exit code for bad revisions
- `--good` <`string`>: the initial known "good" revision
- `--bad` <`string`>: the initial known "bad" revision
- `--no-check` <`bool`>: don't check if `--good` and `--bad` are indeed "good" and "bad"


## Signatures
| input     | output   |
| --------- | -------- |
| `nothing` | `string` |
