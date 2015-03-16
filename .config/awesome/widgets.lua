local wibox = require("wibox")
local awful = require("awful")
local lain = require("lain")
local beautiful = require("beautiful")

-- Spacer
local spacer = wibox.widget.textbox(" ")
local markup      = lain.util.markup

-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = awful.widget.textclock(markup("#7788af", "%A %d %B ") .. markup("#343639", ">") .. markup("#de5e1e", " %H:%M "))

-- Calendar
lain.widgets.calendar:attach(mytextclock, { font_size = 10 })

-- / fs
fsicon = wibox.widget.imagebox(beautiful.widget_fs)
fswidget = lain.widgets.fs({
    settings  = function()
        widget:set_markup(markup("#80d9d8", fs_now.used .. "% "))
    end
})

--[[ Mail IMAP check
-- commented because it needs to be set before use
mailicon = wibox.widget.imagebox()
mailicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn(mail) end)))
mailwidget = lain.widgets.imap({
    timeout  = 180,
    server   = "server",
    mail     = "mail",
    password = "keyring get mail",
    settings = function()
        if mailcount > 0 then
            mailicon:set_image(beautiful.widget_mail)
            widget:set_markup(markup("#cccccc", mailcount .. " "))
        else
            widget:set_text("")
            mailicon:set_image(nil)
        end
    end
})
]]

-- CPU
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
cpuwidget = lain.widgets.cpu({
    settings = function()
        widget:set_markup(markup("#e33a6e", cpu_now.usage .. "% "))
    end
})

-- Coretemp
tempicon = wibox.widget.imagebox(beautiful.widget_temp)
tempwidget = lain.widgets.temp({
    settings = function()
        widget:set_markup(markup("#f1af5f", coretemp_now .. "°C "))
	end
})


-- Battery
baticon = wibox.widget.imagebox(beautiful.widget_batt)
batwidget = lain.widgets.bat({
    settings = function()
        if bat_now.perc == "N/A" then
            bat_now.perc = "AC "
        else
            bat_now.perc = bat_now.perc .. "% "
        end
        widget:set_text(bat_now.perc)
    end
})

-- ALSA volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.alsa({
    settings = function()
        if volume_now.status == "off" then
            volume_now.level = volume_now.level .. "M"
        end

        widget:set_markup(markup("#7493d2", volume_now.level .. "% "))
    end
})

-- Net
netdownicon = wibox.widget.imagebox(beautiful.widget_netdown)
--netdownicon.align = "middle"
netdowninfo = wibox.widget.textbox()
netupicon = wibox.widget.imagebox(beautiful.widget_netup)
--netupicon.align = "middle"
netupinfo = lain.widgets.net({
    settings = function()
        --if iface ~= "network off" and
           --string.match(yawn.widget._layout.text, "N/A")
        --then
            --yawn.fetch_weather()
        --end

        widget:set_markup(markup("#e54c62", net_now.sent .. " "))
        netdowninfo:set_markup(markup("#87af5f", net_now.received .. " "))
    end
})

-- MEM
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = lain.widgets.mem({
    settings = function()
        widget:set_markup(markup("#e0da37", mem_now.used .. "M "))
    end
})

-- MPD
mpdicon = wibox.widget.imagebox()
mpdwidget = lain.widgets.mpd({
    settings = function()
        mpd_notification_preset = {
            text = string.format("%s [%s] - %s\n%s", mpd_now.artist,
                   mpd_now.album, mpd_now.date, mpd_now.title)
        }

        if mpd_now.state == "play" then
            artist = mpd_now.artist .. " > "
            title  = mpd_now.title .. " "
            mpdicon:set_image(beautiful.widget_note_on)
        elseif mpd_now.state == "pause" then
            artist = "mpd "
            title  = "paused "
        else
            artist = ""
            title  = ""
            mpdicon:set_image(nil)
        end
        widget:set_markup(markup("#e54c62", artist) .. markup("#b2b2b2", title))
    end
})


--left_layout:add(mypromptbox[s])
--left_layout:add(mpdicon)
--left_layout:add(mpdwidget)

--right_layout:add(netdownicon)
--right_layout:add(netdowninfo)
--right_layout:add(netupicon)
--right_layout:add(netupinfo)
--right_layout:add(volicon)
--right_layout:add(volumewidget)
--right_layout:add(memicon)
--right_layout:add(memwidget)
--right_layout:add(cpuicon)
--right_layout:add(cpuwidget)
--right_layout:add(fsicon)
--right_layout:add(fswidget)
----right_layout:add(weathericon)
----right_layout:add(yawn.widget)
--right_layout:add(tempicon)
--right_layout:add(tempwidget)
--right_layout:add(baticon)
--right_layout:add(batwidget)
--right_layout:add(clockicon)
--right_layout:add(mytextclock)


local widgets = {
	top = {
		left = {
			mpdicon,
			mpdwidget
		},
		right = {
			netdownicon,
			netdowninfo,
			netupicon,
			netupinfo,
			volicon,
			volumewidget,
			memicon,
			memwidget,
			cpuicon,
			cpuwidget,
			fsicon,
			fswidget,
			tempicon,
			tempwidget,
			baticon,
			batwidget,
			clockicon,
			mytextclock
		}
	}
}

return widgets
