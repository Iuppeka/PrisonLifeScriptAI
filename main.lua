-- ██████ FULL ALL-IN-ONE FINAL SCRIPT ██████
repeat task.wait() until game:IsLoaded()

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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

    -- HEAL
    Heal = false,

    SpawnCFrame = nil
}

local ESP_COLORS = {
    Guards = Color3.fromRGB(0,170,255),
    Inmates = Color3.fromRGB(255,170,0),
    Criminals = Color3.fromRGB(255,60,60)
}

--------------------------------------------------
-- TEAM SPAWNS / TELEPORTS
--------------------------------------------------
local Teleports = {
    Police = CFrame.new(818.1,100,2235.8),
    Yard = CFrame.new(792.6,98,2457.7),
    Kitchen = CFrame.new(897,112,2209),
    Cellblock = CFrame.new(870.5,114.8,2487.7),
    Cafe = CFrame.new(868.3,100.4,2263.6)
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
coord.Size = UDim2.fromScale(0.24,0.05)
coord.Position = UDim2.fromScale(0.01,0.01)
coord.BackgroundColor3 = Color3.fromRGB(10,10,10)
coord.TextColor3 = Color3.fromRGB(255,255,255)
coord.Font = Enum.Font.Code
coord.TextScaled = true
coord.BorderSizePixel = 2
coord.BorderColor3 = Color3.fromRGB(80,80,80)

RunService.RenderStepped:Connect(function()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        local p = c.HumanoidRootPart.Position
        coord.Text = string.format("X %.1f | Y %.1f | Z %.1f", p.X,p.Y,p.Z)
    end
end)

--------------------------------------------------
-- AIMBOT + FOV
--------------------------------------------------
local fovGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
fovGui.ResetOnSpawn = false

local circle = Instance.new("Frame", fovGui)
circle.AnchorPoint = Vector2.new(0.5,0.5)
circle.Position = UDim2.fromScale(0.5,0.5)
circle.BackgroundTransparency = 1
circle.BorderSizePixel = 2
circle.BorderColor3 = Color3.fromRGB(255,255,255)
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
-- ESP (FIXED, RESPAWN SAFE)
--------------------------------------------------
local esp = {}

local function applyESP(p)
    if not p.Character then return end
    if esp[p] then esp[p]:Destroy() end

    local h = Instance.new("Highlight")
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0
    h.OutlineColor = Color3.fromRGB(255,255,255)

    local teamName = p.Team and p.Team.Name
    h.FillColor = ESP_COLORS[teamName] or Color3.fromRGB(255,255,255)
    h.Parent = p.Character
    esp[p] = h
end

local function setupESP(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.3)
        if Settings.ESP then applyESP(p) end
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
        for _,h in pairs(esp) do if h then h:Destroy() end end
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
-- HEAL (10 HP / SEC)
--------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
    if not Settings.Heal then return end
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h and h.Health < h.MaxHealth then
        h.Health = math.min(h.Health + 10 * dt, h.MaxHealth)
    end
end)

--------------------------------------------------
-- GUI (8-BIT BLACK & WHITE)
--------------------------------------------------
local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.55,0.7)
main.Position = UDim2.fromScale(0.5,0.5)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(0,0,0)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(255,255,255)
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromScale(1,0.1)
title.Text = "HI, "..LocalPlayer.Name
title.Font = Enum.Font.Code
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.BackgroundColor3 = Color3.fromRGB(20,20,20)

local content = Instance.new("Frame", main)
content.Size = UDim2.fromScale(1,0.8)
content.Position = UDim2.fromScale(0,0.1)
content.BackgroundTransparency = 1

local elements = {}

local function clear()
    for _,v in ipairs(elements) do v:Destroy() end
    table.clear(elements)
end

local function button(txt,y,cb)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.fromScale(0.9,0.08)
    b.Position = UDim2.fromScale(0.05,y)
    b.Text = txt
    b.Font = Enum.Font.Code
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(15,15,15)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BorderSizePixel = 2
    b.BorderColor3 = Color3.fromRGB(255,255,255)
    b.MouseButton1Click:Connect(cb)
    table.insert(elements,b)
end

local function slider(name,y,get,set)
    local l = Instance.new("TextLabel", content)
    l.Text = name
    l.Size = UDim2.fromScale(0.9,0.05)
    l.Position = UDim2.fromScale(0.05,y)
    l.Font = Enum.Font.Code
    l.TextColor3 = Color3.fromRGB(255,255,255)
    l.BackgroundTransparency = 1
    table.insert(elements,l)

    local box = Instance.new("TextBox", content)
    box.Size = UDim2.fromScale(0.9,0.06)
    box.Position = UDim2.fromScale(0.05,y+0.05)
    box.Text = tostring(get())
    box.Font = Enum.Font.Code
    box.TextScaled = true
    box.BackgroundColor3 = Color3.fromRGB(15,15,15)
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.BorderSizePixel = 2
    box.BorderColor3 = Color3.fromRGB(255,255,255)
    box.FocusLost:Connect(function()
        local v = tonumber(box.Text)
        if v then set(v) end
        box.Text = tostring(get())
    end)
    table.insert(elements,box)
end

--------------------------------------------------
-- PLAYER TELEPORT DROPDOWN
--------------------------------------------------
local function playerDropdown(y)
    local open = false
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.fromScale(0.9,0.08)
    btn.Position = UDim2.fromScale(0.05,y)
    btn.Text = "TP TO PLAYER ▼"
    btn.Font = Enum.Font.Code
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(15,15,15)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(255,255,255)
    table.insert(elements,btn)

    btn.MouseButton1Click:Connect(function()
        open = not open
        if not open then return end

        local offset = y + 0.09
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                button(p.Name.." ["..(p.Team and p.Team.Name or "?").."]", offset, function()
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame =
                            p.Character.HumanoidRootPart.CFrame
                    end
                end)
                offset += 0.085
            end
        end
    end)
end

--------------------------------------------------
-- PAGE CONTENT
--------------------------------------------------
local function updatePage()
    clear()
    if Settings.Page == 1 then
        button("AIMBOT: E TOGGLE",0.1,function() end)
        slider("FOV",0.25,function() return Settings.AimbotFOV end,function(v) Settings.AimbotFOV=v end)
        slider("SMOOTH",0.45,function() return Settings.AimbotSmooth end,function(v) Settings.AimbotSmooth=v end)

    elseif Settings.Page == 2 then
        button(Settings.ESP and "DISABLE ESP" or "ENABLE ESP",0.2,function()
            Settings.ESP = not Settings.ESP
            updatePage()
        end)

    elseif Settings.Page == 3 then
        button("TP POLICE",0.05,function() LocalPlayer.Character.HumanoidRootPart.CFrame = Teleports.Police end)
        button("TP YARD",0.15,function() LocalPlayer.Character.HumanoidRootPart.CFrame = Teleports.Yard end)
        button("TP KITCHEN",0.25,function() LocalPlayer.Character.HumanoidRootPart.CFrame = Teleports.Kitchen end)
        button("TP CELLBLOCK",0.35,function() LocalPlayer.Character.HumanoidRootPart.CFrame = Teleports.Cellblock end)
        button("TP CAFE",0.45,function() LocalPlayer.Character.HumanoidRootPart.CFrame = Teleports.Cafe end)
        playerDropdown(0.58)

    elseif Settings.Page == 4 then
        button(Settings.Heal and "DISABLE HEAL" or "ENABLE HEAL",0.25,function()
            Settings.Heal = not Settings.Heal
            updatePage()
        end)
    end
end

--------------------------------------------------
-- PAGE NAVIGATION
--------------------------------------------------
local prev = Instance.new("TextButton", main)
prev.Text = "<"
prev.Size = UDim2.fromScale(0.1,0.06)
prev.Position = UDim2.fromScale(0.02,0.92)
prev.Font = Enum.Font.Code
prev.TextScaled = true
prev.BackgroundColor3 = Color3.fromRGB(0,0,0)
prev.TextColor3 = Color3.fromRGB(255,255,255)
prev.BorderSizePixel = 2
prev.BorderColor3 = Color3.fromRGB(255,255,255)
prev.MouseButton1Click:Connect(function()
    Settings.Page = math.max(1,Settings.Page-1)
    updatePage()
end)

local nextb = prev:Clone()
nextb.Parent = main
nextb.Text = ">"
nextb.Position = UDim2.fromScale(0.88,0.92)
nextb.MouseButton1Click:Connect(function()
    Settings.Page = math.min(4,Settings.Page+1)
    updatePage()
end)

updatePage()
