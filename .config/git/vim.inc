[mergetool "nvim"]
	cmd = nvim -f -c \"Gvdiffsplit!\" \"$MERGED\"
[merge]
	tool = nvim
[mergetool]
	keepBackup = false
	prompt = false
