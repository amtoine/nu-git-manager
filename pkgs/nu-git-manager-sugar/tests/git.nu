use ../../../pkgs/nu-git-manager/nu-git-manager/fs path ["path sanitize"]
    use ../../../pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/lib git [
    use ../../../pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/lib prompt [
    use ../../../pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/lib style [
        let actual = get-revision --short-hash