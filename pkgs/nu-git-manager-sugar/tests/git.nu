use ../../../pkgs/nu-git-manager/nu-git-manager/fs/path.nu ["path sanitize"]
    use ../../../pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/lib/lib.nu [
    use ../../../pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/lib/prompt.nu [
    use ../../../pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/lib/style.nu [
        let actual = get-revision --short-hash true