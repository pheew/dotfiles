
# Git status
function Get-GitStatusPlain { git status }
New-Alias gst Get-GitStatusPlain

# git gui
function Git-Gui { git gui }
New-Alias gg Git-Gui

# gitk
function Git-History { gitk }
New-Alias gk Git-History

# gitk --all
function Git-History-All { gitk --all }
New-Alias gka Git-History-All

# gck
function Git-Checkout { git checkout }
New-Alias gck Git-Checkout

# cf / Concat-Files
function Concat-Files([string] $srcFiles, [string] $destFile) {
    Add-Content -path $destFile -value (Get-Content $srcFiles)
}
New-Alias cf Concat-Files