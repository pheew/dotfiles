function valid-version
    set -l revision "$argv[1]"

    if not type -q semver
        echo "Can't find semver, need it to check the validity of a version"
        return 1
    end

    semver "$revision" >/dev/null 2>&1
end
