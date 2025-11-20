# set --query XDG_DATA_HOME || set --local XDG_DATA_HOME ~/.local/share
# set --query nvm_mirror || set --global nvm_mirror https://nodejs.org/dist
# set --query nvm_data || set --global nvm_data $XDG_DATA_HOME/nvm

if status is-interactive

    # yarn
    abbr --add y yarn
    abbr --add yi yarn install
end
