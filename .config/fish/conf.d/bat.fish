# Replace cat with bat if available
if command -q bat
    function cat --wraps bat --description "bat (cat replacement)"
        bat $argv
    end
end
