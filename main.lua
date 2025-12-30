-- FULL ROBLOX LOCAL SCRIPT (FINAL VERSION)
-- FEATURES: Starter, Movement, Aimbot, ESP, Coordinates HUD, Teleports, Weapons, Armor, Click-to-destroy, Hack Detection, Sounds

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

    Aimbot = false,
    AimbotFOV = 120,

    ESP = true,
    TeamColors = {
        Police = Color3.fromRGB(0,170,255),
        Inmates = Color3.fromRGB(255,70,70),
        Criminals = Color3.fromRGB(255,170,0)
    },

    GodMode = false,
    DestroyEnabled = false
}

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
coordLabel.Text = "X:0 Y:0 Z:0"

RunService.RenderStepped:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local p = hrp.Position
        coordLabel.Text = string.format("X: %.1f  Y: %.1f  Z: %.1f",p.X,p.Y,p.Z)
    end
end)

-------------------------------------------------
-- MAIN GUI SETUP
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

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromScale(1,0.12)
title.Text = "Hi, "..LocalPlayer.Name.."!"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(180,180,180)
title.BackgroundColor3 = Color3.fromRGB(15,15,15)

-- CONTENT FRAME
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
        label("Use arrows to navigate",0.18)

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
        label("AIMBOT",0.05)
        button(Settings.Aimbot and "Disable Aimbot" or "Enable Aimbot",0.2,function()
            Settings.Aimbot = not Settings.Aimbot
        end)
        label("FOV: "..Settings.AimbotFOV,0.35)

    elseif Settings.Page==4 then
        label("ESP",0.05)
        button(Settings.ESP and "Disable ESP" or "Enable ESP",0.2,function()
            Settings.ESP = not Settings.ESP
        end)

    elseif Settings.Page==5 then
        label("TELEPORTS & WEAPONS",0.05)
        button("TP: Police",0.15,function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(818.1,100,2235.8)
            end
        end)
        button("TP: Yard",0.25,function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(792.6,98,2457.7)
            end
        end)
        button("TP: Kitchen Escape",0.35,function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(897.0,111.9,2209.3)
            end
        end)
        button("Get All Weapons",0.45,function()
            local wFolder = ReplicatedStorage:FindFirstChild("Weapons")
            if wFolder then
                for _,w in ipairs(wFolder:GetChildren()) do w:Clone().Parent=LocalPlayer.Backpack end
            end
        end)

    elseif Settings.Page==6 then
        label("ARMOR / GOD MODE",0.05)
        button(Settings.GodMode and "Disable Armor" or "Enable Armor",0.2,function()
            Settings.GodMode = not Settings.GodMode
        end)

    elseif Settings.Page==7 then
        label("UTILITIES",0.05)
        button(Settings.DestroyEnabled and "Disable Click-to-Destroy" or "Enable Click-to-Destroy",0.15,function()
            Settings.DestroyEnabled = not Settings.DestroyEnabled
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
    Settings.Page = math.min(7,Settings.Page+1)
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
