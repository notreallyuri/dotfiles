local M = {}

math.randomseed(os.time())

local json_decode

if _G.vim and vim.json then
	json_decode = vim.json.decode
else
	local ok, dkjson = pcall(require, "dkjson")
	if not ok then
		error("No JSON decoder available (vim.json or dkjson)")
	end
	json_decode = dkjson.decode
end

local base_path = os.getenv("HOME") .. "/.config/nothings"
local data_path = base_path .. "/cringe.json"
local ascii_path = base_path .. "/ascii"

local function load_json()
	local file, err = io.open(data_path, "r")
	if not file then
		error("Failed to open " .. data_path .. ": " .. err)
	end

	local content = file:read("*a")
	file:close()

	return json_decode(content)
end

function M.random_text()
	local data = load_json()
	local category = data.weights[math.random(#data.weights)]
	local pool = data[category]
	return pool[math.random(#pool)]
end

local function list_files(dir)
	local files = {}
	local p = io.popen('ls -1 "' .. dir .. '" 2>/dev/null')
	if not p then
		return files
	end

	for name in p:lines() do
		table.insert(files, name)
	end

	p:close()
	return files
end

function M.list_ascii(opts)
	opts = opts or {}
	local dir = ascii_path
	if opts.mini then
		dir = dir .. "/mini"
	end
	return list_files(dir)
end

function M.ascii(name, opts)
	opts = opts or {}
	local dir = ascii_path

	if opts.mini then
		dir = dir .. "/mini"
	end

	if not name then
		local files = list_files(dir)
		if #files == 0 then
			return nil
		end
		name = files[math.random(#files)]
	end

	local path = dir .. "/" .. name
	local file = io.open(path, "r")
	if not file then
		return nil
	end

	local content = file:read("*a")
	file:close()
	return content
end

return M
