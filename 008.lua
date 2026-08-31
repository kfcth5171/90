-- =====================================================================
-- [[ HONKUKI AUDIO LOGGER & DUMPER - ULTIMATE 3D VIP EDITION (FIXED STUTTER) ]] --
-- =====================================================================

-- ระบบป้องกันการ Dump / Hook เบื้องต้น
if getrawmetatable and setreadonly then
    local mt = getrawmetatable(game)
    if not isreadonly(mt) then
        pcall(function()
            game:GetService("Players").LocalPlayer:Kick("❌ ตรวจพบความผิดปกติในการดักจับระบบ (Security Violation)")
        end)
        return
    end
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CurrentSelectedPlayer = nil
local StatusLabel = nil
local ShowTagsEnabled = true
local CurrentViewMode = 1
local PlayerButtons = {}
local ListeningLocalSound = nil
local IsListeningRealTime = false

local TAG_NAME = "Honkuki_Active_Runner_Tag"

-- 🛡️ รายชื่อ Admin 3 คน ( Admin ดึงกันเองได้ แต่ผู้เล่นทั่วไปดึง Admin ไม่ได้ )
local ProtectedCreatorUsers = {
    ["kfc_punyai"] = true,
    ["Aekshop_34d3c"] = true,
    ["CGGG_PRJOOOO"] = true
}

local function isAdmin(player)
    if not player then return false end
    return ProtectedCreatorUsers[player.Name] == true
end

-- ==================== ระบบสื่อสาร & TAG 3D บนหัวผู้เล่น ====================
local function markSelfAsRunner()
    if LocalPlayer.Character then
        local tagVal = LocalPlayer.Character:FindFirstChild(TAG_NAME)
        if not tagVal then
            tagVal = Instance.new("BoolValue")
            tagVal.Name = TAG_NAME
            tagVal.Value = true
            tagVal.Parent = LocalPlayer.Character
        end
    end
end

markSelfAsRunner()
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    markSelfAsRunner()
end)

local function setupPlayerTag(player)
    if not player or not player.Character then return end
    local char = player.Character
    local head = char:FindFirstChild("Head")
    if not head then return end

    if not ShowTagsEnabled or not char:FindFirstChild(TAG_NAME) then
        if head:FindFirstChild("Honkuki3DHeadTag") then
            head.Honkuki3DHeadTag:Destroy()
        end
        return
    end

    if head:FindFirstChild("Honkuki3DHeadTag") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Honkuki3DHeadTag"
    billboard.Size = UDim2.new(0, 180, 0, 45)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local bgFrame = Instance.new("Frame", billboard)
    bgFrame.Size = UDim2.new(1, 0, 1, 0)
    bgFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    bgFrame.BackgroundTransparency = 0.25
    Instance.new("UICorner", bgFrame).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", bgFrame)
    stroke.Color = Color3.fromRGB(255, 215, 0)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.2

    local shadowLabel = Instance.new("TextLabel", bgFrame)
    shadowLabel.Size = UDim2.new(1, 0, 1, 0)
    shadowLabel.Position = UDim2.new(0, 2, 0, 2)
    shadowLabel.BackgroundTransparency = 1
    shadowLabel.Font = Enum.Font.GothamBold
    shadowLabel.TextSize = 12
    shadowLabel.Text = "⚡ VIP SCRIPT USER ⚡"
    shadowLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    shadowLabel.TextTransparency = 0.3

    local tagLabel = Instance.new("TextLabel", bgFrame)
    tagLabel.Size = UDim2.new(1, 0, 1, 0)
    tagLabel.BackgroundTransparency = 1
    tagLabel.Font = Enum.Font.GothamBold
    tagLabel.TextSize = 12
    tagLabel.Text = "⚡ VIP SCRIPT USER ⚡"
    tagLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    tagLabel.TextStrokeColor3 = Color3.fromRGB(20, 20, 25)
    tagLabel.TextStrokeTransparency = 0.3

    task.spawn(function()
        while billboard and billboard.Parent do
            local tween1 = TweenService:Create(billboard, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {StudsOffset = Vector3.new(0, 3.6, 0)})
            tween1:Play()
            tween1.Completed:Wait()
            local tween2 = TweenService:Create(billboard, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {StudsOffset = Vector3.new(0, 3.2, 0)})
            tween2:Play()
            tween2.Completed:Wait()
        end
    end)
end

-- ==================== REMOTE COMBO & BLOCKED IDS ====================
local SpecificRE = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Ca1r")
local ScooterRE = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1NoMoto1rVehicle1s")

local function ForcePlayMusicCombo(musicId)
    if not musicId or musicId == "" then return false end
    local re = ReplicatedStorage:FindFirstChild("RE")
    if not re then return false end
    
    local success1, success2, success3, success4 = false, false, false, false
    local toolEvent = re:FindFirstChild("PlayerToolEvent")
    if toolEvent then
        local args1 = { "ToolMusicText", tostring(musicId), "", [4] = true }
        success1 = pcall(function() toolEvent:FireServer(unpack(args1)) end)
    end
    
    local vehicleEvent = re:FindFirstChild("1NoMoto1rVehicle1s")
    if vehicleEvent then
        local args2 = { "ToolMusicText", tostring(musicId), "", [4] = true }
        success2 = pcall(function() vehicleEvent:FireServer(unpack(args2)) end)
        
        local args3 = { "PickingScooterMusicText", tostring(musicId), "", [4] = true }
        success3 = pcall(function() vehicleEvent:FireServer(unpack(args3)) end)
    end

    if SpecificRE then
        pcall(function() SpecificRE:FireServer("ToolMusicText", tostring(musicId), "", true) end)
    end

    if ScooterRE then
        success4 = pcall(function() ScooterRE:FireServer("PickingScooterMusicText", tostring(musicId), nil, true) end)
    end

    return success1 or success2 or success3 or success4
end

local BlockedIDs = {
    ["54410081542"] = true, ["70999314371231"] = true,
    ["71352236"] = true, ["76500780055460"] = true,
    ["78515442941510"] = true, ["90533928572341"] = true,
    ["99721399503975"] = true
}

local function urlDecode(str)
    if not str then return "" end
    str = string.gsub(str, "+", " ")
    return (string.gsub(str, "%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

local function hexDecode(str)
    if not str then return "" end
    str = string.gsub(str, "0x", ""):gsub("\\x", ""):gsub("%%", ""):gsub("%s+", "")
    if string.match(str, "^%x+$") and #str % 2 == 0 then
        local decoded = ""
        for i = 1, #str, 2 do
            local byte = tonumber(string.sub(str, i, i+1), 16)
            if byte then decoded = decoded .. string.char(byte) end
        end
        if #decoded > 0 then return decoded end
    end
    return str
end

local function deepDecode(str)
    if type(str) ~= "string" then return str end
    local prev
    repeat
        prev = str
        str = urlDecode(str)
        str = hexDecode(str)
    until str == prev
    return str
end

local function extractIDsFromPattern(text)
    local ids = {}
    local patterns = {
        "69%%64=([^&]*)", "&id=([^&]*)", "id=([^&]*)",
        "audio=([^&]*)", "song=([^&]*)", "music=([^&]*)",
        "%%69%%64=([^&]*)", "&%%69%%64=([^&]*)",
        "9%s*d%s*=%s*([^&]*)", "9d=([^&]*)", "9_d=([^&]*)", "9%%20d%%20=([^&]*)"
    }
    for _, pat in ipairs(patterns) do
        for capture in string.gmatch(text, pat) do
            for num in string.gmatch(capture, "%d+") do
                if not BlockedIDs[num] then table.insert(ids, num) end
            end
        end
    end
    return ids
end

local function getPlayerVehicle(player)
    if not player or not player.Character then return nil end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or not humanoid.SeatPart then return nil end
    local vehicle = humanoid.SeatPart.Parent
    while vehicle and not vehicle:IsA("Model") do vehicle = vehicle.Parent end
    return (vehicle and vehicle:IsA("Model")) and vehicle or nil
end

-- ⚡ OPTIMIZED SOUND SCANNER (รองรับ Sled, Vehicle, Scooter และเงื่อนไข Admin)
local function checkPlayerAllSounds(targetPlayer)
    if not targetPlayer then return {} end
    
    -- เงื่อนไข Admin: ผู้เล่นทั่วไปดึง Admin ไม่ได้ แต่ Admin ดึงกันเองได้
    if isAdmin(targetPlayer) and not isAdmin(LocalPlayer) then
        return {}
    end

    local scanTargets = {}
    if targetPlayer.Character then table.insert(scanTargets, targetPlayer.Character) end
    local backpack = targetPlayer:FindFirstChild("Backpack")
    if backpack then table.insert(scanTargets, backpack) end
    local vehicle = getPlayerVehicle(targetPlayer)
    if vehicle then table.insert(scanTargets, vehicle) end

    -- สแกนยานพาหนะ / รถอีเวนต์ Sled ใน Workspace
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            local lowerName = string.lower(obj.Name)
            if string.find(lowerName, "sled") or string.find(lowerName, "scooter") or string.find(lowerName, "vehicle") or string.find(lowerName, "bike") or string.find(lowerName, "car") then
                local ownerVal = obj:FindFirstChild("Owner") or obj:FindFirstChild("Player") or obj:FindFirstChild("VehicleOwner")
                local isOwner = ownerVal and (ownerVal.Value == targetPlayer or ownerVal.Value == targetPlayer.Name)
                
                -- เช็กคนนั่งถ้าหา Value Owner ไม่เจอ
                if not isOwner then
                    for _, child in ipairs(obj:GetDescendants()) do
                        if child:IsA("VehicleSeat") or child:IsA("Seat") then
                            if child.Occupant and child.Occupant.Parent == targetPlayer.Character then
                                isOwner = true
                                break
                            end
                        end
                    end
                end

                if isOwner then
                    table.insert(scanTargets, obj)
                end
            end
        end
    end

    local validSounds = {}
    local soundMap = {}
    local NameBlacklist = { ["gettingup"] = true, ["died"] = true, ["freefalling"] = true, ["jumping"] = true, ["landing"] = true, ["running"] = true }

    for _, folder in ipairs(scanTargets) do
        local success, descendants = pcall(function() return folder:GetDescendants() end)
        if success and descendants then
            for _, obj in ipairs(descendants) do
                if obj:IsA("Sound") and obj.SoundId ~= "" then
                    local isBlacklisted = false
                    for blockedName, _ in pairs(NameBlacklist) do
                        if string.find(string.lower(obj.Name), blockedName) then
                            isBlacklisted = true; break
                        end
                    end
                    if not isBlacklisted and not soundMap[obj.SoundId] then
                        soundMap[obj.SoundId] = true
                        table.insert(validSounds, obj)
                    end
                end
            end
        end
    end
    return validSounds
end

local function copyToClipboard(text)
    local setclip = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    if setclip then setclip(text) end
end

-- ==================== UI BUILDER ====================
local GuiParent = CoreGui:FindFirstChild("RobloxGui") or PlayerGui
if GuiParent:FindFirstChild("HonkukiUltimateAudioGui") then
    GuiParent.HonkukiUltimateAudioGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", GuiParent)
ScreenGui.Name = "HonkukiUltimateAudioGui"
ScreenGui.ResetOnSpawn = false

local AuraGlow = Instance.new("Frame", ScreenGui)
AuraGlow.Name = "AuraGlow"
AuraGlow.Size = UDim2.new(0, 544, 0, 264)
AuraGlow.Position = UDim2.new(0.5, -272, 0.5, -132)
AuraGlow.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
AuraGlow.BackgroundTransparency = 0.7
AuraGlow.BorderSizePixel = 0
Instance.new("UICorner", AuraGlow).CornerRadius = UDim.new(0, 18)

local Shadow3D = Instance.new("Frame", ScreenGui)
Shadow3D.Size = UDim2.new(0, 530, 0, 250)
Shadow3D.Position = UDim2.new(0.5, -262, 0.5, -120)
Shadow3D.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow3D.BackgroundTransparency = 0.3
Shadow3D.BorderSizePixel = 0
Instance.new("UICorner", Shadow3D).CornerRadius = UDim.new(0, 16)

local LEDBorder = Instance.new("Frame", ScreenGui)
LEDBorder.Name = "LEDBorder"
LEDBorder.Size = UDim2.new(0, 530, 0, 250)
LEDBorder.Position = UDim2.new(0.5, -265, 0.5, -125)
LEDBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LEDBorder.BorderSizePixel = 0
LEDBorder.Active = true
Instance.new("UICorner", LEDBorder).CornerRadius = UDim.new(0, 16)

local LEDGradient = Instance.new("UIGradient", LEDBorder)
LEDGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 50, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 170, 0))
}

local MainFrame = Instance.new("Frame", LEDBorder)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, -6, 1, -6)
MainFrame.Position = UDim2.new(0, 3, 0, 3)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local ParticleCanvas = Instance.new("Frame", MainFrame)
ParticleCanvas.Size = UDim2.new(1, 0, 1, 0)
ParticleCanvas.BackgroundTransparency = 1

for i = 1, 15 do
    local Star = Instance.new("Frame", ParticleCanvas)
    Star.Size = UDim2.new(0, math.random(2, 3), 0, math.random(2, 3))
    Star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    Star.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    Star.BorderSizePixel = 0
    Star.BackgroundTransparency = math.random(3, 7) / 10
    Instance.new("UICorner", Star).CornerRadius = UDim.new(1, 0)
    
    task.spawn(function()
        while Star and Star.Parent do
            local TargetY = Star.Position.Y.Scale - 0.2
            if TargetY < -0.1 then TargetY = 1.1 end
            local tween = TweenService:Create(Star, TweenInfo.new(math.random(15, 30) / 10, Enum.EasingStyle.Linear), {
                Position = UDim2.new(Star.Position.X.Scale, 0, TargetY, 0),
                BackgroundTransparency = math.random(2, 8) / 10
            })
            tween:Play()
            tween.Completed:Wait()
        end
    end)
end

RunService.RenderStepped:Connect(function()
    LEDGradient.Rotation = (LEDGradient.Rotation + 1.2) % 360
    AuraGlow.BackgroundTransparency = 0.6 + ((math.sin(tick() * 3) + 1) / 2 * 0.2)
end)

local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(LEDBorder, MainFrame)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "✨ HONKUKI AUDIO LOGGER VIP"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local TagToggleSwitch = Instance.new("TextButton", TopBar)
TagToggleSwitch.Size = UDim2.new(0, 95, 0, 26)
TagToggleSwitch.Position = UDim2.new(1, -140, 0.5, -13)
TagToggleSwitch.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
TagToggleSwitch.Text = "🏷️ Tag: ON"
TagToggleSwitch.Font = Enum.Font.GothamBold
TagToggleSwitch.TextSize = 10
TagToggleSwitch.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", TagToggleSwitch).CornerRadius = UDim.new(0, 8)

TagToggleSwitch.MouseButton1Click:Connect(function()
    ShowTagsEnabled = not ShowTagsEnabled
    TagToggleSwitch.Text = ShowTagsEnabled and "🏷️ Tag: ON" or "🏷️ Tag: OFF"
    TagToggleSwitch.BackgroundColor3 = ShowTagsEnabled and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(200, 50, 50)
    for _, p in ipairs(Players:GetPlayers()) do pcall(function() setupPlayerTag(p) end) end
end)

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local ListScroll = Instance.new("ScrollingFrame", MainFrame)
ListScroll.Size = UDim2.new(0.44, 0, 0.65, 0)
ListScroll.Position = UDim2.new(0.03, 0, 0.20, 0)
ListScroll.BackgroundColor3 = Color3.fromRGB(16, 17, 24)
ListScroll.BorderSizePixel = 0
ListScroll.ScrollBarThickness = 4
ListScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
Instance.new("UICorner", ListScroll).CornerRadius = UDim.new(0, 10)

local Layout = Instance.new("UIListLayout", ListScroll)
Layout.Padding = UDim.new(0, 6)

local ButtonsContainer = Instance.new("Frame", MainFrame)
ButtonsContainer.Size = UDim2.new(0.48, 0, 0.65, 0)
ButtonsContainer.Position = UDim2.new(0.49, 0, 0.20, 0)
ButtonsContainer.BackgroundTransparency = 1

local BLayout = Instance.new("UIListLayout", ButtonsContainer)
BLayout.Padding = UDim.new(0, 6)

local function create3DButton(parent, text, color)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.ZIndex = (parent and parent.ZIndex or 1) + 2
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    return btn
end

local GetIDBtn = create3DButton(ButtonsContainer, "⚡ เจาะดึงไอดีเพลง", Color3.fromRGB(210, 160, 0))
local GetJunkBtn = create3DButton(ButtonsContainer, "🎵 ยิงเปิดเพลงตามขยะ", Color3.fromRGB(160, 100, 220))
local ListenToggleBtn = create3DButton(ButtonsContainer, "🎧 ฟังเพลงส่วนตัว (Volume 80%)", Color3.fromRGB(0, 140, 220))
local ViewRawJunkBtn = create3DButton(ButtonsContainer, "👁️ ดูขยะ RAW เรียลไทม์", Color3.fromRGB(40, 45, 60))
local ViewInstantBtn = create3DButton(ButtonsContainer, "🔍 ดู ID เจาะสด Real-time", Color3.fromRGB(40, 45, 60))

StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(0.94, 0, 0, 22)
StatusLabel.Position = UDim2.new(0.03, 0, 0.88, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
StatusLabel.Text = "📌 กรุณาเลือกชื่อผู้เล่นจากรายการด้านซ้าย..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 10
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 6)

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Name = "HonkukiToggleButton"
ToggleBtn.Size = UDim2.new(0, 120, 0, 36)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
ToggleBtn.Text = "⚡ HONKUKI UI"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 11
ToggleBtn.Active = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

local tStroke = Instance.new("UIStroke", ToggleBtn)
tStroke.Color = Color3.fromRGB(255, 215, 0)
tStroke.Thickness = 1.5
makeDraggable(ToggleBtn, ToggleBtn)

-- ==================== SECONDARY JUNK VIEWER UI ====================
local JunkFrame = Instance.new("Frame", MainFrame)
JunkFrame.Size = UDim2.new(1, 0, 1, 0)
JunkFrame.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
JunkFrame.Visible = false
JunkFrame.ZIndex = 10
Instance.new("UICorner", JunkFrame).CornerRadius = UDim.new(0, 14)

local JunkTitle = Instance.new("TextLabel", JunkFrame)
JunkTitle.Size = UDim2.new(0.7, 0, 0, 35)
JunkTitle.Position = UDim2.new(0, 15, 0, 5)
JunkTitle.BackgroundTransparency = 1
JunkTitle.Text = "RAW JUNK VIEWER"
JunkTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
JunkTitle.Font = Enum.Font.GothamBold
JunkTitle.TextSize = 12
JunkTitle.TextXAlignment = Enum.TextXAlignment.Left
JunkTitle.ZIndex = 11

local JunkScroll = Instance.new("ScrollingFrame", JunkFrame)
JunkScroll.Size = UDim2.new(0.92, 0, 0.68, 0)
JunkScroll.Position = UDim2.new(0.04, 0, 0.16, 0)
JunkScroll.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
JunkScroll.ScrollBarThickness = 6
JunkScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
JunkScroll.ZIndex = 11
JunkScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
JunkScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", JunkScroll).CornerRadius = UDim.new(0, 8)

local JunkTextLabel = Instance.new("TextLabel", JunkScroll)
JunkTextLabel.Size = UDim2.new(1, -12, 0, 0)
JunkTextLabel.Position = UDim2.new(0, 6, 0, 6)
JunkTextLabel.BackgroundTransparency = 1
JunkTextLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
JunkTextLabel.Font = Enum.Font.Code
JunkTextLabel.TextSize = 10
JunkTextLabel.TextXAlignment = Enum.TextXAlignment.Left
JunkTextLabel.TextYAlignment = Enum.TextYAlignment.Top
JunkTextLabel.TextWrapped = true
JunkTextLabel.AutomaticSize = Enum.AutomaticSize.Y
JunkTextLabel.ZIndex = 12

local JunkCopyBtn = create3DButton(JunkFrame, "📋 คัดลอกข้อมูล", Color3.fromRGB(0, 160, 100))
JunkCopyBtn.Size = UDim2.new(0.43, 0, 0, 26)
JunkCopyBtn.Position = UDim2.new(0.04, 0, 0.86, 0)
JunkCopyBtn.ZIndex = 12

local JunkBackBtn = create3DButton(JunkFrame, "⬅️ ย้อนกลับ", Color3.fromRGB(200, 50, 60))
JunkBackBtn.Size = UDim2.new(0.43, 0, 0, 26)
JunkBackBtn.Position = UDim2.new(0.53, 0, 0.86, 0)
JunkBackBtn.ZIndex = 12

-- ==================== ANIMATIONS & LOGIC ====================
local function toggleUI(state)
    if state then
        LEDBorder.Visible = true
        Shadow3D.Visible = true
        AuraGlow.Visible = true
        LEDBorder.Size = UDim2.new(0, 0, 0, 0)
        LEDBorder.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        TweenService:Create(LEDBorder, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 530, 0, 250),
            Position = UDim2.new(0.5, -265, 0.5, -125)
        }):Play()
        TweenService:Create(Shadow3D, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 530, 0, 250),
            Position = UDim2.new(0.5, -262, 0.5, -120)
        }):Play()
        TweenService:Create(AuraGlow, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 544, 0, 264),
            Position = UDim2.new(0.5, -272, 0.5, -132)
        }):Play()
    else
        local tween = TweenService:Create(LEDBorder, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        TweenService:Create(Shadow3D, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        TweenService:Create(AuraGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        tween:Play()
        tween.Completed:Wait()
        LEDBorder.Visible = false
        Shadow3D.Visible = false
        AuraGlow.Visible = false
    end
end

CloseBtn.MouseButton1Click:Connect(function() toggleUI(false) end)
ToggleBtn.MouseButton1Click:Connect(function() toggleUI(not LEDBorder.Visible) end)

local function stopLocalListeningSound()
    if ListeningLocalSound then
        ListeningLocalSound:Stop()
        ListeningLocalSound:Destroy()
        ListeningLocalSound = nil
    end
    IsListeningRealTime = false
    ListenToggleBtn.Text = "🎧 ฟังเพลงส่วนตัว (Volume 80%)"
    ListenToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
end

-- 🎧 ระบบปุ่มฟัง: ดึงเสียงจากคนที่เปิดใน Map ตรงๆ โดยไม่สนใจระยะทางและไม่แคร์ ID เสียงแมพ
ListenToggleBtn.MouseButton1Click:Connect(function()
    if IsListeningRealTime then
        stopLocalListeningSound()
        StatusLabel.Text = "⏹️ หยุดฟังเพลงส่วนตัวเรียบร้อยแล้ว"
        return
    end

    if CurrentSelectedPlayer then
        local targetPlayer = Players:FindFirstChild(CurrentSelectedPlayer.Name)
        local soundObjects = checkPlayerAllSounds(targetPlayer)
        
        if #soundObjects > 0 then
            local targetSound = soundObjects[1]
            stopLocalListeningSound()

            -- สร้าง Sound ส่วนตัวฝั่ง Local Player เพื่อข้ามการจำกัดระยะทาง (Spatial Distance/RollOff)
            ListeningLocalSound = Instance.new("Sound")
            ListeningLocalSound.SoundId = targetSound.SoundId
            ListeningLocalSound.Volume = 0.8
            ListeningLocalSound.TimePosition = targetSound.TimePosition
            ListeningLocalSound.Looped = targetSound.Looped
            ListeningLocalSound.Parent = PlayerGui
            ListeningLocalSound:Play()

            IsListeningRealTime = true
            ListenToggleBtn.Text = "⏹️ หยุดฟังเพลง (กำลังเปิด)"
            ListenToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            StatusLabel.Text = "🔊 กำลังเล่นเพลงของ " .. targetPlayer.DisplayName .. " แบบไร้ขีดจำกัดระยะทาง (80% Vol)"
        else
            StatusLabel.Text = "❌ ไม่พบเพลงที่ผู้เล่นคนนี้กำลังเปิดอยู่"
        end
    else
        StatusLabel.Text = "⚠️ โปรดเลือกชื่อผู้เล่นก่อนกดฟังเพลง!"
    end
end)

local function updateJunkViewerLive()
    if not JunkFrame.Visible or not CurrentSelectedPlayer then return end
    local targetPlayer = Players:FindFirstChild(CurrentSelectedPlayer.Name)
    if not targetPlayer then return end

    local soundObjects = checkPlayerAllSounds(targetPlayer)
    local outputText = ""

    if CurrentViewMode == 1 then
        JunkTitle.Text = "RAW JUNK VIEWER (แสดงขยะดิบทั้งหมด)"
        if #soundObjects == 0 then
            outputText = "❌ ไม่พบออบเจกต์เสียงบนตัวผู้เล่นนี้"
        else
            for i, obj in ipairs(soundObjects) do
                outputText = outputText .. string.format("[%d] ออบเจกต์: %s\nRAW DATA: %s\n\n", i, obj:GetFullName(), tostring(obj.SoundId))
            end
        end
    elseif CurrentViewMode == 2 then
        JunkTitle.Text = "INSTANT LOG VIEWER (ID เจาะสดทั้งหมด)"
        if #soundObjects == 0 then
            outputText = "❌ ไม่พบค่าเพลงของผู้เล่นนี้"
        else
            local finalIds, seenIds = {}, {}
            for _, soundObj in ipairs(soundObjects) do
                local rawId = soundObj.SoundId or ""
                local decoded = deepDecode(rawId)
                local searchText = (decoded ~= "" and decoded) or rawId
                local extractedIds = extractIDsFromPattern(searchText)
                if #extractedIds == 0 then
                    for num in string.gmatch(searchText, "%d+") do
                        if not BlockedIDs[num] then table.insert(extractedIds, num) end
                    end
                end
                for _, id in ipairs(extractedIds) do
                    if not seenIds[id] then
                        seenIds[id] = true
                        table.insert(finalIds, id)
                    end
                end
            end
            if #finalIds == 0 then
                outputText = "❌ ไม่พบ ID เพลงจริงอยู่ข้างใน"
            else
                outputText = "--- พบบทเพลงเจาะสำเร็จทั้งหมด " .. #finalIds .. " ID ---\n\n"
                for idx, id in ipairs(finalIds) do
                    outputText = outputText .. string.format("[%d] ID เจาะได้: %s\n", idx, id)
                end
            end
        end
    end

    JunkTextLabel.Text = outputText
    JunkTextLabel.Size = UDim2.new(1, -12, 0, 0)
end

local function refreshPlayers()
    if not ListScroll or not ListScroll:IsDescendantOf(game) then return end
    local currentPlayers = Players:GetPlayers()
    local activeMap = {}

    for _, p in ipairs(currentPlayers) do
        if p ~= LocalPlayer then
            activeMap[p] = true
            local btn = PlayerButtons[p]
            if not btn then
                btn = Instance.new("TextButton", ListScroll)
                btn.Size = UDim2.new(1, -6, 0, 26)
                btn.Font = Enum.Font.GothamMedium
                btn.TextSize = 10
                btn.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                local bStroke = Instance.new("UIStroke", btn)
                bStroke.Color = Color3.fromRGB(40, 45, 60)

                btn.MouseButton1Click:Connect(function()
                    for _, b in pairs(PlayerButtons) do
                        if b:FindFirstChildOfClass("UIStroke") then b.UIStroke.Color = Color3.fromRGB(40, 45, 60) end
                    end
                    bStroke.Color = Color3.fromRGB(255, 215, 0)
                    CurrentSelectedPlayer = p
                    StatusLabel.Text = "🎯 เลือก: " .. p.DisplayName
                    updateJunkViewerLive()
                end)
                PlayerButtons[p] = btn
            end

            local activeSounds = checkPlayerAllSounds(p)
            local isRunnerTag = (p.Character and p.Character:FindFirstChild(TAG_NAME)) and " [TAG]" or ""
            
            if #activeSounds > 0 then
                btn.Text = " 🎵 " .. p.DisplayName .. " (@" .. p.Name .. ")" .. isRunnerTag
                btn.TextColor3 = Color3.fromRGB(0, 255, 150)
            else
                btn.Text = " 👤 " .. p.DisplayName .. " (@" .. p.Name .. ")" .. isRunnerTag
                btn.TextColor3 = Color3.fromRGB(200, 200, 210)
            end
        end
    end

    for p, btn in pairs(PlayerButtons) do
        if not activeMap[p] then
            btn:Destroy()
            PlayerButtons[p] = nil
        end
    end
    ListScroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end

-- Button Events
GetIDBtn.MouseButton1Click:Connect(function()
    if CurrentSelectedPlayer then
        local targetPlayer = Players:FindFirstChild(CurrentSelectedPlayer.Name)
        local soundObjects = checkPlayerAllSounds(targetPlayer)
        local finalIds, seenIds = {}, {}
        for _, soundObj in ipairs(soundObjects) do
            local decoded = deepDecode(soundObj.SoundId or "")
            local extractedIds = extractIDsFromPattern(decoded)
            if #extractedIds == 0 then
                for num in string.gmatch(decoded, "%d+") do
                    if not BlockedIDs[num] then table.insert(extractedIds, num) end
                end
            end
            for _, id in ipairs(extractedIds) do
                if not seenIds[id] then
                    seenIds[id] = true; table.insert(finalIds, id)
                end
            end
        end
        if #finalIds > 0 then
            copyToClipboard(table.concat(finalIds, " "))
            StatusLabel.Text = "📋 คัดลอก " .. #finalIds .. " ID เรียบร้อยแล้ว!"
        else
            StatusLabel.Text = "❌ ไม่พบ ID ที่ใช้เปิดได้"
        end
    else
        StatusLabel.Text = "⚠️ โปรดเลือกชื่อผู้เล่นก่อนกดเจาะไอดี!"
    end
end)

GetJunkBtn.MouseButton1Click:Connect(function()
    if CurrentSelectedPlayer then
        local targetPlayer = Players:FindFirstChild(CurrentSelectedPlayer.Name)
        local soundObjects = checkPlayerAllSounds(targetPlayer)
        local firstCleanId = nil
        for _, soundObj in ipairs(soundObjects) do
            local cleanId = string.gsub(soundObj.SoundId or "", "^rbxassetid://", "")
            if not BlockedIDs[cleanId] and cleanId ~= "" then
                firstCleanId = cleanId; break
            end
        end
        if firstCleanId and ForcePlayMusicCombo(firstCleanId) then
            StatusLabel.Text = "✅ ส่งคำสั่งเปิดเพลงสำเร็จ: " .. firstCleanId
        else
            StatusLabel.Text = "❌ เล่นเพลงไม่สำเร็จ หรือระบบบล็อกไว้"
        end
    end
end)

ViewRawJunkBtn.MouseButton1Click:Connect(function()
    if CurrentSelectedPlayer then
        CurrentViewMode = 1
        JunkFrame.Visible = true
        updateJunkViewerLive()
    end
end)

ViewInstantBtn.MouseButton1Click:Connect(function()
    if CurrentSelectedPlayer then
        CurrentViewMode = 2
        JunkFrame.Visible = true
        updateJunkViewerLive()
    end
end)

JunkCopyBtn.MouseButton1Click:Connect(function()
    if JunkTextLabel.Text ~= "" then copyToClipboard(JunkTextLabel.Text) end
end)

JunkBackBtn.MouseButton1Click:Connect(function() JunkFrame.Visible = false end)

-- ⚡ SMOOTH BACKGROUND THREAD
task.spawn(function()
    while true do
        task.wait(4)
        markSelfAsRunner()
        
        for _, p in ipairs(Players:GetPlayers()) do
            pcall(function() setupPlayerTag(p) end)
            task.wait()
        end
        
        if MainFrame.Visible then
            pcall(function()
                refreshPlayers()
                if JunkFrame.Visible then updateJunkViewerLive() end
            end)
        end
    end
end)

refreshPlayers()
