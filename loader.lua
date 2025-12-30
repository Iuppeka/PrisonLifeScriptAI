-- loader.lua
local BASE = "https://raw.githubusercontent.com/Iuppeka/PrisonLifeScriptAI/main/"

-- Helper function to fetch code safely
local function safeHttpGet(url)
    local success, result = pcall(function()
        return game:HttpGet(url .. "?v=" .. tick(), true)
    end)
    if not success then
        warn("HttpGet failed:", result)
        return nil
    end
    return result
end

-- Fetch main.lua
local code = safeHttpGet(BASE .. "main.lua")
if not code then
    warn("Failed to fetch main.lua")
    return
end

-- Load and run main.lua safely
local fn, err = loadstring(code)
if not fn then
    warn("Loadstring failed:", err)
    return
end

local ok, runErr = pcall(fn)
if not ok then
    warn("Error running main.lua:", runErr)
else
    print("PrisonLifeScriptAI loaded successfully!")
end
