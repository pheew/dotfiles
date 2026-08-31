complete -c latest-tags -f
complete -c latest-tags -n "not __fish_seen_argument" \
    -a "(git tag --list 'v*-*' 2>/dev/null | string replace -r 'v[^-]*-([^.]+)\..*' '\$1' | sort -u)" \
    -d "prerelease identifier"
