#!/bin/sh

user="$(whoami)"
cachedir="/home/$user/.cache/yay"

rm -rf "$cachedir/protontricks"
rm -rf "$cachedir/avaloniailspy"

# sudo pacman -Syu
yay -Syu --answerclean None --answerdiff None --answeredit None --removemake --useask

removed="$(comm -23 <(basename -a $(find $cachedir -mindepth 1 -maxdepth 1 -type d) | sort) <(pacman -Qqm | sort) | xargs -r printf "$cachedir/%s\n")"

## Remove yay cache for foreign packages that are not installed anymore
rm -rf $removed

for pkgdir in "$cachedir"/*/; do

    pkgname=$(basename "$pkgdir")

    ## Remove untracked files (e. g. source/build files) excepting package files and main source files for installed version if non-git package
    if [[ ! "$pkgname" =~ ^.*-git$ ]]; then

        pkgver="$(pacman -Q $pkgname | cut -d ' ' -f2 | cut -d '-' -f1 | cut -d ':' -f2)"

        cd "$pkgdir"
        #rm -f $(git ls-files --others | grep -v -e '^.*\.pkg\.tar.*$' -e '^.*/$' -e "^.*$pkgver.*$" | xargs -r printf "$pkgdir/%s\n")
        git ls-files --others | grep -v -e '^.*\.pkg\.tar.*$' -e '^.*/$' -e "^.*$pkgver.*$" | xargs -r -I {} rm -f "$pkgdir/{}"

    fi

    rm -rf "$pkgdir"/src/

done

## Remove everything for uninstalled foreign packages, keep latest version for uninstalled native packages, keep two latest versions for installed packages
/usr/bin/paccache -qruk0 $cachedir/*/
/usr/bin/paccache -qruk1
/usr/bin/paccache -qrk2 -c /var/cache/pacman/pkg 
/usr/bin/paccache -qrk2 $cachedir/*/
