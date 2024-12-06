use path.nu ["path sanitize"]

# clean all empty directories recursively, starting from a list of empty leaves
#
# /!\ this command will return sanitized paths /!\
export def clean-empty-directories-rec []: list<path> -> list<path> {
    let deleted = generate {|directories|
        let next = $directories | each {|it|
            rm --force $it

            let parent = $it | path dirname;
            if (ls $parent | is-empty) {
                $parent | path sanitize
            }
        }

        if ($next | is-empty) {
            {out: $directories}
        } else {
            {out: $directories, next: $next}
        }
    } $in

    $deleted | flatten
}
