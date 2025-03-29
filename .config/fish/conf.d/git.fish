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
end
