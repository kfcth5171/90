-- =====================================================================
-- ระบบป้องกันการ Dump / Hook เบื้องต้นในโค้ด Lua
-- =====================================================================

-- 1. ตรวจจับว่าเครื่องนี้มีฟังก์ชันสำหรับดักจับหรือถอดรหัสระดับสูงเปิดอยู่ไหม (เช่น สายแกะสคริปต์)
if getrawmetatable and setreadonly then
    local mt = getrawmetatable(game)
    if not isreadonly(mt) then
        -- ถ้าตรวจสอบพบว่า Metatable ถูกเปิดให้แก้ไขได้แบบผิดปกติ อาจจะให้เกมเด้งออกหรือหยุดทำงาน
        pcall(function()
            game:GetService("Players").LocalPlayer:Kick("❌ ตรวจพบความผิดปกติในการดักจับระบบ (Security Violation)")
        end)
        return -- ตัดจบการทำงานทันที ไม่ให้สคริปต์รันต่อ
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

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CurrentSelectedPlayer = nil
local StatusLabel = nil

local AssetCache = {}

-- ==================== รายชื่อ Admin Whitelist ====================
local AdminList = {
    ["kfc_punyai"] = true,
    ["Aekshop_34d3c"] = true,
    ["CGGG_PRJOOOO"] = true,
    ["Haren_902"] = true,
}

local function IsAdmin(player)
    if not player then return false end
    return AdminList[player.Name] == true
end

local function IsLocalAdmin()
    return IsAdmin(LocalPlayer)
end

-- ==================== ระบบสื่อสาร & TAG บนหัว ====================
local TAG_NAME = "Honkuki_Active_Runner_Tag"

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
    local head = char:WaitForChild("Head", 5)
    if not head then return end

    if not char:FindFirstChild(TAG_NAME) and player ~= LocalPlayer then
        if head:FindFirstChild("HonkukiHeadTag") then
            head.HonkukiHeadTag:Destroy()
        end
        return
    end

    if head:FindFirstChild("HonkukiHeadTag") then
        head.HonkukiHeadTag:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HonkukiHeadTag"
    billboard.Size = UDim2.new(0, 160, 0, 32)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local tagLabel = Instance.new("TextLabel", billboard)
    tagLabel.Size = UDim2.new(1, 0, 1, 0)
    tagLabel.BackgroundTransparency = 1
    tagLabel.Font = Enum.Font.GothamBold
    tagLabel.TextSize = 12
    tagLabel.TextStrokeTransparency = 0.2

    if IsAdmin(player) then
        tagLabel.Text = "👑 [ ADMIN ]"
        tagLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        tagLabel.TextStrokeColor3 = Color3.fromRGB(150, 100, 0)
    else
        tagLabel.Text = "🔰 [ PLAYER ]"
        tagLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
        tagLabel.TextStrokeColor3 = Color3.fromRGB(0, 100, 50)
    end
end

-- ==================== 2 REMOTE COMBO FOR MUSIC ====================
local function ForcePlayMusicCombo(musicId)
    if not musicId or musicId == "" then return false end
    local re = ReplicatedStorage:FindFirstChild("RE")
    if not re then return false end
    
    local success1, success2, success3 = false, false, false
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
    
    return success1 or success2 or success3
end

-- ==================== ระบบบล็อค ID ปลอม ====================
local BlockedIDs = {
    -- คุณ Hon สามารถนำลิสต์ ID ขยะแบบเต็ม 100% ของคุณมาวางทับตรงนี้ได้เลยครับ
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
    ["0083260119448675"] = true, ["00129462618639650"] = true, ["0083932827347443"] = true, ["00100800577164015"] = true, ["0090309298517536"] = true, ["00117628672363749"] = true, ["0091848271981900"] = true, ["00134476916426685"] = true, ["00196872951970254"] = true,
    ["00129643829992035"] = true, ["00107058019826867"] = true, ["00121320815776761"] = true,  ["0097681411562121"] = true, ["00104523837494454"] = true, ["00108763959187625"] = true,  ["00103341533670628"] = true, ["0073567657933546"] = true, ["00117484747381529"] = true,  ["00102583982042068"] = true, ["0089689020278596"] = true, ["00126329595231978"] = true,  ["0090338113256962"] = true, ["0087260439948695"] = true, ["00103462658039651"] = true,  ["0093931829347443"] = true, ["00106800817264017"] = true, ["0090307298519537"] = true, ["00117628371363749"] = true, ["0083848201981900"] = true, ["00134076916421685"] = true,   ["00116872955970254"] = true, ["00129043827992035"] = true, ["00137058099826867"] = true,    ["00121320825772761"] = true, ["0083681471562121"] = true, ["00134523838494464"] = true,
    ["00138763959207625"] = true, ["00113841533670628"] = true, ["0070567654933546"] = true,
    ["00117424747387525"] = true, ["00112583972042063"] = true, ["0079688020178596"] = true,
    ["00125329595131078"] = true, ["0093338918256962"] = true, ["0083260119948695"] = true,
    ["00109462618039650"] = true, ["0093932829347443"] = true, ["00106800577264015"] = true,
    ["00101424747387525"] = true, ["00116872915970654"] = true, ["00129943827692035"] = true,
    ["00167058097826867"] = true, ["00121120825772761"] = true, ["0083641471512121"] = true,
    ["00135523831494464"] = true, ["00138763959507620"] = true, ["00111841033670628"] = true,
    ["0083260109948697"] = true, ["00106462618019650"] = true, ["0093934829347743"] = true,
    ["00116800577264015"] = true, ["00137055199826817"] = true, ["0097681471562121"] = true,
    ["00112583912041063"] = true, ["00107700577264015"] = true, ["00137058099823667"] = true,
    ["0093932829347413"] = true, ["00137058099821867"] = true, ["00112583971042063"] = true,
    ["0079688120178796"] = true, ["00125329590131098"] = true, ["0093338928256062"] = true,
    ["0083262119978695"] = true, ["00149462658039650"] = true, ["0093932829346493"] = true,
    ["00106800517254015"] = true, ["0090308998517538"] = true, ["00117668371763749"] = true,
    ["0083858201911900"] = true, ["00135076816421685"] = true, ["00116872955971254"] = true,
    ["00129043827992055"] = true, ["00137258099826867"] = true, ["00124320825772766"] = true,
    ["0083681471562123"] = true, ["00134523838494454"] = true, ["00138763959207624"] = true,
    ["00112841533670628"] = true, ["00107810577264015"] = true, ["93932829347443"] = true,
    ["00106815577264015"] = true, ["93932829347441"] = true, ["00106990577264015"] = true,
    ["93932829347443"] = true, ["00106800777264315"] = true, ["3000000000000000"] = true,
    ["5555555"] = true,  
    ["0010781057726401593932829347443"] = true, ["0010681557726401593932829347441"] = true, ["0010699057726401593932829347443"] = true,
    ["555555"] = true,
}

local function urlDecode(str)
    if not str then return "" end
    str = string.gsub(str, "+", " ")
    return (string.gsub(str, "%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

local function hexDecode(str)
    if not str then return "" end
    str = string.gsub(str, "0x", "")
    str = string.gsub(str, "\\x", "")
    str = string.gsub(str, "%%", "")
    str = string.gsub(str, "%s+", "")
    
    if string.match(str, "^%x+$") and #str % 2 == 0 then
        local decoded = ""
        for i = 1, #str, 2 do
            local byteStr = string.sub(str, i, i+1)
            local byte = tonumber(byteStr, 16)
            if byte then 
                decoded = decoded .. string.char(byte) 
            end
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
    local seen = {}

    if type(text) ~= "string" or text == "" then
        return ids
    end

    -- จับเฉพาะ "ค่าหลังตัวแปรเพลง" ไม่กวาดเลขทุกตัวในข้อความ
    local patterns = {
        "69%%64=([^&%%s]+)",       -- %69%64 = id
        "[?&]id=([^&%%s]+)",       -- ?id= / &id=
        "^id=([^&%%s]+)$",
        "[?&]audio=([^&%%s]+)",
        "[?&]song=([^&%%s]+)",
        "[?&]music=([^&%%s]+)",
        "%%69%%64=([^&%%s]+)",
        "&%%69%%64=([^&%%s]+)",
        "9%s*d%s*=%s*([^&%%s]+)",
        "9d=([^&%%s]+)",
        "9_d=([^&%%s]+)",
        "9%%20d%%20=([^&%%s]+)"
    }

    for _, pat in ipairs(patterns) do
        local ok, iterator = pcall(string.gmatch, text, pat)
        if ok and iterator then
            for capture in iterator do
                local value = tostring(capture or "")
                value = value:match("^%s*(.-)%s*$") or ""

                -- รับเฉพาะค่าที่เป็นตัวเลขล้วนทั้งค่า
                local num = value:match("^(%d+)$")
                if num and not BlockedIDs[num] and not seen[num] then
                    seen[num] = true
                    table.insert(ids, num)
                end
            end
        end
    end

    return ids
end

local function getPlayerVehicle(player)
    if not player then return nil end
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    local seatPart = humanoid.SeatPart
    if not seatPart then return nil end
    local vehicle = seatPart.Parent
    while vehicle and not vehicle:IsA("Model") do
        vehicle = vehicle.Parent
    end
    if vehicle and vehicle:IsA("Model") then
        return vehicle
    end
    return nil
end

local function checkPlayerAllSounds(targetPlayer)
    if not targetPlayer then return {} end
    -- ป้องกันไม่ให้ผู้เล่นทั่วไปสแกนเสียงของ Admin
    if IsAdmin(targetPlayer) and not IsLocalAdmin() then
        return {}
    end

    local scanTargets = {}
    if targetPlayer.Character then table.insert(scanTargets, targetPlayer.Character) end
    local backpack = targetPlayer:FindFirstChild("Backpack")
    if backpack then table.insert(scanTargets, backpack) end
    
    local vehicle = getPlayerVehicle(targetPlayer)
    if vehicle then table.insert(scanTargets, vehicle) end

    local validSounds = {}
    local soundMap = {}
    local NameBlacklist = {
        ["gettingup"] = true, ["died"] = true, ["freefalling"] = true,
        ["jumping"] = true, ["landing"] = true, ["running"] = true,
        ["splash"] = true, ["swimming"] = true, ["climbing"] = true,
        ["engine"] = true, ["motor"] = true, ["horn"] = true
    }

    for _, folder in ipairs(scanTargets) do
        local success, descendants = pcall(function() return folder:GetDescendants() end)
        if success and descendants then
            for _, obj in ipairs(descendants) do
                if obj:IsA("Sound") and obj.SoundId ~= "" and obj.IsPlaying then
                    local soundNameLower = string.lower(obj.Name)
                    local isBlacklisted = false
                    for blockedName, _ in pairs(NameBlacklist) do
                        if string.find(soundNameLower, blockedName) then
                            isBlacklisted = true
                            break
                        end
                    end
                    if not isBlacklisted then
                        local key = obj.SoundId
                        if not soundMap[key] then
                            soundMap[key] = true
                            table.insert(validSounds, obj)
                        end
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

local function playMusicFromId(musicId)
    return ForcePlayMusicCombo(musicId)
end

-- ==================== โครงสร้าง UI หลัก (RENOVATED & SMOOTH) ====================
if PlayerGui:FindFirstChild("Honkuki-191") then PlayerGui.Honkuki_DeepSoundSpy:Destroy() end

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "เมนูสคริปดึงเพลงBY.HONKUKI⊂⁠(⁠◉⁠‿⁠◉⁠)⁠つ"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function setDrag(frame, handle)
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

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 200)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = false
MainFrame.ZIndex = 1
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mStroke = Instance.new("UIStroke", MainFrame)
mStroke.Color = Color3.fromRGB(255, 215, 0)
mStroke.Transparency = 1

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)
setDrag(MainFrame, TopBar)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -15, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "✨ สคริปดึงเพลงHonkuki ✨"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

local ListScroll = Instance.new("ScrollingFrame", MainFrame)
ListScroll.Size = UDim2.new(0.45, 0, 0, 115)
ListScroll.Position = UDim2.new(0.03, 0, 0.22, 0)
ListScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
ListScroll.BorderSizePixel = 0
ListScroll.ScrollBarThickness = 4
ListScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
Instance.new("UICorner", ListScroll).CornerRadius = UDim.new(0, 8)

local Layout = Instance.new("UIListLayout", ListScroll)
Layout.Padding = UDim.new(0, 5)

local ButtonsContainer = Instance.new("Frame", MainFrame)
ButtonsContainer.Size = UDim2.new(0.47, 0, 0, 115)
ButtonsContainer.Position = UDim2.new(0.5, 0, 0.22, 0)
ButtonsContainer.BackgroundTransparency = 1

local BLayout = Instance.new("UIListLayout", ButtonsContainer)
BLayout.Padding = UDim.new(0, 6)

local GetIDBtn = Instance.new("TextButton", ButtonsContainer)
GetIDBtn.Size = UDim2.new(1, 0, 0, 26)
GetIDBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
GetIDBtn.Text = "⚡ เจาะเพลง"
GetIDBtn.Font = Enum.Font.GothamBold
GetIDBtn.TextSize = 11
GetIDBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", GetIDBtn).CornerRadius = UDim.new(0, 6)

local GetJunkBtn = Instance.new("TextButton", ButtonsContainer)
GetJunkBtn.Size = UDim2.new(1, 0, 0, 26)
GetJunkBtn.BackgroundColor3 = Color3.fromRGB(230, 90, 40)
GetJunkBtn.Text = "🎵 เปิดเพลงตามขยะอย่างเดียว"
GetJunkBtn.Font = Enum.Font.GothamBold
GetJunkBtn.TextSize = 11
GetJunkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", GetJunkBtn).CornerRadius = UDim.new(0, 6)
GetJunkBtn.Visible = IsLocalAdmin()

local ViewRawJunkBtn = Instance.new("TextButton", ButtonsContainer)
ViewRawJunkBtn.Size = UDim2.new(1, 0, 0, 26)
ViewRawJunkBtn.BackgroundColor3 = Color3.fromRGB(140, 20, 230)
ViewRawJunkBtn.Text = "ดูRawดิบ"
ViewRawJunkBtn.Font = Enum.Font.GothamBold
ViewRawJunkBtn.TextSize = 11
ViewRawJunkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", ViewRawJunkBtn).CornerRadius = UDim.new(0, 6)

local ViewInstantBtn = Instance.new("TextButton", ButtonsContainer)
ViewInstantBtn.Size = UDim2.new(1, 0, 0, 26)
ViewInstantBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
ViewInstantBtn.Text = "ดูไอดีที่เจาะReal time"
ViewInstantBtn.Font = Enum.Font.GothamBold
ViewInstantBtn.TextSize = 11
ViewInstantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", ViewInstantBtn).CornerRadius = UDim.new(0, 6)

StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(0.68, 0, 0, 24)
StatusLabel.Position = UDim2.new(0.03, 0, 0.82, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
StatusLabel.BackgroundTransparency = 0.9
StatusLabel.Text = "เลือกชื่อผู้เล่นก่อนดึงไอดีเพลง"
StatusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.TextWrapped = true
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 4)

local RefreshBtn = Instance.new("TextButton", MainFrame)
RefreshBtn.Size = UDim2.new(0.24, 0, 0, 24)
RefreshBtn.Position = UDim2.new(0.73, 0, 0.82, 0)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
RefreshBtn.Text = "🔄 รีเฟรชรายชื่อ"
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 10
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 6)

-- ปุ่มเปิด-ปิดเมนูหลัก (เปลี่ยนรูปภาพตามคำสั่งเรียบร้อยแล้ว)
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 52, 0, 52)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleBtn.Image = "rbxassetid://104747656190057" -- เปลี่ยนตรงนี้ตามสั่ง 100%
ToggleBtn.ZIndex = 10
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 16)
local tStroke = Instance.new("UIStroke", ToggleBtn)
tStroke.Color = Color3.fromRGB(255, 215, 0)
tStroke.Thickness = 2
setDrag(ToggleBtn, ToggleBtn)

-- ==================== หน้าต่างรองส่อง Real-time ====================
local JunkFrame = Instance.new("Frame", ScreenGui)
JunkFrame.Size = UDim2.new(0, 420, 0, 240)
JunkFrame.Position = UDim2.new(0.5, -210, 0.5, -120)
JunkFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
JunkFrame.BackgroundTransparency = 1
JunkFrame.Visible = false
JunkFrame.ZIndex = 5
Instance.new("UICorner", JunkFrame).CornerRadius = UDim.new(0, 12)
local jStroke = Instance.new("UIStroke", JunkFrame)
jStroke.Color = Color3.fromRGB(140, 20, 230)
jStroke.Transparency = 1

local JunkTopBar = Instance.new("Frame", JunkFrame)
JunkTopBar.Size = UDim2.new(1, 0, 0, 32)
JunkTopBar.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
Instance.new("UICorner", JunkTopBar).CornerRadius = UDim.new(0, 12)
setDrag(JunkFrame, JunkTopBar)

local JunkTitle = Instance.new("TextLabel", JunkTopBar)
JunkTitle.Size = UDim2.new(1, -15, 1, 0)
JunkTitle.Position = UDim2.new(0, 15, 0, 0)
JunkTitle.BackgroundTransparency = 1
JunkTitle.Text = "ปิดหน้าต่าง"
JunkTitle.TextColor3 = Color3.fromRGB(200, 100, 255)
JunkTitle.Font = Enum.Font.GothamBold
JunkTitle.TextSize = 11
JunkTitle.TextXAlignment = Enum.TextXAlignment.Left

local JunkScroll = Instance.new("ScrollingFrame", JunkFrame)
JunkScroll.Size = UDim2.new(0.94, 0, 0, 150)
JunkScroll.Position = UDim2.new(0.03, 0, 0.18, 0)
JunkScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
JunkScroll.BorderSizePixel = 0
JunkScroll.ScrollBarThickness = 4
JunkScroll.ScrollBarImageColor3 = Color3.fromRGB(140, 20, 230)
Instance.new("UICorner", JunkScroll).CornerRadius = UDim.new(0, 8)

local JunkTextLabel = Instance.new("TextLabel", JunkScroll)
JunkTextLabel.Size = UDim2.new(1, -10, 0, 0)
JunkTextLabel.Position = UDim2.new(0, 5, 0, 5)
JunkTextLabel.BackgroundTransparency = 1
JunkTextLabel.Text = "ไม่มีข้อมูลเพลงผู้เล่น หรือผู้เล่นไม่ได้เปิดเพลงภายในเเมพ"
JunkTextLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
JunkTextLabel.Font = Enum.Font.Code
JunkTextLabel.TextSize = 11
JunkTextLabel.TextXAlignment = Enum.TextXAlignment.Left
JunkTextLabel.TextYAlignment = Enum.TextYAlignment.Top
JunkTextLabel.TextWrapped = true

local JunkCopyBtn = Instance.new("TextButton", JunkFrame)
JunkCopyBtn.Size = UDim2.new(0.45, 0, 0, 26)
JunkCopyBtn.Position = UDim2.new(0.03, 0, 0.86, 0)
JunkCopyBtn.BackgroundColor3 = Color3.fromRGB(140, 20, 230)
JunkCopyBtn.Text = "📋 คัดลอกไอดีเพลงทั้งหมด"
JunkCopyBtn.Font = Enum.Font.GothamBold
JunkCopyBtn.TextSize = 11
JunkCopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", JunkCopyBtn).CornerRadius = UDim.new(0, 6)

local JunkBackBtn = Instance.new("TextButton", JunkFrame)
JunkBackBtn.Size = UDim2.new(0.45, 0, 0, 26)
JunkBackBtn.Position = UDim2.new(0.52, 0, 0.86, 0)
JunkBackBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
JunkBackBtn.Text = "⬅️ ย้อนกลับ"
JunkBackBtn.Font = Enum.Font.GothamBold
JunkBackBtn.TextSize = 11
JunkBackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", JunkBackBtn).CornerRadius = UDim.new(0, 6)

-- ==================== ระบบ Animation ความสมูท (Tween) ====================
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function toggleUI(isOpen)
    if isOpen then
        MainFrame.Visible = true
        TweenService:Create(MainFrame, tweenInfo, {BackgroundTransparency = 0.15}):Play()
        TweenService:Create(mStroke, tweenInfo, {Transparency = 0}):Play()
    else
        local tw1 = TweenService:Create(MainFrame, tweenInfo, {BackgroundTransparency = 1})
        local tw2 = TweenService:Create(mStroke, tweenInfo, {Transparency = 1})
        tw1:Play()
        tw2:Play()
        tw1.Completed:Connect(function()
            if MainFrame.BackgroundTransparency == 1 then
                MainFrame.Visible = false
                JunkFrame.Visible = false
            end
        end)
    end
end

local function toggleJunkUI(isOpen)
    if isOpen then
        JunkFrame.Visible = true
        TweenService:Create(JunkFrame, tweenInfo, {BackgroundTransparency = 0.1}):Play()
        TweenService:Create(jStroke, tweenInfo, {Transparency = 0}):Play()
    else
        local tw1 = TweenService:Create(JunkFrame, tweenInfo, {BackgroundTransparency = 1})
        local tw2 = TweenService:Create(jStroke, tweenInfo, {Transparency = 1})
        tw1:Play()
        tw2:Play()
        tw1.Completed:Connect(function()
            if JunkFrame.BackgroundTransparency == 1 then
                JunkFrame.Visible = false
            end
        end)
    end
end

local CurrentViewMode = 1
local PlayerButtons = {}

local function updateJunkViewerLive()
    if not JunkFrame.Visible then return end
    local outputText = ""

    if CurrentSelectedPlayer then
        local targetPlayer = Players:FindFirstChild(CurrentSelectedPlayer.Name)
        if not targetPlayer then return end
        
        if IsAdmin(targetPlayer) and not IsLocalAdmin() then
            outputText = "❌ Protection Admin"
        else
            local soundObjects = checkPlayerAllSounds(targetPlayer)

            if CurrentViewMode == 1 then
                JunkTitle.Text = "RAW JUNK VIEWER (ขยะดิบทั้งหมด 100%)"
                jStroke.Color = Color3.fromRGB(140, 20, 230)
                JunkCopyBtn.BackgroundColor3 = Color3.fromRGB(140, 20, 230)
                
                if #soundObjects == 0 then 
                    outputText = "❌ ไม่พบออบเจกต์เสียงบนตัวผู้เล่นนี้"
                else
                    for i, obj in ipairs(soundObjects) do
                        outputText = outputText .. string.format("[%d] ออบเจกต์: %s\nID ดั้งเดิม: %s\n\n", i, obj:GetFullName(), obj.SoundId)
                    end
                end
            elseif CurrentViewMode == 2 then
                JunkTitle.Text = "INSTANT LOG VIEWER (ID เจาะสดเรียลไทม์)"
                jStroke.Color = Color3.fromRGB(0, 200, 100)
                JunkCopyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                
                if #soundObjects == 0 then
                    outputText = "❌ ไม่พบค่าเพลงของผู้เล่นนี้"
                else
                    local finalIds = {}
                    local seenIds = {}
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
                        outputText = "❌ ดึงค่าแล้วไม่พบ ID เพลงจริงอยู่ข้างในเลย"
                    else
                        outputText = "--- พบบทเพลงเจาะสำเร็จทั้งหมด " .. #finalIds .. " ID ---\n\n"
                        for idx, id in ipairs(finalIds) do
                            outputText = outputText .. string.format("[%d] ID เจาะได้: %s\n", idx, id)
                        end
                    end
                end
            end
        end
    end

    if JunkTextLabel.Text ~= outputText then
        JunkTextLabel.Text = outputText
        local textBounds = TextService:GetTextSize(outputText, 11, Enum.Font.Code, Vector2.new(JunkScroll.AbsoluteSize.X - 15, math.huge))
        JunkTextLabel.Size = UDim2.new(1, -10, 0, textBounds.Y + 20)
        JunkScroll.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y + 40)
    end
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
                btn.Size = UDim2.new(1, -6, 0, 28)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 11
                btn.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                local bStroke = Instance.new("UIStroke", btn)
                bStroke.Color = Color3.fromRGB(40, 40, 50)

                btn.MouseButton1Click:Connect(function()
                    for playerObj, b in pairs(PlayerButtons) do
                        if b:FindFirstChildOfClass("UIStroke") then
                            b.UIStroke.Color = Color3.fromRGB(40, 40, 50)
                        end
                    end
                    bStroke.Color = Color3.fromRGB(255, 215, 0)
                    CurrentSelectedPlayer = p
                    StatusLabel.Text = "เลือก: " .. p.DisplayName
                    updateJunkViewerLive()
                end)
                PlayerButtons[p] = btn
            end

            local activeSounds = checkPlayerAllSounds(p)
            local adminSymbol = IsAdmin(p) and " 👑" or ""
            
            if #activeSounds > 0 and not (IsAdmin(p) and not IsLocalAdmin()) then
                btn.Text = " 🎵 " .. p.DisplayName .. " (@" .. p.Name .. ")" .. adminSymbol
                btn.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                btn.Text = " 👤 " .. p.DisplayName .. " (@" .. p.Name .. ")" .. adminSymbol
                btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            end

            if CurrentSelectedPlayer == p then
                btn.UIStroke.Color = Color3.fromRGB(255, 215, 0)
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

GetIDBtn.MouseButton1Click:Connect(function()
    if not CurrentSelectedPlayer then
        StatusLabel.Text = "⚠️ โปรดเลือกชื่อผู้เล่นก่อนกดดึงไอดีเพลง"
        return
    end

    if IsAdmin(CurrentSelectedPlayer) and not IsLocalAdmin() then
        StatusLabel.Text = "❌ ไม่สามารถดึงข้อมูลของ ผู้เล่นนี้ได้ Protection Admin"
        return
    end

    StatusLabel.Text = "🔍 กำลังตรวจตัวแปรกับ Sound ที่กำลังเล่นจริง..."

    local targetPlayer = Players:FindFirstChild(CurrentSelectedPlayer.Name)
    if not targetPlayer then
        StatusLabel.Text = "❌ ไม่พบผู้เล่นเป้าหมาย"
        return
    end

    -- ใช้ระบบเดิมในการหา Sound Object ที่กำลังเล่นจริง
    local soundObjects = checkPlayerAllSounds(targetPlayer)

    local finalIds = {}
    local seenIds = {}

    for _, soundObj in ipairs(soundObjects) do
        if soundObj
            and soundObj:IsA("Sound")
            and soundObj.Parent
            and soundObj.IsPlaying
            and soundObj.SoundId ~= "" then

            -- อ่าน SoundId สดจาก Object เสียง
            local rawId = tostring(soundObj.SoundId or "")
            local decoded = deepDecode(rawId)
            local searchText = (decoded ~= "" and decoded) or rawId

            -- ตัวแปรเพลงสร้างได้แค่ candidate ที่อยู่หลังตัวแปรเท่านั้น
            local candidates = extractIDsFromPattern(searchText)

            -- ยืนยัน candidate กับ Sound Object จริง
            for _, candidateId in ipairs(candidates) do
                if not BlockedIDs[candidateId] and not seenIds[candidateId] then
                    local rawDigits = rawId:match("(%d+)")
                    local decodedDigits = searchText:match("(%d+)%s*$")

                    -- รับเฉพาะเมื่อ candidate มีหลักฐานตรงกับค่าที่มาจาก SoundId
                    if candidateId == rawDigits or candidateId == decodedDigits then
                        seenIds[candidateId] = true
                        table.insert(finalIds, candidateId)
                        break
                    end
                end
            end
        end
    end

    if #finalIds > 0 then
        copyToClipboard(table.concat(finalIds, " "))
        StatusLabel.Text = "📋 พบเพลงที่ Match กับ Sound สดจริง " .. #finalIds .. " ID"
    else
        StatusLabel.Text = "❌ ไม่พบ ID ที่ตัวแปร Match กับ Sound ซึ่งกำลังเล่นจริง"
    end
end)

GetJunkBtn.MouseButton1Click:Connect(function()
    if CurrentSelectedPlayer then
        if IsAdmin(CurrentSelectedPlayer) and not IsLocalAdmin() then
            StatusLabel.Text = "❌ ไม่สามารถเปิดเพลงตามผู้เล่นที่เป็น Admin ได้"
            return
        end
        StatusLabel.Text = "🎵 กำลังยิงคำสั่งเปิดเพลงตามขยะ..."
        local targetPlayer = Players:FindFirstChild(CurrentSelectedPlayer.Name)
        local soundObjects = checkPlayerAllSounds(targetPlayer)
        local firstCleanId = nil
        for _, soundObj in ipairs(soundObjects) do
            local rawId = soundObj.SoundId or ""
            local cleanId = string.gsub(rawId, "^rbxassetid://", "")
            if string.find(cleanId, "rbxassetid://") then
                cleanId = string.match(cleanId, "rbxassetid://(%d+)") or cleanId
            end
            if not BlockedIDs[cleanId] and cleanId ~= "" then
                firstCleanId = cleanId
                break
            end
        end
        if firstCleanId and playMusicFromId(firstCleanId) then
            StatusLabel.Text = "✅ เปิดเพลงสำเร็จ: " .. firstCleanId
        else
            StatusLabel.Text = "❌ เล่นเพลงไม่สำเร็จ หรือโดนบล็อก"
        end
    else
        StatusLabel.Text = "⚠️ โปรดเลือกชื่อผู้เล่นก่อนเปิดเพลง!"
    end
end)

ViewRawJunkBtn.MouseButton1Click:Connect(function()
    if CurrentSelectedPlayer then
        if IsAdmin(CurrentSelectedPlayer) and not IsLocalAdmin() then
            StatusLabel.Text = "❌ ไม่สามารถดูข้อมูลของ Admin ได้"
            return
        end
        CurrentViewMode = 1
        toggleJunkUI(true)
        updateJunkViewerLive()
        StatusLabel.Text = "👁️ เปิดหน้าต่างแสดงขยะ RAW เรียลไทม์แล้ว"
    else
        StatusLabel.Text = "⚠️ โปรดเลือกชื่อผู้เล่นก่อนกดดูขยะดิบ!"
    end
end)

ViewInstantBtn.MouseButton1Click:Connect(function()
    if CurrentSelectedPlayer then
        if IsAdmin(CurrentSelectedPlayer) and not IsLocalAdmin() then
            StatusLabel.Text = "❌ ไม่สามารถดูข้อมูลของ Admin ได้"
            return
        end
        CurrentViewMode = 2
        toggleJunkUI(true)
        updateJunkViewerLive()
        StatusLabel.Text = "🔍 เปิดหน้าต่างสแกน ID เจาะสด Real-time"
    else
        StatusLabel.Text = "⚠️ โปรดเลือกชื่อผู้เล่นก่อนกดดู ID เจาะสด!"
    end
end)

JunkCopyBtn.MouseButton1Click:Connect(function()
    if JunkTextLabel.Text ~= "ไม่มีข้อมูล..." and not string.find(JunkTextLabel.Text, "❌") then
        copyToClipboard(JunkTextLabel.Text)
        StatusLabel.Text = "📋 คัดลอกเนื้อหาทั้งหมดเรียบร้อย!"
    end
end)

JunkBackBtn.MouseButton1Click:Connect(function()
    toggleJunkUI(false)
    StatusLabel.Text = "⬅️ กลับสู่แผงควบคุมหลักแล้ว"
end)

RefreshBtn.MouseButton1Click:Connect(refreshPlayers)

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(function(p)
    if CurrentSelectedPlayer == p then
        CurrentSelectedPlayer = nil
        StatusLabel.Text = "โปรดเลือกชื่อผู้เล่นก่อนดึงจั๊ฟฟ"
    end
    refreshPlayers()
end)

ToggleBtn.MouseButton1Click:Connect(function()
    if MainFrame.Visible and MainFrame.BackgroundTransparency < 0.5 then
        toggleUI(false)
    else
        toggleUI(true)
        refreshPlayers()
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        markSelfAsRunner()
        for _, p in ipairs(Players:GetPlayers()) do
            pcall(function() setupPlayerTag(p) end)
        end
        if MainFrame.Visible and MainFrame.BackgroundTransparency < 0.5 then
            pcall(function()
                refreshPlayers()
                if JunkFrame.Visible and JunkFrame.BackgroundTransparency < 0.5 then 
                    updateJunkViewerLive() 
                end
            end)
        end
    end
end)

refreshPlayers()
