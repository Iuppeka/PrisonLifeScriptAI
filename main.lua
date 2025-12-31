repeat task.wait() until game:IsLoaded()

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--------------------------------------------------
-- SETTINGS
--------------------------------------------------
local Settings = {
    Page = 1,

    -- Aimbot
    AimbotEnabled = false,
    AimbotFOV = 120,
    AimbotSmoothness = 0.08,

    -- ESP
    ESPEnabled = true,

    -- Movement
    WalkSpeed = 16,
    JumpPower = 50,

    -- Armor
    GodMode = false,

    SpawnCFrame = nil
}

--------------------------------------------------
-- SAVE SPAWN
--------------------------------------------------
local function saveSpawn()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Settings.SpawnCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end

saveSpawn()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    saveSpawn()
end)

--------------------------------------------------
-- Z TO SPAWN
--------------------------------------------------
UserInputService.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.Z and Settings.SpawnCFrame and LocalPlayer.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = Settings.SpawnCFrame
    end
end)

--------------------------------------------------
-- AIMBOT (TEAM LOGIC)
--------------------------------------------------
local function validTarget(player)
    if player == LocalPlayer then return false end
    if not player.Character or not player.Character:FindFirstChild("Head") then return false end

    local myTeam = LocalPlayer.Team and LocalPlayer.Team.Name
    local tTeam = player.Team and player.Team.Name

    if myTeam == "Guards" then
        return tTeam == "Inmates" or tTeam == "Criminals"
    elseif myTeam == "Inmates" or myTeam == "Criminals" then
        return tTeam == "Guards"
    end
    return false
end

local function getTarget()
    local best, angle = nil, Settings.AimbotFOV
    for _,p in ipairs(Players:GetPlayers()) do
        if validTarget(p) then
            local head = p.Character.Head
            local dir = (head.Position - Camera.CFrame.Position).Unit
            local a = math.deg(math.acos(Camera.CFrame.LookVector:Dot(dir)))
            if a < angle then
                angle = a
                best = head
            end
        end
    end
    return best
end

--------------------------------------------------
-- FOV CIRCLE
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

RunService.RenderStepped:Connect(function()
    circle.Size = UDim2.fromOffset(Settings.AimbotFOV*6, Settings.AimbotFOV*6)
    if Settings.AimbotEnabled then
        local t = getTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, t.Position),
                Settings.AimbotSmoothness
            )
        end
    end
end)

UserInputService.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.E then
        Settings.AimbotEnabled = not Settings.AimbotEnabled
        circle.Visible = Settings.AimbotEnabled
    end
end)

--------------------------------------------------
-- ESP (RESPAWN SAFE)
--------------------------------------------------
local ESPColors = {
    Guards = Color3.fromRGB(0,170,255),
    Inmates = Color3.fromRGB(255,140,0),
    Criminals = Color3.fromRGB(255,0,0)
}

local ESPObjects = {}

local function applyESP(player, character)
    if not Settings.ESPEnabled then return end
    if player == LocalPlayer then return end
    if ESPObjects[player] then ESPObjects[player]:Destroy() end

    local h = Instance.new("Highlight")
    h.FillTransparency = 0.45
    h.OutlineTransparency = 1
    h.FillColor = ESPColors[player.Team and player.Team.Name] or Color3.new(1,1,1)
    h.Parent = character
    ESPObjects[player] = h
end

local function hookPlayer(player)
    if player.Character then
        applyESP(player, player.Character)
    end
    player.CharacterAdded:Connect(function(c)
        task.wait(0.2)
        applyESP(player,c)
    end)
    player.CharacterRemoving:Connect(function()
        if ESPObjects[player] then ESPObjects[player]:Destroy() end
    end)
end

for _,p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then hookPlayer(p) end
end
Players.PlayerAdded:Connect(hookPlayer)

--------------------------------------------------
-- GOD MODE / ARMOR
--------------------------------------------------
local function applyGodMode(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if Settings.GodMode then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum.HealthChanged:Connect(function()
            if Settings.GodMode then hum.Health = math.huge end
        end)
    else
        hum.MaxHealth = 100
        hum.Health = 100
    end
end

LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.2)
    applyGodMode(c)
end)

--------------------------------------------------
-- TELEPORT FUNCTIONS
--------------------------------------------------
local function tp(cf)
    if LocalPlayer.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = cf
    end
end

local Teleports = {
    Cellblock = CFrame.new(870.5,114.8,2487.7),
    Cafe = CFrame.new(868.3,100.4,2263.6)
}

--------------------------------------------------
-- COORD HUD
--------------------------------------------------
local coordGui = Instance.new("ScreenGui",LocalPlayer.PlayerGui)
coordGui.ResetOnSpawn = false

local coord = Instance.new("TextLabel",coordGui)
coord.Size = UDim2.fromScale(0.22,0.05)
coord.BackgroundColor3 = Color3.fromRGB(15,15,15)
coord.TextColor3 = Color3.fromRGB(0,200,255)
coord.Font = Enum.Font.GothamBold
coord.TextScaled = true
Instance.new("UICorner",coord)

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character then
        local p = LocalPlayer.Character.HumanoidRootPart.Position
        coord.Text = string.format("X %.1f  Y %.1f  Z %.1f",p.X,p.Y,p.Z)
    end
end)
