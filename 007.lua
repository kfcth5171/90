-- [[ HONKUKI ULTIMATE LOADER V2 - RGB NEON EDITION ]] --
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- ดึงข้อมูลแมพปัจจุบัน
local Success, GameInfo = pcall(function()
    return MarketplaceService:GetProductInfo(PlaceId)
end)
local CurrentGameName = Success and GameInfo.Name or "Unknown Map"

-- ลบ UI เก่าออกหากมีอยู่แล้ว
if CoreGui:FindFirstChild("HonkukiLoaderV2") then
    CoreGui.HonkukiLoaderV2:Destroy()
end

-- ==========================================
-- 🟢 ฟังก์ชันรันสคริปต์หลัก (ติดตั้ง loadstring แล้ว)
-- ==========================================
local function ExecuteMainScript()
    task.spawn(function()
        local success, err = pcall(function()
            -- รันสคริปต์ดูดไอดีเพลง By.Honkuki
            loadstring(game:HttpGet("https://raw.githubusercontent.com/kfcth5171/90/refs/heads/main/006.lua"))()
        end)
        
        if not success then
            warn("[Honkuki Loader Error]: " .. tostring(err))
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Execution Error!",
                Text = "เกิดข้อผิดพลาดในการโหลดสคริปต์หลัก",
                Duration = 5
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Honkuki Loader",
                Text = "โหลดสคริปต์ดูดไอดีเพลงสำเร็จ!",
                Duration = 5
            })
        end
    end)
end

-- สร้าง ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HonkukiLoaderV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Outer LED Border Frame (กรอบขอบไฟ RGB)
local LEDBorder = Instance.new("Frame")
LEDBorder.Name = "LEDBorder"
LEDBorder.Size = UDim2.new(0, 544, 0, 334)
LEDBorder.Position = UDim2.new(0.5, -272, 0.5, -167)
LEDBorder.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
LEDBorder.BorderSizePixel = 0
LEDBorder.Active = true
LEDBorder.Draggable = true
LEDBorder.Parent = ScreenGui

local LEDCorner = Instance.new("UICorner")
LEDCorner.CornerRadius = UDim.new(0, 14)
LEDCorner.Parent = LEDBorder

-- UIGradient สำหรับทำไฟวิ่ง Rainbow LED
local LEDGradient = Instance.new("UIGradient")
LEDGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
}
LEDGradient.Rotation = 0
LEDGradient.Parent = LEDBorder

-- ระบบวนลูปหมุนองศาไฟ LED
RunService.RenderStepped:Connect(function()
    LEDGradient.Rotation = (LEDGradient.Rotation + 2) % 360
end)

-- Main Frame (หน้าต่างหลักด้านใน)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, -4, 1, -4)
MainFrame.Position = UDim2.new(0, 2, 0, 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = LEDBorder

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 12)
MainUICorner.Parent = MainFrame

-- Header Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 0, 45)
TitleLabel.Position = UDim2.new(0, 20, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "HONKUKI LOADER <font color=\"#00E5FF\">v2.0</font>"
TitleLabel.RichText = true
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- Close Button (✕)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Sidebar Container
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -65)
Sidebar.Position = UDim2.new(0, 15, 0, 55)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local TabGame = Instance.new("TextButton")
TabGame.Size = UDim2.new(1, 0, 0, 40)
TabGame.Position = UDim2.new(0, 0, 0, 0)
TabGame.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
TabGame.Text = "   🎮  GAMES"
TabGame.TextColor3 = Color3.fromRGB(0, 229, 255)
TabGame.Font = Enum.Font.GothamBold
TabGame.TextSize = 12
TabGame.TextXAlignment = Enum.TextXAlignment.Left
TabGame.Parent = Sidebar

local TabGameCorner = Instance.new("UICorner")
TabGameCorner.CornerRadius = UDim.new(0, 8)
TabGameCorner.Parent = TabGame

local TabInfo = Instance.new("TextButton")
TabInfo.Size = UDim2.new(1, 0, 0, 40)
TabInfo.Position = UDim2.new(0, 0, 0, 48)
TabInfo.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
TabInfo.Text = "   📊  STATUS"
TabInfo.TextColor3 = Color3.fromRGB(130, 135, 150)
TabInfo.Font = Enum.Font.GothamBold
TabInfo.TextSize = 12
TabInfo.TextXAlignment = Enum.TextXAlignment.Left
TabInfo.Parent = Sidebar

local TabInfoCorner = Instance.new("UICorner")
TabInfoCorner.CornerRadius = UDim.new(0, 8)
TabInfoCorner.Parent = TabInfo

-- Content Container
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -185, 1, -65)
ContentFrame.Position = UDim2.new(0, 170, 0, 55)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Page 1: Game Scripts
local PageGame = Instance.new("Frame")
PageGame.Size = UDim2.new(1, 0, 1, 0)
PageGame.BackgroundTransparency = 1
PageGame.Visible = true
PageGame.Parent = ContentFrame

local ScriptCard = Instance.new("Frame")
ScriptCard.Size = UDim2.new(1, 0, 0, 70)
ScriptCard.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
ScriptCard.BorderSizePixel = 0
ScriptCard.Parent = PageGame

local ScriptCardCorner = Instance.new("UICorner")
ScriptCardCorner.CornerRadius = UDim.new(0, 10)
ScriptCardCorner.Parent = ScriptCard

local ScriptTitle = Instance.new("TextLabel")
ScriptTitle.Size = UDim2.new(1, -120, 0, 25)
ScriptTitle.Position = UDim2.new(0, 15, 0, 12)
ScriptTitle.BackgroundTransparency = 1
ScriptTitle.Text = "ดูดไอดีเพลง By.Honkuki"
ScriptTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ScriptTitle.Font = Enum.Font.GothamBold
ScriptTitle.TextSize = 13
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left
ScriptTitle.Parent = ScriptCard

local ScriptSub = Instance.new("TextLabel")
ScriptSub.Size = UDim2.new(1, -120, 0, 18)
ScriptSub.Position = UDim2.new(0, 15, 0, 37)
ScriptSub.BackgroundTransparency = 1
ScriptSub.Text = "Audio Logger System (Universal)"
ScriptSub.TextColor3 = Color3.fromRGB(0, 229, 255)
ScriptSub.Font = Enum.Font.Gotham
ScriptSub.TextSize = 11
ScriptSub.TextXAlignment = Enum.TextXAlignment.Left
ScriptSub.Parent = ScriptCard

local RunBtn = Instance.new("TextButton")
RunBtn.Size = UDim2.new(0, 95, 0, 36)
RunBtn.Position = UDim2.new(1, -110, 0.5, -18)
RunBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
RunBtn.Text = "EXECUTE"
RunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RunBtn.Font = Enum.Font.GothamBold
RunBtn.TextSize = 11
RunBtn.Parent = ScriptCard

local RunBtnCorner = Instance.new("UICorner")
RunBtnCorner.CornerRadius = UDim.new(0, 8)
RunBtnCorner.Parent = RunBtn

-- Page 2: Map Status
local PageInfo = Instance.new("Frame")
PageInfo.Size = UDim2.new(1, 0, 1, 0)
PageInfo.BackgroundTransparency = 1
PageInfo.Visible = false
PageInfo.Parent = ContentFrame

local StatusCard = Instance.new("Frame")
StatusCard.Size = UDim2.new(1, 0, 0, 85)
StatusCard.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
StatusCard.Parent = PageInfo

local StatusCardCorner = Instance.new("UICorner")
StatusCardCorner.CornerRadius = UDim.new(0, 10)
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
PlaceIdLabel.Position = UDim2.new(0, 15, 0, 45)
PlaceIdLabel.BackgroundTransparency = 1
PlaceIdLabel.Text = "Place ID: " .. tostring(PlaceId) .. " (Ready)"
PlaceIdLabel.TextColor3 = Color3.fromRGB(80, 250, 120)
PlaceIdLabel.Font = Enum.Font.Gotham
PlaceIdLabel.TextSize = 11
PlaceIdLabel.TextXAlignment = Enum.TextXAlignment.Left
PlaceIdLabel.Parent = StatusCard

-- Tab Switching Logic
TabGame.MouseButton1Click:Connect(function()
    PageGame.Visible = true
    PageInfo.Visible = false
    TabGame.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
    TabGame.TextColor3 = Color3.fromRGB(0, 229, 255)
    TabInfo.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    TabInfo.TextColor3 = Color3.fromRGB(130, 135, 150)
end)

TabInfo.MouseButton1Click:Connect(function()
    PageGame.Visible = false
    PageInfo.Visible = true
    TabInfo.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
    TabInfo.TextColor3 = Color3.fromRGB(0, 229, 255)
    TabGame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    TabGame.TextColor3 = Color3.fromRGB(130, 135, 150)
end)

-- Loading Screen Overlay
local LoadingOverlay = Instance.new("Frame")
LoadingOverlay.Size = UDim2.new(1, 0, 1, 0)
LoadingOverlay.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
LoadingOverlay.BackgroundTransparency = 0.05
LoadingOverlay.Visible = false
LoadingOverlay.ZIndex = 10
LoadingOverlay.Parent = MainFrame

local OverlayCorner = Instance.new("UICorner")
OverlayCorner.CornerRadius = UDim.new(0, 12)
OverlayCorner.Parent = LoadingOverlay

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0, 30)
LoadingText.Position = UDim2.new(0, 0, 0.35, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "LOADING SYSTEM... 0%"
LoadingText.TextColor3 = Color3.fromRGB(0, 229, 255)
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 14
LoadingText.ZIndex = 11
LoadingText.Parent = LoadingOverlay

local BarTrack = Instance.new("Frame")
BarTrack.Size = UDim2.new(0.75, 0, 0, 8)
BarTrack.Position = UDim2.new(0.125, 0, 0.52, 0)
BarTrack.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
BarTrack.BorderSizePixel = 0
BarTrack.ZIndex = 11
BarTrack.Parent = LoadingOverlay

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(0, 4)
TrackCorner.Parent = BarTrack

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 12
BarFill.Parent = BarTrack

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 4)
FillCorner.Parent = BarFill

local WaveGlow = Instance.new("Frame")
WaveGlow.Size = UDim2.new(0, 40, 1, 0)
WaveGlow.Position = UDim2.new(1, -20, 0, 0)
WaveGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WaveGlow.BackgroundTransparency = 0.2
WaveGlow.BorderSizePixel = 0
WaveGlow.ZIndex = 13
WaveGlow.Parent = BarFill

local WaveCorner = Instance.new("UICorner")
WaveCorner.CornerRadius = UDim.new(0, 4)
WaveCorner.Parent = WaveGlow

-- Run Button Click Event
RunBtn.MouseButton1Click:Connect(function()
    LoadingOverlay.Visible = true
    
    task.spawn(function()
        while LoadingOverlay.Visible do
            local Tween1 = TweenService:Create(WaveGlow, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.7})
            Tween1:Play()
            Tween1.Completed:Wait()
            local Tween2 = TweenService:Create(WaveGlow, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.1})
            Tween2:Play()
            Tween2.Completed:Wait()
        end
    end)

    for i = 1, 100 do
        BarFill.Size = UDim2.new(i / 100, 0, 1, 0)
        LoadingText.Text = "LOADING SYSTEM... " .. i .. "%"
        task.wait(0.015)
    end
    
    task.wait(0.1)
    LoadingOverlay.Visible = false
    ExecuteMainScript()
end)
