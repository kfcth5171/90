-- [[ HONKUKI LOADER SYSTEM ]] --
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- ดึงชื่อแมพปัจจุบัน
local Success, GameInfo = pcall(function()
    return MarketplaceService:GetProductInfo(PlaceId)
end)
local CurrentGameName = Success and GameInfo.Name or "Unknown Game"

-- ฟังก์ชันหลักที่จะรันเมื่อโหลดครบ 100%
local function ExecuteMainScript()
    -- ใส่โค้ดสคริปต์หลักของคุณ "ดูดไอดีเพลง By.Honkuki" ตรงนี้
    print("Executing: ดูดไอดีเพลง By.Honkuki")
    
    -- ตัวอย่างแจ้งเตือน
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Honkuki Loader",
        Text = "โหลดสคริปต์เรียบร้อยแล้ว!",
        Duration = 5
    })
end

-- สร้าง ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HonkukiLoaderUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Frame (หน้าต่างหลัก)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 320)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

-- Header Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 0, 40)
TitleLabel.Position = UDim2.new(0, 20, 0, 10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "HONKUKI LOADER"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- Close Button (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 10)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Sidebar Container
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -60)
Sidebar.Position = UDim2.new(0, 15, 0, 50)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local TabGame = Instance.new("TextButton")
TabGame.Size = UDim2.new(1, 0, 0, 35)
TabGame.Position = UDim2.new(0, 0, 0, 0)
TabGame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabGame.Text = "  GAME"
TabGame.TextColor3 = Color3.fromRGB(255, 255, 255)
TabGame.Font = Enum.Font.GothamMedium
TabGame.TextSize = 12
TabGame.TextXAlignment = Enum.TextXAlignment.Left
TabGame.Parent = Sidebar

local TabGameCorner = Instance.new("UICorner")
TabGameCorner.CornerRadius = UDim.new(0, 6)
TabGameCorner.Parent = TabGame

local TabInfo = Instance.new("TextButton")
TabInfo.Size = UDim2.new(1, 0, 0, 35)
TabInfo.Position = UDim2.new(0, 0, 0, 42)
TabInfo.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
TabInfo.Text = "  ABOUT / STATUS"
TabInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
TabInfo.Font = Enum.Font.GothamMedium
TabInfo.TextSize = 12
TabInfo.TextXAlignment = Enum.TextXAlignment.Left
TabInfo.Parent = Sidebar

local TabInfoCorner = Instance.new("UICorner")
TabInfoCorner.CornerRadius = UDim.new(0, 6)
TabInfoCorner.Parent = TabInfo

-- Content Container
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -170, 1, -60)
ContentFrame.Position = UDim2.new(0, 155, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Page 1: Game Scripts (หมวดรันสคริปต์)
local PageGame = Instance.new("Frame")
PageGame.Size = UDim2.new(1, 0, 1, 0)
PageGame.BackgroundTransparency = 1
PageGame.Visible = true
PageGame.Parent = ContentFrame

local ScriptCard = Instance.new("Frame")
ScriptCard.Size = UDim2.new(1, 0, 0, 60)
ScriptCard.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
ScriptCard.BorderSizePixel = 0
ScriptCard.Parent = PageGame

local ScriptCardCorner = Instance.new("UICorner")
ScriptCardCorner.CornerRadius = UDim.new(0, 8)
ScriptCardCorner.Parent = ScriptCard

local ScriptTitle = Instance.new("TextLabel")
ScriptTitle.Size = UDim2.new(1, -110, 0, 25)
ScriptTitle.Position = UDim2.new(0, 12, 0, 8)
ScriptTitle.BackgroundTransparency = 1
ScriptTitle.Text = "ดูดไอดีเพลง By.Honkuki"
ScriptTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ScriptTitle.Font = Enum.Font.GothamBold
ScriptTitle.TextSize = 13
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left
ScriptTitle.Parent = ScriptCard

local ScriptSub = Instance.new("TextLabel")
ScriptSub.Size = UDim2.new(1, -110, 0, 18)
ScriptSub.Position = UDim2.new(0, 12, 0, 32)
ScriptSub.BackgroundTransparency = 1
ScriptSub.Text = "Audio Logger System"
ScriptSub.TextColor3 = Color3.fromRGB(120, 120, 120)
ScriptSub.Font = Enum.Font.Gotham
ScriptSub.TextSize = 11
ScriptSub.TextXAlignment = Enum.TextXAlignment.Left
ScriptSub.Parent = ScriptCard

local RunBtn = Instance.new("TextButton")
RunBtn.Size = UDim2.new(0, 90, 0, 32)
RunBtn.Position = UDim2.new(1, -100, 0.5, -16)
RunBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
RunBtn.Text = "EXECUTE"
RunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RunBtn.Font = Enum.Font.GothamBold
RunBtn.TextSize = 11
RunBtn.Parent = ScriptCard

local RunBtnCorner = Instance.new("UICorner")
RunBtnCorner.CornerRadius = UDim.new(0, 6)
RunBtnCorner.Parent = RunBtn

-- Page 2: About / Map Status (หมวดเช็คแมพ)
local PageInfo = Instance.new("Frame")
PageInfo.Size = UDim2.new(1, 0, 1, 0)
PageInfo.BackgroundTransparency = 1
PageInfo.Visible = false
PageInfo.Parent = ContentFrame

local StatusCard = Instance.new("Frame")
StatusCard.Size = UDim2.new(1, 0, 0, 80)
StatusCard.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
StatusCard.Parent = PageInfo

local StatusCardCorner = Instance.new("UICorner")
StatusCardCorner.CornerRadius = UDim.new(0, 8)
StatusCardCorner.Parent = StatusCard

local MapLabel = Instance.new("TextLabel")
MapLabel.Size = UDim2.new(1, -20, 0, 25)
MapLabel.Position = UDim2.new(0, 15, 0, 15)
MapLabel.BackgroundTransparency = 1
MapLabel.Text = "Current Map: " .. CurrentGameName
MapLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MapLabel.Font = Enum.Font.GothamBold
MapLabel.TextSize = 13
MapLabel.TextXAlignment = Enum.TextXAlignment.Left
MapLabel.Parent = StatusCard

local PlaceIdLabel = Instance.new("TextLabel")
PlaceIdLabel.Size = UDim2.new(1, -20, 0, 20)
PlaceIdLabel.Position = UDim2.new(0, 15, 0, 42)
PlaceIdLabel.BackgroundTransparency = 1
PlaceIdLabel.Text = "Place ID: " .. tostring(PlaceId) .. " (Supported)"
PlaceIdLabel.TextColor3 = Color3.fromRGB(100, 225, 120)
PlaceIdLabel.Font = Enum.Font.Gotham
PlaceIdLabel.TextSize = 11
PlaceIdLabel.TextXAlignment = Enum.TextXAlignment.Left
PlaceIdLabel.Parent = StatusCard

-- Tab Switching Logic
TabGame.MouseButton1Click:Connect(function()
    PageGame.Visible = true
    PageInfo.Visible = false
    TabGame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TabGame.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabInfo.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    TabInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

TabInfo.MouseButton1Click:Connect(function()
    PageGame.Visible = false
    PageInfo.Visible = true
    TabInfo.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TabInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabGame.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    TabGame.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

-- Loading Screen Overlay (หน้าต่างดาวน์โหลดคลื่น 1-100%)
local LoadingOverlay = Instance.new("Frame")
LoadingOverlay.Size = UDim2.new(1, 0, 1, 0)
LoadingOverlay.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
LoadingOverlay.BackgroundTransparency = 0.05
LoadingOverlay.Visible = false
LoadingOverlay.ZIndex = 10
LoadingOverlay.Parent = MainFrame

local OverlayCorner = Instance.new("UICorner")
OverlayCorner.CornerRadius = UDim.new(0, 10)
OverlayCorner.Parent = LoadingOverlay

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0, 30)
LoadingText.Position = UDim2.new(0, 0, 0.35, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "LOADING SCRIPT... 0%"
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 14
LoadingText.ZIndex = 11
LoadingText.Parent = LoadingOverlay

-- Background Loading Bar Track
BarTrack = Instance.new("Frame")
BarTrack.Size = UDim2.new(0.7, 0, 0, 8)
BarTrack.Position = UDim2.new(0.15, 0, 0.5, 0)
BarTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
BarTrack.BorderSizePixel = 0
BarTrack.ZIndex = 11
BarTrack.Parent = LoadingOverlay

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(0, 4)
TrackCorner.Parent = BarTrack

-- Active Loading Bar Fill
local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 12
BarFill.Parent = BarTrack

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 4)
FillCorner.Parent = BarFill

-- Glow/Wave Effect Line
local WaveGlow = Instance.new("Frame")
WaveGlow.Size = UDim2.new(0, 30, 1, 0)
WaveGlow.Position = UDim2.new(1, -15, 0, 0)
WaveGlow.BackgroundColor3 = Color3.fromRGB(180, 220, 255)
WaveGlow.BackgroundTransparency = 0.3
WaveGlow.BorderSizePixel = 0
WaveGlow.ZIndex = 13
WaveGlow.Parent = BarFill

local WaveCorner = Instance.new("UICorner")
WaveCorner.CornerRadius = UDim.new(0, 4)
WaveCorner.Parent = WaveGlow

-- Run Button Execution Event
RunBtn.MouseButton1Click:Connect(function()
    LoadingOverlay.Visible = true
    
    -- แอนิเมชันคลื่นแสงวิ่งไปมาบนหลอด Progress
    task.spawn(function()
        while LoadingOverlay.Visible do
            local Tween1 = TweenService:Create(WaveGlow, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.8})
            Tween1:Play()
            Tween1.Completed:Wait()
            local Tween2 = TweenService:Create(WaveGlow, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.2})
            Tween2:Play()
            Tween2.Completed:Wait()
        end
    end)

    -- คำนวณความก้าวหน้า 1-100%
    for i = 1, 100 do
        BarFill.Size = UDim2.new(i / 100, 0, 1, 0)
        LoadingText.Text = "LOADING SCRIPT... " .. i .. "%"
        task.wait(0.02) -- ปรับความเร็วการโหลดตรงนี้
    end
    
    task.wait(0.2)
    LoadingOverlay.Visible = false
    ExecuteMainScript()
end)

-- ฟังก์ชันหลักที่จะรันเมื่อโหลดครบ 100%
local function ExecuteMainScript()
    print("Executing: ดูดไอดีเพลง By.Honkuki")
    
    -- ========================================================
    -- 🟢 วางโค้ด "ดูดไอดีเพลง By.Honkuki" ของคุณลงตรงนี้ได้เลย
    -- ========================================================

    loadstring(game:HttpGet("https://raw.githubusercontent.com/kfcth5171/90/refs/heads/main/006.lua"))()

    -- ========================================================

    -- ตัวอย่างแจ้งเตือน
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Honkuki Loader",
        Text = "โหลดสคริปต์เรียบร้อยแล้ว!",
        Duration = 5
    })
end
