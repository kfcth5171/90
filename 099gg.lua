-- =====================================================================
-- [[ STYLEKUKI VIP LOADER & KEY SYSTEM - CYBERPUNK 3D EDITION ]] --
-- =====================================================================

local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileImageId = "130797657143524"
local PlaceId = game.PlaceId
local CORRECT_KEY = "°"

-- 🔒 WHITELIST USER IDs FOR ADMIN / VIP
local WhitelistedUserIDs = {
    [9802544328] = true,
    [1697390697] = true,
    [6030349781] = true
}

local LocalPlayer = Players.LocalPlayer

local Success, GameInfo = pcall(function()
    return MarketplaceService:GetProductInfo(PlaceId)
end)
local CurrentGameName = Success and GameInfo.Name or "Unknown Map"

local GuiParent = CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
if GuiParent:FindFirstChild("StyleKukiVIPLoader") then
    GuiParent.StyleKukiVIPLoader:Destroy()
end

-- ฟังก์ชันรันสคริปต์หลัก
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

-- 📦 MainContainer (ปรับขนาดกระทัดรัดพอดีจอโทรศัพท์ 480x280)
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 480, 0, 280)
MainContainer.Position = UDim2.new(0.5, -240, 0.5, -140)
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

-- 🔘 TOGGLE OPEN/CLOSE BUTTON SYSTEM
local ToggleBtnContainer = Instance.new("Frame", ScreenGui)
ToggleBtnContainer.Name = "ToggleBtnContainer"
ToggleBtnContainer.Size = UDim2.new(0, 42, 0, 42)
ToggleBtnContainer.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleBtnContainer.BackgroundTransparency = 1
ToggleBtnContainer.Visible = true

local ToggleLED = Instance.new("Frame", ToggleBtnContainer)
ToggleLED.Size = UDim2.new(1, 0, 1, 0)
ToggleLED.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleLED.BorderSizePixel = 0
Instance.new("UICorner", ToggleLED).CornerRadius = UDim.new(0, 8)

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
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

RunService.RenderStepped:Connect(function()
    LEDGradient.Rotation = (LEDGradient.Rotation + 1.5) % 360
    ToggleLEDGradient.Rotation = (ToggleLEDGradient.Rotation + 2) % 360
    local PulseVal = (math.sin(tick() * 3) + 1) / 2
    AuraGlow.BackgroundTransparency = 0.5 + (PulseVal * 0.2)
end)

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

-- ⚡ ULTRA SMOOTH TOGGLE ANIMATION SYSTEM
local isUIVisible = true
local isAnimating = false

local function ToggleUI()
    if isAnimating then return end
    isAnimating = true
    
    if isUIVisible then
        local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        local t1 = TweenService:Create(MainContainer, tweenInfo, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        t1:Play()
        t1.Completed:Wait()
        MainContainer.Visible = false
        isUIVisible = false
    else
        MainContainer.Visible = true
        MainContainer.Size = UDim2.new(0, 0, 0, 0)
        MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        local t1 = TweenService:Create(MainContainer, tweenInfo, {
            Size = UDim2.new(0, 480, 0, 280),
            Position = UDim2.new(0.5, -240, 0.5, -140)
        })
        t1:Play()
        t1.Completed:Wait()
        isUIVisible = true
    end
    isAnimating = false
end

ToggleBtn.MouseButton1Click:Connect(ToggleUI)

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
IconHolder.Size = UDim2.new(0, 34, 0, 34)
IconHolder.Position = UDim2.new(0, 10, 0, 8)
IconHolder.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
IconHolder.BorderSizePixel = 0
Instance.new("UICorner", IconHolder).CornerRadius = UDim.new(0, 8)

local IconImage = Instance.new("ImageLabel", IconHolder)
IconImage.Size = UDim2.new(1, -4, 1, -4)
IconImage.Position = UDim2.new(0, 2, 0, 2)
IconImage.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
IconImage.BorderSizePixel = 0
IconImage.Image = "rbxassetid://" .. ProfileImageId
IconImage.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", IconImage).CornerRadius = UDim.new(0, 6)

local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.Size = UDim2.new(0, 150, 0, 34)
TitleLabel.Position = UDim2.new(0, 50, 0, 8)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "StyleKuki VIP"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local TitleGradient = Instance.new("UIGradient", TitleLabel)
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 200))
}

local TopMapBanner = Instance.new("Frame", MainFrame)
TopMapBanner.Size = UDim2.new(0, 170, 0, 26)
TopMapBanner.Position = UDim2.new(0.5, -85, 0, 12)
TopMapBanner.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
TopMapBanner.BorderSizePixel = 0
Instance.new("UICorner", TopMapBanner).CornerRadius = UDim.new(0, 6)

local BannerStroke = Instance.new("UIStroke", TopMapBanner)
BannerStroke.Color = Color3.fromRGB(0, 229, 255)
BannerStroke.Thickness = 1
BannerStroke.Transparency = 0.6

local TopMapText = Instance.new("TextLabel", TopMapBanner)
TopMapText.Size = UDim2.new(1, -10, 1, 0)
TopMapText.Position = UDim2.new(0, 5, 0, 0)
TopMapText.BackgroundTransparency = 1
TopMapText.Text = "📍 " .. CurrentGameName
TopMapText.TextColor3 = Color3.fromRGB(240, 240, 255)
TopMapText.TextSize = 10
TopMapText.Font = Enum.Font.GothamMedium
TopMapText.TextTruncate = Enum.TextTruncate.AtEnd

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -34, 0, 12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local CloseStroke = Instance.new("UIStroke", CloseBtn)
CloseStroke.Color = Color3.fromRGB(255, 0, 100)
CloseStroke.Thickness = 1.5
CloseBtn.MouseButton1Click:Connect(ToggleUI)

-- Navigation Sidebar (7 หมวดหมู่)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 120, 1, -55)
Sidebar.Position = UDim2.new(0, 10, 0, 48)
Sidebar.BackgroundTransparency = 1

local TabGame = Instance.new("TextButton", Sidebar)
TabGame.Size = UDim2.new(1, 0, 0, 24)
TabGame.Position = UDim2.new(0, 0, 0, 0)
TabGame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
TabGame.Text = "  🎮  สคริปต่างๆ"
TabGame.TextColor3 = Color3.fromRGB(0, 229, 255)
TabGame.Font = Enum.Font.GothamBold
TabGame.TextSize = 9
TabGame.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", TabGame).CornerRadius = UDim.new(0, 6)

local TabGameStroke = Instance.new("UIStroke", TabGame)
TabGameStroke.Color = Color3.fromRGB(0, 229, 255)
TabGameStroke.Thickness = 1

local TabInfo = Instance.new("TextButton", Sidebar)
TabInfo.Size = UDim2.new(1, 0, 0, 24)
TabInfo.Position = UDim2.new(0, 0, 0, 27)
TabInfo.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
TabInfo.Text = "  📊  STATUS"
TabInfo.TextColor3 = Color3.fromRGB(120, 125, 140)
TabInfo.Font = Enum.Font.GothamBold
TabInfo.TextSize = 9
TabInfo.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", TabInfo).CornerRadius = UDim.new(0, 6)

local TabInfoStroke = Instance.new("UIStroke", TabInfo)
TabInfoStroke.Color = Color3.fromRGB(40, 45, 60)
TabInfoStroke.Thickness = 1

local TabTools = Instance.new("TextButton", Sidebar)
TabTools.Size = UDim2.new(1, 0, 0, 24)
TabTools.Position = UDim2.new(0, 0, 0, 54)
TabTools.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
TabTools.Text = "  🛠️  TOOLS🔥"
TabTools.TextColor3 = Color3.fromRGB(120, 125, 140)
TabTools.Font = Enum.Font.GothamBold
TabTools.TextSize = 9
TabTools.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", TabTools).CornerRadius = UDim.new(0, 6)

local TabToolsStroke = Instance.new("UIStroke", TabTools)
TabToolsStroke.Color = Color3.fromRGB(40, 45, 60)
TabToolsStroke.Thickness = 1

local TabCars = Instance.new("TextButton", Sidebar)
TabCars.Size = UDim2.new(1, 0, 0, 24)
TabCars.Position = UDim2.new(0, 0, 0, 81)
TabCars.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
TabCars.Text = "  🚗  CARS"
TabCars.TextColor3 = Color3.fromRGB(120, 125, 140)
TabCars.Font = Enum.Font.GothamBold
TabCars.TextSize = 9
TabCars.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", TabCars).CornerRadius = UDim.new(0, 6)

local TabCarsStroke = Instance.new("UIStroke", TabCars)
TabCarsStroke.Color = Color3.fromRGB(40, 45, 60)
TabCarsStroke.Thickness = 1

local TabESP = Instance.new("TextButton", Sidebar)
TabESP.Size = UDim2.new(1, 0, 0, 24)
TabESP.Position = UDim2.new(0, 0, 0, 108)
TabESP.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
TabESP.Text = "  👁️  ESP"
TabESP.TextColor3 = Color3.fromRGB(120, 125, 140)
TabESP.Font = Enum.Font.GothamBold
TabESP.TextSize = 9
TabESP.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", TabESP).CornerRadius = UDim.new(0, 6)

local TabESPStroke = Instance.new("UIStroke", TabESP)
TabESPStroke.Color = Color3.fromRGB(40, 45, 60)
TabESPStroke.Thickness = 1

-- หมวดหมู่ที่ 6: Protection
local TabProtection = Instance.new("TextButton", Sidebar)
TabProtection.Size = UDim2.new(1, 0, 0, 24)
TabProtection.Position = UDim2.new(0, 0, 0, 135)
TabProtection.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
TabProtection.Text = "  🛡️  protection"
TabProtection.TextColor3 = Color3.fromRGB(120, 125, 140)
TabProtection.Font = Enum.Font.GothamBold
TabProtection.TextSize = 9
TabProtection.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", TabProtection).CornerRadius = UDim.new(0, 6)

local TabProtectionStroke = Instance.new("UIStroke", TabProtection)
TabProtectionStroke.Color = Color3.fromRGB(40, 45, 60)
TabProtectionStroke.Thickness = 1

-- หมวดหมู่ที่ 7: Rainbow
local TabRainbow = Instance.new("TextButton", Sidebar)
TabRainbow.Size = UDim2.new(1, 0, 0, 24)
TabRainbow.Position = UDim2.new(0, 0, 0, 162)
TabRainbow.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
TabRainbow.Text = "  🌈  Rainbow"
TabRainbow.TextColor3 = Color3.fromRGB(120, 125, 140)
TabRainbow.Font = Enum.Font.GothamBold
TabRainbow.TextSize = 9
TabRainbow.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", TabRainbow).CornerRadius = UDim.new(0, 6)

local TabRainbowStroke = Instance.new("UIStroke", TabRainbow)
TabRainbowStroke.Color = Color3.fromRGB(40, 45, 60)
TabRainbowStroke.Thickness = 1

-- Main Content Frame
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -145, 1, -55)
ContentFrame.Position = UDim2.new(0, 135, 0, 48)
ContentFrame.BackgroundTransparency = 1

-- Tab 1: สคริปต่างๆ
local PageGame = Instance.new("ScrollingFrame", ContentFrame)
PageGame.Size = UDim2.new(1, 0, 1, 0)
PageGame.BackgroundTransparency = 1
PageGame.ScrollBarThickness = 3
PageGame.ScrollBarImageColor3 = Color3.fromRGB(0, 229, 255)
PageGame.BorderSizePixel = 0
PageGame.Visible = true

local PageListLayout = Instance.new("UIListLayout", PageGame)
PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PageListLayout.Padding = UDim.new(0, 8)

PageListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PageGame.CanvasSize = UDim2.new(0, 0, 0, PageListLayout.AbsoluteContentSize.Y + 8)
end)

local function CreateScriptCard(parent, title, subtitle, btnText, isSpecialGradient)
    local Card = Instance.new("Frame", parent)
    Card.Size = UDim2.new(1, -8, 0, 55)
    Card.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    Card.BorderSizePixel = 0
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Color = Color3.fromRGB(35, 40, 55)
    Stroke.Thickness = 1

    local Title = Instance.new("TextLabel", Card)
    Title.Size = UDim2.new(1, -100, 0, 20)
    Title.Position = UDim2.new(0, 10, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 11
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Sub = Instance.new("TextLabel", Card)
    Sub.Size = UDim2.new(1, -100, 0, 16)
    Sub.Position = UDim2.new(0, 10, 0, 28)
    Sub.BackgroundTransparency = 1
    Sub.Text = subtitle
    Sub.TextColor3 = isSpecialGradient and Color3.fromRGB(255, 0, 200) or Color3.fromRGB(0, 229, 255)
    Sub.Font = Enum.Font.Gotham
    Sub.TextSize = 9
    Sub.TextXAlignment = Enum.TextXAlignment.Left

    local RunBtn = Instance.new("TextButton", Card)
    RunBtn.Size = UDim2.new(0, 75, 0, 28)
    RunBtn.Position = UDim2.new(1, -83, 0.5, -14)
    RunBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
    RunBtn.Text = btnText or "EXECUTE"
    RunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RunBtn.Font = Enum.Font.GothamBold
    RunBtn.TextSize = 9
    Instance.new("UICorner", RunBtn).CornerRadius = UDim.new(0, 6)

    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    RunBtn.MouseEnter:Connect(function()
        TweenService:Create(RunBtn, tweenInfo, {Size = UDim2.new(0, 78, 0, 30), Position = UDim2.new(1, -85, 0.5, -15)}):Play()
    end)
    RunBtn.MouseLeave:Connect(function()
        TweenService:Create(RunBtn, tweenInfo, {Size = UDim2.new(0, 75, 0, 28), Position = UDim2.new(1, -83, 0.5, -14)}):Play()
    end)

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

    return RunBtn, Gradient, BtnStroke
end

local RunBtn1 = CreateScriptCard(PageGame, "ดูดไอดีเพลง By.Honkuki", "Audio Logger System (Universal)", "EXECUTE", false)
local RunBtn2 = CreateScriptCard(PageGame, "Script by AVX HUB", "RVX / AVX Hub Main System", "EXECUTE", true)
local RunBtn3 = CreateScriptCard(PageGame, "Coquette Hub Remake", "Brookhaven RP Special Script", "EXECUTE", false)

-- Tab 2: Status Page
local PageInfo = Instance.new("Frame", ContentFrame)
PageInfo.Size = UDim2.new(1, 0, 1, 0)
PageInfo.BackgroundTransparency = 1
PageInfo.Visible = false

local StatusCard = Instance.new("Frame", PageInfo)
StatusCard.Size = UDim2.new(1, -8, 0, 75)
StatusCard.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
Instance.new("UICorner", StatusCard).CornerRadius = UDim.new(0, 8)

local StatusCardStroke = Instance.new("UIStroke", StatusCard)
StatusCardStroke.Color = Color3.fromRGB(35, 40, 55)
StatusCardStroke.Thickness = 1

local MapLabel = Instance.new("TextLabel", StatusCard)
MapLabel.Size = UDim2.new(1, -20, 0, 20)
MapLabel.Position = UDim2.new(0, 12, 0, 12)
MapLabel.BackgroundTransparency = 1
MapLabel.Text = "Current Game: " .. CurrentGameName
MapLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MapLabel.Font = Enum.Font.GothamBold
MapLabel.TextSize = 11
MapLabel.TextXAlignment = Enum.TextXAlignment.Left

local PlaceIdLabel = Instance.new("TextLabel", StatusCard)
PlaceIdLabel.Size = UDim2.new(1, -20, 0, 18)
PlaceIdLabel.Position = UDim2.new(0, 12, 0, 38)
PlaceIdLabel.BackgroundTransparency = 1
PlaceIdLabel.Text = "Place ID: " .. tostring(PlaceId) .. " (System Ready)"
PlaceIdLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
PlaceIdLabel.Font = Enum.Font.Gotham
PlaceIdLabel.TextSize = 10
PlaceIdLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Tab 3: Tools Page
local PageTools = Instance.new("ScrollingFrame", ContentFrame)
PageTools.Size = UDim2.new(1, 0, 1, 0)
PageTools.BackgroundTransparency = 1
PageTools.ScrollBarThickness = 3
PageTools.ScrollBarImageColor3 = Color3.fromRGB(0, 229, 255)
PageTools.BorderSizePixel = 0
PageTools.Visible = false

local ToolsListLayout = Instance.new("UIListLayout", PageTools)
ToolsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ToolsListLayout.Padding = UDim.new(0, 8)

ToolsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PageTools.CanvasSize = UDim2.new(0, 0, 0, ToolsListLayout.AbsoluteContentSize.Y + 8)
end)

-- Tab 4: Cars Page
local PageCars = Instance.new("ScrollingFrame", ContentFrame)
PageCars.Size = UDim2.new(1, 0, 1, 0)
PageCars.BackgroundTransparency = 1
PageCars.ScrollBarThickness = 3
PageCars.ScrollBarImageColor3 = Color3.fromRGB(0, 229, 255)
PageCars.BorderSizePixel = 0
PageCars.Visible = false

local CarsListLayout = Instance.new("UIListLayout", PageCars)
CarsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
CarsListLayout.Padding = UDim.new(0, 8)

CarsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PageCars.CanvasSize = UDim2.new(0, 0, 0, CarsListLayout.AbsoluteContentSize.Y + 8)
end)

-- Tab 5: ESP Page
local PageESP = Instance.new("ScrollingFrame", ContentFrame)
PageESP.Size = UDim2.new(1, 0, 1, 0)
PageESP.BackgroundTransparency = 1
PageESP.ScrollBarThickness = 3
PageESP.ScrollBarImageColor3 = Color3.fromRGB(0, 229, 255)
PageESP.BorderSizePixel = 0
PageESP.Visible = false

local ESPListLayout = Instance.new("UIListLayout", PageESP)
ESPListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ESPListLayout.Padding = UDim.new(0, 8)

ESPListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PageESP.CanvasSize = UDim2.new(0, 0, 0, ESPListLayout.AbsoluteContentSize.Y + 8)
end)

-- Tab 6: Rainbow Page
local PageRainbow = Instance.new("ScrollingFrame", ContentFrame)
PageRainbow.Size = UDim2.new(1, 0, 1, 0)
PageRainbow.BackgroundTransparency = 1
PageRainbow.ScrollBarThickness = 3
PageRainbow.ScrollBarImageColor3 = Color3.fromRGB(0, 229, 255)
PageRainbow.BorderSizePixel = 0
PageRainbow.Visible = false

local RainbowListLayout = Instance.new("UIListLayout", PageRainbow)
RainbowListLayout.SortOrder = Enum.SortOrder.LayoutOrder
RainbowListLayout.Padding = UDim.new(0, 8)

RainbowListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PageRainbow.CanvasSize = UDim2.new(0, 0, 0, RainbowListLayout.AbsoluteContentSize.Y + 8)
end)

-- Tab 6: Protection Page
local PageProtection = Instance.new("ScrollingFrame", ContentFrame)
PageProtection.Size = UDim2.new(1, 0, 1, 0)
PageProtection.BackgroundTransparency = 1
PageProtection.ScrollBarThickness = 3
PageProtection.ScrollBarImageColor3 = Color3.fromRGB(0, 229, 255)
PageProtection.BorderSizePixel = 0
PageProtection.Visible = false

local ProtectionListLayout = Instance.new("UIListLayout", PageProtection)
ProtectionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ProtectionListLayout.Padding = UDim.new(0, 8)

ProtectionListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PageProtection.CanvasSize = UDim2.new(0, 0, 0, ProtectionListLayout.AbsoluteContentSize.Y + 8)
end)

local function GetNil(Name, DebugId)
    for _, Object in getnilinstances() do
        if Object.Name == Name and Object:GetDebugId() == DebugId then
            return Object
        end
    end
end

local function SmartClearTools()
    if LocalPlayer then
        if LocalPlayer:FindFirstChildOfClass("Backpack") then
            for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if item:IsA("Tool") then item:Destroy() end
            end
        end
        if LocalPlayer.Character then
            for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
                if item:IsA("Tool") then item:Destroy() end
            end
        end
    end
    
    task.spawn(function()
        for i = 1, 3 do
            local QuickDeleteEvent = GetNil("QuickDelete", "1_29270557")
            if QuickDeleteEvent then
                QuickDeleteEvent:FireServer()
            end
            
            local MainEvent = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Too1l")
            if MainEvent then
                pcall(function()
                    MainEvent:InvokeServer("ClearTools")
                    MainEvent:InvokeServer("RemoveTools")
                end)
            end
            task.wait(0.05)
        end
    end)
end

-- 1. ปุ่มเสก / ลบ BoomBox ใน Tools
local BoomBoxBtn, BoomBoxGradient, BoomBoxBtnStroke = CreateScriptCard(PageTools, "เสก BoomBox", "Spawn & Delete Boombox Item", "เสก", false)
local isBoomBoxSpawned = false

BoomBoxBtn.MouseButton1Click:Connect(function()
    if not isBoomBoxSpawned then
        local Event = ReplicatedStorage.RE["1Too1l"]
        if Event then
            Event:InvokeServer("PickingTools", "Boombox")
        end
        
        BoomBoxBtn.Text = "ลบ"
        BoomBoxGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 100)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 0, 50))
        }
        BoomBoxBtnStroke.Color = Color3.fromRGB(255, 100, 150)
        isBoomBoxSpawned = true
    else
        SmartClearTools()
        
        BoomBoxBtn.Text = "เสก"
        BoomBoxGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 120, 255))
        }
        BoomBoxBtnStroke.Color = Color3.fromRGB(150, 240, 255)
        isBoomBoxSpawned = false
    end
end)

-- 2. ปุ่มเสก / ลบ ปืนตด (Minions2026_FartGun) ใน Tools
local FartGunBtn, FartGunGradient, FartGunBtnStroke = CreateScriptCard(PageTools, "เสก ปืนตด (Fart Gun)", "Spawn & Delete Minions Fart Gun", "เสก", true)
local isFartGunSpawned = false

FartGunBtn.MouseButton1Click:Connect(function()
    if not isFartGunSpawned then
        local Event = ReplicatedStorage.RE["1Too1l"]
        Event:InvokeServer("PickingTools", "Minions2026_FartGun")
        
        FartGunBtn.Text = "ลบ"
        FartGunGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 100)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 0, 50))
        }
        FartGunBtnStroke.Color = Color3.fromRGB(255, 100, 150)
        isFartGunSpawned = true
    else
        SmartClearTools()
        
        FartGunBtn.Text = "เสก"
        FartGunGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
        }
        FartGunBtnStroke.Color = Color3.fromRGB(255, 150, 240)
        isFartGunSpawned = false
    end
end)

-- 🚗 ปุ่มเสกรถแพ
local RaftCarBtn, RaftCarGradient, RaftCarBtnStroke = CreateScriptCard(PageCars, "รถแพ", "Spawn Sled Raft Native Sequence", "เสก", false)

RaftCarBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        local StarterGui = game:GetService("StarterGui")
        local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
        local RE = ReplicatedStorage:WaitForChild("RE", 5)

        if not Remotes or not RE then return end

        pcall(function()
            Remotes.TelemetryClientInteraction:FireServer("filterClick", {
                name = "Sled",
                itemType = "Vehicles"
            })
        end)

        pcall(function()
            if RE:FindFirstChild("1Player1sCa1r") then
                RE["1Player1sCa1r"]:FireServer("VehicleMusicStop", "", nil, true)
                RE["1Player1sCa1r"]:FireServer("CarMusicStop", "", nil, true)
                RE["1Player1sCa1r"]:FireServer("MusicStop", "", nil, true)
                RE["1Player1sCa1r"]:FireServer("WickedGramophoneMusicStop", "", nil, true)
            end
            if RE:FindFirstChild("PlayerToolEvent") then RE.PlayerToolEvent:FireServer("ToolMusicStop", "", nil, true) end
            if RE:FindFirstChild("Props") then RE.Props:FireServer("PropMusicStop", "", nil, true) end
            if RE:FindFirstChild("1Hors1eRemot1e") then RE["1Hors1eRemot1e"]:FireServer("HorseMusicStop", "", nil, true) end
            if RE:FindFirstChild("1Player1sHous1e") then RE["1Player1sHous1e"]:FireServer("PickingHouseMusicStop", "", nil, true) end
            if Remotes:FindFirstChild("Emotes:StopSyncableEmote") then Remotes["Emotes:StopSyncableEmote"]:FireServer() end
        end)

        pcall(function()
            if firesignal and Remotes:FindFirstChild("PlayerStoppedDriving") then
                firesignal(Remotes.PlayerStoppedDriving.OnClientEvent)
            end
        end)

        pcall(function()
            if RE:FindFirstChild("1Ca1r") then
                RE["1Ca1r"]:FireServer("NoMotorVehicleDeleteCar")
            end
        end)

        task.wait(0.1)

        pcall(function()
            if RE:FindFirstChild("1NoMoto1rVehicle1s") then
                RE["1NoMoto1rVehicle1s"]:FireServer("Sled", nil, nil)
            end
        end)

        pcall(function()
            if Remotes:FindFirstChild("LoadPanel") then
                Remotes.LoadPanel:FireServer("MainGUIHandler", "NoMotorVehicleControl", true)
            end
        end)

        pcall(function()
            if firesignal and Remotes:FindFirstChild("PlayerStartedDriving") then
                firesignal(Remotes.PlayerStartedDriving.OnClientEvent, LocalPlayer)
            end

            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local mainGui = playerGui:FindFirstChild("MainGUIHandler") or playerGui:FindFirstChild("MainGUI")
                if mainGui then
                    mainGui:SetAttribute("CurrentVehicleOwner", LocalPlayer.Name)
                    mainGui:SetAttribute("InVehicle", true)
                end
            end
        end)

        pcall(function()
            if Remotes:FindFirstChild("GetNoMotorVehicleSpeed") then Remotes.GetNoMotorVehicleSpeed:InvokeServer() end
            if Remotes:FindFirstChild("SetNoMotorVehicleSpeed") then Remotes.SetNoMotorVehicleSpeed:InvokeServer(25) end

            if Remotes:FindFirstChild("GetNoMotorVehicleSpeed") then
                local speedResult = table.pack(Remotes.GetNoMotorVehicleSpeed:InvokeServer())
            end

            if Remotes:FindFirstChild("SetNoMotorVehicleSpeed") then Remotes.SetNoMotorVehicleSpeed:InvokeServer(25) end

            if firesignal and Remotes:FindFirstChild("NoMotorVehicleSpeedChanged") then
                firesignal(Remotes.NoMotorVehicleSpeedChanged.OnClientEvent, 25)
            end
        end)

        pcall(function()
            if Remotes:FindFirstChild("ClientProfiling:SendData") then
                Remotes["ClientProfiling:SendData"]:FireServer({
                    frameTimeStability = { min = 0.0174, p1Low = 0.0174, mean = 0.1306, max = 0.4845, stdDev = 0.1776, p01Low = 0.0174 },
                    identifier = "MainVehicleMenu",
                    memoryStability = { min = 1535.6211, p1Low = 1535.6211, mean = 1546.9508, max = 1573.9414, stdDev = 13.8404, p01Low = 1535.6211 },
                    avgCPURenderTime = 0.0296, avgGPURenderTime = 0.0196, duration = 4.4981, avgTotalMemory = 1546.9508, avgFrameTime = 0.1306
                })
            end
        end)

        StarterGui:SetCore("SendNotification", {
            Title = "StyleKuki VIP",
            Text = "🛶 เสกรถ ซิงค์ UI และตั้งค่าระบบเสียงสมบูรณ์!",
            Duration = 3
        })
    end)
end)

-- Helper Function สร้าง Switch Toggle
local function CreateSwitchCard(parent, title, subtitle, onToggleCallback)
    local Card = Instance.new("Frame", parent)
    Card.Size = UDim2.new(1, -8, 0, 50)
    Card.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    Card.BorderSizePixel = 0
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Color = Color3.fromRGB(35, 40, 55)
    Stroke.Thickness = 1

    local Title = Instance.new("TextLabel", Card)
    Title.Size = UDim2.new(1, -90, 0, 18)
    Title.Position = UDim2.new(0, 10, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 10
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Sub = Instance.new("TextLabel", Card)
    Sub.Size = UDim2.new(1, -90, 0, 14)
    Sub.Position = UDim2.new(0, 10, 0, 26)
    Sub.BackgroundTransparency = 1
    Sub.Text = subtitle
    Sub.TextColor3 = Color3.fromRGB(0, 229, 255)
    Sub.Font = Enum.Font.Gotham
    Sub.TextSize = 8
    Sub.TextXAlignment = Enum.TextXAlignment.Left

    local SwitchBackground = Instance.new("Frame", Card)
    SwitchBackground.Size = UDim2.new(0, 42, 0, 22)
    SwitchBackground.Position = UDim2.new(1, -52, 0.5, -11)
    SwitchBackground.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
    SwitchBackground.BorderSizePixel = 0
    Instance.new("UICorner", SwitchBackground).CornerRadius = UDim.new(1, 0)

    local SwitchKnob = Instance.new("Frame", SwitchBackground)
    SwitchKnob.Size = UDim2.new(0, 16, 0, 16)
    SwitchKnob.Position = UDim2.new(0, 3, 0.5, -8)
    SwitchKnob.BackgroundColor3 = Color3.fromRGB(180, 185, 200)
    SwitchKnob.BorderSizePixel = 0
    Instance.new("UICorner", SwitchKnob).CornerRadius = UDim.new(1, 0)

    local ClickBtn = Instance.new("TextButton", SwitchBackground)
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text = ""

    local state = false
    ClickBtn.MouseButton1Click:Connect(function()
        state = not state
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if state then
            TweenService:Create(SwitchBackground, tweenInfo, {BackgroundColor3 = Color3.fromRGB(0, 229, 255)}):Play()
            TweenService:Create(SwitchKnob, tweenInfo, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(SwitchBackground, tweenInfo, {BackgroundColor3 = Color3.fromRGB(35, 40, 50)}):Play()
            TweenService:Create(SwitchKnob, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(180, 185, 200)}):Play()
        end
        onToggleCallback(state)
    end)

    return Card
end

-- =====================================================================
-- 🛡️ [หมวดหมู่ที่ 6: PROTECTION]
-- =====================================================================
local ProtectionState = {
    AntiSit = false,
    Noclip = false,
    AntiFling = false,
    AntiLag = false
}

local AntiSitConn
local NoclipConn
local AntiFlingConn
local AntiLagRunning = false

local function SetupAntiSit(state)
    if AntiSitConn then AntiSitConn:Disconnect(); AntiSitConn = nil end
    ProtectionState.AntiSit = state
    if not state then return end

    local function hookCharacter(char)
        local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
        if not hum or not ProtectionState.AntiSit then return end
        AntiSitConn = hum.Seated:Connect(function(active)
            if active and ProtectionState.AntiSit then
                hum.Sit = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
        hum:GetPropertyChangedSignal("Sit"):Connect(function()
            if ProtectionState.AntiSit and hum.Sit then hum.Sit = false end
        end)
    end
    if LocalPlayer.Character then hookCharacter(LocalPlayer.Character) end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    if ProtectionState.AntiSit then SetupAntiSit(true) end
end)

local function SetupNoclip(state)
    if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
    ProtectionState.Noclip = state
    if not state then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
        return
    end
    NoclipConn = RunService.Stepped:Connect(function()
        if not ProtectionState.Noclip then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

local function SetupAntiFling(state)
    if AntiFlingConn then AntiFlingConn:Disconnect(); AntiFlingConn = nil end
    ProtectionState.AntiFling = state
    if not state then return end
    AntiFlingConn = RunService.Heartbeat:Connect(function()
        if not ProtectionState.AntiFling then return end
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            if root.AssemblyLinearVelocity.Magnitude > 80 then root.AssemblyLinearVelocity = Vector3.zero end
            if root.AssemblyAngularVelocity.Magnitude > 80 then root.AssemblyAngularVelocity = Vector3.zero end
        end
    end)
end

local function SetupAntiLag(state)
    ProtectionState.AntiLag = state
    if state and not AntiLagRunning then
        AntiLagRunning = true
        task.spawn(function()
            while ProtectionState.AntiLag do
                collectgarbage("collect")
                task.wait(5)
            end
            AntiLagRunning = false
        end)
    end
end

CreateSwitchCard(PageProtection, "1. กันนั่ง", "ป้องกันตัวละครถูกบังคับให้นั่ง", SetupAntiSit)
CreateSwitchCard(PageProtection, "2. noclip", "เดินทะลุสิ่งกีดขวาง", SetupNoclip)
CreateSwitchCard(PageProtection, "3. anti fling", "ลดผลกระทบจากแรงเหวี่ยง/การกระแทกผิดปกติ", SetupAntiFling)
CreateSwitchCard(PageProtection, "4. ป้องกันแลค-กระตุก", "ตัวช่วยเก็บหน่วยความจำเป็นระยะ โดยไม่ลบวัตถุหรือปิดเงา", SetupAntiLag)

-- =====================================================================
-- 🌈 [หมวดหมู่ที่ 7: RAINBOW SYSTEM (SPEED 100)]
-- =====================================================================

local RainbowSpeed = 100

-- Switch 1: สีรถเรนโบว์
local CarRainbowConn
CreateSwitchCard(PageRainbow, "สีรถเรนโบว์", "ลูปเปลี่ยนสีรถเรนโบว์ ความเร็ว 100", function(state)
    if state then
        CarRainbowConn = RunService.RenderStepped:Connect(function()
            local hue = (tick() * (RainbowSpeed / 10)) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            local Event = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Player1sCa1r")
            if Event then
                Event:FireServer("NoMotorColor", color)
            end
        end)
    else
        if CarRainbowConn then
            CarRainbowConn:Disconnect()
            CarRainbowConn = nil
        end
    end
end)

-- Switch 2: สีชื่อบนหัวRP NAME
local NameRainbowConn
CreateSwitchCard(PageRainbow, "สีชื่อบนหัวRP NAME", "ลูปเปลี่ยนสีชื่อ RP Name เรนโบว์ ความเร็ว 100", function(state)
    if state then
        NameRainbowConn = RunService.RenderStepped:Connect(function()
            local hue = (tick() * (RainbowSpeed / 10)) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            local Event = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1RPNam1eColo1r")
            if Event then
                Event:FireServer("PickingRPNameColor", color)
            end
        end)
    else
        if NameRainbowConn then
            NameRainbowConn:Disconnect()
            NameRainbowConn = nil
        end
    end
end)

-- Switch 3: Rainbow Boombox
local BoomboxRainbowConn
CreateSwitchCard(PageRainbow, "Rainbow Boombox", "ลูปเปลี่ยนสี Boombox เรนโบว์ ความเร็ว 100", function(state)
    if state then
        BoomboxRainbowConn = RunService.RenderStepped:Connect(function()
            local hue = (tick() * (RainbowSpeed / 10)) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            pcall(function()
                local Event = LocalPlayer.PlayerGui.ToolGui.ToolSettings.Settings.PropsColor.SetColor
                Event:FireServer(color)
            end)
        end)
    else
        if BoomboxRainbowConn then
            BoomboxRainbowConn:Disconnect()
            BoomboxRainbowConn = nil
        end
    end
end)

-- =====================================================================
-- 👁️ [ESP SYSTEM IMPLEMENTATION] - REAL-TIME TRACERS & THIN WIREFRAME BOX
-- =====================================================================

local ESP_State = {
    Box = false,
    Tracer = false,
    Name = false,
    SelectedPlayer = nil,
    Spectate = false,
    TPLoop = false
}

local ESPBoxes = {}
local ESPCharacterConnections = {}

local function RemoveBoxESP(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Destroy()
        ESPBoxes[player] = nil
    end
end

local function DisconnectBoxCharacter(player)
    if ESPCharacterConnections[player] then
        ESPCharacterConnections[player]:Disconnect()
        ESPCharacterConnections[player] = nil
    end
end

local function ApplyWireframeBox(player)
    if player == LocalPlayer or not ESP_State.Box then return end

    local function CreateBox(character)
        if not ESP_State.Box or not character then return end
        RemoveBoxESP(player)

        local Box = Instance.new("Highlight")
        Box.Name = "StyleKuki_ThinBox"
        Box.FillTransparency = 1
        Box.OutlineTransparency = 0
        Box.OutlineColor = Color3.fromRGB(255, 255, 255)
        Box.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Box.Adornee = character
        Box.Parent = character

        ESPBoxes[player] = Box
    end

    if player.Character then CreateBox(player.Character) end
    DisconnectBoxCharacter(player)
    ESPCharacterConnections[player] = player.CharacterAdded:Connect(function(character)
        if ESP_State.Box then
            task.wait(0.15)
            CreateBox(character)
        end
    end)
end

-- 1. Box ESP Switch (เส้นบางสีขาวครอบตัวผู้เล่น)
CreateSwitchCard(PageESP, "1. Box ESP", "กรอบเส้นบางสีขาวครอบรอบตัวผู้เล่นทุกคน", function(state)
    ESP_State.Box = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do
            ApplyWireframeBox(p)
        end
    else
        for p, _ in pairs(ESPBoxes) do
            RemoveBoxESP(p)
            DisconnectBoxCharacter(p)
        end
        for p, conn in pairs(ESPCharacterConnections) do
            if conn then conn:Disconnect() end
            ESPCharacterConnections[p] = nil
        end
    end
end)

-- 2. Tracer ESP Switch
local Tracers = {}

CreateSwitchCard(PageESP, "2. Tracer Line ESP", "มองเห็นเส้นนำสายตาไปยังตำแหน่งผู้เล่น", function(state)
    ESP_State.Tracer = state
    if not state then
        for _, line in pairs(Tracers) do
            if line then line.Visible = false end
        end
    end
end)

-- 3. Name ESP Switch
CreateSwitchCard(PageESP, "3. Name Tag ESP", "แสดงรายชื่อผู้เล่นลอยอยู่บนหัว", function(state)
    ESP_State.Name = state
end)

-- 4. Player Selector Dropdown Card
local SelectorCard = Instance.new("Frame", PageESP)
SelectorCard.Size = UDim2.new(1, -8, 0, 65)
SelectorCard.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
SelectorCard.BorderSizePixel = 0
Instance.new("UICorner", SelectorCard).CornerRadius = UDim.new(0, 8)

local SelectorStroke = Instance.new("UIStroke", SelectorCard)
SelectorStroke.Color = Color3.fromRGB(35, 40, 55)
SelectorStroke.Thickness = 1

local SelectorTitle = Instance.new("TextLabel", SelectorCard)
SelectorTitle.Size = UDim2.new(1, -10, 0, 16)
SelectorTitle.Position = UDim2.new(0, 10, 0, 6)
SelectorTitle.BackgroundTransparency = 1
SelectorTitle.Text = "4. Select Player Target"
SelectorTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectorTitle.Font = Enum.Font.GothamBold
SelectorTitle.TextSize = 10
SelectorTitle.TextXAlignment = Enum.TextXAlignment.Left

local DropdownBtn = Instance.new("TextButton", SelectorCard)
DropdownBtn.Size = UDim2.new(1, -75, 0, 28)
DropdownBtn.Position = UDim2.new(0, 10, 0, 28)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
DropdownBtn.Text = "  เลือกผู้เล่น..."
DropdownBtn.TextColor3 = Color3.fromRGB(0, 229, 255)
DropdownBtn.Font = Enum.Font.Gotham
DropdownBtn.TextSize = 9
DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", DropdownBtn).CornerRadius = UDim.new(0, 6)

local RefreshBtn = Instance.new("TextButton", SelectorCard)
RefreshBtn.Size = UDim2.new(0, 50, 0, 28)
RefreshBtn.Position = UDim2.new(1, -60, 0, 28)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
RefreshBtn.Text = "รีเฟรช"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 9
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 6)

local DropListFrame = Instance.new("ScrollingFrame", SelectorCard)
DropListFrame.Size = UDim2.new(1, -20, 0, 80)
DropListFrame.Position = UDim2.new(0, 10, 1, 2)
DropListFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
DropListFrame.Visible = false
DropListFrame.ZIndex = 50
DropListFrame.ScrollBarThickness = 2
Instance.new("UICorner", DropListFrame).CornerRadius = UDim.new(0, 6)

local DropListLayout = Instance.new("UIListLayout", DropListFrame)
DropListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function UpdatePlayerList()
    for _, child in ipairs(DropListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", DropListFrame)
            pBtn.Size = UDim2.new(1, 0, 0, 22)
            pBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
            pBtn.Text = "  @" .. p.Name .. " (" .. p.DisplayName .. ")"
            pBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
            pBtn.Font = Enum.Font.Gotham
            pBtn.TextSize = 8
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            pBtn.ZIndex = 51

            pBtn.MouseButton1Click:Connect(function()
                ESP_State.SelectedPlayer = p
                DropdownBtn.Text = "  @" .. p.Name .. " (" .. p.DisplayName .. ")"
                DropListFrame.Visible = false
            end)
        end
    end
    DropListFrame.CanvasSize = UDim2.new(0, 0, 0, DropListLayout.AbsoluteContentSize.Y)
end

DropdownBtn.MouseButton1Click:Connect(function()
    DropListFrame.Visible = not DropListFrame.Visible
    if DropListFrame.Visible then UpdatePlayerList() end
end)

RefreshBtn.MouseButton1Click:Connect(function()
    ESP_State.SelectedPlayer = nil
    DropdownBtn.Text = "  เลือกผู้เล่น..."
    UpdatePlayerList()
end)

-- 5. Spectator Switch
CreateSwitchCard(PageESP, "5. Spectate Target", "ส่องมุมมองกล้องผู้เล่นที่เลือกแบบ Real-time", function(state)
    ESP_State.Spectate = state
    local Camera = workspace.CurrentCamera
    if state and ESP_State.SelectedPlayer and ESP_State.SelectedPlayer.Character then
        local targetHum = ESP_State.SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        if targetHum then Camera.CameraSubject = targetHum end
    else
        if LocalPlayer.Character then
            local myHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHum then Camera.CameraSubject = myHum end
        end
    end
end)

-- 6. TP Loop Switch
CreateSwitchCard(PageESP, "6. TP Loop Target", "วาร์ปติดตัวผู้เล่นที่เลือกแบบถี่ๆ Real-time", function(state)
    ESP_State.TPLoop = state
end)

-- Loop การทำงานของ ESP & TP Loop
local Camera = workspace.CurrentCamera

RunService.RenderStepped:Connect(function()
    -- 1. TP Loop Logic
    if ESP_State.TPLoop and ESP_State.SelectedPlayer and ESP_State.SelectedPlayer.Character then
        local myChar = LocalPlayer.Character
        local targetChar = ESP_State.SelectedPlayer.Character
        if myChar and targetChar and myChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
            myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
        end
    end

    -- 2. Real-time ESP Engine
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                -- Name Tag ESP
                local head = char:FindFirstChild("Head")
                if head then
                    local bgui = head:FindFirstChild("StyleKuki_Name")
                    if ESP_State.Name then
                        if not bgui then
                            bgui = Instance.new("BillboardGui")
                            bgui.Name = "StyleKuki_Name"
                            bgui.Size = UDim2.new(0, 100, 0, 30)
                            bgui.StudsOffset = Vector3.new(0, 2.5, 0)
                            bgui.AlwaysOnTop = true
                            
                            local txt = Instance.new("TextLabel", bgui)
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.Text = "@" .. p.Name .. " (" .. p.DisplayName .. ")"
                            txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                            txt.Font = Enum.Font.GothamBold
                            txt.TextSize = 10
                            bgui.Parent = head
                        end
                    elseif bgui then
                        bgui:Destroy()
                    end
                end

                -- Tracer Line ESP
                if ESP_State.Tracer then
                    if Drawing then
                        if not Tracers[p] then
                            local line = Drawing.new("Line")
                            line.Thickness = 1.5
                            line.Color = Color3.fromRGB(255, 0, 0)
                            line.Transparency = 1
                            Tracers[p] = line
                        end
                        if onScreen then
                            Tracers[p].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            Tracers[p].To = Vector2.new(vector.X, vector.Y)
                            Tracers[p].Visible = true
                        else
                            Tracers[p].Visible = false
                        end
                    end
                else
                    if Tracers[p] then
                        Tracers[p].Visible = false
                    end
                end
            else
                if Tracers[p] then Tracers[p].Visible = false end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    RemoveBoxESP(p)
    DisconnectBoxCharacter(p)
    if Tracers[p] then
        Tracers[p]:Remove()
        Tracers[p] = nil
    end
end)

-- Tab Switch Events (สลับ 7 หมวดหมู่)
local function SwitchTab(activePage, activeTab, activeStroke)
    PageGame.Visible    = (activePage == PageGame)
    PageInfo.Visible    = (activePage == PageInfo)
    PageTools.Visible   = (activePage == PageTools)
    PageCars.Visible    = (activePage == PageCars)
    PageESP.Visible     = (activePage == PageESP)
    PageProtection.Visible = (activePage == PageProtection)
    PageRainbow.Visible = (activePage == PageRainbow)

    local tabs = {
        {TabGame, TabGameStroke}, 
        {TabInfo, TabInfoStroke}, 
        {TabTools, TabToolsStroke},
        {TabCars, TabCarsStroke},
        {TabESP, TabESPStroke},
        {TabProtection, TabProtectionStroke},
        {TabRainbow, TabRainbowStroke}
    }
    for _, item in ipairs(tabs) do
        local btn, stroke = item[1], item[2]
        if btn == activeTab then
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(25, 30, 45), TextColor3 = Color3.fromRGB(0, 229, 255)}):Play()
            stroke.Color = Color3.fromRGB(0, 229, 255)
        else
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(15, 17, 24), TextColor3 = Color3.fromRGB(120, 125, 140)}):Play()
            stroke.Color = Color3.fromRGB(40, 45, 60)
        end
    end
end

TabGame.MouseButton1Click:Connect(function() SwitchTab(PageGame, TabGame, TabGameStroke) end)
TabInfo.MouseButton1Click:Connect(function() SwitchTab(PageInfo, TabInfo, TabInfoStroke) end)
TabTools.MouseButton1Click:Connect(function() SwitchTab(PageTools, TabTools, TabToolsStroke) end)
TabCars.MouseButton1Click:Connect(function() SwitchTab(PageCars, TabCars, TabCarsStroke) end)
TabESP.MouseButton1Click:Connect(function() SwitchTab(PageESP, TabESP, TabESPStroke) end)
TabProtection.MouseButton1Click:Connect(function() SwitchTab(PageProtection, TabProtection, TabProtectionStroke) end)
TabRainbow.MouseButton1Click:Connect(function() SwitchTab(PageRainbow, TabRainbow, TabRainbowStroke) end)

-- 🔑 KEY SYSTEM OVERLAY
local KeyOverlay = Instance.new("Frame", MainFrame)
KeyOverlay.Size = UDim2.new(1, 0, 1, 0)
KeyOverlay.BackgroundColor3 = Color3.fromRGB(8, 9, 13)
KeyOverlay.BackgroundTransparency = 0.02
KeyOverlay.Visible = true
KeyOverlay.ZIndex = 30
Instance.new("UICorner", KeyOverlay).CornerRadius = UDim.new(0, 14)

local CompactKeyCard = Instance.new("Frame", KeyOverlay)
CompactKeyCard.Size = UDim2.new(0, 360, 0, 190)
CompactKeyCard.Position = UDim2.new(0.5, -180, 0.5, -95)
CompactKeyCard.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
CompactKeyCard.ZIndex = 31
Instance.new("UICorner", CompactKeyCard).CornerRadius = UDim.new(0, 12)

local CompactCardStroke = Instance.new("UIStroke", CompactKeyCard)
CompactCardStroke.Color = Color3.fromRGB(40, 45, 60)
CompactCardStroke.Thickness = 1.5

local KeyBadge = Instance.new("Frame", CompactKeyCard)
KeyBadge.Size = UDim2.new(0, 36, 0, 18)
KeyBadge.Position = UDim2.new(0, 110, 0, 18)
KeyBadge.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
KeyBadge.ZIndex = 32
Instance.new("UICorner", KeyBadge).CornerRadius = UDim.new(0, 4)

local KeyBadgeText = Instance.new("TextLabel", KeyBadge)
KeyBadgeText.Size = UDim2.new(1, 0, 1, 0)
KeyBadgeText.BackgroundTransparency = 1
KeyBadgeText.Text = "KEY"
KeyBadgeText.TextColor3 = Color3.fromRGB(200, 205, 220)
KeyBadgeText.Font = Enum.Font.GothamBold
KeyBadgeText.TextSize = 8
KeyBadgeText.ZIndex = 33

local PopupTitle = Instance.new("TextLabel", CompactKeyCard)
PopupTitle.Size = UDim2.new(0, 160, 0, 20)
PopupTitle.Position = UDim2.new(0, 150, 0, 16)
PopupTitle.BackgroundTransparency = 1
PopupTitle.Text = "StyleKuki VIP"
PopupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
PopupTitle.Font = Enum.Font.GothamBold
PopupTitle.TextSize = 13
PopupTitle.TextXAlignment = Enum.TextXAlignment.Left
PopupTitle.ZIndex = 32

local CircleFrame = Instance.new("Frame", CompactKeyCard)
CircleFrame.Size = UDim2.new(0, 75, 0, 75)
CircleFrame.Position = UDim2.new(0, 20, 0, 20)
CircleFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 15)
CircleFrame.ZIndex = 32
Instance.new("UICorner", CircleFrame).CornerRadius = UDim.new(1, 0)

local CircleStroke = Instance.new("UIStroke", CircleFrame)
CircleStroke.Color = Color3.fromRGB(0, 229, 255)
CircleStroke.Thickness = 3

local PercentText = Instance.new("TextLabel", CircleFrame)
PercentText.Size = UDim2.new(1, 0, 0, 24)
PercentText.Position = UDim2.new(0, 0, 0.28, 0)
PercentText.BackgroundTransparency = 1
PercentText.Text = "LOCK"
PercentText.TextColor3 = Color3.fromRGB(255, 255, 255)
PercentText.Font = Enum.Font.GothamBold
PercentText.TextSize = 12
PercentText.ZIndex = 33

local StatusSubText = Instance.new("TextLabel", CircleFrame)
StatusSubText.Size = UDim2.new(1, 0, 0, 12)
StatusSubText.Position = UDim2.new(0, 0, 0.60, 0)
StatusSubText.BackgroundTransparency = 1
StatusSubText.Text = "VERIFYING"
StatusSubText.TextColor3 = Color3.fromRGB(120, 125, 140)
StatusSubText.Font = Enum.Font.GothamMedium
StatusSubText.TextSize = 7
StatusSubText.ZIndex = 33

local KeySub = Instance.new("TextLabel", CompactKeyCard)
KeySub.Size = UDim2.new(0, 200, 0, 16)
KeySub.Position = UDim2.new(0, 110, 0, 42)
KeySub.BackgroundTransparency = 1
KeySub.Text = "Please enter key..."
KeySub.TextColor3 = Color3.fromRGB(140, 145, 160)
KeySub.Font = Enum.Font.Gotham
KeySub.TextSize = 9
KeySub.TextXAlignment = Enum.TextXAlignment.Left
KeySub.ZIndex = 32

local KeyInputBox = Instance.new("TextBox", CompactKeyCard)
KeyInputBox.Size = UDim2.new(0, 230, 0, 26)
KeyInputBox.Position = UDim2.new(0, 110, 0, 65)
KeyInputBox.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
KeyInputBox.Text = ""
KeyInputBox.PlaceholderText = "Enter Access Key..."
KeyInputBox.PlaceholderColor3 = Color3.fromRGB(80, 85, 100)
KeyInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInputBox.Font = Enum.Font.GothamMedium
KeyInputBox.TextSize = 9
KeyInputBox.ClearTextOnFocus = false
KeyInputBox.ZIndex = 32
Instance.new("UICorner", KeyInputBox).CornerRadius = UDim.new(0, 6)

local KeyInputStroke = Instance.new("UIStroke", KeyInputBox)
KeyInputStroke.Color = Color3.fromRGB(0, 229, 255)
KeyInputStroke.Thickness = 1
KeyInputStroke.Transparency = 0.5

local CheckKeyBtn = Instance.new("TextButton", CompactKeyCard)
CheckKeyBtn.Size = UDim2.new(0, 230, 0, 26)
CheckKeyBtn.Position = UDim2.new(0, 110, 0, 98)
CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
CheckKeyBtn.Text = "UNLOCK SYSTEM"
CheckKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckKeyBtn.Font = Enum.Font.GothamBold
CheckKeyBtn.TextSize = 9
CheckKeyBtn.ZIndex = 32
Instance.new("UICorner", CheckKeyBtn).CornerRadius = UDim.new(0, 6)

local CheckBtnGradient = Instance.new("UIGradient", CheckKeyBtn)
CheckBtnGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 200))
}

local VisContainer = Instance.new("Frame", CompactKeyCard)
VisContainer.Size = UDim2.new(0, 320, 0, 20)
VisContainer.Position = UDim2.new(0, 20, 0, 145)
VisContainer.BackgroundTransparency = 1
VisContainer.ZIndex = 32

local VisLayout = Instance.new("UIListLayout", VisContainer)
VisLayout.FillDirection = Enum.FillDirection.Horizontal
VisLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
VisLayout.VerticalAlignment = Enum.VerticalAlignment.Center
VisLayout.Padding = UDim.new(0, 3)

for i = 1, 24 do
    local Bar = Instance.new("Frame", VisContainer)
    Bar.Size = UDim2.new(0, 3, 0, math.random(4, 16))
    Bar.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 33
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 2)
    
    task.spawn(function()
        while Bar and Bar.Parent do
            TweenService:Create(Bar, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 3, 0, math.random(3, 18))
            }):Play()
            task.wait(0.18)
        end
    end)
end

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

-- ==================== ⚡ COQUETTE HUB STYLE LOADING SYSTEM (1-100% 3D NEON) ====================
local LoadingOverlay = Instance.new("Frame", MainFrame)
LoadingOverlay.Size = UDim2.new(1, 0, 1, 0)
LoadingOverlay.BackgroundColor3 = Color3.fromRGB(8, 9, 13)
LoadingOverlay.BackgroundTransparency = 0.02
LoadingOverlay.Visible = false
LoadingOverlay.ZIndex = 40
Instance.new("UICorner", LoadingOverlay).CornerRadius = UDim.new(0, 14)

local LoadCard = Instance.new("Frame", LoadingOverlay)
LoadCard.Size = UDim2.new(0, 360, 0, 190)
LoadCard.Position = UDim2.new(0.5, -180, 0.5, -95)
LoadCard.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
LoadCard.ZIndex = 41
Instance.new("UICorner", LoadCard).CornerRadius = UDim.new(0, 12)

local LoadCardStroke = Instance.new("UIStroke", LoadCard)
LoadCardStroke.Color = Color3.fromRGB(0, 229, 255)
LoadCardStroke.Thickness = 1.5

local LoadCircleFrame = Instance.new("Frame", LoadCard)
LoadCircleFrame.Size = UDim2.new(0, 75, 0, 75)
LoadCircleFrame.Position = UDim2.new(0, 20, 0, 20)
LoadCircleFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 15)
LoadCircleFrame.ZIndex = 42
Instance.new("UICorner", LoadCircleFrame).CornerRadius = UDim.new(1, 0)

local LoadCircleStroke = Instance.new("UIStroke", LoadCircleFrame)
LoadCircleStroke.Color = Color3.fromRGB(0, 229, 255)
LoadCircleStroke.Thickness = 3

local LoadPercentText = Instance.new("TextLabel", LoadCircleFrame)
LoadPercentText.Size = UDim2.new(1, 0, 0, 24)
LoadPercentText.Position = UDim2.new(0, 0, 0.28, 0)
LoadPercentText.BackgroundTransparency = 1
LoadPercentText.Text = "0%"
LoadPercentText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadPercentText.Font = Enum.Font.GothamBold
LoadPercentText.TextSize = 12
LoadPercentText.ZIndex = 43

local LoadSubText = Instance.new("TextLabel", LoadCircleFrame)
LoadSubText.Size = UDim2.new(1, 0, 0, 12)
LoadSubText.Position = UDim2.new(0, 0, 0.60, 0)
LoadSubText.BackgroundTransparency = 1
LoadSubText.Text = "CARREGANDO"
LoadSubText.TextColor3 = Color3.fromRGB(0, 229, 255)
LoadSubText.Font = Enum.Font.GothamMedium
LoadSubText.TextSize = 6
LoadSubText.ZIndex = 43

local LoadBadge = Instance.new("Frame", LoadCard)
LoadBadge.Size = UDim2.new(0, 36, 0, 18)
LoadBadge.Position = UDim2.new(0, 110, 0, 18)
LoadBadge.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
LoadBadge.ZIndex = 42
Instance.new("UICorner", LoadBadge).CornerRadius = UDim.new(0, 4)

local LoadBadgeText = Instance.new("TextLabel", LoadBadge)
LoadBadgeText.Size = UDim2.new(1, 0, 1, 0)
LoadBadgeText.BackgroundTransparency = 1
LoadBadgeText.Text = "RUN"
LoadBadgeText.TextColor3 = Color3.fromRGB(0, 229, 255)
LoadBadgeText.Font = Enum.Font.GothamBold
LoadBadgeText.TextSize = 8
LoadBadgeText.ZIndex = 43

local RunningScriptName = Instance.new("TextLabel", LoadCard)
RunningScriptName.Size = UDim2.new(0, 200, 0, 20)
RunningScriptName.Position = UDim2.new(0, 150, 0, 16)
RunningScriptName.BackgroundTransparency = 1
RunningScriptName.Text = "Script Name"
RunningScriptName.TextColor3 = Color3.fromRGB(255, 255, 255)
RunningScriptName.Font = Enum.Font.GothamBold
RunningScriptName.TextSize = 10
RunningScriptName.TextXAlignment = Enum.TextXAlignment.Left
RunningScriptName.TextTruncate = Enum.TextTruncate.AtEnd
RunningScriptName.ZIndex = 42

local SubStatusLabel = Instance.new("TextLabel", LoadCard)
SubStatusLabel.Size = UDim2.new(0, 200, 0, 16)
SubStatusLabel.Position = UDim2.new(0, 110, 0, 40)
SubStatusLabel.BackgroundTransparency = 1
SubStatusLabel.Text = "Aguardando o hub carregar..."
SubStatusLabel.TextColor3 = Color3.fromRGB(140, 145, 160)
SubStatusLabel.Font = Enum.Font.Gotham
SubStatusLabel.TextSize = 9
SubStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
SubStatusLabel.ZIndex = 42

local LoadTrack = Instance.new("Frame", LoadCard)
LoadTrack.Size = UDim2.new(0, 230, 0, 8)
LoadTrack.Position = UDim2.new(0, 110, 0, 68)
LoadTrack.BackgroundColor3 = Color3.fromRGB(22, 25, 36)
LoadTrack.BorderSizePixel = 0
LoadTrack.ZIndex = 42
Instance.new("UICorner", LoadTrack).CornerRadius = UDim.new(0, 4)

local LoadFill = Instance.new("Frame", LoadTrack)
LoadFill.Size = UDim2.new(0, 0, 1, 0)
LoadFill.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
LoadFill.BorderSizePixel = 0
LoadFill.ZIndex = 43
Instance.new("UICorner", LoadFill).CornerRadius = UDim.new(0, 4)

local LoadFillGradient = Instance.new("UIGradient", LoadFill)
LoadFillGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(138, 43, 226)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 200))
}

local LoadVisContainer = Instance.new("Frame", LoadCard)
LoadVisContainer.Size = UDim2.new(0, 320, 0, 20)
LoadVisContainer.Position = UDim2.new(0, 20, 0, 140)
LoadVisContainer.BackgroundTransparency = 1
LoadVisContainer.ZIndex = 42

local LoadVisLayout = Instance.new("UIListLayout", LoadVisContainer)
LoadVisLayout.FillDirection = Enum.FillDirection.Horizontal
LoadVisLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
LoadVisLayout.VerticalAlignment = Enum.VerticalAlignment.Center
LoadVisLayout.Padding = UDim.new(0, 3)

for i = 1, 24 do
    local Bar = Instance.new("Frame", LoadVisContainer)
    Bar.Size = UDim2.new(0, 3, 0, math.random(4, 16))
    Bar.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 43
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 2)
    
    task.spawn(function()
        while Bar and Bar.Parent do
            TweenService:Create(Bar, TweenInfo.new(0.18), {
                Size = UDim2.new(0, 3, 0, math.random(3, 18))
            }):Play()
            task.wait(0.16)
        end
    end)
end

local function ExecuteWithCoquetteLoading(scriptUrl, scriptName, displayThaiName)
    RunningScriptName.Text = "กำลังรันสคริปต์: " .. displayThaiName
    LoadPercentText.Text = "0%"
    LoadFill.Size = UDim2.new(0, 0, 1, 0)
    LoadingOverlay.Visible = true

    for i = 1, 100 do
        LoadFill.Size = UDim2.new(i / 100, 0, 1, 0)
        LoadPercentText.Text = i .. "%"
        task.wait(0.008)
    end

    task.wait(0.15)
    LoadingOverlay.Visible = false
    RunScript(scriptUrl, scriptName)
end

-- 1. ปุ่มรันสคริปต์ดึงเพลง (หมวดหมู่ 1 ปุ่ม 1)
RunBtn1.MouseButton1Click:Connect(function()
    ExecuteWithCoquetteLoading("https://raw.githubusercontent.com/kfcth5171/90/refs/heads/main/006.lua", "Audio Logger System", "ดึงเพลง By.Honkuki")
end)

RunBtn2.MouseButton1Click:Connect(function()
    ExecuteWithCoquetteLoading("https://raw.githubusercontent.com/RVXv2/RVX-hub/main/main.lua", "Script by AVX HUB", "AVX HUB")
end)

RunBtn3.MouseButton1Click:Connect(function()
    ExecuteWithCoquetteLoading("https://rawscripts.net/raw/Brookhaven-RP-Coquette-Hub-Remake-133562", "Coquette Hub Remake", "Coquette Hub Remake")
end)
