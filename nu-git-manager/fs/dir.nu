# Cross platform wrapper to open a directory, a file or a URL in the default application
export def open-item [pth:path] {

    let cmd = match $nu.os-info.name {
        "windows" => "explorer",
        "macos" => "open",
        "linux" => "xdg-open"
    }

    ^$cmd $pth

}

