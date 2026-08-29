-- [[ WORM-SEGAGA 22.0 : ULTRA MOBILE CUSTOM UI ]] --
-- [[ CREDIT: แกล้งคน By Hon 😈 ]] --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local whitelist = {}
local active = false

-- [[ Remote References ]] --
local re1 = ReplicatedStorage:WaitForChild("RE", 5) and ReplicatedStorage.RE:WaitForChild("1Playe1rTrigge1rEven1t", 5)
local re2 = ReplicatedStorage:WaitForChild("RE", 5) and ReplicatedStorage.RE:WaitForChild("1Clea1rTool1s", 5)

local function GetNil(Name, DebugId)
    if getnilinstances then
        for _, Object in pairs(getnilinstances()) do
            if Object.Name == Name and Object:GetDebugId() == DebugId then
                return Object
            end
        end
    end
    return nil
end

-- [[ Logic Core : กวาดล้างระดับพระเจ้า ]] --
local function ExecuteWipe()
    -- Remote เพิ่มเติม 1: QuickDelete จาก getnilinstances
    local nilEvent = GetNil("QuickDelete", "1_49091517")
    if nilEvent then
        pcall(function() nilEvent:FireServer() end)
    end

    -- Remote เพิ่มเติม 2: Direct ClearAllTools
    if re2 then
        pcall(function() re2:FireServer("ClearAllTools") end)
    end

    -- Remotes เดิม
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and not whitelist[p.Name] and p.Character then
            local tool = p.Character:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function()
                    if re1 then re1:FireServer("AcceptedToolToServer", tool.Name, p) end
                    if re2 then re2:FireServer("ClearAllTools") end
                end)
            end
        end
    end
end

-- [[ Infinite Wipe Loop ]] --
RunService.Heartbeat:Connect(function()
    if active then
        ExecuteWipe()
    end
end)

-- [[ Custom Ultra Smooth UI Creation ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WormSegagaUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

-- Main Frame (ปรับสเกลพอดีมือถือ)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.42, 0, 0.52, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Parent = ScreenGui

local AspectConstraint = Instance.new("UIAspectRatioConstraint")
AspectConstraint.AspectRatio = 1.3
AspectConstraint.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- LED RGB Border Effect
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2.5
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 128)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0, 230, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 128)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 230, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 128))
})
UIGradient.Parent = UIStroke

task.spawn(function()
    while true do
        UIGradient.Rotation = (UIGradient.Rotation + 2) % 360
        task.wait(0.02)
    end
end)

-- Header Title
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, 0, 0.18, 0)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Header.Text = "แกล้งคน By Hon | WORM 22.0 ⚡"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.TextSize = 14
Header.Font = Enum.Font.GothamBold
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- Control Container
local Container = Instance.new("Frame")
Container.Size = UDim2.new(0.9, 0, 0.75, 0)
Container.Position = UDim2.new(0.05, 0, 0.2, 0)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)
UIList.Parent = Container

-- Wipe Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 0.28, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
ToggleBtn.Text = "🔥 เปิดใช้งานการกวาดล้าง : OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ToggleBtn.Font = Enum.Font.GothamSemibold
ToggleBtn.TextSize = 12
ToggleBtn.Parent = Container

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    active = not active
    if active then
        ToggleBtn.Text = "🔥 เปิดใช้งานการกวาดล้าง : ON (GOD SPEED)"
        TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 180, 120), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    else
        ToggleBtn.Text = "🔥 เปิดใช้งานการกวาดล้าง : OFF"
        TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 55), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
    end
end)

-- Scroll Whitelist Section
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 0.68, 0)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Container

local ScrollList = Instance.new("UIListLayout")
ScrollList.SortOrder = Enum.SortOrder.LayoutOrder
ScrollList.Padding = UDim.new(0, 5)
ScrollList.Parent = Scroll

local function AddPlayerUI(p)
    if p == player then return end
    local PItem = Instance.new("TextButton")
    PItem.Name = p.Name
    PItem.Size = UDim2.new(0.98, 0, 0, 28)
    PItem.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    PItem.Text = "  🛡️ " .. p.Name .. " [❌ Unwhitelisted]"
    PItem.TextColor3 = Color3.fromRGB(180, 180, 180)
    PItem.TextXAlignment = Enum.TextXAlignment.Left
    PItem.Font = Enum.Font.Gotham
    PItem.TextSize = 11
    PItem.Parent = Scroll

    local ItemCorner = Instance.new("UICorner")
    ItemCorner.CornerRadius = UDim.new(0, 6)
    ItemCorner.Parent = PItem

    PItem.MouseButton1Click:Connect(function()
        whitelist[p.Name] = not whitelist[p.Name]
        if whitelist[p.Name] then
            PItem.Text = "  🛡️ " .. p.Name .. " [✅ Whitelisted]"
            TweenService:Create(PItem, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 85, 125), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            PItem.Text = "  🛡️ " .. p.Name .. " [❌ Unwhitelisted]"
            TweenService:Create(PItem, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 42), TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do AddPlayerUI(p) end
Players.PlayerAdded:Connect(AddPlayerUI)
Players.PlayerRemoving:Connect(function(p)
    whitelist[p.Name] = nil
    local item = Scroll:FindFirstChild(p.Name)
    if item then item:Destroy() end
end)

-- [[ Floating Ultra Smooth Toggle Button (ปุ่มเปิด-ปิด UI) ]] --
local ToggleUIBtn = Instance.new("TextButton")
ToggleUIBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleUIBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleUIBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ToggleUIBtn.Text = "⚡"
ToggleUIBtn.TextSize = 20
ToggleUIBtn.Parent = ScreenGui
ToggleUIBtn.Active = true
ToggleUIBtn.Draggable = true

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleUIBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2
ToggleStroke.Color = Color3.fromRGB(0, 230, 255)
ToggleStroke.Parent = ToggleUIBtn

local uiVisible = true
ToggleUIBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    if uiVisible then
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0.42, 0, 0.52, 0)
        }):Play()
    else
        local tw = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        tw:Play()
        tw.Completed:Connect(function()
            if not uiVisible then MainFrame.Visible = false end
        end)
    end
end)

print("--------------------------------------")
print("WORM-SEGAGA 22.0 : LOADED SUCCESS")
print("AUTHOR: แกล้งคน By Hon 😈⚡")
print("--------------------------------------")
