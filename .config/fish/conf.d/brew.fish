if status is-interactive

    if test "$(uname)" = Darwin
        set -l brew_bin "/usr/local/homebrew/bin/brew"
        if test "$(arch)" = "arm64"
            set brew_bin "/opt/homebrew/bin/brew"
        end

        if test -e "$brew_bin"
            # set -l brew_prefix $($brew_bin config | awk -F ': ' '/HOMEBREW_PREFIX/ {print $2}')
            set -gx HOMEBREW_NO_AUTO_UPDATE yes

            fish_add_path "$brew_prefix/bin" "$brew_prefix/sbin"
            /opt/homebrew/bin/brew shellenv | source

            alias bubo "brew update && brew outdated"
            alias bugbc "brew upgrade --greedy && brew cleanup"
            abbr --add bubu "bubo && bugbc"
        end
    end

    # echo "Loading nvm"
    # if path is ~/.nvm/nvm.sh
    #     echo "Script exists"
    #     set -gx NVM_DIR $(path filter -d "$XDG_CONFIG_HOME/.nvm"  "$HOME/.nvm")
    #     echo "NVM_DIR $NVM_DIR"
    #
    #     if path is $NVM_DIR/nvm.sh
    #         source $NVM_DIR/./nvm.sh --no-use # This loads nvm
    #     end
    #     set -l NVM_SYMLINK_CURRENT "true"
    #
    #     fish_add_path "~/.nvm/current/bin"
    # end
end
