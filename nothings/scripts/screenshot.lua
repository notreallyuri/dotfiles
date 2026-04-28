#!/usr/bin/env lua

local mode = arg[1]
local dir = os.getenv("HOME") .. "/Pictures/Screenshots"

os.execute('mkdir -p "' .. dir .. '"')

local date = os.date("%Y-%m-%d-%H-%M-%S")
local file = dir .. "/" .. date .. ".png"

local function exec()
	local f = io.open(file, "r")
	if f then
		f:close()
		os.execute('wl-copy < "' .. file .. '"')
	end
end

if mode == "full" then
	local success = os.execute(string.format('GEOM=$(slurp) && grim -g "$GEOM" "%s"', file))
	if success == 0 or success == true then
		exec()
	end
elseif mode == "window" then
	local handle = io.popen("hyprctl activewindow -j | jq -r '\"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\"'")
	local geom = handle:read("*a"):gsub("%s+", "")
	handle:close()

	if geom == "0,00x0" or geom == "" then
		os.execute('notify-send "Screenshot" "No active window found"')
		os.exit(1)
	end

	os.execute(string.format('grim -g "%s" "%s"', geom, file))
	exec()
else
	os.execute(string.format('notify-send "Screenshot" "Invalid mode: %s"', mode or "none"))
	os.exit(1)
end
