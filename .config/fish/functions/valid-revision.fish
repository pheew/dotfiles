function valid-revision --argument-names revision
    git rev-parse "$revision" >/dev/null 2>&1
end
