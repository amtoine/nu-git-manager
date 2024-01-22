use ../../../tests/common/setup.nu [run-with-env]

use ../../../pkgs/nu-git-manager/nu-git-manager/ ["gm clone", "gm update-cache"]
use ../../../pkgs/nu-git-manager-sugar/nu-git-manager-sugar/ extra ["gm report"]

export def report [] {
    run-with-env {
        use std assert

        gm update-cache
        gm clone https://github.com/amtoine/nu-git-manager --depth 1

        assert equal (gm report) []
    }
}
