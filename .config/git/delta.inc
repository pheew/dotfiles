[pager]
    diff = delta
    log = delta
    reflog = delta
    show = delta

[interactive]
    diffFilter = delta --color-only --features=interactive

[delta]
	features = decorations
	syntax-theme = Solarized (light)
	side-by-side = true
	tabs = 4

[delta "interactive"]
    keep-plus-minus-markers = false

[delta "decorations"]
    commit-decoration-style = blue ol
    commit-style = raw
    file-style = omit
    hunk-header-decoration-style = blue box
    hunk-header-file-style = red
    hunk-header-line-number-style = "#067a00"
    hunk-header-style = file line-number syntax
