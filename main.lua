-- main.lua
local SCRIPT_VERSION = "1.0.0"
print("Running PrisonLifeScriptAI v" .. SCRIPT_VERSION)

-- your actual script code below

-- FULLY FIXED ROBLOX LOCAL SCRIPT
-- Movement, ESP per team, Armor/GodMode, clean GUI with proper pages

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local Settings = {
    WalkSpeed = 16,
    JumpPower = 50,
    ESPEnabled = true,
    ESPTeamToggles = {},
    ArmorEnabled = false,
    Page = 1
}

-- APPLY WALK/JUMP
local function applyWalkJump()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.WalkSpeed = Settings.WalkSpeed
        hum.JumpPower = Settings.JumpPower
    end
end

-- ARMOR / GOD MODE
local function applyArmor()
    if not LocalPlayer.Character then return end
    local char = LocalPlayer.Character
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum.Died:Connect(function() task.wait(0.1) hum.Health = math.huge end)
    end
    if char:FindFirstChild("__Armor") then char.__Armor:Destroy() end
    local folder = Instance.new("Folder", char)
    folder.Name = "__Armor"
    for _,p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            local adorn = Instance.new("BoxHandleAdornment")
            adorn.Adornee = p
            adorn.Size = p.Size + Vector3.new(0.1,0.1,0.1)
            adorn.Color3 = Color3.fromRGB(120,120,120)
            adorn.Transparency = 0.4
            adorn.ZIndex = 5
            adorn.AlwaysOnTop = true
            adorn.Parent = folder
        end
    end
end

local function removeArmor()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("__Armor") then
        LocalPlayer.Character.__Armor:Destroy()
    end
end

-- ESP
local ESP = {}
local function refreshESP()
    if not Settings.ESPEnabled then for _,h in pairs(ESP) do h:Destroy() end ESP = {} return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and Settings.ESPTeamToggles[p.Team.Name] ~= false then
            if ESP[p] then ESP[p]:Destroy() end
            local h = Instance.new("Highlight")
            h.FillColor = p.TeamColor.Color
            h.FillTransparency = 0.4
            h.OutlineTransparency = 1
            h.Parent = p.Character
            ESP[p] = h
        end
    end
end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.2) refreshESP() end) end)
RunService.Heartbeat:Connect(refreshESP)

-- GUI
local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.55,0.7)
main.Position = UDim2.fromScale(0.5,0.5)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromScale(1,0.1)
title.Text = "CONTROL PANEL"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(200,200,200)
title.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", title)

local content = Instance.new("Frame", main)
content.Size = UDim2.fromScale(1,0.8)
content.Position = UDim2.fromScale(0,0.1)
content.BackgroundTransparency = 1

local items = {}
local function clear() for _,v in ipairs(items) do v:Destroy() end items={} end
local function label(text,y)
    local l = Instance.new("TextLabel", content)
    l.Size = UDim2.fromScale(0.9,0.08)
    l.Position = UDim2.fromScale(0.05,y)
    l.Text = text
    l.Font = Enum.Font.GothamBold
    l.TextScaled = true
    l.TextColor3 = Color3.fromRGB(180,180,180)
    l.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Instance.new("UICorner", l)
    table.insert(items,l)
end
local function button(text,y,cb)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.fromScale(0.9,0.07)
    b.Position = UDim2.fromScale(0.05,y)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextScaled = true
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(cb)
    table.insert(items,b)
end

local function slider(min,max,y,default,callback)
    local frame = Instance.new("Frame", content)
    frame.Size = UDim2.fromScale(0.9,0.06)
    frame.Position = UDim2.fromScale(0.05,y)
    frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Instance.new("UICorner", frame)

    local fill = Instance.new("Frame", frame)
    fill.Size = UDim2.fromScale((default-min)/(max-min),1)
    fill.BackgroundColor3 = Color3.fromRGB(0,200,255)
    Instance.new("UICorner", fill)

    local uis = UserInputService
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn
            conn = uis.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = math.clamp((i.Position.X-frame.AbsolutePosition.X)/frame.AbsoluteSize.X,0,1)
                    fill.Size = UDim2.fromScale(pos,1)
                    callback(min + (max-min)*pos)
                end
            end)
            uis.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then conn:Disconnect() end end)
        end
    end)
end

-- PAGE UPDATE
function updatePage()
    clear()
    if Settings.Page==1 then
        label("Movement Sliders",0.05)
        slider(16,500,0.16,Settings.WalkSpeed,function(v) Settings.WalkSpeed=v; applyWalkJump() end)
        slider(50,500,0.28,Settings.JumpPower,function(v) Settings.JumpPower=v; applyWalkJump() end)
    elseif Settings.Page==2 then
        label("ESP / Team Toggles",0.05)
        local y=0.15
        for _,team in ipairs(Players:GetTeams()) do
            if Settings.ESPTeamToggles[team.Name]==nil then Settings.ESPTeamToggles[team.Name]=true end
            button(team.Name..(Settings.ESPTeamToggles[team.Name] and " ON" or " OFF"),y,function()
                Settings.ESPTeamToggles[team.Name]=not Settings.ESPTeamToggles[team.Name]; updatePage(); refreshESP()
            end)
            y+=0.08
        end
    elseif Settings.Page==3 then
        label("Armor / God Mode",0.05)
        button(Settings.ArmorEnabled and "Disable Armor" or "Enable Armor",0.18,function()
            Settings.ArmorEnabled=not Settings.ArmorEnabled
            if Settings.ArmorEnabled then applyArmor() else removeArmor() end
            updatePage()
        end)
    end
end

-- NAVIGATION
local prev = Instance.new("TextButton", main)
prev.Size=UDim2.fromScale(0.12,0.06)
prev.Position=UDim2.fromScale(0.02,0.92)
prev.Text="<"
prev.BackgroundColor3=Color3.fromRGB(45,45,45)
Instance.new("UICorner", prev)
prev.MouseButton1Click:Connect(function() Settings.Page=math.max(1,Settings.Page-1); updatePage() end)

local next = Instance.new("TextButton", main)
next.Size=UDim2.fromScale(0.12,0.06)
next.Position=UDim2.fromScale(0.86,0.92)
next.Text=">"
next.BackgroundColor3=Color3.fromRGB(45,45,45)
Instance.new("UICorner", next)
next.MouseButton1Click:Connect(function() Settings.Page=math.min(3,Settings.Page+1); updatePage() end)

updatePage()

-- Ensure Humanoid updates on respawn
LocalPlayer.CharacterAdded:Connect(function(char) task.wait(0.2); applyWalkJump(); if Settings.ArmorEnabled then applyArmor() end end)

