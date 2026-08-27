-- =====================================================================
-- [[ STYLEKUKI VIP LOADER & KEY SYSTEM - CYBERPUNK 3D EDITION ]] --
-- =====================================================================

local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local ProfileImageId = "130797657143524" -- Asset ID โลโก้ตามที่ระบุ
local PlaceId = game.PlaceId
local CORRECT_KEY = "Honeiei56" -- คีย์สำหรับปลดล็อกระบบ

local Success, GameInfo = pcall(function()
    return MarketplaceService:GetProductInfo(PlaceId)
end)
local CurrentGameName = Success and GameInfo.Name or "Unknown Map"

local GuiParent = CoreGui:FindFirstChild("RobloxGui") or Players.LocalPlayer:WaitForChild("PlayerGui")
if GuiParent:FindFirstChild("StyleKukiVIPLoader") then
    GuiParent.StyleKukiVIPLoader:Destroy()
end

-- ฟังก์ชันรันสคริปต์หลักต่างๆ
local function RunScript(scriptUrl, scriptName)
    task.spawn(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "StyleKuki VIP",
        Text = "⚡ Executed " .. scriptName .. " Successfully!",
        Duration = 5
    })
end

-- ScreenGui Main Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StyleKukiVIPLoader"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GuiParent

-- 📦 MainContainer
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 570, 0, 360)
MainContainer.Position = UDim2.new(0.5, -285, 0.5, -180)
MainContainer.BackgroundTransparency = 1
MainContainer.Parent = ScreenGui

-- 1. Outer Neon Aura Layer
local AuraGlow = Instance.new("Frame", MainContainer)
AuraGlow.Name = "AuraGlow"
AuraGlow.Size = UDim2.new(1, 14, 1, 14)
AuraGlow.Position = UDim2.new(0, -7, 0, -7)
AuraGlow.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
AuraGlow.BackgroundTransparency = 0.6
AuraGlow.BorderSizePixel = 0
Instance.new("UICorner", AuraGlow).CornerRadius = UDim.new(0, 18)

-- 2. 3D Shadow Layer
local Shadow3D = Instance.new("Frame", MainContainer)
Shadow3D.Name = "Shadow3D"
Shadow3D.Size = UDim2.new(1, 0, 1, 0)
Shadow3D.Position = UDim2.new(0, 4, 0, 8)
Shadow3D.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow3D.BackgroundTransparency = 0.3
Shadow3D.BorderSizePixel = 0
Instance.new("UICorner", Shadow3D).CornerRadius = UDim.new(0, 16)

-- 3. Outer LED Frame
local LEDBorder = Instance.new("Frame", MainContainer)
LEDBorder.Name = "LEDBorder"
LEDBorder.Size = UDim2.new(1, 0, 1, 0)
LEDBorder.Position = UDim2.new(0, 0, 0, 0)
LEDBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LEDBorder.BorderSizePixel = 0
LEDBorder.Active = true
Instance.new("UICorner", LEDBorder).CornerRadius = UDim.new(0, 16)

local LEDGradient = Instance.new("UIGradient", LEDBorder)
LEDGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(138, 43, 226)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 0, 128)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 229, 255))
}

-- 4. Main Window
local MainFrame = Instance.new("Frame", LEDBorder)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, -6, 1, -6)
MainFrame.Position = UDim2.new(0, 3, 0, 3)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

-- Dynamic Star Particle System
local ParticleCanvas = Instance.new("Frame", MainFrame)
ParticleCanvas.Size = UDim2.new(1, 0, 1, 0)
ParticleCanvas.BackgroundTransparency = 1

for i = 1, 20 do
    local Star = Instance.new("Frame", ParticleCanvas)
    Star.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
    Star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    Star.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
    Star.BorderSizePixel = 0
    Star.BackgroundTransparency = math.random(3, 7) / 10
    Instance.new("UICorner", Star).CornerRadius = UDim.new(1, 0)
    
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

-- ----------------------------------------------------
-- 🔘 TOGGLE OPEN/CLOSE BUTTON SYSTEM (มีไฟ LED วิ่ง + โลโก้)
-- ----------------------------------------------------
local ToggleBtnContainer = Instance.new("Frame", ScreenGui)
ToggleBtnContainer.Name = "ToggleBtnContainer"
ToggleBtnContainer.Size = UDim2.new(0, 50, 0, 50)
ToggleBtnContainer.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleBtnContainer.BackgroundTransparency = 1
ToggleBtnContainer.Visible = true

local ToggleLED = Instance.new("Frame", ToggleBtnContainer)
ToggleLED.Size = UDim2.new(1, 0, 1, 0)
ToggleLED.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleLED.BorderSizePixel = 0
Instance.new("UICorner", ToggleLED).CornerRadius = UDim.new(1, 0)

local ToggleLEDGradient = Instance.new("UIGradient", ToggleLED)
ToggleLEDGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 128)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 229, 255))
}

local ToggleBtn = Instance.new("ImageButton", ToggleLED)
ToggleBtn.Size = UDim2.new(1, -4, 1, -4)
ToggleBtn.Position = UDim2.new(0, 2, 0, 2)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Image = "rbxassetid://" .. ProfileImageId
ToggleBtn.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

-- RenderStepped Animation for UI and Toggle LED
RunService.RenderStepped:Connect(function()
    LEDGradient.Rotation = (LEDGradient.Rotation + 1.5) % 360
    ToggleLEDGradient.Rotation = (ToggleLEDGradient.Rotation + 2) % 360
    local PulseVal = (math.sin(tick() * 3) + 1) / 2
    AuraGlow.BackgroundTransparency = 0.5 + (PulseVal * 0.2)
end)

-- Dragging System for Toggle Button
local toggleDragging, toggleDragStart, toggleStartPos
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDragging = true
        toggleDragStart = input.Position
        toggleStartPos = ToggleBtnContainer.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - toggleDragStart
        ToggleBtnContainer.Position = UDim2.new(toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X, toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDragging = false
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = not MainContainer.Visible
end)

-- Smooth Dragging System for Main Container
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainContainer.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Header Bar Component
local IconHolder = Instance.new("Frame", MainFrame)
IconHolder.Size = UDim2.new(0, 42, 0, 42)
IconHolder.Position = UDim2.new(0, 14, 0, 12)
IconHolder.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
IconHolder.BorderSizePixel = 0
Instance.new("UICorner", IconHolder).CornerRadius = UDim.new(0, 10)

local IconImage = Instance.new("ImageLabel", IconHolder)
IconImage.Size = UDim2.new(1, -4, 1, -4)
IconImage.Position = UDim2.new(0, 2, 0, 2)
IconImage.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
IconImage.BorderSizePixel = 0
IconImage.Image = "rbxassetid://" .. ProfileImageId
IconImage.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", IconImage).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.Size = UDim2.new(0, 200, 0, 42)
TitleLabel.Position = UDim2.new(0, 64, 0, 12)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "StyleKuki Activate"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local TitleGradient = Instance.new("UIGradient", TitleLabel)
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 200))
}

local TopMapBanner = Instance.new("Frame", MainFrame)
TopMapBanner.Size = UDim2.new(0, 210, 0, 32)
TopMapBanner.Position = UDim2.new(0.5, -105, 0, 17)
TopMapBanner.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
TopMapBanner.BorderSizePixel = 0
Instance.new("UICorner", TopMapBanner).CornerRadius = UDim.new(0, 8)

local BannerStroke = Instance.new("UIStroke", TopMapBanner)
BannerStroke.Color = Color3.fromRGB(0, 229, 255)
BannerStroke.Thickness = 1
BannerStroke.Transparency = 0.6

local TopMapText = Instance.new("TextLabel", TopMapBanner)
TopMapText.Size = UDim2.new(1, -12, 1, 0)
TopMapText.Position = UDim2.new(0, 6, 0, 0)
TopMapText.BackgroundTransparency = 1
TopMapText.Text = "📍 " .. CurrentGameName
TopMapText.TextColor3 = Color3.fromRGB(240, 240, 255)
TopMapText.TextSize = 11
TopMapText.Font = Enum.Font.GothamMedium
TopMapText.TextTruncate = Enum.TextTruncate.AtEnd

-- ปุ่มย่อ/ปิด GUI
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -44, 0, 14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local CloseStroke = Instance.new("UIStroke", CloseBtn)
CloseStroke.Color = Color3.fromRGB(255, 0, 100)
CloseStroke.Thickness = 1.5
CloseBtn.MouseButton1Click:Connect(function() MainContainer.Visible = false end)

-- Navigation Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 145, 1, -80)
Sidebar.Position = UDim2.new(0, 14, 0, 68)
Sidebar.BackgroundTransparency = 1

local TabGame = Instance.new("TextButton", Sidebar)
TabGame.Size = UDim2.new(1, 0, 0, 42)
TabGame.Position = UDim2.new(0, 0, 0, 0)
TabGame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
TabGame.Text = "   🎮   GAMES"
TabGame.TextColor3 = Color3.fromRGB(0, 229, 255)
TabGame.Font = Enum.Font.GothamBold
TabGame.TextSize = 12
TabGame.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", TabGame).CornerRadius = UDim.new(0, 10)

local TabGameStroke = Instance.new("UIStroke", TabGame)
TabGameStroke.Color = Color3.fromRGB(0, 229, 255)
TabGameStroke.Thickness = 1

local TabInfo = Instance.new("TextButton", Sidebar)
TabInfo.Size = UDim2.new(1, 0, 0, 42)
TabInfo.Position = UDim2.new(0, 0, 0, 52)
TabInfo.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
TabInfo.Text = "   📊   STATUS"
TabInfo.TextColor3 = Color3.fromRGB(120, 125, 140)
TabInfo.Font = Enum.Font.GothamBold
TabInfo.TextSize = 12
TabInfo.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", TabInfo).CornerRadius = UDim.new(0, 10)

local TabInfoStroke = Instance.new("UIStroke", TabInfo)
TabInfoStroke.Color = Color3.fromRGB(40, 45, 60)
TabInfoStroke.Thickness = 1

-- Main Content Frame
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -185, 1, -80)
ContentFrame.Position = UDim2.new(0, 170, 0, 68)
ContentFrame.BackgroundTransparency = 1

-- Tab 1: Games Page (ScrollingFrame)
local PageGame = Instance.new("ScrollingFrame", ContentFrame)
PageGame.Size = UDim2.new(1, 0, 1, 0)
PageGame.BackgroundTransparency = 1
PageGame.ScrollBarThickness = 4
PageGame.ScrollBarImageColor3 = Color3.fromRGB(0, 229, 255)
PageGame.BorderSizePixel = 0
PageGame.Visible = true

local PageListLayout = Instance.new("UIListLayout", PageGame)
PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PageListLayout.Padding = UDim.new(0, 10)

PageListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PageGame.CanvasSize = UDim2.new(0, 0, 0, PageListLayout.AbsoluteContentSize.Y + 10)
end)

-- ฟังก์ชันสำหรับสร้างการ์ดสคริปต์ให้อ่านง่าย
local function CreateScriptCard(title, subtitle, scriptUrl, isSpecialGradient)
    local Card = Instance.new("Frame", PageGame)
    Card.Size = UDim2.new(1, -10, 0, 75)
    Card.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    Card.BorderSizePixel = 0
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Color = Color3.fromRGB(35, 40, 55)
    Stroke.Thickness = 1

    local Title = Instance.new("TextLabel", Card)
    Title.Size = UDim2.new(1, -130, 0, 25)
    Title.Position = UDim2.new(0, 16, 0, 14)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Sub = Instance.new("TextLabel", Card)
    Sub.Size = UDim2.new(1, -130, 0, 18)
    Sub.Position = UDim2.new(0, 16, 0, 39)
    Sub.BackgroundTransparency = 1
    Sub.Text = subtitle
    Sub.TextColor3 = isSpecialGradient and Color3.fromRGB(255, 0, 200) or Color3.fromRGB(0, 229, 255)
    Sub.Font = Enum.Font.Gotham
    Sub.TextSize = 11
    Sub.TextXAlignment = Enum.TextXAlignment.Left

    local RunBtn = Instance.new("TextButton", Card)
    RunBtn.Size = UDim2.new(0, 100, 0, 38)
    RunBtn.Position = UDim2.new(1, -114, 0.5, -19)
    RunBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
    RunBtn.Text = "EXECUTE"
    RunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RunBtn.Font = Enum.Font.GothamBold
    RunBtn.TextSize = 11
    Instance.new("UICorner", RunBtn).CornerRadius = UDim.new(0, 10)

    local Gradient = Instance.new("UIGradient", RunBtn)
    if isSpecialGradient then
        Gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
        }
    else
        Gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 120, 255))
        }
    end

    local BtnStroke = Instance.new("UIStroke", RunBtn)
    BtnStroke.Color = isSpecialGradient and Color3.fromRGB(255, 150, 240) or Color3.fromRGB(150, 240, 255)
    BtnStroke.Thickness = 1.5

    return RunBtn
end

-- 📜 SCRIPT 1: ดูดไอดีเพลง By.Honkuki
local RunBtn1 = CreateScriptCard("ดูดไอดีเพลง By.Honkuki", "Audio Logger System (Universal)", "", false)
-- 📜 SCRIPT 2: Script by AVX HUB
local RunBtn2 = CreateScriptCard("Script by AVX HUB", "RVX / AVX Hub Main System", "", true)
-- 📜 SCRIPT 3: Coquette Hub Remake
local RunBtn3 = CreateScriptCard("Coquette Hub Remake", "Brookhaven RP Special Script", "", false)
-- 📜 SCRIPT 4: Dark Hub
local RunBtn4 = CreateScriptCard("Dark Hub", "Brookhaven RP Dark Edition", "", true)

-- Tab 2: Status Page
local PageInfo = Instance.new("Frame", ContentFrame)
PageInfo.Size = UDim2.new(1, 0, 1, 0)
PageInfo.BackgroundTransparency = 1
PageInfo.Visible = false

local StatusCard = Instance.new("Frame", PageInfo)
StatusCard.Size = UDim2.new(1, 0, 0, 90)
StatusCard.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
Instance.new("UICorner", StatusCard).CornerRadius = UDim.new(0, 12)

local StatusCardStroke = Instance.new("UIStroke", StatusCard)
StatusCardStroke.Color = Color3.fromRGB(35, 40, 55)
StatusCardStroke.Thickness = 1

local MapLabel = Instance.new("TextLabel", StatusCard)
MapLabel.Size = UDim2.new(1, -20, 0, 25)
MapLabel.Position = UDim2.new(0, 16, 0, 16)
MapLabel.BackgroundTransparency = 1
MapLabel.Text = "Current Game: " .. CurrentGameName
MapLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MapLabel.Font = Enum.Font.GothamBold
MapLabel.TextSize = 13
MapLabel.TextXAlignment = Enum.TextXAlignment.Left

local PlaceIdLabel = Instance.new("TextLabel", StatusCard)
PlaceIdLabel.Size = UDim2.new(1, -20, 0, 20)
PlaceIdLabel.Position = UDim2.new(0, 16, 0, 46)
PlaceIdLabel.BackgroundTransparency = 1
PlaceIdLabel.Text = "Place ID: " .. tostring(PlaceId) .. " (System Ready)"
PlaceIdLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
PlaceIdLabel.Font = Enum.Font.Gotham
PlaceIdLabel.TextSize = 11
PlaceIdLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Tab Switch Logic
TabGame.MouseButton1Click:Connect(function()
    PageGame.Visible = true; PageInfo.Visible = false
    TabGame.BackgroundColor3 = Color3.fromRGB(25, 30, 45); TabGame.TextColor3 = Color3.fromRGB(0, 229, 255); TabGameStroke.Color = Color3.fromRGB(0, 229, 255)
    TabInfo.BackgroundColor3 = Color3.fromRGB(15, 17, 24); TabInfo.TextColor3 = Color3.fromRGB(120, 125, 140); TabInfoStroke.Color = Color3.fromRGB(40, 45, 60)
end)

TabInfo.MouseButton1Click:Connect(function()
    PageGame.Visible = false; PageInfo.Visible = true
    TabInfo.BackgroundColor3 = Color3.fromRGB(25, 30, 45); TabInfo.TextColor3 = Color3.fromRGB(0, 229, 255); TabInfoStroke.Color = Color3.fromRGB(0, 229, 255)
    TabGame.BackgroundColor3 = Color3.fromRGB(15, 17, 24); TabGame.TextColor3 = Color3.fromRGB(120, 125, 140); TabGameStroke.Color = Color3.fromRGB(40, 45, 60)
end)

-- ==================== 🔑 KEY SYSTEM & OVERLAY DESIGN (ดัดแปลงตามรูปภาพ) ====================
local KeyOverlay = Instance.new("Frame", MainFrame)
KeyOverlay.Size = UDim2.new(1, 0, 1, 0)
KeyOverlay.BackgroundColor3 = Color3.fromRGB(8, 9, 13)
KeyOverlay.BackgroundTransparency = 0.02
KeyOverlay.Visible = true
KeyOverlay.ZIndex = 30
Instance.new("UICorner", KeyOverlay).CornerRadius = UDim.new(0, 14)

-- กล่องป็อปอัปสี่เหลี่ยมขอบมนกะทัดรัด (Style Coquette Hub ในรูป)
local CompactKeyCard = Instance.new("Frame", KeyOverlay)
CompactKeyCard.Size = UDim2.new(0, 440, 0, 230)
CompactKeyCard.Position = UDim2.new(0.5, -220, 0.5, -115)
CompactKeyCard.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
CompactKeyCard.ZIndex = 31
Instance.new("UICorner", CompactKeyCard).CornerRadius = UDim.new(0, 16)

local CompactCardStroke = Instance.new("UIStroke", CompactKeyCard)
CompactCardStroke.Color = Color3.fromRGB(40, 45, 60)
CompactCardStroke.Thickness = 1.5

-- ส่วน Header ของป็อปอัป
local KeyBadge = Instance.new("Frame", CompactKeyCard)
KeyBadge.Size = UDim2.new(0, 42, 0, 22)
KeyBadge.Position = UDim2.new(0, 140, 0, 22)
KeyBadge.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
KeyBadge.ZIndex = 32
Instance.new("UICorner", KeyBadge).CornerRadius = UDim.new(0, 6)

local KeyBadgeText = Instance.new("TextLabel", KeyBadge)
KeyBadgeText.Size = UDim2.new(1, 0, 1, 0)
KeyBadgeText.BackgroundTransparency = 1
KeyBadgeText.Text = "KEY"
KeyBadgeText.TextColor3 = Color3.fromRGB(200, 205, 220)
KeyBadgeText.Font = Enum.Font.GothamBold
KeyBadgeText.TextSize = 10
KeyBadgeText.ZIndex = 33

local PopupTitle = Instance.new("TextLabel", CompactKeyCard)
PopupTitle.Size = UDim2.new(0, 200, 0, 25)
PopupTitle.Position = UDim2.new(0, 190, 0, 20)
PopupTitle.BackgroundTransparency = 1
PopupTitle.Text = "StyleKuki VIP"
PopupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
PopupTitle.Font = Enum.Font.GothamBold
PopupTitle.TextSize = 16
PopupTitle.TextXAlignment = Enum.TextXAlignment.Left
PopupTitle.ZIndex = 32

-- วงกลมแสดงสถานะ/เปอร์เซ็นต์ (ตามแบบรูปภาพ)
local CircleFrame = Instance.new("Frame", CompactKeyCard)
CircleFrame.Size = UDim2.new(0, 95, 0, 95)
CircleFrame.Position = UDim2.new(0, 25, 0, 25)
CircleFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 15)
CircleFrame.ZIndex = 32
Instance.new("UICorner", CircleFrame).CornerRadius = UDim.new(1, 0)

local CircleStroke = Instance.new("UIStroke", CircleFrame)
CircleStroke.Color = Color3.fromRGB(0, 229, 255)
CircleStroke.Thickness = 3.5

local PercentText = Instance.new("TextLabel", CircleFrame)
PercentText.Size = UDim2.new(1, 0, 0, 30)
PercentText.Position = UDim2.new(0, 0, 0.28, 0)
PercentText.BackgroundTransparency = 1
PercentText.Text = "LOCK"
PercentText.TextColor3 = Color3.fromRGB(255, 255, 255)
PercentText.Font = Enum.Font.GothamBold
PercentText.TextSize = 15
PercentText.ZIndex = 33

local StatusSubText = Instance.new("TextLabel", CircleFrame)
StatusSubText.Size = UDim2.new(1, 0, 0, 15)
StatusSubText.Position = UDim2.new(0, 0, 0.60, 0)
StatusSubText.BackgroundTransparency = 1
StatusSubText.Text = "VERIFYING"
StatusSubText.TextColor3 = Color3.fromRGB(120, 125, 140)
StatusSubText.Font = Enum.Font.GothamMedium
StatusSubText.TextSize = 8
StatusSubText.ZIndex = 33

-- ข้อความแนะนำ
local KeySub = Instance.new("TextLabel", CompactKeyCard)
KeySub.Size = UDim2.new(0, 260, 0, 20)
KeySub.Position = UDim2.new(0, 140, 0, 52)
KeySub.BackgroundTransparency = 1
KeySub.Text = "Please enter key to unlock access..."
KeySub.TextColor3 = Color3.fromRGB(140, 145, 160)
KeySub.Font = Enum.Font.Gotham
KeySub.TextSize = 11
KeySub.TextXAlignment = Enum.TextXAlignment.Left
KeySub.ZIndex = 32

-- ช่องป้อนคีย์
local KeyInputBox = Instance.new("TextBox", CompactKeyCard)
KeyInputBox.Size = UDim2.new(0, 275, 0, 32)
KeyInputBox.Position = UDim2.new(0, 140, 0, 80)
KeyInputBox.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
KeyInputBox.Text = ""
KeyInputBox.PlaceholderText = "Enter Access Key..."
KeyInputBox.PlaceholderColor3 = Color3.fromRGB(80, 85, 100)
KeyInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInputBox.Font = Enum.Font.GothamMedium
KeyInputBox.TextSize = 11
KeyInputBox.ClearTextOnFocus = false
KeyInputBox.ZIndex = 32
Instance.new("UICorner", KeyInputBox).CornerRadius = UDim.new(0, 8)

local KeyInputStroke = Instance.new("UIStroke", KeyInputBox)
KeyInputStroke.Color = Color3.fromRGB(0, 229, 255)
KeyInputStroke.Thickness = 1
KeyInputStroke.Transparency = 0.5

-- ปุ่มตรวจสอบคีย์
local CheckKeyBtn = Instance.new("TextButton", CompactKeyCard)
CheckKeyBtn.Size = UDim2.new(0, 275, 0, 32)
CheckKeyBtn.Position = UDim2.new(0, 140, 0, 120)
CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
CheckKeyBtn.Text = "UNLOCK SYSTEM"
CheckKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckKeyBtn.Font = Enum.Font.GothamBold
CheckKeyBtn.TextSize = 11
CheckKeyBtn.ZIndex = 32
Instance.new("UICorner", CheckKeyBtn).CornerRadius = UDim.new(0, 8)

local CheckBtnGradient = Instance.new("UIGradient", CheckKeyBtn)
CheckBtnGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 200))
}

-- Visualizer แถบเสียงแบบในรูป
local VisContainer = Instance.new("Frame", CompactKeyCard)
VisContainer.Size = UDim2.new(0, 390, 0, 25)
VisContainer.Position = UDim2.new(0, 25, 0, 180)
VisContainer.BackgroundTransparency = 1
VisContainer.ZIndex = 32

local VisLayout = Instance.new("UIListLayout", VisContainer)
VisLayout.FillDirection = Enum.FillDirection.Horizontal
VisLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
VisLayout.VerticalAlignment = Enum.VerticalAlignment.Center
VisLayout.Padding = UDim.new(0, 4)

for i = 1, 24 do
    local Bar = Instance.new("Frame", VisContainer)
    Bar.Size = UDim2.new(0, 3, 0, math.random(6, 20))
    Bar.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 33
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 2)
    
    task.spawn(function()
        while Bar and Bar.Parent do
            TweenService:Create(Bar, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 3, 0, math.random(4, 22))
            }):Play()
            task.wait(0.18)
        end
    end)
end

-- Loading Overlay
local LoadingOverlay = Instance.new("Frame", MainFrame)
LoadingOverlay.Size = UDim2.new(1, 0, 1, 0)
LoadingOverlay.BackgroundColor3 = Color3.fromRGB(8, 9, 13)
LoadingOverlay.BackgroundTransparency = 0.03
LoadingOverlay.Visible = false
LoadingOverlay.ZIndex = 40
Instance.new("UICorner", LoadingOverlay).CornerRadius = UDim.new(0, 14)

local LoadingText = Instance.new("TextLabel", LoadingOverlay)
LoadingText.Size = UDim2.new(1, 0, 0, 30)
LoadingText.Position = UDim2.new(0, 0, 0.38, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "INITIALIZING SYSTEM... 0%"
LoadingText.TextColor3 = Color3.fromRGB(0, 229, 255)
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 13
LoadingText.ZIndex = 41

local BarTrack = Instance.new("Frame", LoadingOverlay)
BarTrack.Size = UDim2.new(0.75, 0, 0, 10)
BarTrack.Position = UDim2.new(0.125, 0, 0.52, 0)
BarTrack.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
BarTrack.BorderSizePixel = 0
BarTrack.ZIndex = 41
Instance.new("UICorner", BarTrack).CornerRadius = UDim.new(0, 5)

local BarFill = Instance.new("Frame", BarTrack)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 42
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(0, 5)

local BarFillGradient = Instance.new("UIGradient", BarFill)
BarFillGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 200))
}

-- Verify Key Event
CheckKeyBtn.MouseButton1Click:Connect(function()
    local userKey = KeyInputBox.Text
    if userKey == CORRECT_KEY then
        PercentText.Text = "100%"
        PercentText.TextColor3 = Color3.fromRGB(0, 255, 150)
        StatusSubText.Text = "SUCCESS"
        CircleStroke.Color = Color3.fromRGB(0, 255, 150)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "StyleKuki VIP",
            Text = "พร้อมรันสคริปต์ต่างๆแล้วครับ",
            Duration = 5
        })
        
        task.wait(0.6)
        KeyOverlay.Visible = false
    else
        PercentText.Text = "ERR"
        PercentText.TextColor3 = Color3.fromRGB(255, 70, 70)
        StatusSubText.Text = "INVALID KEY"
        CircleStroke.Color = Color3.fromRGB(255, 50, 50)
        KeyInputStroke.Color = Color3.fromRGB(255, 50, 50)
        
        task.wait(1.5)
        PercentText.Text = "LOCK"
        PercentText.TextColor3 = Color3.fromRGB(255, 255, 255)
        StatusSubText.Text = "VERIFYING"
        CircleStroke.Color = Color3.fromRGB(0, 229, 255)
        KeyInputStroke.Color = Color3.fromRGB(0, 229, 255)
    end
end)

-- ฟังก์ชันรันอนิเมชัน Loading
local function ExecuteWithLoading(scriptUrl, scriptName)
    LoadingOverlay.Visible = true
    for i = 1, 100 do
        BarFill.Size = UDim2.new(i / 100, 0, 1, 0)
        LoadingText.Text = "INITIALIZING SYSTEM... " .. i .. "%"
        task.wait(0.008)
    end
    task.wait(0.15)
    LoadingOverlay.Visible = false
    RunScript(scriptUrl, scriptName)
end

-- Run Execution Events
RunBtn1.MouseButton1Click:Connect(function()
    ExecuteWithLoading("https://raw.githubusercontent.com/kfcth5171/90/refs/heads/main/006.lua", "Audio Logger System")
end)

RunBtn2.MouseButton1Click:Connect(function()
    ExecuteWithLoading("https://raw.githubusercontent.com/RVXv2/RVX-hub/main/main.lua", "Script by AVX HUB")
end)

RunBtn3.MouseButton1Click:Connect(function()
    ExecuteWithLoading("https://rawscripts.net/raw/Brookhaven-RP-Coquette-Hub-Remake-133562", "Coquette Hub Remake")
end)

RunBtn4.MouseButton1Click:Connect(function()
    ExecuteWithLoading("https://rawscripts.net/raw/Brookhaven-RP-Dark-Hub-214104", "Dark Hub")
end)
