local awful = require("awful")

local autorun = {}

function autorun.run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

function autorun.run()
	autorun.run_once("urxvtd")
	autorun.run_once("unclutter")
	autorun.run_once("compton --config ~/.config/compton.conf -GCb")
end

return autorun

