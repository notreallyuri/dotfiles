#!/usr/bin/env lua

local capture_mode = arg[1]
local action = arg[2]
local home = os.getenv("HOME")

if not home then
	os.execute('notify-send "Screenshot Error" "$HOME is not set!"')
	os.exit(1)
end

local dir_img = home .. "/Pictures/Screenshots"
local dir_vid = home .. "/Videos/Recordings"
os.execute('mkdir -p "' .. dir_img .. '"')
os.execute('mkdir -p "' .. dir_vid .. '"')

local date = os.date("%Y-%m-%d-%H-%M-%S")
local file_img = dir_img .. "/" .. date .. ".png"
local file_vid = dir_vid .. "/" .. date .. ".mp4"

local function notify(title, msg)
	os.execute(string.format('notify-send "%s" "%s"', title, msg))
end

local function get_active_window_geom()
	local handle = io.popen("hyprctl activewindow -j | jq -r '\"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\"'")
	if not handle then
		return nil
	end
	local geom = handle:read("*a"):gsub("%s+", "")
	handle:close()
	if geom == "0,00x0" or geom == "" then
		return nil
	end
	return geom
end

local function freeze_screen()
	local handle = io.popen("hyprpicker -r -z >/dev/null 2>&1 & echo $!")
	if not handle then
		return nil
	end
	local pid = handle:read("*a"):match("%d+")
	handle:close()

	os.execute("sleep 0.1")
	return pid
end

local function unfreeze_screen(pid)
	if pid then
		os.execute("kill " .. pid .. " >/dev/null 2>&1")
	end
end

local function take_screenshot(mode, file)
	local success

	if mode == "full" then
		success = os.execute(string.format('grim "%s"', file))
	elseif mode == "region" then
		local pid = freeze_screen()
		success = os.execute(string.format('GEOM=$(slurp) && grim -g "$GEOM" "%s"', file))
		unfreeze_screen(pid)
	elseif mode == "window" then
		local geom = get_active_window_geom()
		if not geom then
			notify("Screenshot Error", "No active window found")
			return false
		end
		success = os.execute(string.format('grim -g "%s" "%s"', geom, file))
	else
		return false
	end

	return (success == 0 or success == true)
end

local function process_image(act, file)
	local f = io.open(file, "r")
	if not f then
		return
	end
	f:close()

	if act == "ocr" then
		if os.execute(string.format('tesseract "%s" - | wl-copy', file)) then
			notify("OCR Complete", "Text copied to clipboard.")
		else
			notify("OCR Failed", "Make sure tesseract is installed.")
		end
	elseif act == "search" then
		notify("Searching...", "Uploading image to Catbox.moe")

		local cmd = 'curl -sS -F "reqtype=fileupload" -F "fileToUpload=@' .. file .. '" https://catbox.moe/user/api.php'
		local handle = io.popen(cmd)

		if handle then
			local img_url = handle:read("*a"):gsub("%s+", "")
			handle:close()

			if img_url ~= "" and img_url:match("^http") then
				local lens_url = "https://lens.google.com/uploadbyurl?url=" .. img_url

				local browser_cmd = string.format('zen-browser "%s" >/dev/null 2>&1 &', lens_url)
				if not os.execute(browser_cmd) then
					notify("Browser Error", "Failed to launch zen-browser.")
				end
			else
				local err_msg = img_url ~= "" and img_url or "Empty response or timeout"
				notify("Search Failed", "Server returned: " .. err_msg)
			end
		else
			notify("System Error", "Failed to run curl command.")
		end
	end
end

local function handle_recording(mode, file)
	local is_running = os.execute("pgrep -x wf-recorder > /dev/null")
	if is_running == 0 or is_running == true then
		os.execute("killall -s SIGINT wf-recorder")
		notify("Recording Saved", "Video saved to Videos/Recordings")
	else
		local audio_flag = (mode == "recordsound") and "--audio " or ""
		local handle = io.popen("hyprctl activeworkspace -j | jq -r '.monitor'")
		local monitor = handle and handle:read("*a"):gsub("%s+", "") or ""
		if handle then
			handle:close()
		end

		local out_flag = monitor ~= "" and string.format('-o "%s"', monitor) or ""
		os.execute(string.format('wf-recorder %s %s -f "%s" & disown', audio_flag, out_flag, file))
		notify("Recording Started", "Capturing " .. monitor .. ".\nRun shortcut again to stop.")
	end
end

if capture_mode == "record" or capture_mode == "recordsound" then
	handle_recording(capture_mode, file_vid)
elseif capture_mode == "full" or capture_mode == "region" or capture_mode == "window" then
	if take_screenshot(capture_mode, file_img) then
		process_image(action, file_img)
	end
else
	notify("Error", string.format("Invalid mode: '%s'", capture_mode or "none"))
end
