function _tide_item_git_wip
    # Only show if we're in a git repo
    if not command git rev-parse --git-dir &>/dev/null
        return
    end

    # Check if HEAD commit message contains --wip--
    if command git -c log.showSignature=false log -n 1 --format="%s" 2>/dev/null | string match -q '*--wip--*'
        _tide_print_item git_wip (set_color brred)'⚠ WIP'
    end
end
