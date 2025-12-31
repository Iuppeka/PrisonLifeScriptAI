-- FULL ALL-IN-ONE FINAL SCRIPT (WITH FIXED ESP + HEAL + TELEPORTS + GUI)

repeat task.wait() until game:IsLoaded()

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--------------------------------------------------
-- SETTINGS
--------------------------------------------------
local Settings = {
    Page = 1,

    -- AIMBOT
    Aimbot = false,
    AimbotFOV = 120,
    AimbotSmooth = 0.08,
    AimbotPart = "Head",

    -- ESP
    ESP = true,
    ESPColors = {
        Guards = Color3.fromRGB(0,170,255),
        Inmates = Color3.fromRGB(255,170,0),
        Criminals = Color3.fromRGB(255,60,60)
    },

    -- Movement
    WalkSpeed = 16,
    JumpPower = 50,

    -- Heal
    HealEnabled = false,

    SpawnCFrame = nil
}

--------------------------------------------------
-- TEAM SPAWNS
--------------------------------------------------
local TeamSpawns = {
    Guards = CFrame.new(818.1,100,2235.8),
    Inmates = CFrame.new(792.6,98,2457.7),
    Criminals = CFrame.new(897,112,2209)
}

--------------------------------------------------
-- SAVE SPAWN
--------------------------------------------------
local function saveSpawn()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        Settings.SpawnCFrame = c.HumanoidRootPart.CFrame
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    saveSpawn()
end)
saveSpawn()

--------------------------------------------------
-- COORDINATES HUD
--------------------------------------------------
local coordGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
coordGui.ResetOnSpawn = false
local coord = Instance.new("TextLabel", coordGui)
coord.Size = UDim2.fromScale(0.23,0.05)
coord.Position = UDim2.fromScale(0.01,0.01)
coord.BackgroundColor3 = Color3.fromRGB(20,20,20)
coord.TextColor3 = Color3.fromRGB(0,200,255)
coord.Font = Enum.Font.GothamBold
coord.TextScaled = true
Instance.new("UICorner",coord)

RunService.RenderStepped:Connect(function()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        local p = c.HumanoidRootPart.Position
        coord.Text = string.format("X %.1f  Y %.1f  Z %.1f", p.X,p.Y,p.Z)
    end
end)

--------------------------------------------------
-- AIMBOT + FOV CIRCLE
--------------------------------------------------
local fovGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
fovGui.ResetOnSpawn = false

local circle = Instance.new("Frame", fovGui)
circle.AnchorPoint = Vector2.new(0.5,0.5)
circle.Position = UDim2.fromScale(0.5,0.5)
circle.BackgroundTransparency = 1
circle.BorderSizePixel = 2
circle.BorderColor3 = Color3.fromRGB(0,200,255)
circle.Visible = false
Instance.new("UICorner",circle).CornerRadius = UDim.new(1,0)

UserInputService.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.E then
        Settings.Aimbot = not Settings.Aimbot
        circle.Visible = Settings.Aimbot
    elseif i.KeyCode == Enum.KeyCode.Z then
        if Settings.SpawnCFrame and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Settings.SpawnCFrame
        end
    end
end)

local function validTarget(p)
    if p == LocalPlayer then return false end
    if not p.Character or not p.Character:FindFirstChild(Settings.AimbotPart) then return false end
    local myTeam = LocalPlayer.Team and LocalPlayer.Team.Name
    local t = p.Team and p.Team.Name
    if myTeam == "Guards" then
        return t == "Inmates" or t == "Criminals"
    elseif myTeam == "Inmates" or myTeam == "Criminals" then
        return t == "Guards"
    end
    return false
end

local function getTarget()
    local best, ang = nil, Settings.AimbotFOV
    for _,p in ipairs(Players:GetPlayers()) do
        if validTarget(p) then
            local part = p.Character[Settings.AimbotPart]
            local dir = (part.Position - Camera.CFrame.Position).Unit
            local a = math.deg(math.acos(Camera.CFrame.LookVector:Dot(dir)))
            if a < ang then
                ang = a
                best = part
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    circle.Size = UDim2.fromOffset(Settings.AimbotFOV*6, Settings.AimbotFOV*6)
    if Settings.Aimbot then
        local t = getTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, t.Position),
                Settings.AimbotSmooth
            )
        end
    end
end)

--------------------------------------------------
-- FIXED ESP
--------------------------------------------------
local esp = {}
local function applyESP(p)
    if not p.Character then return end
    if esp[p] then esp[p]:Destroy() end

    local h = Instance.new("Highlight")
    h.FillTransparency = 0.6
    h.OutlineTransparency = 0
    h.OutlineColor = Color3.fromRGB(255,255,255)
    local teamName = p.Team and p.Team.Name
    h.FillColor = Settings.ESPColors[teamName] or Color3.fromRGB(255,255,255)
    h.Parent = p.Character
    esp[p] = h
end

local function setupESP(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.2)
        if Settings.ESP then
            applyESP(p)
        end
    end)
end

for _,p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        setupESP(p)
        if p.Character then applyESP(p) end
    end
end

Players.PlayerAdded:Connect(setupESP)

RunService.Heartbeat:Connect(function()
    if not Settings.ESP then
        for _,h in pairs(esp) do
            if h then h:Destroy() end
        end
        table.clear(esp)
    else
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not esp[p] then
                applyESP(p)
            end
        end
    end
end)

--------------------------------------------------
-- HEAL PER SECOND
--------------------------------------------------
RunService.Heartbeat:Connect(function()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if not h then return end

    if Settings.HealEnabled then
        h.Health = math.min(h.Health + 10 * RunService.Heartbeat:Wait(), h.MaxHealth)
    elseif h.Health < 10 then
        local t = LocalPlayer.Team and LocalPlayer.Team.Name
        if TeamSpawns[t] then
            c.HumanoidRootPart.CFrame = TeamSpawns[t]
            h.Health = h.MaxHealth
        end
    end
end)

--------------------------------------------------
-- GUI
--------------------------------------------------
local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.55,0.7)
main.Position = UDim2.fromScale(0.5,0.5)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(0,0,0)
main.Active = true
main.Draggable = true
Instance.new("UICorner",main)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromScale(1,0.12)
title.Text = "Hi, "..LocalPlayer.Name
title.Font = Enum.Font.GothamBlack
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.BackgroundColor3 = Color3.fromRGB(40,40,40)

-- Content
local content = Instance.new("Frame", main)
content.Size = UDim2.fromScale(1,0.78)
content.Position = UDim2.fromScale(0,0.12)
content.BackgroundTransparency = 1
local elems = {}

local function clear()
    for _,v in ipairs(elems) do v:Destroy() end
    elems = {}
end

local function button(text,y,cb)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.fromScale(0.9,0.08)
    b.Position = UDim2.fromScale(0.05,y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner",b)
    b.MouseButton1Click:Connect(cb)
    table.insert(elems,b)
end

local function slider(label,y,get,set)
    local l = Instance.new("TextLabel", content)
    l.Size = UDim2.fromScale(0.9,0.05)
    l.Position = UDim2.fromScale(0.05,y)
    l.Text = label
    l.TextColor3 = Color3.fromRGB(255,255,255)
    l.BackgroundTransparency = 1
    table.insert(elems,l)

    local box = Instance.new("TextBox", content)
    box.Size = UDim2.fromScale(0.9,0.06)
    box.Position = UDim2.fromScale(0.05,y+0.05)
    box.Text = tostring(get())
    box.TextScaled = true
    box.BackgroundColor3 = Color3.fromRGB(30,30,30)
    box.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner",box)
    box.FocusLost:Connect(function()
        local v = tonumber(box.Text)
        if v then set(v) end
        box.Text = tostring(get())
    end)
    table.insert(elems,box)
end

function updatePage()
    clear()
    if Settings.Page == 1 then
        button("Aimbot: E Toggle",0.1,function() end)
        slider("Aimbot FOV",0.25,function() return Settings.AimbotFOV end,function(v) Settings.AimbotFOV=v end)
        slider("Aimbot Smooth",0.45,function() return Settings.AimbotSmooth end,function(v) Settings.AimbotSmooth=v end)
        button("Target: "..Settings.AimbotPart,0.7,function()
            Settings.AimbotPart = Settings.AimbotPart=="Head" and "HumanoidRootPart" or "Head"
            updatePage()
        end)
    elseif Settings.Page == 2 then
        button(Settings.ESP and "Disable ESP" or "Enable ESP",0.2,function()
            Settings.ESP = not Settings.ESP
            updatePage()
        end)
    elseif Settings.Page == 3 then
        button("TP Police",0.1,function() LocalPlayer.Character.HumanoidRootPart.CFrame = TeamSpawns.Guards end)
        button("TP Yard",0.22,function() LocalPlayer.Character.HumanoidRootPart.CFrame = TeamSpawns.Inmates end)
        button("TP Kitchen",0.34,function() LocalPlayer.Character.HumanoidRootPart.CFrame = TeamSpawns.Criminals end)
        button("TP Cellblock",0.46,function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(870.5,114.8,2487.7) end)
        button("TP Cafe",0.58,function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(868.3,100.4,2263.6) end)
        button("TP Weapons",0.7,function()
            local folder = ReplicatedStorage:FindFirstChild("Weapons")
            if folder then
                for _,w in ipairs(folder:GetChildren()) do
                    w:Clone().Parent = LocalPlayer.Backpack
                end
            end
        end)
    elseif Settings.Page == 4 then
        slider("WalkSpeed",0.1,function() return Settings.WalkSpeed end,function(v)
            Settings.WalkSpeed=v
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed=v
            end
        end)
        slider("JumpPower",0.3,function() return Settings.JumpPower end,function(v)
            Settings.JumpPower=v
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower=v
            end
        end)
    elseif Settings.Page == 5 then
        button(Settings.HealEnabled and "Disable Heal" or "Enable Heal",0.2,function()
            Settings.HealEnabled = not Settings.HealEnabled
            updatePage()
        end)
    end
end

-- Navigation buttons
local prev = Instance.new("TextButton", main)
prev.Text="<"
prev.Size=UDim2.fromScale(0.1,0.06)
prev.Position=UDim2.fromScale(0.02,0.92)
prev.MouseButton1Click:Connect(function()
    Settings.Page=math.max(1,Settings.Page-1)
    updatePage()
end)

local nextb = Instance.new("TextButton", main)
nextb.Text=">"
nextb.Size=UDim2.fromScale(0.1,0.06)
nextb.Position=UDim2.fromScale(0.88,0.92)
nextb.MouseButton1Click:Connect(function()
    Settings.Page=math.min(5,Settings.Page+1)
    updatePage()
end)

updatePage()
