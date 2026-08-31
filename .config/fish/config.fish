if status is-interactive
    # Commands to run in interactive sessions can go here

    # Enable vi mode
    fish_vi_key_bindings

    if command -q nvim
        set -gx EDITOR nvim
    end

    # force commands to output colored output
    set -gx CLICOLOR_FORCE 1

    # pipe shortcuts
    abbr --add --position anywhere G '| grep'
    abbr --add --position anywhere H '| head'
    abbr --add --position anywhere T '| tail'

    abbr --add reload fish

    abbr --add l ls -lFh

    fish_add_path ~/.local/bin

end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/niek/.cache/lm-studio/bin
# End of LM Studio CLI section

set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
