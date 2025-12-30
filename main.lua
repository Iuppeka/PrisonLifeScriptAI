-- FULL ROBLOX LOCAL SCRIPT (FINAL VERSION + AIMBOT UPGRADE)
-- Added: Z = return to spawn, E = toggle aimbot + FOV circle, team-only aimbot, adjustable FOV circle

repeat task.wait() until game:IsLoaded()

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-------------------------------------------------
-- SETTINGS
-------------------------------------------------
local Settings = {
    Page = 1,
    WalkSpeed = 16,
    JumpPower = 50,

    -- AIMBOT
    Aimbot = false,
    AimbotFOV = 120,
    AimbotSmooth = 0.08,
    AimbotPart = "Head",

    -- ESP
    ESP = true,
    TeamColors = {
        Police = Color3.fromRGB(0,170,255),
        Inmates = Color3.fromRGB(255,70,70),
        Criminals = Color3.fromRGB(255,170,0)
    },

    -- OTHER
    GodMode = false,
    DestroyEnabled = false,
    SpawnCFrame = nil
}

-------------------------------------------------
-- SAVE SPAWN
-------------------------------------------------
local function saveSpawn()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Settings.SpawnCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end
saveSpawn()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    saveSpawn()
end)

-------------------------------------------------
-- INPUT HOTKEYS
-------------------------------------------------
UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.E then
        Settings.Aimbot = not Settings.Aimbot
        FOVCircle.Visible = Settings.Aimbot
    end

    if input.KeyCode == Enum.KeyCode.Z then
        if Settings.SpawnCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Settings.SpawnCFrame
        end
    end
end)

-------------------------------------------------
-- COORDINATES HUD
-------------------------------------------------
local coordGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
coordGui.ResetOnSpawn = false

local coordLabel = Instance.new("TextLabel", coordGui)
coordLabel.Size = UDim2.fromScale(0.25,0.05)
coordLabel.Position = UDim2.fromScale(0.01,0.01)
coordLabel.BackgroundColor3 = Color3.fromRGB(20,20,20)
coordLabel.TextColor3 = Color3.fromRGB(0,255,255)
coordLabel.TextScaled = true
coordLabel.Font = Enum.Font.GothamBold

RunService.RenderStepped:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local p = hrp.Position
        coordLabel.Text = string.format("X: %.1f  Y: %.1f  Z: %.1f",p.X,p.Y,p.Z)
    end
end)

-------------------------------------------------
-- AIMBOT FOV CIRCLE
-------------------------------------------------
local fovGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
fovGui.ResetOnSpawn = false

FOVCircle = Instance.new("Frame", fovGui)
FOVCircle.AnchorPoint = Vector2.new(0.5,0.5)
FOVCircle.Position = UDim2.fromScale(0.5,0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 2
FOVCircle.BorderColor3 = Color3.fromRGB(0,170,255)
FOVCircle.Visible = false
Instance.new("UICorner",FOVCircle).CornerRadius = UDim.new(1,0)

RunService.RenderStepped:Connect(function()
    FOVCircle.Size = UDim2.fromOffset(Settings.AimbotFOV*6,Settings.AimbotFOV*6)
end)

-------------------------------------------------
-- AIMBOT LOGIC (TEAM ONLY)
-------------------------------------------------
local function getTarget()
    local best, angle = nil, Settings.AimbotFOV
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team == LocalPlayer.Team then
            if p.Character and p.Character:FindFirstChild(Settings.AimbotPart) then
                local part = p.Character[Settings.AimbotPart]
                local dir = (part.Position - Camera.CFrame.Position).Unit
                local a = math.deg(math.acos(Camera.CFrame.LookVector:Dot(dir)))
                if a < angle then
                    angle = a
                    best = part
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not Settings.Aimbot then return end
    local t = getTarget()
    if t then
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(Camera.CFrame.Position, t.Position),
            Settings.AimbotSmooth
        )
    end
end)

-------------------------------------------------
-- MAIN GUI
-------------------------------------------------
local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.55,0.65)
main.Position = UDim2.fromScale(0.5,0.5)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true
Instance.new("UICorner",main).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromScale(1,0.12)
title.Text = "Hi, "..LocalPlayer.Name.."!"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(180,180,180)
title.BackgroundColor3 = Color3.fromRGB(15,15,15)

local content = Instance.new("Frame", main)
content.Size = UDim2.fromScale(1,0.76)
content.Position = UDim2.fromScale(0,0.12)
content.BackgroundTransparency = 1

local elements = {}
local function clear()
    for _,v in ipairs(elements) do v:Destroy() end
    table.clear(elements)
end

local function label(text,y)
    local l = Instance.new("TextLabel",content)
    l.Size = UDim2.fromScale(0.9,0.08)
    l.Position = UDim2.fromScale(0.05,y)
    l.Text = text
    l.Font = Enum.Font.GothamBold
    l.TextScaled = true
    l.TextColor3 = Color3.fromRGB(200,200,200)
    l.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Instance.new("UICorner",l)
    table.insert(elements,l)
end

local function button(text,y,cb)
    local b = Instance.new("TextButton",content)
    b.Size = UDim2.fromScale(0.9,0.08)
    b.Position = UDim2.fromScale(0.05,y)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextScaled = true
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Instance.new("UICorner",b)
    b.MouseButton1Click:Connect(cb)
    table.insert(elements,b)
end

-------------------------------------------------
-- PAGES
-------------------------------------------------
function updatePage()
    clear()
    if Settings.Page==1 then
        label("WELCOME",0.05)
        label("E = Toggle Aimbot | Z = Return to Spawn",0.18)

    elseif Settings.Page==2 then
        label("MOVEMENT",0.05)
        label("WalkSpeed",0.2)
        local ws = Instance.new("TextBox",content)
        ws.Size = UDim2.fromScale(0.9,0.07)
        ws.Position = UDim2.fromScale(0.05,0.28)
        ws.Text = Settings.WalkSpeed
        ws.BackgroundColor3 = Color3.fromRGB(40,40,40)
        ws.TextScaled = true
        ws.FocusLost:Connect(function()
            local v = tonumber(ws.Text)
            if v then Settings.WalkSpeed=v end
        end)
        table.insert(elements,ws)

        label("JumpPower",0.4)
        local jp = ws:Clone()
        jp.Position = UDim2.fromScale(0.05,0.48)
        jp.Text = Settings.JumpPower
        jp.FocusLost:Connect(function()
            local v = tonumber(jp.Text)
            if v then Settings.JumpPower=v end
        end)
        jp.Parent = content
        table.insert(elements,jp)

    elseif Settings.Page==3 then
        label("AIMBOT SETTINGS",0.05)
        label("FOV Size",0.2)
        local fov = Instance.new("TextBox",content)
        fov.Size = UDim2.fromScale(0.9,0.07)
        fov.Position = UDim2.fromScale(0.05,0.28)
        fov.Text = Settings.AimbotFOV
        fov.BackgroundColor3 = Color3.fromRGB(40,40,40)
        fov.TextScaled = true
        fov.FocusLost:Connect(function()
            local v = tonumber(fov.Text)
            if v then Settings.AimbotFOV=v end
        end)
        table.insert(elements,fov)

    elseif Settings.Page==4 then
        label("ESP",0.05)
        button(Settings.ESP and "Disable ESP" or "Enable ESP",0.2,function()
            Settings.ESP = not Settings.ESP
        end)

    elseif Settings.Page==5 then
        label("ARMOR / GOD MODE",0.05)
        button(Settings.GodMode and "Disable Armor" or "Enable Armor",0.2,function()
            Settings.GodMode = not Settings.GodMode
        end)
    end
end

-------------------------------------------------
-- NAVIGATION
-------------------------------------------------
local prev = Instance.new("TextButton",main)
prev.Size = UDim2.fromScale(0.12,0.06)
prev.Position = UDim2.fromScale(0.02,0.92)
prev.Text = "<"
Instance.new("UICorner",prev)
prev.MouseButton1Click:Connect(function()
    Settings.Page = math.max(1,Settings.Page-1)
    updatePage()
end)

local next = prev:Clone()
next.Parent = main
next.Position = UDim2.fromScale(0.86,0.92)
next.Text = ">"
next.MouseButton1Click:Connect(function()
    Settings.Page = math.min(5,Settings.Page+1)
    updatePage()
end)

-------------------------------------------------
-- APPLY MOVEMENT + GODMODE
-------------------------------------------------
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Settings.WalkSpeed
        hum.JumpPower = Settings.JumpPower
        if Settings.GodMode then
            hum.MaxHealth = math.huge
            hum.Health = hum.MaxHealth
        end
    end
end)

-------------------------------------------------
updatePage()
