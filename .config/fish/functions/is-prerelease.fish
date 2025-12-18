function is-prerelease --description "tests whether the version includes a pre-release tag"
    set -l version_input "$argv[1]"


    if not valid-version "$version_input" 
        echo "'$version_input' is not a valid version" >&2
        return 3
    end

    not semver -r '*' "$version_input" >/dev/null 2>&1
end
