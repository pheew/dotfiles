function latest-tags
    set -l prerelease "$argv[1]"

    if test -n $prerelease
        git tag --sort=version:refname --list "v*-$prerelease.*" | tail -n 10
    else
        git tag --list --sort=version:refname "v*" | awk '!/-.+$/ {print}' | tail -n 10
    end
end
