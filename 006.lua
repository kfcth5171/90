-- =====================================================================
-- [[ HONKUKI AUDIO LOGGER & DUMPER - ULTIMATE 3D VIP EDITION ]] --
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
    ["99721399503975"] = true,
    ["00101020203030404"] = true, ["00112233445566778"] = true,
    ["00123456789012345"] = true, ["00135791357913579"] = true,
    ["00159260374815926"] = true, ["00246802468024680"] = true,
    ["00405060708090001"] = true, ["00543210987654321"] = true,
    ["00731959731959731"] = true, ["00864208642086420"] = true,
    ["00887766554433221"] = true, ["00975319753197531"] = true,
    ["00987654321098765"] = true, ["00998877665544332"] = true,
    ["129569049476734"] = true, ["81067084464165"] = true,
    ["00159837264918375"] = true, ["115897193508594"] = true, ["123728962822472"] = true,
    ["0106800577264015"] = true, ["0090308298517537"] = true, ["0082763296909782"] = true,
    ["001487259163048"] = true, ["00984317620519"] = true, ["001320598471652"] = true,
    ["007659184302781"] = true, ["00971542086317"] = true, ["001563908247615"] = true,
    ["00821475390648"] = true, ["001145739628405"] = true, ["007482051963147"] = true,
    ["00938627541052"] = true, ["008719452861439"] = true, ["00153682974105"] = true,
    ["009417285603187"] = true, ["0072849156380"] = true, ["001865942713084"] = true,
    ["0092541768309"] = true, ["001174926580315"] = true, ["0084617295306"] = true,
    ["001938571462098"] = true, ["0056714928306"] = true, ["001692847513894"] = true,
    ["0085142976031"] = true, ["009741638259047"] = true, ["0024819573608"] = true,
    ["001780564921835"] = true, ["00659274185609"] = true, ["00841679520841"] = true,
    ["001295841760392"] = true, ["00571486925071"] = true, ["001985271640958"] = true,
    ["0014796528174059"] = true, ["0087415926804"] = true, ["001927845160984"] = true,
    ["0052641879502"] = true, ["001895714628051"] = true, ["0095168427095"] = true,
    ["002174958613047"] = true, ["0086294751806"] = true, ["001358074926185"] = true,
    ["0098461752908"] = true,
    ["106800577264015"] = true, ["90308298517537"] = true, ["82763296909782"] = true,
    ["1487259163048"] = true, ["984317620519"] = true, ["1320598471652"] = true,
    ["7659184302781"] = true, ["971542086317"] = true, ["1563908247615"] = true,
    ["821475390648"] = true, ["1145739628405"] = true, ["7482051963147"] = true,
    ["938627541052"] = true, ["8719452861439"] = true, ["153682974105"] = true,
    ["9417285603187"] = true, ["72849156380"] = true, ["1865942713084"] = true,
    ["92541768309"] = true, ["1174926580315"] = true, ["84617295306"] = true,
    ["1938571462098"] = true, ["56714928306"] = true, ["1692847513894"] = true,
    ["85142976031"] = true, ["9741638259047"] = true, ["24819573608"] = true,
    ["1780564921835"] = true, ["659274185609"] = true, ["841679520841"] = true,
    ["1295841760392"] = true, ["571486925071"] = true, ["1985271640958"] = true,
    ["14796528174059"] = true, ["87415926804"] = true, ["1927845160984"] = true,
    ["52641879502"] = true, ["1895714628051"] = true, ["95168427095"] = true,
    ["2174958613047"] = true, ["86294751806"] = true, ["1358074926185"] = true,
    ["98461752908"] = true,
    ["520268273928362"] = true, ["726381937273927"] = true,
    ["828283747362837"] = true, ["822873728182728"] = true,
    ["916392946194817"] = true, ["323466748315842"] = true,
    ["277364728273297"] = true, ["188273627276327"] = true,
    ["362783746382823"] = true, ["717263536173739"] = true,
    ["71726353617373"]  = true, ["235408273918271"] = true,
    ["5678904826695139"] = true, ["0123415962284074"] = true,
    ["4027895317706428"] = true, ["1956362703348153"] = true,
    ["2834037149950260"] = true, ["33786926931174059"] = true,
    ["7402180465529731"] = true, ["6319548620017395"] = true,
    ["8135709247763587"] = true, ["9240651784430966"] = true,
    ["24213056027674"]   = true, ["543334512086734"] = true,
    ["262185420860413"]  = true, ["137434811238124"] = true,
    ["400070907684669374"] = true, ["7251328351"] = true,
    ["1885881335441"] = true, ["9972"] = true, ["1399503975"] = true,
    ["98989868891534"] = true, ["04761075"] = true, ["19559141331210"] = true,
    ["97167526395722"] = true, ["00135717653489469"] = true,
    ["00117978901016225"] = true, ["00131120650233515"] = true,
    ["0078490779676864"] = true, ["00117218102929740"] = true,
    ["0094252516016921"] = true, ["00136038459746844"] = true,
    ["00139822448198319"] = true, ["0070713244695741"] = true,
    ["72034120547897"] = true, ["112052998244603"] = true,
    ["0098255111051273"] = true, ["0094641125562624"] = true,
    ["0088288669346964"] = true, ["00105865479058889"] = true,
    ["97254689160075"] = true, ["122396455391746"] = true,
    ["00131424277232086"] = true, ["0075803753062002"] = true,
    ["00111672619544063"] = true, ["0073368804709511"] = true,
    ["0079081439699719"] = true, ["112304110902021"] = true,
    ["86747216886858"] = true, ["115703625280167"] = true,
    ["71888511332145"] = true, ["0095777599051645"] = true,
    ["0096986144648971"] = true, ["0097814679309386"] = true,
    ["00125754236775831"] = true, ["00117270024340473"] = true,
    ["0093368365346019"] = true, ["00110230276570667"] = true,
    ["00126849958062666"] = true, ["00119215996902118"] = true,
    ["0092024219036595"] = true, ["0096956767904014"] = true,
    ["00131832663605571"] = true, ["00124108858982827"] = true,
    ["00100792843330236"] = true, ["75818865124123"] = true,
    ["81077586198430"] = true, ["123771703997621"] = true,
    ["90634248855281"] = true, ["137632553110798"] = true,
    ["0013603845"] = true, ["00116795644452053"] = true,
    ["0087506925032199"] = true, ["00114854729127123"] = true,
    ["0090543954744950"] = true, ["00130372250847248"] = true,
    ["00132565074561820"] = true, ["0083370097021520"] = true,
    ["0080728009566180"] = true, ["00113578921715175"] = true,
    ["0019006509949"] = true, ["0096774521681190"] = true,
    ["00135159509633580"] = true, ["0087473955499107"] = true,
    ["0083056197503510"] = true, ["00104007943345258"] = true,
    ["00138058631419886"] = true, ["0082791323516669"] = true,
    ["00122209668269742"] = true,
    ["00651180925541685"] = true,
    ["0052315987524169"] = true,
    ["00123568751245557"] = true,
    ["00965488877651295"] = true,
    ["008106708446416535"] = true,
    ["123728962822472"] = true,
    ["122929786531506"] = true,
    ["140497415402103"] = true,
    ["00120104871360327"] = true,
    ["00129060362076134"] = true,
    ["117871196330268"] = true,
    ["137555839480738"] = true,
    ["101631982347841"] = true,
    ["115819698454027"] = true,
    ["116331922770563"] = true,
    ["134216333534795"] = true,
    ["112210298860778"] = true,
    ["120313493879944"] = true,
    ["117391349741339"] = true,
    ["7"] = true,
    ["00"] = true,
    ["9"] = true,
    ["0083260119948695"] = true,
    ["00109462618039650"] = true,
    ["0093932829347443"] = true,
    ["00106800577264015"] = true,
    ["00117628371363749"] = true,
    ["0083848201981900"] = true,
    ["00134076916421685"] = true,
    ["00116872955970254"] = true,
    ["00129043827992035"] = true,
    ["00137058099826867"] = true,
    ["00121320825772761"] = true,
    ["0083681471562121"] = true,
    ["00134523838494464"] = true,
    ["00138763959207625"] = true,
    ["00113841533670628"] = true,
    ["0070567654933546"] = true,
    ["00117424747387525"] = true,
    ["00112583972042063"] = true,
    ["0079688020178596"] = true,
    ["00125329595131078"] = true,
    ["0093338918256962"] = true,
    ["115897193508594"] = true,
    ["0090308297517537"] = true,
    ["0082763296909182"] = true,
    ["0059274185609"] = true,
    ["0041679520841"] = true,
    ["00195841760392"] = true,
    ["0051486925071"] = true,
    ["00185271640958"] = true,
    ["005796528174059"] = true,
    ["005415926804"] = true,
    ["00527845160984"] = true,
    ["005641879502"] = true,
    ["005168427095"] = true,
    ["00358074926185"] = true,
    ["008461752908"] = true,
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

-- ⚡ SOUND SCANNER (เพิ่มการยกเว้นตามสั่ง)
local function checkPlayerAllSounds(targetPlayer)
    if not targetPlayer then return {} end
    
    if isAdmin(targetPlayer) and not isAdmin(LocalPlayer) then
        return {}
    end

    local scanTargets = {}
    if targetPlayer.Character then table.insert(scanTargets, targetPlayer.Character) end
    local backpack = targetPlayer:FindFirstChild("Backpack")
    if backpack then table.insert(scanTargets, backpack) end
    local vehicle = getPlayerVehicle(targetPlayer)
    if vehicle then table.insert(scanTargets, vehicle) end

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            local lowerName = string.lower(obj.Name)
            if string.find(lowerName, "sled") or string.find(lowerName, "scooter") or string.find(lowerName, "vehicle") or string.find(lowerName, "bike") or string.find(lowerName, "car") then
                local ownerVal = obj:FindFirstChild("Owner") or obj:FindFirstChild("Player") or obj:FindFirstChild("VehicleOwner")
                local isOwner = ownerVal and (ownerVal.Value == targetPlayer or ownerVal.Value == targetPlayer.Name)
                
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
    
    -- 🛑 BLACKLIST ตามสั่งแบบเป๊ะๆ
    local NameBlacklist = { 
        ["gettingup"] = true, ["died"] = true, ["freefalling"] = true, 
        ["jumping"] = true, ["landing"] = true, ["running"] = true, 
        ["water"] = true, ["footstep"] = true,
        ["fart1"] = true, ["climbing"] = true,
        ["swimming"] = true, ["splash"] = true
    }

    for _, folder in ipairs(scanTargets) do
        local success, descendants = pcall(function() return folder:GetDescendants() end)
        if success and descendants then
            for _, obj in ipairs(descendants) do
                if obj:IsA("Sound") and obj.SoundId ~= "" then
                    local objNameLower = string.lower(obj.Name)
                    local fullNameLower = string.lower(obj:GetFullName())
                    local soundIdLower = string.lower(obj.SoundId)

                    local isBlacklisted = false

                    -- เช็คชื่อทั่วไป
                    for blockedName, _ in pairs(NameBlacklist) do
                        if string.find(objNameLower, blockedName) then
                            isBlacklisted = true
                            break
                        end
                    end

                    -- เช็คเคสเจาะจงตามสั่ง (เพิ่มการบล็อกทางผ่านทั้ง 4 รายการ)
                    if not isBlacklisted then
                        if string.find(fullNameLower, "minions2026_fartgun") or
                           string.find(fullNameLower, "nomotorvehiclemodel.middle.sound") or
                           string.find(soundIdLower, "action_footsteps_plastic") or
                           string.find(fullNameLower, "flashlight.handle.toggle") or
                           string.find(fullNameLower, "nomotorvehiclemodel.middle.engine") or
                           string.find(fullNameLower, "handheldfan.handle.open_sound") or
                           string.find(fullNameLower, "handheldfan.handle.fanclose_sound") or
                           string.find(fullNameLower, "moneygun.lefthand.althandle.activate") or
                           string.find(fullNameLower, "workspace.head.crying") or
                           string.find(fullNameLower, "electricguitar.handle.sound") then
                            
                           isBlacklisted = true
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
Title.Text = "✨ HONKUKI AUDIO LOGGER EIEI"
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

local GetIDBtn = create3DButton(ButtonsContainer, "⚡ เจาะไอดีเพลง", Color3.fromRGB(210, 160, 0))
local GetJunkBtn = create3DButton(ButtonsContainer, "🎵 ยิงเปิดเพลงตามplayer", Color3.fromRGB(160, 100, 220))
local ListenToggleBtn = create3DButton(ButtonsContainer, "🎧 ฟังเพลงส่วนตัว (Volume 80%)", Color3.fromRGB(0, 140, 220))
local ViewRawJunkBtn = create3DButton(ButtonsContainer, "👁️ ดูขยะplayer", Color3.fromRGB(40, 45, 60))
local ViewInstantBtn = create3DButton(ButtonsContainer, "🔍 ดู ID ที่เจาะมา", Color3.fromRGB(40, 45, 60))

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

-- ==================== SECONDARY JUNK & LOG VIEWER UI ====================
local JunkFrame = Instance.new("Frame", MainFrame)
JunkFrame.Size = UDim2.new(1, 0, 1, 0)
JunkFrame.Position = UDim2.new(0, 0, 0, 0)
JunkFrame.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
JunkFrame.Visible = false
JunkFrame.ZIndex = 10
Instance.new("UICorner", JunkFrame).CornerRadius = UDim.new(0, 14)

local JunkTitle = Instance.new("TextLabel", JunkFrame)
JunkTitle.Size = UDim2.new(0.9, 0, 0, 30)
JunkTitle.Position = UDim2.new(0, 15, 0, 6)
JunkTitle.BackgroundTransparency = 1
JunkTitle.Text = "RAW JUNK VIEWER"
JunkTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
JunkTitle.Font = Enum.Font.GothamBold
JunkTitle.TextSize = 12
JunkTitle.TextXAlignment = Enum.TextXAlignment.Left
JunkTitle.ZIndex = 11

local JunkScroll = Instance.new("ScrollingFrame", JunkFrame)
JunkScroll.Size = UDim2.new(0.94, 0, 0.72, 0)
JunkScroll.Position = UDim2.new(0.03, 0, 0.13, 0)
JunkScroll.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
JunkScroll.ScrollBarThickness = 6
JunkScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
JunkScroll.ZIndex = 11
JunkScroll.ScrollingDirection = Enum.ScrollingDirection.Y
JunkScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", JunkScroll).CornerRadius = UDim.new(0, 8)

local JunkListLayout = Instance.new("UIListLayout", JunkScroll)
JunkListLayout.SortOrder = Enum.SortOrder.LayoutOrder
JunkListLayout.Padding = UDim.new(0, 4)

JunkListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    JunkScroll.CanvasSize = UDim2.new(0, 0, 0, JunkListLayout.AbsoluteContentSize.Y + 10)
end)

local JunkCopyBtn = create3DButton(JunkFrame, "📋 คัดลอกข้อมูล", Color3.fromRGB(0, 160, 100))
JunkCopyBtn.Size = UDim2.new(0.45, 0, 0, 28)
JunkCopyBtn.Position = UDim2.new(0.03, 0, 0.87, 0)
JunkCopyBtn.ZIndex = 12

local JunkBackBtn = create3DButton(JunkFrame, "⬅️ ย้อนกลับ", Color3.fromRGB(200, 50, 60))
JunkBackBtn.Size = UDim2.new(0.45, 0, 0, 28)
JunkBackBtn.Position = UDim2.new(0.52, 0, 0.87, 0)
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

local lastFullStringForCopy = ""

local function updateJunkViewerLive()
    if not JunkFrame.Visible or not CurrentSelectedPlayer then return end
    local targetPlayer = Players:FindFirstChild(CurrentSelectedPlayer.Name)
    if not targetPlayer then return end

    local soundObjects = checkPlayerAllSounds(targetPlayer)
    
    for _, child in ipairs(JunkScroll:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local fullRawText = ""

    if CurrentViewMode == 1 then
        JunkTitle.Text = "RAW JUNK VIEWER (แสดงขยะดิบเต็มระบบ)"
        if #soundObjects == 0 then
            fullRawText = "❌ ไม่พบออบเจกต์เสียงบนตัวผู้เล่นนี้"
        else
            local chunks = {}
            for i, obj in ipairs(soundObjects) do
                table.insert(chunks, string.format("[%d] ออบเจกต์: %s\nRAW DATA: %s\n", i, obj:GetFullName(), tostring(obj.SoundId)))
            end
            fullRawText = table.concat(chunks, "\n")
        end
    elseif CurrentViewMode == 2 then
        JunkTitle.Text = "INSTANT LOG VIEWER (ID เจาะสดเต็มระบบ)"
        if #soundObjects == 0 then
            fullRawText = "❌ ไม่พบค่าเพลงของผู้เล่นนี้"
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
                fullRawText = "❌ ไม่พบ ID เพลงจริงอยู่ข้างใน"
            else
                local chunks = { "--- พบบทเพลงเจาะสำเร็จทั้งหมด " .. #finalIds .. " ID ---" }
                for idx, id in ipairs(finalIds) do
                    table.insert(chunks, string.format("[%d] ID เจาะได้: %s", idx, id))
                end
                fullRawText = table.concat(chunks, "\n")
            end
        end
    end

    lastFullStringForCopy = fullRawText

    local CHUNK_SIZE = 200
    local textLength = #fullRawText

    if textLength == 0 then return end

    task.spawn(function()
        for i = 1, textLength, CHUNK_SIZE do
            if not JunkFrame.Visible then break end
            
            local chunkText = string.sub(fullRawText, i, i + CHUNK_SIZE - 1)
            local label = Instance.new("TextLabel", JunkScroll)
            label.Size = UDim2.new(1, -10, 0, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(200, 220, 255)
            label.Font = Enum.Font.Code
            label.TextSize = 10
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Top
            label.TextWrapped = true
            label.AutomaticSize = Enum.AutomaticSize.Y
            label.Text = chunkText
            label.ZIndex = 12
            
            if (i / CHUNK_SIZE) % 50 == 0 then
                task.wait()
            end
        end
    end)
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
    if lastFullStringForCopy ~= "" then 
        copyToClipboard(lastFullStringForCopy)
        StatusLabel.Text = "📋 คัดลอกข้อมูลลง คลิปบอร์ด แล้ว!"
    end
end)

JunkBackBtn.MouseButton1Click:Connect(function() JunkFrame.Visible = false end)

-- ⚡ SMOOTH BACKGROUND THREAD
task.spawn(function()
    while true do
        task.wait(2)
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
