-- =====================================================================
-- [[ CATALOG AVATAR CREATOR - FULL SYNC MUSIC PLAYER ]]
-- =====================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remotes
local ReliableRemote = ReplicatedStorage:WaitForChild("RelicsXYZ")
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("maximumadhd_network@1.1.1")
    :WaitForChild("network")
    :WaitForChild("Remotes")
    :WaitForChild("Reliable")

local SettingUpdatedRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("OnSettingUpdated")

-- UI SETUP
local GuiParent = CoreGui:FindFirstChild("RobloxGui") or PlayerGui
if GuiParent:FindFirstChild("CatalogMusicPlayerUI") then
    GuiParent.CatalogMusicPlayerUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", GuiParent)
ScreenGui.Name = "CatalogMusicPlayerUI"
ScreenGui.ResetOnSpawn = false

local isPlaying = false

-- ==================== FUNCTION เล่น / หยุดเพลง ====================
local function stopMusic()
    pcall(function()
        local bufStop = buffer.fromstring("\b\x00")
        ReliableRemote:FireServer("RELICSxyz_AudioPatch", { _b = bufStop })
    end)
    isPlaying = false
end

local function playMusic(songId)
    if not songId or songId == "" then return end
    songId = tostring(songId):gsub("%D", "")
    local numId = tonumber(songId)

    pcall(function()
        -- 1. ยิงดึงข้อมูล Asset จาก Marketplace
        if numId then
            ReliableRemote:FireServer("Marketplace_RequestProductInfo", numId, Enum.InfoType.Asset)
            task.wait(0.03)
        end

        -- 2. ยิงเข้า Recents ด้วย Obfuscated Payload (อ่านยาก/ข้อความเพี้ยนบน UI)
        -- แทรก Null Byte และ Control Codes ระหว่างตัวเลขเพื่อรบกวนการแสดงผลของ UI
        local maskedId = ""
        for i = 1, #songId do
            maskedId = maskedId .. songId:sub(i, i) .. "\x00\x08"
        end
        local fakeRecentPayload = "\x0D\x0C" .. "rbxassetid://" .. maskedId .. string.rep(" ", 30)

        ReliableRemote:FireServer("RELICSxyz_PushRecentSong", fakeRecentPayload)
        task.wait(0.03)

        -- 3. ยิง Buffers สั่งเล่นเพลง (ใช้อักขระ ID แท้ โครงสร้างเดิม 100%)
        local buf1 = buffer.fromstring("\x12rbxassetid://" .. songId .. "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00")
        ReliableRemote:FireServer("RELICSxyz_AudioPatch", { _b = buf1 })
        task.wait(0.01)

        local buf2 = buffer.fromstring("\b\x01")
        ReliableRemote:FireServer("RELICSxyz_AudioPatch", { _b = buf2 })
        task.wait(0.01)

        local buf3 = buffer.fromstring("\x12rbxassetid://" .. songId .. "\x00\x00\x00\x00\x00\x00\x00\x00\xCD\xCC\xCC=")
        ReliableRemote:FireServer("RELICSxyz_AudioPatch", { _b = buf3 })
        task.wait(0.01)

        local buf4 = buffer.fromstring("\x10\xCD\xCC\xCC=")
        ReliableRemote:FireServer("RELICSxyz_AudioPatch", { _b = buf4 })
    end)

    isPlaying = true
end

-- ==================== FUNCTION ปรับความดัง ====================
local function setVolume(volValue)
    local targetVol = math.clamp(math.round(volValue), 0, 100)
    pcall(function()
        SettingUpdatedRemote:FireServer("MusicVolume", targetVol)
    end)
end

-- ==================== DRAGGABLE SYSTEM ====================
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

-- ==================== UI BUILDER ====================
local ToggleIconButton = Instance.new("ImageButton", ScreenGui)
ToggleIconButton.Name = "ToggleIconButton"
ToggleIconButton.Size = UDim2.new(0, 42, 0, 42)
ToggleIconButton.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleIconButton.Image = "rbxassetid://71528188513749"
ToggleIconButton.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
ToggleIconButton.BackgroundTransparency = 0.2
ToggleIconButton.Active = true
Instance.new("UICorner", ToggleIconButton).CornerRadius = UDim.new(0, 10)

local ToggleStroke = Instance.new("UIStroke", ToggleIconButton)
ToggleStroke.Color = Color3.fromRGB(0, 180, 255)
ToggleStroke.Thickness = 1.5

makeDraggable(ToggleIconButton, ToggleIconButton)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 310, 0, 220)
MainFrame.Position = UDim2.new(0.5, -155, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 180, 255)
MainStroke.Thickness = 1.5

makeDraggable(MainFrame, MainFrame)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎵 Catalog Music Player"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local TextBox = Instance.new("TextBox", MainFrame)
TextBox.Size = UDim2.new(0.9, 0, 0, 35)
TextBox.Position = UDim2.new(0.05, 0, 0.2, 0)
TextBox.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
TextBox.PlaceholderText = "วาง ID เพลงที่นี่..."
TextBox.PlaceholderColor3 = Color3.fromRGB(120, 125, 140)
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Font = Enum.Font.GothamMedium
TextBox.TextSize = 12
TextBox.ClearTextOnFocus = false
Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 8)

local TextStroke = Instance.new("UIStroke", TextBox)
TextStroke.Color = Color3.fromRGB(50, 55, 75)

local PlayStopBtn = Instance.new("TextButton", MainFrame)
PlayStopBtn.Size = UDim2.new(0.9, 0, 0, 36)
PlayStopBtn.Position = UDim2.new(0.05, 0, 0.42, 0)
PlayStopBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 230)
PlayStopBtn.Text = "▶️ เล่นเพลง"
PlayStopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayStopBtn.Font = Enum.Font.GothamBold
PlayStopBtn.TextSize = 13
Instance.new("UICorner", PlayStopBtn).CornerRadius = UDim.new(0, 8)

-- VOLUME SLIDER UI
local VolContainer = Instance.new("Frame", MainFrame)
VolContainer.Size = UDim2.new(0.9, 0, 0, 45)
VolContainer.Position = UDim2.new(0.05, 0, 0.65, 0)
VolContainer.BackgroundTransparency = 1

local VolLabel = Instance.new("TextLabel", VolContainer)
VolLabel.Size = UDim2.new(1, 0, 0, 18)
VolLabel.BackgroundTransparency = 1
VolLabel.Text = "🔊 ความดัง: 100"
VolLabel.TextColor3 = Color3.fromRGB(200, 205, 220)
VolLabel.Font = Enum.Font.GothamMedium
VolLabel.TextSize = 11
VolLabel.TextXAlignment = Enum.TextXAlignment.Left

local SliderBackground = Instance.new("Frame", VolContainer)
SliderBackground.Size = UDim2.new(1, 0, 0, 8)
SliderBackground.Position = UDim2.new(0, 0, 0, 24)
SliderBackground.BackgroundColor3 = Color3.fromRGB(35, 38, 52)
Instance.new("UICorner", SliderBackground).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame", SliderBackground)
SliderFill.Size = UDim2.new(1, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

local SliderBtn = Instance.new("TextButton", SliderBackground)
SliderBtn.Size = UDim2.new(0, 16, 0, 16)
SliderBtn.Position = UDim2.new(1, -8, 0.5, -8)
SliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderBtn.Text = ""
Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)

local sliding = false

local function updateSlider(input)
    local absPos = SliderBackground.AbsolutePosition.X
    local absSize = SliderBackground.AbsoluteSize.X
    local mouseX = input.Position.X
    local percentage = math.clamp((mouseX - absPos) / absSize, 0, 1)

    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    SliderBtn.Position = UDim2.new(percentage, -8, 0.5, -8)

    local vol100 = math.round(percentage * 100)
    VolLabel.Text = "🔊 ความดัง: " .. vol100
    
    setVolume(vol100)
end

SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

SliderBackground.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = true
        updateSlider(input)
    end
end)

-- EVENTS
ToggleIconButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

PlayStopBtn.MouseButton1Click:Connect(function()
    if isPlaying then
        stopMusic()
        PlayStopBtn.Text = "▶️ เล่นเพลง"
        PlayStopBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 230)
    else
        local inputId = TextBox.Text
        if inputId ~= "" then
            playMusic(inputId)
            PlayStopBtn.Text = "⏹️ หยุดเพลง"
            PlayStopBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 60)
        end
    end
end)
