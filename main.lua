-- main.lua
local SCRIPT_VERSION = "1.0.0"
print("Running PrisonLifeScriptAI v" .. SCRIPT_VERSION)

-- your actual script code below

-- FULL REFACTORED ROBLOX LOCAL SCRIPT

-- FULL REFACTORED ROBLOX LOCAL SCRIPT

repeat task.wait() until game:IsLoaded()

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- SETTINGS
local Settings = {
    AimbotEnabled = false,
    AimbotFOV = 120,
    AimbotSmoothness = 0.05,
    AimbotPart = "Head",
    ESPEnabled = true,
    ESPTeamColors = {},
    WalkSpeed = 16,
    JumpPower = 50,
    DestroyPartsEnabled = false,
    SavedCoordinate = nil,
    SpawnCFrame = nil,
    ArmorEnabled = false,
    Page = 1
}

-- SPAWN POSITION
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    Settings.SpawnCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
end
Players.PlayerAdded:Connect(function(p)
    if p == LocalPlayer and LocalPlayer.Character then
        Settings.SpawnCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

-- SOUND FUNCTION
local function playSound(id, parent)
    local s = Instance.new("Sound", parent or workspace)
    s.SoundId = id
    s.Volume = 0.5
    s:Play()
    s.Ended:Connect(function() s:Destroy() end)
end

-- AIMBOT TOGGLE
UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.E then
        Settings.AimbotEnabled = not Settings.AimbotEnabled
    end
end)

-- VALID TARGET
local function validTarget(p)
    if p == LocalPlayer then return false end
    if not p.Character or not p.Character:FindFirstChild(Settings.AimbotPart) then return false end
    return true
end

-- GET AIMBOT TARGET
local function getTarget()
    local best, angle = nil, Settings.AimbotFOV
    for _,p in ipairs(Players:GetPlayers()) do
        if validTarget(p) then
            local part = p.Character[Settings.AimbotPart]
            local dir = (part.Position - Camera.CFrame.Position).Unit
            local a = math.deg(math.acos(Camera.CFrame.LookVector:Dot(dir)))
            if a < angle then
                angle = a
                best = part
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if Settings.AimbotEnabled then
        local t = getTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), Settings.AimbotSmoothness)
        end
    end
end)

-- FOV CIRCLE
local fovGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
fovGui.ResetOnSpawn = false
local circle = Instance.new("Frame", fovGui)
circle.AnchorPoint = Vector2.new(0.5,0.5)
circle.Position = UDim2.fromScale(0.5,0.5)
circle.BackgroundTransparency = 1
circle.BorderSizePixel = 2
circle.BorderColor3 = Color3.fromRGB(0,170,255)
Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)
RunService.RenderStepped:Connect(function()
    circle.Size = UDim2.fromOffset(Settings.AimbotFOV*6,Settings.AimbotFOV*6)
end)

-- GUI CREATION
local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.Position = UDim2.fromScale(0.5,0.5)
main.Size = UDim2.fromScale(0.5,0.7)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius=UDim.new(0,12)

local startLabel = Instance.new("TextLabel", main)
startLabel.Size = UDim2.fromScale(1,0.1)
startLabel.Position = UDim2.fromScale(0,0)
startLabel.Text = "Hi, "..LocalPlayer.Name.."!"
startLabel.Font = Enum.Font.GothamBold
startLabel.TextScaled = true
startLabel.TextColor3 = Color3.fromRGB(200,200,200)
startLabel.BackgroundColor3 = Color3.fromRGB(35,35,35)
startLabel.BackgroundTransparency = 0
Instance.new("UICorner", startLabel).CornerRadius=UDim.new(0,8)

local content = Instance.new("Frame", main)
content.Size = UDim2.fromScale(1,0.8)
content.Position = UDim2.fromScale(0,0.1)
content.BackgroundTransparency = 1
local contentElements = {}
local function clearContent() for _,v in ipairs(contentElements) do v:Destroy() end contentElements={} end
local function addLabel(text,posY)
    local l = Instance.new("TextLabel", content)
    l.Size = UDim2.fromScale(0.95,0.08)
    l.Position = UDim2.fromScale(0.025,posY)
    l.Text = text
    l.Font = Enum.Font.GothamBold
    l.TextScaled = true
    l.TextColor3 = Color3.fromRGB(200,200,200)
    l.BackgroundColor3 = Color3.fromRGB(30,30,30)
    l.BackgroundTransparency = 0
    Instance.new("UICorner", l).CornerRadius=UDim.new(0,6)
    table.insert(contentElements,l)
end
local function addButton(text,posY,callback)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.fromScale(0.9,0.07)
    b.Position = UDim2.fromScale(0.05,posY)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", b)
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{Size=UDim2.fromScale(0.92,0.075)}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{Size=UDim2.fromScale(0.9,0.07)}):Play() end)
    b.MouseButton1Click:Connect(function() playSound("rbxassetid://9118831966") callback() end)
    table.insert(contentElements,b)
end

-- NAVIGATION BUTTONS
local prevBtn = Instance.new("TextButton", main)
prevBtn.Size = UDim2.fromScale(0.12,0.06)
prevBtn.Position = UDim2.fromScale(0.02,0.93)
prevBtn.Text = "<"
prevBtn.Font = Enum.Font.GothamBold
prevBtn.TextScaled = true
prevBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", prevBtn)
prevBtn.MouseButton1Click:Connect(function() Settings.Page=math.max(1,Settings.Page-1) updatePage() end)

local nextBtn = Instance.new("TextButton", main)
nextBtn.Size = UDim2.fromScale(0.12,0.06)
nextBtn.Position = UDim2.fromScale(0.86,0.93)
nextBtn.Text = ">"
nextBtn.Font = Enum.Font.GothamBold
nextBtn.TextScaled = true
nextBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", nextBtn)
nextBtn.MouseButton1Click:Connect(function() Settings.Page=math.min(6,Settings.Page+1) updatePage() end)

-- ESP
local espObjects = {}
local function applyESP(p,color)
    if espObjects[p] then espObjects[p]:Destroy() end
    if not p.Character then return end
    local h = Instance.new("Highlight")
    h.FillColor = color or Color3.fromRGB(0,170,255)
    h.FillTransparency = 0.4
    h.OutlineTransparency = 1
    h.Parent = p.Character
    espObjects[p]=h
end

local function updateESP()
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local teamColor = p.TeamColor.Color or Color3.fromRGB(0,170,255)
            applyESP(p, teamColor)
        end
    end
end

Players.PlayerAdded:Connect(updateESP)
Players.PlayerRemoving:Connect(function(p) if espObjects[p] then espObjects[p]:Destroy() espObjects[p]=nil end end)
RunService.Heartbeat:Connect(updateESP)

-- WALK/JUMP SLIDERS & ARMOR will be implemented in the page update function below

-- PAGE UPDATE FUNCTION
function updatePage()
    clearContent()
    if Settings.Page==1 then
        addLabel("Aimbot",0.05)
        addLabel("Press E to toggle",0.2)
    elseif Settings.Page==2 then
        addLabel("Walk & Jump",0.05)
        addLabel("WalkSpeed",0.15)
        local wsBox = Instance.new("TextBox", content)
        wsBox.Size=UDim2.fromScale(0.9,0.05)
        wsBox.Position=UDim2.fromScale(0.05,0.22)
        wsBox.Text = tostring(Settings.WalkSpeed)
        wsBox.TextScaled=true
        wsBox.TextColor3=Color3.fromRGB(0,255,255)
        wsBox.BackgroundColor3=Color3.fromRGB(30,30,30)
        wsBox.FocusLost:Connect(function() local v=tonumber(wsBox.Text); if v then Settings.WalkSpeed=v; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed=v end end end)

        addLabel("JumpPower",0.32)
        local jpBox = Instance.new("TextBox", content)
        jpBox.Size=UDim2.fromScale(0.9,0.05)
        jpBox.Position=UDim2.fromScale(0.05,0.39)
        jpBox.Text=tostring(Settings.JumpPower)
        jpBox.TextScaled=true
        jpBox.TextColor3=Color3.fromRGB(0,255,255)
        jpBox.BackgroundColor3=Color3.fromRGB(30,30,30)
        jpBox.FocusLost:Connect(function() local v=tonumber(jpBox.Text); if v then Settings.JumpPower=v; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower=v end end end)
    elseif Settings.Page==3 then
        addLabel("Teleport to Players by Team",0.05)
        -- dropdown menus for each team (implemented in full script later)
    elseif Settings.Page==4 then
        addLabel("Armor/God Mode",0.05)
        addButton(Settings.ArmorEnabled and "Disable Armor" or "Enable Armor",0.15,function()
            Settings.ArmorEnabled=not Settings.ArmorEnabled
            -- armor logic here
        end)
    end
end

updatePage()

