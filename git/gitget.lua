--[[ /gitget
GitHub downloading utility for CC.
Developed by apemanzilla.
Direct link: http://pastebin.com/raw.php?i=6aMMzdwd
 
If you want to use this as an automated installer, please see lines 13 and 23.
 
This requires ElvishJerricco's JSON parsing API.
Direct link: http://pastebin.com/raw.php?i=4nRg9CHU
]]--
 
local args = {...}
 
--Remove the line above this and change the lines below to use automated mode.
local automated = true                                                  -- Don't touch!
local hide_progress = true                                              -- If true, will not list out files as they are downloaded
args[1] = "mbainter"                                                    -- Github username
args[2] = "BregOS"                                                -- Github repo name
args[3] = nil                                                                   -- Branch - defaults to "master"
args[4] = nil                                                                   -- Path - defaults to root ("/")
local pre_dl = "print('Starting download...')"  -- Command(s) to run before download starts.
local post_dl = "print('Download complete!')"   -- Command(s) to run after download completes.
--Remove the line below this and change the lines below to use automated mode.
 
args[3] = args[3] or "master"
args[4] = args[4] or ""
 
if not automated and #args < 2 then
        print("Usage:\n"..shell.getRunningProgram().." <user> <repo> [branch=master] [path=/]") error()
end
 
local function save(data,file)
        local file = shell.resolve(file)
        if not (fs.exists(string.sub(file,1,#file - #fs.getName(file))) and fs.isDir(string.sub(file,1,#file - #fs.getName(file)))) then
                if fs.exists(string.sub(file,1,#file - #fs.getName(file))) then fs.delete(string.sub(file,1,#file - #fs.getName(file))) end
                fs.makeDir(string.sub(file,1,#file - #fs.getName(file)))
        end
        local f = fs.open(file,"w")
        f.write(data)
        f.close()
end
 
local function download(url, file)
        save(http.get(url).readAll(),file)
end

if not json then
        print("Downloading JSON api...\n(Credits to ElvishJerricco!)")
        --download("http://pastebin.com/raw.php?i=4nRg9CHU","json")
        download("https://raw.github.com/"..args[1].."/"..args[2].."/"..args[3].."/git/json.lua","json")
        os.loadAPI("json")
end
 
if pre_dl then loadstring(pre_dl)() else print("Downloading files from github....") end
local data = json.decode(http.get("https://api.github.com/repos/"..args[1].."/"..args[2].."/git/trees/"..args[3].."?recursive=1").readAll())
if data.message and data.message == "Not found" then error("Invalid repository",2) else
	for k,v in pairs(data.tree) do
		-- Make directories
		if v.type == "tree" then
			fs.makeDir(fs.combine(args[4],v.path))
			if not hide_progress then
				print(v.path)
			end
		end
	end
	for k,v in pairs(data.tree) do
		-- Download files
		if v.type == "blob" then
			download("https://raw.github.com/"..args[1].."/"..args[2].."/"..args[3].."/"..v.path,fs.combine(args[4],v.path))
			if not hide_progress then
				print(v.path)
			end
		end
	end
end
if post_dl then loadstring(post_dl)() end
