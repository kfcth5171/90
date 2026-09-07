-- Roblox UI Script for Delta Executor (Hon Kuki Ultra LED Edition V7.2)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Assets Config
local IMAGE_ID = "rbxassetid://71528188513749"
local OPEN_SOUND_ID = "rbxassetid://70452176150315"
local CLOSE_SOUND_ID = "rbxassetid://115916891254154"
local PLAY_SOUND_ID = "rbxassetid://542332175"

local SAVE_FILE_NAME = "MusicPlayer_SavedSongs.json"

-- Sound Objects Setup
local function createSFX(id)
    local sfx = Instance.new("Sound")
    sfx.SoundId = id
    sfx.Volume = 1
    sfx.Parent = SoundService or Workspace
    return sfx
end

local openSFX = createSFX(OPEN_SOUND_ID)
local closeSFX = createSFX(CLOSE_SOUND_ID)
local playSFX = createSFX(PLAY_SOUND_ID)

-- Saved Songs Data Manager
local savedSongs = {}

local function loadSongsFromFile()
    if readfile and isfile and isfile(SAVE_FILE_NAME) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(SAVE_FILE_NAME))
        end)
        if success and type(result) == "table" then
            savedSongs = result
        end
    end
end

local function saveSongsToFile()
    if writefile then
        pcall(function()
            writefile(SAVE_FILE_NAME, HttpService:JSONEncode(savedSongs))
        end)
    end
end

loadSongsFromFile()

-- Clean up existing UI if re-executed
if PlayerGui:FindFirstChild("UltraMusicControlUI_HonKuki") then
    PlayerGui.UltraMusicControlUI_HonKuki:Destroy()
end

-- GUI Initialization
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraMusicControlUI_HonKuki"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Helper UI Function (Draw Custom Neon Button)
local function createCustomButton(parent, size, pos, text)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 24)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(0, 255, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = true
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.8
    stroke.Color = Color3.fromRGB(0, 255, 200)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btn

    return btn, stroke
end

-- 1. Square Toggle Button with Custom Image + Running LED Border
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 65, 0, 65)
ToggleButton.Position = UDim2.new(0, 20, 0, 200)
ToggleButton.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
ToggleButton.Image = IMAGE_ID
ToggleButton.ScaleType = Enum.ScaleType.Crop
ToggleButton.ClipsDescendants = true
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 14)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 3
ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ToggleStroke.Parent = ToggleButton

local ToggleGradient = Instance.new("UIGradient")
ToggleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 128)),
    ColorSequenceKeypoint.new(0.20, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 128, 255)),
    ColorSequenceKeypoint.new(0.60, Color3.fromRGB(170, 0, 255)),
    ColorSequenceKeypoint.new(0.80, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 128))
}
ToggleGradient.Parent = ToggleStroke

-- Subtle Overlay Glow for Toggle Button
local ToggleOverlay = Instance.new("Frame")
ToggleOverlay.Size = UDim2.new(1, 0, 1, 0)
ToggleOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleOverlay.BackgroundTransparency = 0.35
ToggleOverlay.Parent = ToggleButton
Instance.new("UICorner", ToggleOverlay).CornerRadius = UDim.new(0, 14)

local ToggleText = Instance.new("TextLabel")
ToggleText.Size = UDim2.new(1, 0, 1, 0)
ToggleText.BackgroundTransparency = 1
ToggleText.Text = "UI"
ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleText.Font = Enum.Font.GothamBlack
ToggleText.TextSize = 16
ToggleText.Parent = ToggleOverlay

-- 2. Main Frame System
local TargetSize = UDim2.new(0, 520, 0, 310)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

-- Vibrant Multi-Color Running LED Neon Border for Main Frame
local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 3.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 128)),
    ColorSequenceKeypoint.new(0.20, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 128, 255)),
    ColorSequenceKeypoint.new(0.60, Color3.fromRGB(170, 0, 255)),
    ColorSequenceKeypoint.new(0.80, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 128))
}
MainGradient.Parent = MainStroke

-- Smooth Ultra LED Running Animation Thread
task.spawn(function()
    local rot = 0
    while task.wait(0.02) do
        rot = (rot + 3) % 360
        MainGradient.Rotation = rot
        ToggleGradient.Rotation = rot
    end
end)

-- Background Image with Dark Vignette Overlay
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "BackgroundImage"
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = IMAGE_ID
BackgroundImage.ImageTransparency = 0.70
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.Parent = MainFrame

local Vignette = Instance.new("Frame")
Vignette.Size = UDim2.new(1, 0, 1, 0)
Vignette.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
Vignette.BackgroundTransparency = 0.45
Vignette.Parent = MainFrame

-- Header Label
local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Size = UDim2.new(1, -30, 0, 32)
HeaderLabel.Position = UDim2.new(0, 18, 0, 10)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Text = "PLAYER / VISUALIZER"
HeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderLabel.Font = Enum.Font.GothamBlack
HeaderLabel.TextSize = 14
HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
HeaderLabel.Parent = MainFrame

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -36, 0, 2)
HeaderLine.Position = UDim2.new(0, 18, 0, 42)
HeaderLine.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

local HeaderLineGradient = Instance.new("UIGradient")
HeaderLineGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 128)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 128, 255))
}
HeaderLineGradient.Parent = HeaderLine

-- Pages Container
local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -36, 1, -100)
PagesContainer.Position = UDim2.new(0, 18, 0, 50)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

local HomePage = Instance.new("Frame")
HomePage.Size = UDim2.new(1, 0, 1, 0)
HomePage.BackgroundTransparency = 1
HomePage.Visible = false
HomePage.Parent = PagesContainer

local PlayerPage = Instance.new("Frame")
PlayerPage.Size = UDim2.new(1, 0, 1, 0)
PlayerPage.BackgroundTransparency = 1
PlayerPage.Visible = true
PlayerPage.Parent = PagesContainer

local SavePage = Instance.new("Frame")
SavePage.Size = UDim2.new(1, 0, 1, 0)
SavePage.BackgroundTransparency = 1
SavePage.Visible = false
SavePage.Parent = PagesContainer

----------------------------------------------------
-- 1. HOME PAGE CONTENT
----------------------------------------------------
local HomeText = Instance.new("TextLabel")
HomeText.Size = UDim2.new(1, 0, 1, 0)
HomeText.BackgroundTransparency = 1
HomeText.TextColor3 = Color3.fromRGB(230, 230, 245)
HomeText.Font = Enum.Font.GothamMedium
HomeText.TextSize = 13
HomeText.TextYAlignment = Enum.TextYAlignment.Top
HomeText.TextXAlignment = Enum.TextXAlignment.Left
HomeText.Text = "HEY WELCOME TO BOOMBOX CUSTOM ID V7.2\n\n- Needed (Gamepass)\n- Added Live LED Neon Wallpaper\n\nCredit: @hon kuki\n\nTutorial: (equip boombox and press play)"
HomeText.Parent = HomePage

----------------------------------------------------
-- 2. PLAYER PAGE CONTENT
----------------------------------------------------
local MusicTextBox = Instance.new("TextBox")
MusicTextBox.Size = UDim2.new(0.38, 0, 0, 38)
MusicTextBox.Position = UDim2.new(0.02, 0, 0.08, 0)
MusicTextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MusicTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
MusicTextBox.PlaceholderText = "ENTER ID..."
MusicTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
MusicTextBox.Font = Enum.Font.GothamBold
MusicTextBox.TextSize = 12
MusicTextBox.Text = ""
MusicTextBox.Parent = PlayerPage

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 8)
BoxCorner.Parent = MusicTextBox

local BoxStroke = Instance.new("UIStroke")
BoxStroke.Thickness = 1.5
BoxStroke.Color = Color3.fromRGB(0, 255, 200)
BoxStroke.Parent = MusicTextBox

-- Custom Neon Play/Stop Button Frame
local PlayBtnFrame = Instance.new("TextButton")
PlayBtnFrame.Size = UDim2.new(0.38, 0, 0, 52)
PlayBtnFrame.Position = UDim2.new(0.02, 0, 0.42, 0)
PlayBtnFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
PlayBtnFrame.Text = ""
PlayBtnFrame.Parent = PlayerPage
Instance.new("UICorner", PlayBtnFrame).CornerRadius = UDim.new(0, 10)

local PlayBtnStroke = Instance.new("UIStroke")
PlayBtnStroke.Thickness = 2
PlayBtnStroke.Color = Color3.fromRGB(0, 255, 170)
PlayBtnStroke.Parent = PlayBtnFrame

local PlayIconVisual = Instance.new("TextLabel")
PlayIconVisual.Size = UDim2.new(1, 0, 1, 0)
PlayIconVisual.BackgroundTransparency = 1
PlayIconVisual.Text = "▶ PLAY"
PlayIconVisual.TextColor3 = Color3.fromRGB(0, 255, 170)
PlayIconVisual.Font = Enum.Font.GothamBlack
PlayIconVisual.TextSize = 15
PlayIconVisual.Parent = PlayBtnFrame

-- Visualizer Display Area
local VizFrame = Instance.new("Frame")
VizFrame.Size = UDim2.new(0.56, 0, 0.88, 0)
VizFrame.Position = UDim2.new(0.42, 0, 0.02, 0)
VizFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
VizFrame.BackgroundTransparency = 0.2
VizFrame.Parent = PlayerPage

local VizCorner = Instance.new("UICorner")
VizCorner.CornerRadius = UDim.new(0, 10)
VizCorner.Parent = VizFrame

local VizStroke = Instance.new("UIStroke")
VizStroke.Thickness = 1.5
VizStroke.Color = Color3.fromRGB(0, 255, 200)
VizStroke.Parent = VizFrame

-- Animated Audio Visualizer Bars
local BarsHolder = Instance.new("Frame")
BarsHolder.Size = UDim2.new(0.88, 0, 0.6, 0)
BarsHolder.Position = UDim2.new(0.06, 0, 0.2, 0)
BarsHolder.BackgroundTransparency = 1
BarsHolder.Parent = VizFrame

local vizBars = {}
local barCount = 10
for i = 1, barCount do
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1 / barCount - 0.04, 0, 0.2, 0)
    bar.Position = UDim2.new((i - 1) / barCount + 0.02, 0, 1, 0)
    bar.AnchorPoint = Vector2.new(0, 1)
    bar.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    bar.BorderSizePixel = 0
    bar.Parent = BarsHolder
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)
    
    local barGradient = Instance.new("UIGradient")
    barGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 128))
    }
    barGradient.Rotation = 90
    barGradient.Parent = bar
    
    table.insert(vizBars, bar)
end

----------------------------------------------------
-- 3. SAVE PAGE CONTENT
----------------------------------------------------
local SaveNameBox = Instance.new("TextBox")
SaveNameBox.Size = UDim2.new(0.35, 0, 0, 32)
SaveNameBox.Position = UDim2.new(0.02, 0, 0.02, 0)
SaveNameBox.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
SaveNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveNameBox.PlaceholderText = "NAME..."
SaveNameBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 130)
SaveNameBox.Font = Enum.Font.GothamMedium
SaveNameBox.TextSize = 11
SaveNameBox.Parent = SavePage
Instance.new("UICorner", SaveNameBox).CornerRadius = UDim.new(0, 6)

local SaveIdBox = Instance.new("TextBox")
SaveIdBox.Size = UDim2.new(0.35, 0, 0, 32)
SaveIdBox.Position = UDim2.new(0.39, 0, 0.02, 0)
SaveIdBox.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
SaveIdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveIdBox.PlaceholderText = "ID..."
SaveIdBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 130)
SaveIdBox.Font = Enum.Font.GothamMedium
SaveIdBox.TextSize = 11
SaveIdBox.Parent = SavePage
Instance.new("UICorner", SaveIdBox).CornerRadius = UDim.new(0, 6)

local AddSaveBtn, AddStroke = createCustomButton(SavePage, UDim2.new(0.22, 0, 0, 32), UDim2.new(0.76, 0, 0.02, 0), "ADD")

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 0.78, 0)
ScrollFrame.Position = UDim2.new(0, 0, 0.22, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.Parent = SavePage

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ScrollFrame

----------------------------------------------------
-- BOTTOM NAVIGATION BAR
----------------------------------------------------
local BottomBar = Instance.new("Frame")
BottomBar.Size = UDim2.new(1, 0, 0, 42)
BottomBar.Position = UDim2.new(0, 0, 1, -42)
BottomBar.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
BottomBar.BorderSizePixel = 0
BottomBar.Parent = MainFrame

local HomeTabBtn = Instance.new("TextButton")
HomeTabBtn.Size = UDim2.new(0.18, 0, 1, 0)
HomeTabBtn.Position = UDim2.new(0.06, 0, 0, 0)
HomeTabBtn.BackgroundTransparency = 1
HomeTabBtn.Text = "HOME"
HomeTabBtn.TextColor3 = Color3.fromRGB(150, 150, 180)
HomeTabBtn.Font = Enum.Font.GothamBold
HomeTabBtn.TextSize = 11
HomeTabBtn.Parent = BottomBar

local PlayerTabBtn = Instance.new("TextButton")
PlayerTabBtn.Size = UDim2.new(0.18, 0, 1, 0)
PlayerTabBtn.Position = UDim2.new(0.26, 0, 0, 0)
PlayerTabBtn.BackgroundTransparency = 1
PlayerTabBtn.Text = "PLAYER"
PlayerTabBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
PlayerTabBtn.Font = Enum.Font.GothamBold
PlayerTabBtn.TextSize = 11
PlayerTabBtn.Parent = BottomBar

local SaveTabBtn = Instance.new("TextButton")
SaveTabBtn.Size = UDim2.new(0.18, 0, 1, 0)
SaveTabBtn.Position = UDim2.new(0.46, 0, 0, 0)
SaveTabBtn.BackgroundTransparency = 1
SaveTabBtn.Text = "SAVE"
SaveTabBtn.TextColor3 = Color3.fromRGB(150, 150, 180)
SaveTabBtn.Font = Enum.Font.GothamBold
SaveTabBtn.TextSize = 11
SaveTabBtn.Parent = BottomBar

local CloseXBtn = Instance.new("TextButton")
CloseXBtn.Size = UDim2.new(0.12, 0, 1, 0)
CloseXBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseXBtn.BackgroundTransparency = 1
CloseXBtn.Text = "✕"
CloseXBtn.TextColor3 = Color3.fromRGB(255, 60, 90)
CloseXBtn.Font = Enum.Font.GothamBlack
CloseXBtn.TextSize = 16
CloseXBtn.Parent = BottomBar

-- Tab Switch Logic
local function switchTab(tabName)
    HomePage.Visible = (tabName == "Home")
    PlayerPage.Visible = (tabName == "Player")
    SavePage.Visible = (tabName == "Save")
    
    HomeTabBtn.TextColor3 = (tabName == "Home") and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(150, 150, 180)
    PlayerTabBtn.TextColor3 = (tabName == "Player") and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(150, 150, 180)
    SaveTabBtn.TextColor3 = (tabName == "Save") and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(150, 150, 180)

    if tabName == "Home" then
        HeaderLabel.Text = "HOME"
    elseif tabName == "Player" then
        HeaderLabel.Text = "PLAYER / VISUALIZER"
    elseif tabName == "Save" then
        HeaderLabel.Text = "SAVE"
    end
end

HomeTabBtn.MouseButton1Click:Connect(function() switchTab("Home") end)
PlayerTabBtn.MouseButton1Click:Connect(function() switchTab("Player") end)
SaveTabBtn.MouseButton1Click:Connect(function() switchTab("Save") end)

----------------------------------------------------
-- REMOTE EVENT ONLY PLAYBACK (NO LOOP, NO LOCAL AUDIO)
----------------------------------------------------
local isPlaying = false

local function sendMusicRemote(musicId, state)
    local activeId = state and musicId or ""
    
    local re1 = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1NoMoto1rVehicle1s")
    if re1 then
        pcall(function() re1:FireServer("PickingScooterMusicText", activeId, {[4] = true}) end)
    end

    local re2 = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("PlayerToolEvent")
    if re2 then
        pcall(function() re2:FireServer("ToolMusicText", activeId, {[4] = true}) end)
    end
end

local function stopPlayback()
    isPlaying = false
    PlayIconVisual.Text = "▶ PLAY"
    PlayIconVisual.TextColor3 = Color3.fromRGB(0, 255, 170)
    PlayBtnStroke.Color = Color3.fromRGB(0, 255, 170)
    sendMusicRemote("", false)
end

local function startPlayback(id)
    if id == "" then return end
    isPlaying = true
    PlayIconVisual.Text = "■ STOP"
    PlayIconVisual.TextColor3 = Color3.fromRGB(255, 60, 80)
    PlayBtnStroke.Color = Color3.fromRGB(255, 60, 80)
    sendMusicRemote(id, true)
end

PlayBtnFrame.MouseButton1Click:Connect(function()
    playSFX:Play()
    if isPlaying then
        stopPlayback()
    else
        startPlayback(MusicTextBox.Text)
    end
end)

-- Visualizer Animation Thread
task.spawn(function()
    while task.wait(0.1) do
        if isPlaying then
            for _, bar in ipairs(vizBars) do
                local targetHeight = math.random(15, 95) / 100
                TweenService:Create(bar, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(bar.Size.X.Scale, 0, targetHeight, 0)}):Play()
            end
        else
            for _, bar in ipairs(vizBars) do
                TweenService:Create(bar, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(bar.Size.X.Scale, 0, 0.05, 0)}):Play()
            end
        end
    end
end)

----------------------------------------------------
-- SAVED SONGS LIST RENDER
----------------------------------------------------
local renderSavedList

renderSavedList = function()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local ySize = 0
    for index, songData in ipairs(savedSongs) do
        local ItemFrame = Instance.new("Frame")
        ItemFrame.Size = UDim2.new(1, -5, 0, 36)
        ItemFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        ItemFrame.Parent = ScrollFrame
        Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 6)

        local ItemStroke = Instance.new("UIStroke")
        ItemStroke.Thickness = 1
        ItemStroke.Color = Color3.fromRGB(40, 40, 60)
        ItemStroke.Parent = ItemFrame

        local SongTitle = Instance.new("TextLabel")
        SongTitle.Size = UDim2.new(0.5, 0, 1, 0)
        SongTitle.Position = UDim2.new(0.03, 0, 0, 0)
        SongTitle.BackgroundTransparency = 1
        SongTitle.Text = songData.Name .. " (" .. songData.Id .. ")"
        SongTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
        SongTitle.Font = Enum.Font.GothamMedium
        SongTitle.TextSize = 11
        SongTitle.TextXAlignment = Enum.TextXAlignment.Left
        SongTitle.Parent = ItemFrame

        local QPlayBtn = createCustomButton(ItemFrame, UDim2.new(0, 50, 0, 26), UDim2.new(0.6, 0, 0.14, 0), "PLAY")
        local DelBtn = createCustomButton(ItemFrame, UDim2.new(0, 50, 0, 26), UDim2.new(0.8, 0, 0.14, 0), "DEL")

        QPlayBtn.MouseButton1Click:Connect(function()
            playSFX:Play()
            MusicTextBox.Text = songData.Id
            switchTab("Player")
            startPlayback(songData.Id)
        end)

        DelBtn.MouseButton1Click:Connect(function()
            table.remove(savedSongs, index)
            saveSongsToFile()
            renderSavedList()
        end)

        ySize = ySize + 42
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ySize)
end

AddSaveBtn.MouseButton1Click:Connect(function()
    local id = SaveIdBox.Text ~= "" and SaveIdBox.Text or MusicTextBox.Text
    local name = SaveNameBox.Text ~= "" and SaveNameBox.Text or ("Song " .. #savedSongs + 1)
    
    if id ~= "" then
        table.insert(savedSongs, {Name = name, Id = id})
        saveSongsToFile()
        renderSavedList()
        SaveNameBox.Text = ""
        SaveIdBox.Text = ""
    end
end)

renderSavedList()

----------------------------------------------------
-- DRAGGABLE & TOGGLE GUI LOGIC
----------------------------------------------------
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
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

makeDraggable(ToggleButton)
makeDraggable(MainFrame)

local isOpening = false
local function toggleGUI()
    if isOpening then return end
    isOpening = true

    if not MainFrame.Visible then
        openSFX:Play()
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Visible = true
        
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = TargetSize})
        tween:Play()
        tween.Completed:Wait()
    else
        closeSFX:Play()
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
        tween:Play()
        tween.Completed:Wait()
        MainFrame.Visible = false
    end
    isOpening = false
end

ToggleButton.MouseButton1Click:Connect(toggleGUI)
CloseXBtn.MouseButton1Click:Connect(toggleGUI)
