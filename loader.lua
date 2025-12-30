-- loader.lua
local BASE = "https://raw.githubusercontent.com/Iuppeka/PrisonLifeScriptAI/main/"

local function get(url)
    return game:HttpGet(url .. "?v=" .. tostring(os.time()), true)
end

-- get latest version
local latestVersion = get(BASE .. "version.txt")
latestVersion = latestVersion:gsub("%s+", "")

-- load main script
local success, err = pcall(function()
    loadstring(get(BASE .. "main.lua"))()
end)

if not success then
    warn("Script failed to load:", err)
else
    print("PrisonLifeScriptAI loaded | Version:", latestVersion)
end
