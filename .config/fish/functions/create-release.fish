function create-release \
    --description "creates a release in github" \
    --argument-names new_version source_version target_ref

    # set -f $new_version "$argv[1]"
    # set -f $source_version "$argv[2]"
    # set -f $target_ref "$argv[3]"

    if test -z "$target_ref"
        set -f target_ref "HEAD"
        echo "Did not receive explicit ref to release. Using HEAD"
    end

    if not valid-revision "$target_ref"
        echo "$target_ref doesn't seem to exist. You might need to fetch first" >&2
        return 2
    end

    if not valid-version "$new_version"
        echo "$new_version is not a valid semver version" >&2
        return 3
    end

    if not valid-revision "$source_version"
        echo "$source_version doesn't seem to exist. You might need to fetch first" >&2
        return 4
    end

    set -f changelog (
        npx --quiet --yes \
            --package @grandvisionhq/release-tools@latest changelog "$new_version" \
            --no-header \
            --source-version "$source_version" \
            --target-ref "$target_ref"
    )

    if test -z "$changelog"
        echo "Generating changelog failed, aborting" >&2
        return 5
    end

    set -f release_args "$new_version"
    set -a release_args \
        "--title $new_version" \
        "--target $target_ref" \
        "--notes-file -"

    if is-prerelease "$new_version"
        set -p release_args "--prerelease"
    end


    echo "args"
    echo "$release_args"

    echo "$changelog" | gh release create $release_args
end
