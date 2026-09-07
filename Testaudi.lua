-- Roblox UI Script for Delta Executor (Custom Replica Edition)
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

-- Sound Local Check (Used for Length & Time Detection)
local activeSound = Instance.new("Sound")
activeSound.Parent = SoundService

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

-- GUI Initialization
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraMusicControlUI_V7"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 1. Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 110, 0, 45)
ToggleButton.Position = UDim2.new(0, 15, 0, 180)
ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "Kuki.⸝⁠xyz⸝⸝⁠⸝⁠⸝"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.ClipsDescendants = true
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2
ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ToggleStroke.Parent = ToggleButton

-- 2. Main Frame System
local TargetSize = UDim2.new(0, 520, 0, 310)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- LED Rainbow Border
local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 255))
}
UIGradient.Parent = MainStroke
local ToggleGradient = UIGradient:Clone()
ToggleGradient.Parent = ToggleStroke

task.spawn(function()
    local rot = 0
    while task.wait(0.03) do
        rot = (rot + 2) % 360
        UIGradient.Rotation = rot
        ToggleGradient.Rotation = rot
    end
end)

-- Background Image
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "BackgroundImage"
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = IMAGE_ID
BackgroundImage.ImageTransparency = 0.7
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.Parent = MainFrame

-- Header Label
local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Size = UDim2.new(1, -20, 0, 30)
HeaderLabel.Position = UDim2.new(0, 15, 0, 8)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Text = "PLAYER / VISUALIZER"
HeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderLabel.Font = Enum.Font.GothamBlack
HeaderLabel.TextSize = 15
HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
HeaderLabel.Parent = MainFrame

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -30, 0, 1)
HeaderLine.Position = UDim2.new(0, 15, 0, 38)
HeaderLine.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

-- Content Pages Container
local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -30, 1, -95)
PagesContainer.Position = UDim2.new(0, 15, 0, 45)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

-- Pages Declarations
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
HomeText.TextColor3 = Color3.fromRGB(220, 220, 220)
HomeText.Font = Enum.Font.GothamMedium
HomeText.TextSize = 13
HomeText.TextYAlignment = Enum.TextYAlignment.Top
HomeText.TextXAlignment = Enum.TextXAlignment.Left
HomeText.Text = "HEY WELCOME TO BOOMBOX CUSTOM ID V7.1\n\n-Needed (Gamepass)\n-Added Live Wallpaper\n\nCredit: @LaztDex\n\ntutorial : (equip : boombox and press play)"
HomeText.Parent = HomePage

----------------------------------------------------
-- 2. PLAYER PAGE CONTENT
----------------------------------------------------
local MusicTextBox = Instance.new("TextBox")
MusicTextBox.Size = UDim2.new(0.38, 0, 0, 35)
MusicTextBox.Position = UDim2.new(0.02, 0, 0.05, 0)
MusicTextBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MusicTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
MusicTextBox.PlaceholderText = "ENTER ID.."
MusicTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
MusicTextBox.Font = Enum.Font.GothamMedium
MusicTextBox.TextSize = 12
MusicTextBox.Text = ""
MusicTextBox.Parent = PlayerPage

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = MusicTextBox

local PlayButton = Instance.new("TextButton")
PlayButton.Size = UDim2.new(0.16, 0, 0, 40)
PlayButton.Position = UDim2.new(0.04, 0, 0.38, 0)
PlayButton.BackgroundTransparency = 1
PlayButton.Text = "▶"
PlayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayButton.Font = Enum.Font.GothamBlack
PlayButton.TextSize = 32
PlayButton.Parent = PlayerPage

local LoopButton = Instance.new("TextButton")
LoopButton.Size = UDim2.new(0.16, 0, 0, 40)
LoopButton.Position = UDim2.new(0.22, 0, 0.38, 0)
LoopButton.BackgroundTransparency = 1
LoopButton.Text = "🔁"
LoopButton.TextColor3 = Color3.fromRGB(160, 160, 180)
LoopButton.Font = Enum.Font.GothamBlack
LoopButton.TextSize = 26
LoopButton.Parent = PlayerPage

-- Visualizer Display Area
local VizFrame = Instance.new("Frame")
VizFrame.Size = UDim2.new(0.56, 0, 0.85, 0)
VizFrame.Position = UDim2.new(0.42, 0, 0.02, 0)
VizFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
VizFrame.BackgroundTransparency = 0.3
VizFrame.Parent = PlayerPage

local VizCorner = Instance.new("UICorner")
VizCorner.CornerRadius = UDim.new(0, 8)
VizCorner.Parent = VizFrame

local VizStroke = Instance.new("UIStroke")
VizStroke.Thickness = 1
VizStroke.Color = Color3.fromRGB(80, 80, 100)
VizStroke.Parent = VizFrame

-- Progress Line & Time
local ProgressBg = Instance.new("Frame")
ProgressBg.Size = UDim2.new(0.88, 0, 0, 3)
ProgressBg.Position = UDim2.new(0.06, 0, 0.78, 0)
ProgressBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
ProgressBg.BorderSizePixel = 0
ProgressBg.Parent = VizFrame

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressBg

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(1, 0, 0, 20)
TimeLabel.Position = UDim2.new(0, 0, 0.83, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "00:00 / 00:00"
TimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextSize = 11
TimeLabel.Parent = VizFrame

----------------------------------------------------
-- 3. SAVE PAGE CONTENT
----------------------------------------------------
local SaveNameBox = Instance.new("TextBox")
SaveNameBox.Size = UDim2.new(0.35, 0, 0, 30)
SaveNameBox.Position = UDim2.new(0.02, 0, 0.02, 0)
SaveNameBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
SaveNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveNameBox.PlaceholderText = "NAME.."
SaveNameBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
SaveNameBox.Font = Enum.Font.Gotham
SaveNameBox.TextSize = 11
SaveNameBox.Parent = SavePage
Instance.new("UICorner", SaveNameBox).CornerRadius = UDim.new(0, 6)

local SaveIdBox = Instance.new("TextBox")
SaveIdBox.Size = UDim2.new(0.35, 0, 0, 30)
SaveIdBox.Position = UDim2.new(0.39, 0, 0.02, 0)
SaveIdBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
SaveIdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveIdBox.PlaceholderText = "ID.."
SaveIdBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
SaveIdBox.Font = Enum.Font.Gotham
SaveIdBox.TextSize = 11
SaveIdBox.Parent = SavePage
Instance.new("UICorner", SaveIdBox).CornerRadius = UDim.new(0, 6)

local AddSaveBtn = Instance.new("TextButton")
AddSaveBtn.Size = UDim2.new(0.22, 0, 0, 30)
AddSaveBtn.Position = UDim2.new(0.76, 0, 0.02, 0)
AddSaveBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
AddSaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AddSaveBtn.Text = "ADD"
AddSaveBtn.Font = Enum.Font.GothamBold
AddSaveBtn.TextSize = 11
AddSaveBtn.Parent = SavePage
Instance.new("UICorner", AddSaveBtn).CornerRadius = UDim.new(0, 6)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 0.78, 0)
ScrollFrame.Position = UDim2.new(0, 0, 0.22, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.Parent = SavePage

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ScrollFrame

----------------------------------------------------
-- BOTTOM NAVIGATION BAR
----------------------------------------------------
local BottomBar = Instance.new("Frame")
BottomBar.Size = UDim2.new(1, 0, 0, 45)
BottomBar.Position = UDim2.new(0, 0, 1, -45)
BottomBar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
BottomBar.BorderSizePixel = 0
BottomBar.Parent = MainFrame

local HomeTabBtn = Instance.new("TextButton")
HomeTabBtn.Size = UDim2.new(0.15, 0, 1, 0)
HomeTabBtn.Position = UDim2.new(0.08, 0, 0, 0)
HomeTabBtn.BackgroundTransparency = 1
HomeTabBtn.Text = "🏠"
HomeTabBtn.TextSize = 22
HomeTabBtn.Parent = BottomBar

local PlayerTabBtn = Instance.new("TextButton")
PlayerTabBtn.Size = UDim2.new(0.15, 0, 1, 0)
PlayerTabBtn.Position = UDim2.new(0.25, 0, 0, 0)
PlayerTabBtn.BackgroundTransparency = 1
PlayerTabBtn.Text = "📈"
PlayerTabBtn.TextSize = 22
PlayerTabBtn.Parent = BottomBar

local SaveTabBtn = Instance.new("TextButton")
SaveTabBtn.Size = UDim2.new(0.15, 0, 1, 0)
SaveTabBtn.Position = UDim2.new(0.42, 0, 0, 0)
SaveTabBtn.BackgroundTransparency = 1
SaveTabBtn.Text = "💾"
SaveTabBtn.TextSize = 22
SaveTabBtn.Parent = BottomBar

local CloseXBtn = Instance.new("TextButton")
CloseXBtn.Size = UDim2.new(0.15, 0, 1, 0)
CloseXBtn.Position = UDim2.new(0.8, 0, 0, 0)
CloseXBtn.BackgroundTransparency = 1
CloseXBtn.Text = "✕"
CloseXBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseXBtn.Font = Enum.Font.GothamBold
CloseXBtn.TextSize = 20
CloseXBtn.Parent = BottomBar

-- Tab Switch Logic
local function switchTab(tabName)
    HomePage.Visible = (tabName == "Home")
    PlayerPage.Visible = (tabName == "Player")
    SavePage.Visible = (tabName == "Save")
    
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
-- REMOTE EVENT HELPER & MUSIC LOGIC
----------------------------------------------------
local isPlaying = false
local isLooping = false

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
    PlayButton.Text = "▶"
    sendMusicRemote("", false)
    activeSound:Stop()
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    TimeLabel.Text = "00:00 / 00:00"
end

local function startPlayback(id)
    if id == "" then return end
    isPlaying = true
    PlayButton.Text = "⏹️"
    
    -- Local Sound for Duration Tracking
    activeSound.SoundId = "rbxassetid://" .. id
    activeSound:Play()
    
    sendMusicRemote(id, true)
end

-- Play/Stop Click
PlayButton.MouseButton1Click:Connect(function()
    playSFX:Play()
    if isPlaying then
        stopPlayback()
    else
        startPlayback(MusicTextBox.Text)
    end
end)

-- Loop Click
LoopButton.MouseButton1Click:Connect(function()
    isLooping = not isLooping
    if isLooping then
        LoopButton.TextColor3 = Color3.fromRGB(0, 200, 255)
    else
        LoopButton.TextColor3 = Color3.fromRGB(160, 160, 180)
    end
end)

-- Track Progress & Detect Song End
local function formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", mins, secs)
end

task.spawn(function()
    while task.wait(0.3) do
        if isPlaying and activeSound.IsLoaded then
            local currentTime = activeSound.TimePosition
            local totalTime = activeSound.TimeLength
            
            if totalTime > 0 then
                local ratio = math.clamp(currentTime / totalTime, 0, 1)
                ProgressFill.Size = UDim2.new(ratio, 0, 1, 0)
                TimeLabel.Text = formatTime(currentTime) .. " / " .. formatTime(totalTime)
                
                -- Detect Song End
                if currentTime >= (totalTime - 0.5) then
                    if isLooping then
                        activeSound.TimePosition = 0
                        sendMusicRemote(MusicTextBox.Text, true)
                    else
                        -- Reset instantly to 0 and Stop
                        stopPlayback()
                    end
                end
            end
        end
    end
end)

----------------------------------------------------
-- SAVED SONGS SYSTEM
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
        ItemFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        ItemFrame.Parent = ScrollFrame
        Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 6)

        local SongTitle = Instance.new("TextLabel")
        SongTitle.Size = UDim2.new(0.5, 0, 1, 0)
        SongTitle.Position = UDim2.new(0.03, 0, 0, 0)
        SongTitle.BackgroundTransparency = 1
        SongTitle.Text = songData.Name
        SongTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
        SongTitle.Font = Enum.Font.Gotham
        SongTitle.TextSize = 11
        SongTitle.TextXAlignment = Enum.TextXAlignment.Left
        SongTitle.Parent = ItemFrame

        local QPlayBtn = Instance.new("TextButton")
        QPlayBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
        QPlayBtn.Position = UDim2.new(0.55, 0, 0.15, 0)
        QPlayBtn.BackgroundTransparency = 1
        QPlayBtn.Text = "▶"
        QPlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        QPlayBtn.Font = Enum.Font.GothamBold
        QPlayBtn.TextSize = 14
        QPlayBtn.Parent = ItemFrame

        local DelBtn = Instance.new("TextButton")
        DelBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
        DelBtn.Position = UDim2.new(0.82, 0, 0.15, 0)
        DelBtn.BackgroundTransparency = 1
        DelBtn.Text = "🗑"
        DelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        DelBtn.Font = Enum.Font.GothamBold
        DelBtn.TextSize = 14
        DelBtn.Parent = ItemFrame

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
-- DRAGGABLE & TOGGLE SYSTEM
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
