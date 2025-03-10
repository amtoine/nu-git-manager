use std log

def main [package_file: path] {
    let pkg_root = $package_file | path dirname
    let pkg = open $package_file

    let module_dir = $env.NUPM_HOME | path join "modules"
    log info "ensuring Nupm's module directory exists"
    log debug $"making directory `($module_dir)`"
    mkdir $module_dir

    log info "cleaning previous installation"
    log debug $"removing directory `($module_dir | path join $pkg.name)`"
    rm --recursive --force ($module_dir | path join $pkg.name)

    log info "installing package"
    log debug $"copying `($pkg_root | path join $pkg.name)` to `($module_dir)`"
    cp -r ($pkg_root | path join $pkg.name) $module_dir

    log info "preparing `gm version` command"
    let n = ^git -C $pkg_root describe | parse "{v}-{n}-{r}" | into record | get n? | default 0
    let version_cmd = [
         "# see the version of NGM that is currently installed",
         "#",
         "# # Examples",
         "# ```nushell",
         "# # get the version of NGM",
         "# gm version",
         "# ```",
         "export def \"gm version\" []: nothing -> record<version: string, branch: string, commit: string, date: datetime> {",
         "    {",
        $"        version: \"($pkg.version)+($n)\",",
        $"        branch: \"(^git -C $pkg_root branch --show-current)\",",
        $"        commit: \"(^git -C $pkg_root rev-parse HEAD)\",",
        $"        date: \((date now | to nuon)\),",
         "    }",
         "}",
    ]

    let mod = $env.NUPM_HOME | path join "modules" $pkg.name "mod.nu"
    log info $"dumping `gm version` to `($mod)`"
    "\n" | save --append $mod
    $version_cmd | str join "\n" | save --append $mod
}

