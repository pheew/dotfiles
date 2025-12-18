# Open Claude Code in a specific directory
function claude-in
    cd $argv[1] && claude
end

if status is-interactive
    abbr --add claude-vault "claude-in ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Personal"
end
