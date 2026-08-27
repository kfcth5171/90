-- [[ STYLEKUKI ACTIVATE - ULTIMATE NEON 3D VIP EDITION ]] --
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local ProfileImageId = "93034804228650"
local PlaceId = game.PlaceId

local Success, GameInfo = pcall(function()
    return MarketplaceService:GetProductInfo(PlaceId)
end)
local CurrentGameName = Success and GameInfo.Name or "Unknown Map"

if CoreGui:FindFirstChild("StyleKukiVIPLoader") then
    CoreGui.StyleKukiVIPLoader:Destroy()
end

local function ExecuteMainScript()
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/kfcth5171/90/refs/heads/main/006.lua"))()
    end)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "StyleKuki VIP",
        Text = "⚡ Executed Audio Logger System Successfully!",
        Duration = 5
    })
end

-- Base ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StyleKukiVIPLoader"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- 1. Outer Neon Aura Layer (แสงนีออนฟุ้งชั้นนอกสุด)
local AuraGlow = Instance.new("Frame")
AuraGlow.Name = "AuraGlow"
AuraGlow.Size = UDim2.new(0, 584, 0, 374)
AuraGlow.Position = UDim2.new(0.5, -292, 0.5, -187)
AuraGlow.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
AuraGlow.BackgroundTransparency = 0.6
AuraGlow.BorderSizePixel = 0
AuraGlow.Parent = ScreenGui

local AuraCorner = Instance.new("UICorner")
AuraCorner.CornerRadius = UDim.new(0, 18)
AuraCorner.Parent = AuraGlow

-- 2. 3D Shadow Layer (ทำมิติเงาสมจริง)
local Shadow3D = Instance.new("Frame")
Shadow3D.Name = "Shadow3D"
Shadow3D.Size = UDim2.new(0, 570, 0, 360)
Shadow3D.Position = UDim2.new(0.5, -283, 0.5, -173)
Shadow3D.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow3D.BackgroundTransparency = 0.2
Shadow3D.BorderSizePixel = 0
Shadow3D.Parent = ScreenGui

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 16)
ShadowCorner.Parent = Shadow3D

-- 3. Outer LED Frame (ขอบไฟเคลื่อนไหว)
local LEDBorder = Instance.new("Frame")
LEDBorder.Name = "LEDBorder"
LEDBorder.Size = UDim2.new(0, 570, 0, 360)
LEDBorder.Position = UDim2.new(0.5, -285, 0.5, -180)
LEDBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LEDBorder.BorderSizePixel = 0
LEDBorder.Active = true
LEDBorder.Draggable = true
LEDBorder.Parent = ScreenGui

local LEDCorner = Instance.new("UICorner")
LEDCorner.CornerRadius = UDim.new(0, 16)
LEDCorner.Parent = LEDBorder

local LEDGradient = Instance.new("UIGradient")
LEDGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(138, 43, 226)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 0, 128)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 229, 255))
}
LEDGradient.Rotation = 0
LEDGradient.Parent = LEDBorder

-- 4. Main Window (พื้นหลังแบบ Glassmorphism)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, -6, 1, -6)
MainFrame.Position = UDim2.new(0, 3, 0, 3)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = LEDBorder

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 14)
MainUICorner.Parent = MainFrame

-- Background Canvas (สำหรับเอฟเฟกต์อนุภาค)
local ParticleCanvas = Instance.new("Frame")
ParticleCanvas.Size = UDim2.new(1, 0, 1, 0)
ParticleCanvas.BackgroundTransparency = 1
ParticleCanvas.Parent = MainFrame

-- 🌌 ระบบละอองดาวเรืองแสง (Star Particles Engine)
for i = 1, 20 do
    local Star = Instance.new("Frame")
    Star.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
    Star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    Star.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
    Star.BorderSizePixel = 0
    Star.BackgroundTransparency = math.random(3, 7) / 10
    Star.Parent = ParticleCanvas
    
    local StarCorner = Instance.new("UICorner")
    StarCorner.CornerRadius = UDim.new(1, 0)
    StarCorner.Parent = Star
    
    task.spawn(function()
        while Star and Star.Parent do
            local Speed = math.random(15, 30) / 10
            local TargetY = Star.Position.Y.Scale - 0.2
            if TargetY < -0.1 then TargetY = 1.1 end
            local Tween = TweenService:Create(Star, TweenInfo.new(Speed, Enum.EasingStyle.Linear), {
                Position = UDim2.new(Star.Position.X.Scale, 0, TargetY, 0),
                BackgroundTransparency = math.random(2, 8) / 10
            })
            Tween:Play()
            Tween.Completed:Wait()
        end
    end)
end

-- ลูปแอนิเมชัน Neon Rainbow และ Aura Pulse
RunService.RenderStepped:Connect(function()
    LEDGradient.Rotation = (LEDGradient.Rotation + 1.5) % 360
    local PulseVal = (math.sin(tick() * 3) + 1) / 2
    AuraGlow.BackgroundTransparency = 0.5 + (PulseVal * 0.2)
end)

-- 🖼️ รูปภาพโปรไฟล์ (พร้อมกรอบเรืองแสง 3D)
local IconHolder = Instance.new("Frame")
IconHolder.Size = UDim2.new(0, 42, 0, 42)
IconHolder.Position = UDim2.new(0, 14, 0, 12)
IconHolder.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
IconHolder.BorderSizePixel = 0
IconHolder.Parent = MainFrame

local IconHolderCorner = Instance.new("UICorner")
IconHolderCorner.CornerRadius = UDim.new(0, 10)
IconHolderCorner.Parent = IconHolder

local IconImage = Instance.new("ImageLabel")
IconImage.Size = UDim2.new(1, -4, 1, -4)
IconImage.Position = UDim2.new(0, 2, 0, 2)
IconImage.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
IconImage.BorderSizePixel = 0
IconImage.Image = "rbxassetid://"930348042286 ProfileImageId
IconImage.ScaleType = Enum.ScaleType.Crop
IconImage.Parent = IconHolder

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 8)
IconCorner.Parent = IconImage

-- Title Header: StyleKuki Activate (Neon Gradient Glow)
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 0, 42)
TitleLabel.Position = UDim2.new(0, 64, 0, 12)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "StyleKuki Activate"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 200))
}
TitleGradient.Parent = TitleLabel

-- 📍 ชื่อแมพตรงกลางบนสุด (3D Glass Pill Banner)
local TopMapBanner = Instance.new("Frame")
TopMapBanner.Size = UDim2.new(0, 210, 0, 32)
TopMapBanner.Position = UDim2.new(0.5, -105, 0, 17)
TopMapBanner.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
TopMapBanner.BorderSizePixel = 0
TopMapBanner.Parent = MainFrame

local MapBannerCorner = Instance.new("UICorner")
MapBannerCorner.CornerRadius = UDim.new(0, 8)
MapBannerCorner.Parent = TopMapBanner

local BannerStroke = Instance.new("UIStroke")
BannerStroke.Color = Color3.fromRGB(0, 229, 255)
BannerStroke.Thickness = 1
BannerStroke.Transparency = 0.6
BannerStroke.Parent = TopMapBanner

local TopMapText = Instance.new("TextLabel")
TopMapText.Size = UDim2.new(1, -12, 1, 0)
TopMapText.Position = UDim2.new(0, 6, 0, 0)
TopMapText.BackgroundTransparency = 1
TopMapText.Text = "📍 " .. CurrentGameName
TopMapText.TextColor3 = Color3.fromRGB(240, 240, 255)
TopMapText.TextSize = 11
TopMapText.Font = Enum.Font.GothamMedium
TopMapText.TextTruncate = Enum.TextTruncate.AtEnd
TopMapText.Parent = TopMapBanner

-- Close Button (✕ 3D Glowing)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -44, 0, 14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = Color3.fromRGB(255, 0, 100)
CloseStroke.Thickness = 1.5
CloseStroke.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Sidebar Container
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 145, 1, -80)
Sidebar.Position = UDim2.new(0, 14, 0, 68)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local TabGame = Instance.new("TextButton")
TabGame.Size = UDim2.new(1, 0, 0, 42)
TabGame.Position = UDim2.new(0, 0, 0, 0)
TabGame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
TabGame.Text = "   🎮   GAMES"
TabGame.TextColor3 = Color3.fromRGB(0, 229, 255)
TabGame.Font = Enum.Font.GothamBold
TabGame.TextSize = 12
TabGame.TextXAlignment = Enum.TextXAlignment.Left
TabGame.Parent = Sidebar

local TabGameCorner = Instance.new("UICorner")
TabGameCorner.CornerRadius = UDim.new(0, 10)
TabGameCorner.Parent = TabGame

local TabGameStroke = Instance.new("UIStroke")
TabGameStroke.Color = Color3.fromRGB(0, 229, 255)
TabGameStroke.Thickness = 1
TabGameStroke.Parent = TabGame

local TabInfo = Instance.new("TextButton")
TabInfo.Size = UDim2.new(1, 0, 0, 42)
TabInfo.Position = UDim2.new(0, 0, 0, 52)
TabInfo.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
TabInfo.Text = "   📊   STATUS"
TabInfo.TextColor3 = Color3.fromRGB(120, 125, 140)
TabInfo.Font = Enum.Font.GothamBold
TabInfo.TextSize = 12
TabInfo.TextXAlignment = Enum.TextXAlignment.Left
TabInfo.Parent = Sidebar

local TabInfoCorner = Instance.new("UICorner")
TabInfoCorner.CornerRadius = UDim.new(0, 10)
TabInfoCorner.Parent = TabInfo

local TabInfoStroke = Instance.new("UIStroke")
TabInfoStroke.Color = Color3.fromRGB(40, 45, 60)
TabInfoStroke.Thickness = 1
TabInfoStroke.Parent = TabInfo

-- Content Container
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -185, 1, -80)
ContentFrame.Position = UDim2.new(0, 170, 0, 68)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Page 1: Game Scripts
local PageGame = Instance.new("Frame")
PageGame.Size = UDim2.new(1, 0, 1, 0)
PageGame.BackgroundTransparency = 1
PageGame.Visible = true
PageGame.Parent = ContentFrame

local ScriptCard = Instance.new("Frame")
ScriptCard.Size = UDim2.new(1, 0, 0, 75)
ScriptCard.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
ScriptCard.BorderSizePixel = 0
ScriptCard.Parent = PageGame

local ScriptCardCorner = Instance.new("UICorner")
ScriptCardCorner.CornerRadius = UDim.new(0, 12)
ScriptCardCorner.Parent = ScriptCard

local ScriptCardStroke = Instance.new("UIStroke")
ScriptCardStroke.Color = Color3.fromRGB(35, 40, 55)
ScriptCardStroke.Thickness = 1
ScriptCardStroke.Parent = ScriptCard

local ScriptTitle = Instance.new("TextLabel")
ScriptTitle.Size = UDim2.new(1, -130, 0, 25)
ScriptTitle.Position = UDim2.new(0, 16, 0, 14)
ScriptTitle.BackgroundTransparency = 1
ScriptTitle.Text = "ดูดไอดีเพลง By.Honkuki"
ScriptTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ScriptTitle.Font = Enum.Font.GothamBold
ScriptTitle.TextSize = 13
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left
ScriptTitle.Parent = ScriptCard

local ScriptSub = Instance.new("TextLabel")
ScriptSub.Size = UDim2.new(1, -130, 0, 18)
ScriptSub.Position = UDim2.new(0, 16, 0, 39)
ScriptSub.BackgroundTransparency = 1
ScriptSub.Text = "Audio Logger System (Universal)"
ScriptSub.TextColor3 = Color3.fromRGB(0, 229, 255)
ScriptSub.Font = Enum.Font.Gotham
ScriptSub.TextSize = 11
ScriptSub.TextXAlignment = Enum.TextXAlignment.Left
ScriptSub.Parent = ScriptCard

-- 🚀 ปุ่ม EXECUTE แบบ 3D Glow Button
local RunBtn = Instance.new("TextButton")
RunBtn.Size = UDim2.new(0, 100, 0, 38)
RunBtn.Position = UDim2.new(1, -114, 0.5, -19)
RunBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
RunBtn.Text = "EXECUTE"
RunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RunBtn.Font = Enum.Font.GothamBold
RunBtn.TextSize = 11
RunBtn.Parent = ScriptCard

local RunBtnCorner = Instance.new("UICorner")
RunBtnCorner.CornerRadius = UDim.new(0, 10)
RunBtnCorner.Parent = RunBtn

local RunBtnGradient = Instance.new("UIGradient")
RunBtnGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 120, 255))
}
RunBtnGradient.Parent = RunBtn

local RunBtnStroke = Instance.new("UIStroke")
RunBtnStroke.Color = Color3.fromRGB(150, 240, 255)
RunBtnStroke.Thickness = 1.5
RunBtnStroke.Parent = RunBtn

-- Page 2: Map Status
local PageInfo = Instance.new("Frame")
PageInfo.Size = UDim2.new(1, 0, 1, 0)
PageInfo.BackgroundTransparency = 1
PageInfo.Visible = false
PageInfo.Parent = ContentFrame

local StatusCard = Instance.new("Frame")
StatusCard.Size = UDim2.new(1, 0, 0, 90)
StatusCard.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
StatusCard.Parent = PageInfo

local StatusCardCorner = Instance.new("UICorner")
StatusCardCorner.CornerRadius = UDim.new(0, 12)
StatusCardCorner.Parent = StatusCard

local StatusCardStroke = Instance.new("UIStroke")
StatusCardStroke.Color = Color3.fromRGB(35, 40, 55)
StatusCardStroke.Thickness = 1
StatusCardStroke.Parent = StatusCard

local MapLabel = Instance.new("TextLabel")
MapLabel.Size = UDim2.new(1, -20, 0, 25)
MapLabel.Position = UDim2.new(0, 16, 0, 16)
MapLabel.BackgroundTransparency = 1
MapLabel.Text = "Current Game: " .. CurrentGameName
MapLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MapLabel.Font = Enum.Font.GothamBold
MapLabel.TextSize = 13
MapLabel.TextXAlignment = Enum.TextXAlignment.Left
MapLabel.Parent = StatusCard

local PlaceIdLabel = Instance.new("TextLabel")
PlaceIdLabel.Size = UDim2.new(1, -20, 0, 20)
PlaceIdLabel.Position = UDim2.new(0, 16, 0, 46)
PlaceIdLabel.BackgroundTransparency = 1
PlaceIdLabel.Text = "Place ID: " .. tostring(PlaceId) .. " (System Ready)"
PlaceIdLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
PlaceIdLabel.Font = Enum.Font.Gotham
PlaceIdLabel.TextSize = 11
PlaceIdLabel.TextXAlignment = Enum.TextXAlignment.Left
PlaceIdLabel.Parent = StatusCard

-- Tab Switching Logic (พร้อมปรับแต่งเส้น Glow)
TabGame.MouseButton1Click:Connect(function()
    PageGame.Visible = true
    PageInfo.Visible = false
    TabGame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    TabGame.TextColor3 = Color3.fromRGB(0, 229, 255)
    TabGameStroke.Color = Color3.fromRGB(0, 229, 255)
    
    TabInfo.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
    TabInfo.TextColor3 = Color3.fromRGB(120, 125, 140)
    TabInfoStroke.Color = Color3.fromRGB(40, 45, 60)
end)

TabInfo.MouseButton1Click:Connect(function()
    PageGame.Visible = false
    PageInfo.Visible = true
    TabInfo.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    TabInfo.TextColor3 = Color3.fromRGB(0, 229, 255)
    TabInfoStroke.Color = Color3.fromRGB(0, 229, 255)
    
    TabGame.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
    TabGame.TextColor3 = Color3.fromRGB(120, 125, 140)
    TabGameStroke.Color = Color3.fromRGB(40, 45, 60)
end)

-- Loading Screen Overlay (Cyberpunk High-Tech Bar)
local LoadingOverlay = Instance.new("Frame")
LoadingOverlay.Size = UDim2.new(1, 0, 1, 0)
LoadingOverlay.BackgroundColor3 = Color3.fromRGB(8, 9, 13)
LoadingOverlay.BackgroundTransparency = 0.03
LoadingOverlay.Visible = false
LoadingOverlay.ZIndex = 20
LoadingOverlay.Parent = MainFrame

local OverlayCorner = Instance.new("UICorner")
OverlayCorner.CornerRadius = UDim.new(0, 14)
OverlayCorner.Parent = LoadingOverlay

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0, 30)
LoadingText.Position = UDim2.new(0, 0, 0.38, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "INITIALIZING SYSTEM... 0%"
LoadingText.TextColor3 = Color3.fromRGB(0, 229, 255)
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 13
LoadingText.ZIndex = 21
LoadingText.Parent = LoadingOverlay

local BarTrack = Instance.new("Frame")
BarTrack.Size = UDim2.new(0.75, 0, 0, 10)
BarTrack.Position = UDim2.new(0.125, 0, 0.52, 0)
BarTrack.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
BarTrack.BorderSizePixel = 0
BarTrack.ZIndex = 21
BarTrack.Parent = LoadingOverlay

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(0, 5)
TrackCorner.Parent = BarTrack

local TrackStroke = Instance.new("UIStroke")
TrackStroke.Color = Color3.fromRGB(40, 45, 60)
TrackStroke.Thickness = 1
TrackStroke.Parent = BarTrack

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 22
BarFill.Parent = BarTrack

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 5)
FillCorner.Parent = BarFill

local BarFillGradient = Instance.new("UIGradient")
BarFillGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 200))
}
BarFillGradient.Parent = BarFill

-- Run Event
RunBtn.MouseButton1Click:Connect(function()
    LoadingOverlay.Visible = true
    
    for i = 1, 100 do
        BarFill.Size = UDim2.new(i / 100, 0, 1, 0)
        LoadingText.Text = "INITIALIZING SYSTEM... " .. i .. "%"
        task.wait(0.008)
    end
    
    task.wait(0.15)
    LoadingOverlay.Visible = false
    ExecuteMainScript()
end)
