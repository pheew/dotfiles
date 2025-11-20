if status is-interactive
    abbr --add g git

    #checkout
    abbr --add gco git checkout

    # fetch
    abbr --add gf git fetch

    # status
    abbr --add gst git status
    abbr --add gss git status --short

    # pull
    abbr --add gpr git pull --rebase

    # push
    abbr --add gp git push

    # add
    abbr --add ga git add
    abbr --add gapa git add --patch

    # commit
    abbr --add gc! git commit --amend
    abbr --add gcmsg git commit -m

    # diff
    abbr --add gd git diff
    abbr --add gds git diff --staged

    # log
    abbr --add glol git log

    function gwip -d "Commits all open changes into a WIP commit. Undo with the gunwip function"
        git add -A
        git rm $(git ls-files --deleted) 2>/dev/null
        git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"
    end

    function gunwip -d "When there's a WIP commit, undo it and leave changes on working copy"
        git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1
    end

    # checks if in WIP mode
    function _tid_item_git_wip
        command git -c log.showSignature=false log -n 1 2>/dev/null | grep -q -- --wip-- && echo "WIP!!"
    end
end
