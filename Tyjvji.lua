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

-- เสียงสำหรับฟังเพลงแบบส่วนตัว
local PrivateMusicSound = nil
local IsListeningToPlayerMusic = false

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
    local patterns = {
        "69%%64=([^&]*)", "&id=([^&]*)", "id=([^&]*)",
        "audio=([^&]*)", "song=([^&]*)", "music=([^&]*)",
        "%%69%%64=([^&]*)", "&%%69%%64=([^&]*)",
        "9%s*d%s*=%s*([^&]*)", "9d=([^&]*)", "9_d=([^&]*)", "9%%20d%%20=([^&]*)"
    }
    for _, pat in ipairs(patterns) do
        for capture in string.gmatch(text, pat) do
            for num in string.gmatch(capture, "%d+") do
                if not BlockedIDs[num] then
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

-- ==================== ตัวหาเสียงที่กำลังได้ยินจริง ====================
-- source เดียวสำหรับ: ฟัง / เจาะ ID / RAW / Instant
-- จะรับเฉพาะ Sound ที่ "กำลังเล่นจริง" บน client และมี PlaybackLoudness
-- จากนั้นผูกกับตำแหน่งของผู้เล่น/รถ เพื่อไม่เอา SoundId ที่เป็นข้อมูลลวงใน object อื่น
local function getSoundWorldPosition(sound)
    local node = sound.Parent
    local depth = 0
    while node and depth < 8 do
        if node:IsA("BasePart") then
            return node.Position
        elseif node:IsA("Attachment") then
            return node.WorldPosition
        elseif node:IsA("Model") then
            local pp = node.PrimaryPart
            if pp then return pp.Position end
            local ok, pivot = pcall(function() return node:GetPivot() end)
            if ok then return pivot.Position end
        end
        node = node.Parent
        depth += 1
    end
    return nil
end

local function getTargetMusicOrigin(targetPlayer)
    local character = targetPlayer and targetPlayer.Character
    if not character then return nil, nil end

    local vehicle = getPlayerVehicle(targetPlayer)
    if vehicle then
        local ok, pivot = pcall(function() return vehicle:GetPivot() end)
        if ok then
            return pivot.Position, vehicle
        end
        local pp = vehicle.PrimaryPart
        if pp then return pp.Position, vehicle end
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if root then return root.Position, character end
    return nil, nil
end

local function getHeardMusicSounds(targetPlayer)
    if not targetPlayer then return {} end
    if IsAdmin(targetPlayer) and not IsLocalAdmin() then return {} end

    local candidates = {}
    local seen = {}
    local origin, preferredRoot = getTargetMusicOrigin(targetPlayer)

    local function addSound(obj, priority, distance)
        if not obj:IsA("Sound") then return end
        if obj.SoundId == "" or not obj.IsPlaying then return end
        if seen[obj] then return end

        local loudness = tonumber(obj.PlaybackLoudness) or 0
        if loudness <= 0.1 then return end
        if (tonumber(obj.Volume) or 0) <= 0 then return end

        local name = string.lower(obj.Name)
        if string.find(name, "engine") or string.find(name, "motor")
            or string.find(name, "horn") or string.find(name, "jump")
            or string.find(name, "landing") or string.find(name, "running")
            or string.find(name, "freefall") or string.find(name, "swim")
            or string.find(name, "climb") then
            return
        end

        -- ถ้าเป็นเสียง 3D ให้ต้องอยู่ในระยะที่ผู้เล่นของเป้าหมายได้ยินจริง
        if distance and obj.RollOffMaxDistance and distance > obj.RollOffMaxDistance then
            return
        end

        seen[obj] = true
        local score = (loudness * 100000) + (priority or 0)
        if distance then score += math.max(0, 500 - distance) * 10 end

        table.insert(candidates, {
            sound = obj,
            score = score,
            loudness = loudness,
            distance = distance or 0
        })
    end

    -- 1) ตัวละคร/รถ/Backpack ของเป้าหมายก่อน: นี่คือ source ที่เชื่อถือได้ที่สุด
    local scanTargets = {}
    if targetPlayer.Character then table.insert(scanTargets, targetPlayer.Character) end
    local backpack = targetPlayer:FindFirstChild("Backpack")
    if backpack then table.insert(scanTargets, backpack) end
    if preferredRoot and preferredRoot ~= targetPlayer.Character then
        table.insert(scanTargets, preferredRoot)
    end

    for _, root in ipairs(scanTargets) do
        local ok, descendants = pcall(function() return root:GetDescendants() end)
        if ok and descendants then
            for _, obj in ipairs(descendants) do
                local pos = getSoundWorldPosition(obj)
                local distance = (origin and pos) and (pos - origin).Magnitude or nil
                addSound(obj, 20000, distance)
            end
        end
    end

    -- 2) Sound ที่ถูกสร้างไว้ในแมพ/รถ แต่ไม่ได้เป็น child ของ Character โดยตรง
    -- ต้องเป็นเสียงที่ client กำลังได้ยินจริง และอยู่ใกล้ origin ของผู้เล่น/รถ
    if origin then
        local ok, descendants = pcall(function() return workspace:GetDescendants() end)
        if ok and descendants then
            for _, obj in ipairs(descendants) do
                if obj:IsA("Sound") and obj.IsPlaying and obj.SoundId ~= "" then
                    local pos = getSoundWorldPosition(obj)
                    if pos then
                        local distance = (pos - origin).Magnitude
                        if distance <= 180 then
                            local parent = obj.Parent
                            local tiedToVehicle = preferredRoot and parent and parent:IsDescendantOf(preferredRoot)
                            local priority = tiedToVehicle and 30000 or 1000
                            addSound(obj, priority, distance)
                        end
                    end
                end
            end
        end
    end

    table.sort(candidates, function(a, b)
        if a.score == b.score then
            return a.distance < b.distance
        end
        return a.score > b.score
    end)

    local result = {}
    for _, item in ipairs(candidates) do
        table.insert(result, item.sound)
    end
    return result
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


-- ==================== ฟังเสียงผู้เล่นแบบส่วนตัว ====================
local LastHeardMusicSound = nil
local LastHeardMusicSoundId = ""

local function listenToPlayerMusic(targetPlayer)
    if not targetPlayer then
        return false, "กรุณาเลือกผู้เล่นก่อน"
    end

    local sounds = getHeardMusicSounds(targetPlayer)
    if #sounds == 0 then
        return false, "ไม่พบเพลงที่ผู้เล่นกำลังเปิด/กำลังได้ยินจริง"
    end

    local targetSound = nil
    for _, sound in ipairs(sounds) do
        if sound.IsPlaying and sound.SoundId ~= "" then
            targetSound = sound
            break
        end
    end

    if not targetSound then
        return false, "ไม่พบเสียงที่กำลังเล่น"
    end

    if PrivateMusicSound then
        PrivateMusicSound:Destroy()
        PrivateMusicSound = nil
    end

    PrivateMusicSound = Instance.new("Sound")
    PrivateMusicSound.Name = "PrivateMusicListener"
    -- จำ source จริงที่ใช้ฟังไว้ให้ปุ่มเจาะ/RAW ใช้ source เดียวกัน
    LastHeardMusicSound = targetSound
    LastHeardMusicSoundId = targetSound.SoundId

    PrivateMusicSound.SoundId = targetSound.SoundId
    PrivateMusicSound.Volume = 1
    PrivateMusicSound.Looped = targetSound.Looped
    PrivateMusicSound.Parent = game:GetService("SoundService")

    -- เริ่มเพลงใหม่ตั้งแต่ต้นทุกครั้งที่กดฟัง
    PrivateMusicSound.TimePosition = 0
    PrivateMusicSound:Play()
    return true, targetSound.Name
end

-- ==================== โครงสร้าง UI หลัก (MOBILE RESPONSIVE / ORIGINAL LOGIC PRESERVED) ====================
if PlayerGui:FindFirstChild("เมนูสคริปดึงเพลงBY.HONKUKI⊂⁠(⁠◉⁠‿⁠◉⁠)⁠つ") then
    PlayerGui["เมนูสคริปดึงเพลงBY.HONKUKI⊂⁠(⁠◉⁠‿⁠◉⁠)⁠つ"]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "เมนูสคริปดึงเพลงBY.HONKUKI⊂⁠(⁠◉⁠‿⁠◉⁠)⁠つ"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

local function setDrag(frame, handle)
    -- Drag controller แบบกัน Click หลุด:
    -- ถ้านิ้ว/เมาส์ขยับเกิน threshold จะถือว่าเป็น "ลาก" และป้องกัน
    -- MouseButton1Click/TouchTap ที่ตามหลังการลากไม่ให้เปิด UI เอง
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local moved = false
    local DRAG_THRESHOLD = 8

    frame:SetAttribute("Dragging", false)
    frame:SetAttribute("DragMoved", false)

    local function beginDrag(input)
        dragging = true
        moved = false
        dragInput = nil
        dragStart = input.Position
        startPos = frame.Position
        frame:SetAttribute("Dragging", true)
        frame:SetAttribute("DragMoved", false)
    end

    local function finishDrag()
        dragging = false
        dragInput = nil
        frame:SetAttribute("Dragging", false)

        -- ค้าง flag ไว้สั้น ๆ ให้ event click ที่ตามหลัง Touch/Mouse release
        -- ตรวจเจอก่อน แล้วค่อยเคลียร์ ไม่ให้เกิดการเปิด UI โดยไม่ได้ตั้งใจ
        if moved then
            frame:SetAttribute("DragMoved", true)
            task.delay(0.12, function()
                if frame.Parent then
                    frame:SetAttribute("DragMoved", false)
                end
            end)
        else
            frame:SetAttribute("DragMoved", false)
        end
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(input)

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End
                    or input.UserInputState == Enum.UserInputState.Cancel then
                    finishDrag()
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and dragStart and startPos then
            local delta = input.Position - dragStart

            if math.abs(delta.X) >= DRAG_THRESHOLD or math.abs(delta.Y) >= DRAG_THRESHOLD then
                moved = true
                frame:SetAttribute("DragMoved", true)
            end

            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ==================== ธีม UI ====================
local BG = Color3.fromRGB(8, 8, 14)
local PANEL = Color3.fromRGB(13, 13, 22)
local PANEL2 = Color3.fromRGB(18, 16, 30)
local BORDER = Color3.fromRGB(105, 35, 180)
local PURPLE = Color3.fromRGB(180, 55, 255)
local PURPLE2 = Color3.fromRGB(120, 20, 230)
local WHITE = Color3.fromRGB(245, 240, 255)
local MUTED = Color3.fromRGB(155, 145, 175)
local GREEN = Color3.fromRGB(80, 255, 110)
local RED = Color3.fromRGB(235, 45, 45)

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness, transparency)
    local st = Instance.new("UIStroke")
    st.Color = color
    st.Thickness = thickness or 1
    st.Transparency = transparency or 0
    st.Parent = obj
    return st
end

-- ใช้ขนาดแบบเปอร์เซ็นต์เพื่อให้พอดีทั้งมือถือแนวตั้ง/แนวนอน
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0.74, 0, 0.70, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = BG
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = false
MainFrame.ZIndex = 1
corner(MainFrame, 12)

local mStroke = stroke(MainFrame, Color3.fromRGB(205, 70, 255), 2, 0.01)
mStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- ไฟขอบเป็น "เส้นยาว" เท่านั้น
local EdgeLines = {}
local function makeEdgeLine(parent, size, position)
    local line = Instance.new("Frame", parent)
    line.Size = size
    line.Position = position
    line.BackgroundColor3 = Color3.fromRGB(215, 75, 255)
    line.BorderSizePixel = 0
    line.ZIndex = 3
    table.insert(EdgeLines, line)

    local g = Instance.new("UIGradient", line)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(65, 0, 120)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 150, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 235, 255)),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(255, 150, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(65, 0, 120))
    })
    return line, g
end

local topLine, topGradient = makeEdgeLine(MainFrame, UDim2.new(0.82, 0, 0, 2), UDim2.new(0.09, 0, 0, 0))
local bottomLine, bottomGradient = makeEdgeLine(MainFrame, UDim2.new(0.82, 0, 0, 2), UDim2.new(0.09, 0, 1, -2))
local leftLine, leftGradient = makeEdgeLine(MainFrame, UDim2.new(0, 2, 0.82, 0), UDim2.new(0, 0, 0.09, 0))
local rightLine, rightGradient = makeEdgeLine(MainFrame, UDim2.new(0, 2, 0.82, 0), UDim2.new(1, -2, 0.09, 0))

task.spawn(function()
    local offset = -1
    while ScreenGui.Parent do
        offset += 0.018
        if offset > 1 then offset = -1 end
        topGradient.Offset = Vector2.new(offset, 0)
        bottomGradient.Offset = Vector2.new(-offset, 0)
        leftGradient.Offset = Vector2.new(0, offset)
        rightGradient.Offset = Vector2.new(0, -offset)
        task.wait(0.05)
    end
end)

-- แถบหัว
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, -24, 0, 62)
TopBar.Position = UDim2.new(0, 12, 0, 10)
TopBar.BackgroundColor3 = PANEL
corner(TopBar, 10)
stroke(TopBar, Color3.fromRGB(60, 35, 90), 1, 0.25)
setDrag(MainFrame, TopBar)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -80, 0, 34)
Title.Position = UDim2.new(0, 40, 0, 4)
Title.BackgroundTransparency = 1
Title.Text = "✨ สคริปดึงเพลง Honkuki ✨"
Title.TextColor3 = WHITE
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextScaled = true
Title.TextXAlignment = Enum.TextXAlignment.Center

local TitleSize = Instance.new("UITextSizeConstraint", Title)
TitleSize.MinTextSize = 12
TitleSize.MaxTextSize = 20

local Subtitle = Instance.new("TextLabel", TopBar)
Subtitle.Size = UDim2.new(1, -80, 0, 18)
Subtitle.Position = UDim2.new(0, 40, 0, 39)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "REAL-TIME MUSIC CONTROL PANEL"
Subtitle.TextColor3 = PURPLE
Subtitle.Font = Enum.Font.GothamBold
Subtitle.TextSize = 9
Subtitle.TextXAlignment = Enum.TextXAlignment.Center

-- ปุ่ม X = ปิด UI ถาวรในรอบการรันนี้
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -40, 0, 14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(65, 15, 80)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = WHITE
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 25
CloseBtn.AutoButtonColor = true
corner(CloseBtn, 8)
stroke(CloseBtn, PURPLE, 1, 0.1)
CloseBtn.MouseButton1Click:Connect(function()
    if PrivateMusicSound then
        pcall(function()
            PrivateMusicSound:Stop()
            PrivateMusicSound:Destroy()
        end)
        PrivateMusicSound = nil
        IsListeningToPlayerMusic = false
    end
    ScreenGui:Destroy()
end)

-- แผงซ้าย: รายชื่อผู้เล่น
local LeftPanel = Instance.new("Frame", MainFrame)
LeftPanel.Size = UDim2.new(0.50, -18, 0, 300)
LeftPanel.Position = UDim2.new(0, 12, 0, 82)
LeftPanel.BackgroundColor3 = PANEL
corner(LeftPanel, 10)
stroke(LeftPanel, Color3.fromRGB(55, 35, 80), 1, 0.2)

local PlayerHeader = Instance.new("TextLabel", LeftPanel)
PlayerHeader.Size = UDim2.new(1, -24, 0, 30)
PlayerHeader.Position = UDim2.new(0, 12, 0, 7)
PlayerHeader.BackgroundTransparency = 1
PlayerHeader.Text = "👥  รายชื่อผู้เล่นในแมพ"
PlayerHeader.TextColor3 = WHITE
PlayerHeader.Font = Enum.Font.GothamBold
PlayerHeader.TextSize = 14
PlayerHeader.TextXAlignment = Enum.TextXAlignment.Left

local SearchBox = Instance.new("TextBox", LeftPanel)
SearchBox.Size = UDim2.new(1, -24, 0, 38)
SearchBox.Position = UDim2.new(0, 12, 0, 42)
SearchBox.BackgroundColor3 = Color3.fromRGB(9, 9, 15)
SearchBox.TextColor3 = WHITE
SearchBox.PlaceholderColor3 = MUTED
SearchBox.PlaceholderText = "⌕  ค้นหาผู้เล่น..."
SearchBox.Text = ""
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 12
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
corner(SearchBox, 8)
stroke(SearchBox, Color3.fromRGB(75, 45, 105), 1, 0.1)

local ListScroll = Instance.new("ScrollingFrame", LeftPanel)
ListScroll.Size = UDim2.new(1, -24, 0, 194)
ListScroll.Position = UDim2.new(0, 12, 0, 88)
ListScroll.BackgroundColor3 = Color3.fromRGB(9, 9, 15)
ListScroll.BorderSizePixel = 0
ListScroll.ScrollBarThickness = 3
ListScroll.ScrollBarImageColor3 = PURPLE
ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
corner(ListScroll, 8)

local Layout = Instance.new("UIListLayout", ListScroll)
Layout.Padding = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- แผงขวา: ระบบเดิม ใช้ตัวแปรเดิมทั้งหมด แต่เอาช่องค้นหา ID เพลงออก
local RightPanel = Instance.new("Frame", MainFrame)
RightPanel.Size = UDim2.new(0.50, -18, 0, 300)
RightPanel.Position = UDim2.new(0.50, 6, 0, 82)
RightPanel.BackgroundColor3 = PANEL
corner(RightPanel, 10)
stroke(RightPanel, Color3.fromRGB(55, 35, 80), 1, 0.2)

local MusicHeader = Instance.new("TextLabel", RightPanel)
MusicHeader.Size = UDim2.new(1, -24, 0, 30)
MusicHeader.Position = UDim2.new(0, 12, 0, 7)
MusicHeader.BackgroundTransparency = 1
MusicHeader.Text = "♫  ระบบเจาะเพลง"
MusicHeader.TextColor3 = WHITE
MusicHeader.Font = Enum.Font.GothamBold
MusicHeader.TextSize = 14
MusicHeader.TextXAlignment = Enum.TextXAlignment.Left

local ButtonsContainer = Instance.new("Frame", RightPanel)
ButtonsContainer.Size = UDim2.new(1, -24, 0, 190)
ButtonsContainer.Position = UDim2.new(0, 12, 0, 44)
ButtonsContainer.BackgroundTransparency = 1

local BLayout = Instance.new("UIListLayout", ButtonsContainer)
BLayout.Padding = UDim.new(0, 5)
BLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function styleButton(btn, bg, textColor)
    btn.BackgroundColor3 = bg
    btn.TextColor3 = textColor or WHITE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = true
    corner(btn, 8)
    stroke(btn, Color3.fromRGB(100, 40, 150), 1, 0.35)
end

local GetIDBtn = Instance.new("TextButton", ButtonsContainer)
GetIDBtn.Size = UDim2.new(1, 0, 0, 34)
GetIDBtn.Text = "⚡  เจาะเพลง"
styleButton(GetIDBtn, PURPLE2, WHITE)

local ListenBtn = Instance.new("TextButton", ButtonsContainer)
ListenBtn.Size = UDim2.new(1, 0, 0, 34)
ListenBtn.Text = "🎧  ฟังเพลงผู้เล่น"
styleButton(ListenBtn, Color3.fromRGB(65, 25, 120), WHITE)

local GetJunkBtn = Instance.new("TextButton", ButtonsContainer)
GetJunkBtn.Size = UDim2.new(1, 0, 0, 34)
GetJunkBtn.Text = "🎵  เปิดเพลงตามขยะอย่างเดียว"
styleButton(GetJunkBtn, Color3.fromRGB(45, 20, 75), WHITE)
GetJunkBtn.Visible = IsLocalAdmin()

local ViewRawJunkBtn = Instance.new("TextButton", ButtonsContainer)
ViewRawJunkBtn.Size = UDim2.new(1, 0, 0, 34)
ViewRawJunkBtn.Text = "👁  ดู Raw ดิบ"
styleButton(ViewRawJunkBtn, Color3.fromRGB(50, 20, 80), WHITE)

local ViewInstantBtn = Instance.new("TextButton", ButtonsContainer)
ViewInstantBtn.Size = UDim2.new(1, 0, 0, 34)
ViewInstantBtn.Text = "⚡  ดูไอดีที่เจาะ Real-time"
styleButton(ViewInstantBtn, Color3.fromRGB(35, 55, 45), WHITE)

local ListenPanel = Instance.new("Frame", RightPanel)
ListenPanel.Size = UDim2.new(1, -24, 0, 42)
ListenPanel.Position = UDim2.new(0, 12, 1, -52)
ListenPanel.BackgroundColor3 = PANEL2
corner(ListenPanel, 8)

local ListenTitle = Instance.new("TextLabel", ListenPanel)
ListenTitle.Size = UDim2.new(1, -20, 0, 22)
ListenTitle.Position = UDim2.new(0, 10, 0, 3)
ListenTitle.BackgroundTransparency = 1
ListenTitle.Text = "🎧  ฟังเพลงผู้เล่น"
ListenTitle.TextColor3 = WHITE
ListenTitle.Font = Enum.Font.GothamBold
ListenTitle.TextSize = 11
ListenTitle.TextXAlignment = Enum.TextXAlignment.Left

local ListenHint = Instance.new("TextLabel", ListenPanel)
ListenHint.Size = UDim2.new(1, -20, 0, 15)
ListenHint.Position = UDim2.new(0, 10, 0, 22)
ListenHint.BackgroundTransparency = 1
ListenHint.Text = "เลือกผู้เล่นทางซ้าย แล้วกดปุ่มฟังเพลง"
ListenHint.TextColor3 = MUTED
ListenHint.Font = Enum.Font.Gotham
ListenHint.TextSize = 8
ListenHint.TextWrapped = true
ListenHint.TextXAlignment = Enum.TextXAlignment.Left

-- แถบสถานะด้านล่าง
StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(0.50, -18, 0, 44)
StatusLabel.Position = UDim2.new(0, 12, 1, -108)
StatusLabel.BackgroundColor3 = PANEL
StatusLabel.BackgroundTransparency = 0
StatusLabel.Text = "เลือกชื่อผู้เล่นก่อนดึงไอดีเพลง"
StatusLabel.TextColor3 = PURPLE
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.TextWrapped = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
corner(StatusLabel, 8)
stroke(StatusLabel, Color3.fromRGB(75, 35, 105), 1, 0.25)

local RefreshBtn = Instance.new("TextButton", MainFrame)
RefreshBtn.Size = UDim2.new(0.50, -18, 0, 44)
RefreshBtn.Position = UDim2.new(0.50, 6, 1, -108)
RefreshBtn.BackgroundColor3 = PANEL
RefreshBtn.Text = "🔄  รีเฟรชรายชื่อ"
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 10
RefreshBtn.TextColor3 = WHITE
corner(RefreshBtn, 8)
stroke(RefreshBtn, Color3.fromRGB(75, 35, 105), 1, 0.25)

-- Footer: ผู้ใช้ / สถานะ / เวลา / Ping แบบ Real-time
local Footer = Instance.new("Frame", MainFrame)
Footer.Size = UDim2.new(1, -24, 0, 44)
Footer.Position = UDim2.new(0, 12, 1, -56)
Footer.BackgroundColor3 = Color3.fromRGB(10, 10, 17)
corner(Footer, 8)
stroke(Footer, Color3.fromRGB(55, 35, 80), 1, 0.2)

local UserInfoLabel = Instance.new("TextLabel", Footer)
UserInfoLabel.Size = UDim2.new(0.30, -6, 1, 0)
UserInfoLabel.Position = UDim2.new(0, 8, 0, 0)
UserInfoLabel.BackgroundTransparency = 1
UserInfoLabel.Text = "👤  @" .. LocalPlayer.Name
UserInfoLabel.TextColor3 = WHITE
UserInfoLabel.Font = Enum.Font.GothamBold
UserInfoLabel.TextSize = 9
UserInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
UserInfoLabel.TextTruncate = Enum.TextTruncate.AtEnd

local SafetyLabel = Instance.new("TextLabel", Footer)
SafetyLabel.Size = UDim2.new(0.24, 0, 1, 0)
SafetyLabel.Position = UDim2.new(0.30, 0, 0, 0)
SafetyLabel.BackgroundTransparency = 1
SafetyLabel.Text = "🛡 ปลอดภัย"
SafetyLabel.TextColor3 = GREEN
SafetyLabel.Font = Enum.Font.GothamBold
SafetyLabel.TextSize = 9
SafetyLabel.TextXAlignment = Enum.TextXAlignment.Center

local TimeLabel = Instance.new("TextLabel", Footer)
TimeLabel.Size = UDim2.new(0.23, 0, 1, 0)
TimeLabel.Position = UDim2.new(0.54, 0, 0, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "◷  --:--:--"
TimeLabel.TextColor3 = PURPLE
TimeLabel.Font = Enum.Font.GothamBold
TimeLabel.TextSize = 9
TimeLabel.TextXAlignment = Enum.TextXAlignment.Center

local PingLabel = Instance.new("TextLabel", Footer)
PingLabel.Size = UDim2.new(0.23, -8, 1, 0)
PingLabel.Position = UDim2.new(0.77, 0, 0, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "⌁  PING: -- ms"
PingLabel.TextColor3 = GREEN
PingLabel.Font = Enum.Font.GothamBold
PingLabel.TextSize = 9
PingLabel.TextXAlignment = Enum.TextXAlignment.Right
PingLabel.TextTruncate = Enum.TextTruncate.AtEnd

-- ระบบเวลา + Ping แบบ Real-time
local StatsService = game:GetService("Stats")

local function getRealTimePing()
    local ping = nil

    pcall(function()
        local network = StatsService:FindFirstChild("Network")
        if network then
            local serverStats = network:FindFirstChild("ServerStatsItem")
            if serverStats then
                local dataPing = serverStats:FindFirstChild("Data Ping")
                if dataPing then
                    ping = tonumber(string.match(dataPing:GetValueString(), "%d+"))
                end
            end
        end
    end)

    if not ping then
        pcall(function()
            ping = math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5)
        end)
    end

    return ping
end

task.spawn(function()
    while ScreenGui.Parent do
        TimeLabel.Text = "◷  " .. os.date("%H:%M:%S")

        local ping = getRealTimePing()
        if ping then
            PingLabel.Text = "⌁  PING: " .. tostring(ping) .. " ms"
            if ping <= 80 then
                PingLabel.TextColor3 = GREEN
            elseif ping <= 150 then
                PingLabel.TextColor3 = Color3.fromRGB(255, 215, 80)
            else
                PingLabel.TextColor3 = RED
            end
        else
            PingLabel.Text = "⌁  PING: -- ms"
            PingLabel.TextColor3 = MUTED
        end

        task.wait(0.5)
    end
end)

-- ==================== Responsive Layout ====================
local Camera = workspace.CurrentCamera

local function updateResponsiveLayout()
    if not MainFrame.Parent then return end

    local viewport = Camera and Camera.ViewportSize or Vector2.new(800, 600)
    local compact = viewport.X < 650 or viewport.Y < 500 or viewport.Y > viewport.X * 1.15

    if compact then
        -- มือถือ/จอเตี้ย: คำนวณจากขนาดจริงของ MainFrame กัน UI ล้นจอ
        local frameH = math.max(MainFrame.AbsoluteSize.Y, 300)
        local shortScreen = frameH < 430

        local topH = shortScreen and 46 or 54
        local footerH = shortScreen and 28 or 36
        local actionH = shortScreen and 30 or 36
        local gap = shortScreen and 5 or 8
        local contentTop = topH + 12
        local bottomReserved = footerH + actionH + (gap * 3) + 10
        local contentH = math.max(frameH - contentTop - bottomReserved, 170)

        -- มือถือ: เปลี่ยนเฉพาะการจัดวางให้แถบเลือกผู้เล่นอยู่ซ้าย
        -- ส่วนปุ่ม/ระบบเดิมยังอยู่ฝั่งขวาเหมือนเดิม
        local leftW = 0.36
        local rightW = 0.64

        TopBar.Size = UDim2.new(1, -16, 0, topH)
        TopBar.Position = UDim2.new(0, 8, 0, 8)
        Title.TextSize = shortScreen and 13 or 16
        Subtitle.TextSize = shortScreen and 6 or 7
        CloseBtn.Size = UDim2.new(0, shortScreen and 26 or 34, 0, shortScreen and 26 or 34)
        CloseBtn.Position = UDim2.new(1, -(shortScreen and 31 or 40), 0, shortScreen and 10 or 14)
        CloseBtn.TextSize = shortScreen and 19 or 25

        LeftPanel.Size = UDim2.new(leftW, -10, 1, -(contentTop + bottomReserved))
        LeftPanel.Position = UDim2.new(0, 8, 0, contentTop)
        PlayerHeader.TextSize = shortScreen and 8 or 10
        SearchBox.Size = UDim2.new(1, -12, 0, shortScreen and 24 or 28)
        SearchBox.Position = UDim2.new(0, 6, 0, shortScreen and 28 or 32)
        SearchBox.TextSize = shortScreen and 7 or 9
        ListScroll.Size = UDim2.new(1, -12, 1, -(shortScreen and 58 or 66))
        ListScroll.Position = UDim2.new(0, 6, 0, shortScreen and 57 or 66)
        ListScroll.ScrollBarThickness = 3

        RightPanel.Size = UDim2.new(rightW, -14, 1, -(contentTop + bottomReserved))
        RightPanel.Position = UDim2.new(leftW, 0, 0, contentTop)
        MusicHeader.TextSize = shortScreen and 9 or 11

        local buttonH = shortScreen and 18 or 28
        local buttonGap = shortScreen and 2 or 4
        ButtonsContainer.Size = UDim2.new(1, -12, 0, (buttonH * 5) + (buttonGap * 4))
        ButtonsContainer.Position = UDim2.new(0, 6, 0, shortScreen and 26 or 32)
        BLayout.Padding = UDim.new(0, buttonGap)

        for _, btn in ipairs({GetIDBtn, ListenBtn, GetJunkBtn, ViewRawJunkBtn, ViewInstantBtn}) do
            btn.Size = UDim2.new(1, 0, 0, buttonH)
            btn.TextSize = shortScreen and 7 or 9
        end

        ListenPanel.Size = UDim2.new(1, -12, 0, shortScreen and 20 or 32)
        ListenPanel.Position = UDim2.new(0, 6, 1, -(shortScreen and 25 or 40))
        ListenPanel.Visible = not shortScreen
        ListenTitle.TextSize = shortScreen and 6 or 8
        ListenHint.TextSize = shortScreen and 5 or 7

        StatusLabel.Size = UDim2.new(0.52, -10, 0, actionH)
        StatusLabel.Position = UDim2.new(0, 8, 1, -(footerH + actionH + gap))
        StatusLabel.TextSize = shortScreen and 6 or 8

        RefreshBtn.Size = UDim2.new(0.48, -10, 0, actionH)
        RefreshBtn.Position = UDim2.new(0.52, 2, 1, -(footerH + actionH + gap))
        RefreshBtn.TextSize = shortScreen and 6 or 8

        Footer.Size = UDim2.new(1, -16, 0, footerH)
        Footer.Position = UDim2.new(0, 8, 1, -(footerH + 4))
        UserInfoLabel.TextSize = shortScreen and 5 or 7
        SafetyLabel.TextSize = shortScreen and 5 or 7
        TimeLabel.TextSize = shortScreen and 5 or 7
        PingLabel.TextSize = shortScreen and 5 or 7
    else
        -- จอใหญ่/แนวนอน: คงโครงสร้าง 2 ฝั่งแบบเดิม
        TopBar.Size = UDim2.new(1, -24, 0, 62)
        TopBar.Position = UDim2.new(0, 12, 0, 10)
        Title.TextSize = 20
        Subtitle.TextSize = 9

        LeftPanel.Size = UDim2.new(0.52, -18, 0, 350)
        LeftPanel.Position = UDim2.new(0, 12, 0, 82)
        PlayerHeader.TextSize = 14
        SearchBox.Size = UDim2.new(1, -24, 0, 38)
        SearchBox.Position = UDim2.new(0, 12, 0, 42)
        SearchBox.TextSize = 12
        ListScroll.Size = UDim2.new(1, -24, 0, 244)
        ListScroll.Position = UDim2.new(0, 12, 0, 88)

        RightPanel.Size = UDim2.new(0.48, -18, 0, 350)
        RightPanel.Position = UDim2.new(0.52, 6, 0, 82)
        MusicHeader.TextSize = 14
        ButtonsContainer.Size = UDim2.new(1, -24, 0, 210)
        ButtonsContainer.Position = UDim2.new(0, 12, 0, 44)

        for _, btn in ipairs({GetIDBtn, ListenBtn, GetJunkBtn, ViewRawJunkBtn, ViewInstantBtn}) do
            btn.Size = UDim2.new(1, 0, 0, 34)
            btn.TextSize = 13
        end

        ListenPanel.Visible = true
        ListenPanel.Size = UDim2.new(1, -24, 0, 42)
        ListenPanel.Position = UDim2.new(0, 12, 1, -52)
        ListenTitle.TextSize = 11
        ListenHint.TextSize = 8

        StatusLabel.Size = UDim2.new(0.52, -18, 0, 44)
        StatusLabel.Position = UDim2.new(0, 12, 1, -108)
        StatusLabel.TextSize = 10

        RefreshBtn.Size = UDim2.new(0.48, -18, 0, 44)
        RefreshBtn.Position = UDim2.new(0.52, 6, 1, -108)
        RefreshBtn.TextSize = 10

        Footer.Size = UDim2.new(1, -24, 0, 44)
        Footer.Position = UDim2.new(0, 12, 1, -56)
        UserInfoLabel.TextSize = 9
        SafetyLabel.TextSize = 9
        TimeLabel.TextSize = 9
        PingLabel.TextSize = 9
    end
end

updateResponsiveLayout()
if Camera then
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveLayout)
end
-- ==================== Welcome / Login Gate ====================
-- แสดงชื่อ @username + ตัวละครของผู้เล่นก่อนเริ่มใช้งาน UI
local WelcomeFrame = Instance.new("Frame", ScreenGui)
WelcomeFrame.AnchorPoint = Vector2.new(0.5, 0.5)
WelcomeFrame.Size = UDim2.new(0.42, 0, 0.52, 0)
WelcomeFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
WelcomeFrame.BackgroundColor3 = BG
WelcomeFrame.BackgroundTransparency = 0.08
WelcomeFrame.ZIndex = 30
corner(WelcomeFrame, 16)

local WelcomeStroke = stroke(WelcomeFrame, Color3.fromRGB(215, 75, 255), 2, 0.02)

local WelcomeGlow = Instance.new("UIStroke", WelcomeFrame)
WelcomeGlow.Color = Color3.fromRGB(170, 45, 255)
WelcomeGlow.Thickness = 5
WelcomeGlow.Transparency = 0.72

local WelcomeTitle = Instance.new("TextLabel", WelcomeFrame)
WelcomeTitle.Size = UDim2.new(1, -30, 0, 38)
WelcomeTitle.Position = UDim2.new(0, 15, 0, 14)
WelcomeTitle.BackgroundTransparency = 1
WelcomeTitle.Text = "WELCOME"
WelcomeTitle.TextColor3 = WHITE
WelcomeTitle.Font = Enum.Font.GothamBlack
WelcomeTitle.TextScaled = true
WelcomeTitle.TextXAlignment = Enum.TextXAlignment.Center
WelcomeTitle.ZIndex = 31

local WelcomeTitleSize = Instance.new("UITextSizeConstraint", WelcomeTitle)
WelcomeTitleSize.MinTextSize = 18
WelcomeTitleSize.MaxTextSize = 30

local WelcomeSub = Instance.new("TextLabel", WelcomeFrame)
WelcomeSub.Size = UDim2.new(1, -30, 0, 22)
WelcomeSub.Position = UDim2.new(0, 15, 0, 52)
WelcomeSub.BackgroundTransparency = 1
WelcomeSub.Text = "HONKUKI MUSIC CONTROL"
WelcomeSub.TextColor3 = PURPLE
WelcomeSub.Font = Enum.Font.GothamBold
WelcomeSub.TextSize = 10
WelcomeSub.TextXAlignment = Enum.TextXAlignment.Center
WelcomeSub.ZIndex = 31

local Avatar = Instance.new("ImageLabel", WelcomeFrame)
Avatar.AnchorPoint = Vector2.new(0.5, 0)
Avatar.Size = UDim2.new(0, 104, 0, 104)
Avatar.Position = UDim2.new(0.5, 0, 0, 82)
Avatar.BackgroundColor3 = PANEL2
Avatar.Image = ""
Avatar.ScaleType = Enum.ScaleType.Crop
Avatar.ZIndex = 31
corner(Avatar, 52)
stroke(Avatar, Color3.fromRGB(220, 95, 255), 2, 0.02)

local WelcomeUser = Instance.new("TextLabel", WelcomeFrame)
WelcomeUser.Size = UDim2.new(1, -24, 0, 28)
WelcomeUser.Position = UDim2.new(0, 12, 0, 196)
WelcomeUser.BackgroundTransparency = 1
WelcomeUser.Text = "@"
WelcomeUser.TextColor3 = WHITE
WelcomeUser.Font = Enum.Font.GothamBold
WelcomeUser.TextSize = 17
WelcomeUser.TextXAlignment = Enum.TextXAlignment.Center
WelcomeUser.TextTruncate = Enum.TextTruncate.AtEnd
WelcomeUser.ZIndex = 31

local WelcomeDisplay = Instance.new("TextLabel", WelcomeFrame)
WelcomeDisplay.Size = UDim2.new(1, -24, 0, 20)
WelcomeDisplay.Position = UDim2.new(0, 12, 0, 224)
WelcomeDisplay.BackgroundTransparency = 1
WelcomeDisplay.Text = "กำลังเตรียมระบบ..."
WelcomeDisplay.TextColor3 = MUTED
WelcomeDisplay.Font = Enum.Font.Gotham
WelcomeDisplay.TextSize = 9
WelcomeDisplay.TextXAlignment = Enum.TextXAlignment.Center
WelcomeDisplay.ZIndex = 31

local StartRunBtn = Instance.new("TextButton", WelcomeFrame)
StartRunBtn.Size = UDim2.new(1, -34, 0, 44)
StartRunBtn.Position = UDim2.new(0, 17, 1, -62)
StartRunBtn.BackgroundColor3 = Color3.fromRGB(155, 35, 240)
StartRunBtn.Text = "▶  เริ่มการรันสคริปต์"
StartRunBtn.TextColor3 = WHITE
StartRunBtn.Font = Enum.Font.GothamBold
StartRunBtn.TextSize = 12
StartRunBtn.AutoButtonColor = false
StartRunBtn.ZIndex = 31
corner(StartRunBtn, 10)

local StartStroke = stroke(StartRunBtn, Color3.fromRGB(235, 125, 255), 1, 0.05)

local function loadWelcomeIdentity()
    WelcomeUser.Text = "@ " .. LocalPlayer.Name
    WelcomeDisplay.Text = LocalPlayer.DisplayName ~= LocalPlayer.Name
        and LocalPlayer.DisplayName
        or "ผู้ใช้ Roblox"

    task.spawn(function()
        local ok, content = pcall(function()
            return Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.AvatarBust,
                Enum.ThumbnailSize.Size180x180
            )
        end)
        if ok and content then
            Avatar.Image = content
        end
    end)
end

-- Welcome เป็นหน้าต่างเดียวที่อนุญาตให้เห็นก่อนเริ่ม
MainFrame.Visible = false
if JunkFrame and JunkFrame.Parent then
    JunkFrame.Visible = false
end
WelcomeFrame.Visible = true

loadWelcomeIdentity()

-- ไฟแต่งแบบนุ่ม: หายใจเบา ๆ ไม่กระพริบแรง
task.spawn(function()
    local t = 0
    while ScreenGui.Parent and WelcomeFrame.Parent do
        t += 0.035
        local pulse = 0.62 + (math.sin(t * 1.35) * 0.10)
        WelcomeGlow.Transparency = pulse
        StartStroke.Transparency = 0.04 + ((math.sin(t * 1.35) + 1) * 0.035)
        task.wait(0.035)
    end
end)

-- ล็อกการเปิด UI หลักไว้จนกว่าจะกดเริ่ม
local ScriptStarted = false

StartRunBtn.MouseButton1Click:Connect(function()
    if ScriptStarted then return end
    ScriptStarted = true
    StartRunBtn.Active = false
    StartRunBtn.Text = "✓  กำลังเริ่มระบบ..."

    local fadeInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local fade = TweenService:Create(WelcomeFrame, fadeInfo, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.39, 0, 0.48, 0)
    })
    local strokeFade = TweenService:Create(WelcomeStroke, fadeInfo, {Transparency = 1})
    local glowFade = TweenService:Create(WelcomeGlow, fadeInfo, {Transparency = 1})

    fade:Play()
    strokeFade:Play()
    glowFade:Play()

    fade.Completed:Connect(function()
        WelcomeFrame.Visible = false
        if JunkFrame and JunkFrame.Parent then
            JunkFrame.Visible = false
        end
        MainFrame.Visible = true
        task.defer(function() toggleUI(true) end)
    end)
end)

-- ==================== ปุ่มเปิด UI + ไฟวนรอบ "รูปภาพ" ====================
local ToggleHolder = Instance.new("Frame", ScreenGui)
ToggleHolder.Size = UDim2.new(0, 64, 0, 64)
ToggleHolder.Position = UDim2.new(0.02, 0, 0.50, -32)
ToggleHolder.BackgroundTransparency = 1
ToggleHolder.ZIndex = 10

local ToggleBtn = Instance.new("ImageButton", ToggleHolder)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.5, -25, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
ToggleBtn.Image = "rbxassetid://104747656190057"
ToggleBtn.ScaleType = Enum.ScaleType.Fit
ToggleBtn.ZIndex = 12
ToggleBtn.Active = true
ToggleBtn.AutoButtonColor = false
corner(ToggleBtn, 14)
setDrag(ToggleHolder, ToggleHolder)

-- เส้นหลักรอบรูป
local IconStroke = Instance.new("UIStroke", ToggleBtn)
IconStroke.Thickness = 2
IconStroke.Color = PURPLE
IconStroke.Transparency = 0.05

-- แสงวิ่งเส้นที่ 1 รอบรูป
local IconGlow1 = Instance.new("UIStroke", ToggleBtn)
IconGlow1.Thickness = 4
IconGlow1.Transparency = 0.25
IconGlow1.Color = PURPLE

local IconGradient1 = Instance.new("UIGradient", IconGlow1)
IconGradient1.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(50, 0, 90)),
    ColorSequenceKeypoint.new(0.18, Color3.fromRGB(80, 0, 150)),
    ColorSequenceKeypoint.new(0.42, Color3.fromRGB(255, 100, 255)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 245, 255)),
    ColorSequenceKeypoint.new(0.58, Color3.fromRGB(255, 100, 255)),
    ColorSequenceKeypoint.new(0.82, Color3.fromRGB(80, 0, 150)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(50, 0, 90))
})

-- แสงวิ่งเส้นที่ 2 รอบรูป วิ่งสวนทาง
local IconGlow2 = Instance.new("UIStroke", ToggleBtn)
IconGlow2.Thickness = 2
IconGlow2.Transparency = 0.05
IconGlow2.Color = PURPLE

local IconGradient2 = Instance.new("UIGradient", IconGlow2)
IconGradient2.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(70, 0, 130)),
    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(120, 20, 220)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 190, 255)),
    ColorSequenceKeypoint.new(0.65, Color3.fromRGB(120, 20, 220)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(70, 0, 130))
})

task.spawn(function()
    local rotation = 0
    while ScreenGui.Parent do
        rotation = (rotation + 2.5) % 360
        IconGradient1.Rotation = rotation
        IconGradient2.Rotation = (360 - rotation) % 360
        task.wait(0.04)
    end
end)

-- ==================== หน้าต่างรองส่อง Real-time ====================


local JunkFrame = Instance.new("Frame", ScreenGui)
JunkFrame.Size = UDim2.new(0.64, 0, 0.62, 0)
JunkFrame.AnchorPoint = Vector2.new(0.5, 0.5)
JunkFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
JunkFrame.BackgroundColor3 = BG
JunkFrame.BackgroundTransparency = 1
JunkFrame.Visible = false
JunkFrame.ZIndex = 5
corner(JunkFrame, 14)

local jStroke = stroke(JunkFrame, Color3.fromRGB(205, 70, 255), 3, 0.01)
jStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local jLEDGradient = Instance.new("UIGradient", jStroke)
jLEDGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(65, 0, 120)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(150, 25, 255)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 220, 255)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(150, 25, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(65, 0, 120))
})

task.spawn(function()
    local rotation = 180
    while JunkFrame.Parent do
        rotation = (rotation + 2.2) % 360
        jLEDGradient.Rotation = rotation
        task.wait(0.045)
    end
end)

local JunkTopBar = Instance.new("Frame", JunkFrame)
JunkTopBar.Size = UDim2.new(1, -20, 0, 44)
JunkTopBar.Position = UDim2.new(0, 10, 0, 10)
JunkTopBar.BackgroundColor3 = PANEL
corner(JunkTopBar, 10)
setDrag(JunkFrame, JunkTopBar)

local JunkTitle = Instance.new("TextLabel", JunkTopBar)
JunkTitle.Size = UDim2.new(1, -20, 1, 0)
JunkTitle.Position = UDim2.new(0, 10, 0, 0)
JunkTitle.BackgroundTransparency = 1
JunkTitle.Text = "ปิดหน้าต่าง"
JunkTitle.TextColor3 = PURPLE
JunkTitle.Font = Enum.Font.GothamBold
JunkTitle.TextSize = 13
JunkTitle.TextXAlignment = Enum.TextXAlignment.Left

local JunkScroll = Instance.new("ScrollingFrame", JunkFrame)
JunkScroll.Size = UDim2.new(1, -20, 0, 292)
JunkScroll.Position = UDim2.new(0, 10, 0, 64)
JunkScroll.BackgroundColor3 = Color3.fromRGB(7, 7, 12)
JunkScroll.BorderSizePixel = 0
JunkScroll.ScrollBarThickness = 4
JunkScroll.ScrollBarImageColor3 = PURPLE
corner(JunkScroll, 9)

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
JunkCopyBtn.Size = UDim2.new(0.46, -15, 0, 36)
JunkCopyBtn.Position = UDim2.new(0, 10, 1, -48)
JunkCopyBtn.BackgroundColor3 = PURPLE2
JunkCopyBtn.Text = "📋  คัดลอกไอดีเพลงทั้งหมด"
JunkCopyBtn.Font = Enum.Font.GothamBold
JunkCopyBtn.TextSize = 11
JunkCopyBtn.TextColor3 = WHITE
corner(JunkCopyBtn, 8)

local JunkBackBtn = Instance.new("TextButton", JunkFrame)
JunkBackBtn.Size = UDim2.new(0.46, -15, 0, 36)
JunkBackBtn.Position = UDim2.new(0.54, 5, 1, -48)
JunkBackBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
JunkBackBtn.Text = "⬅️  ย้อนกลับ"
JunkBackBtn.Font = Enum.Font.GothamBold
JunkBackBtn.TextSize = 11
JunkBackBtn.TextColor3 = WHITE
corner(JunkBackBtn, 8)

-- ==================== ระบบ Animation ความสมูท (Tween) ====================
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function toggleUI(isOpen)
    if isOpen then
        MainFrame.Visible = true
        TweenService:Create(MainFrame, tweenInfo, {BackgroundTransparency = 0.15}):Play()
        TweenService:Create(mStroke, tweenInfo, {Transparency = 0.02}):Play()
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


local function updateJunkResponsive()
    if not JunkFrame.Parent then return end
    local viewport = Camera and Camera.ViewportSize or Vector2.new(800, 600)
    local compact = viewport.X < 650 or viewport.Y < 500 or viewport.Y > viewport.X * 1.15

    if compact then
        JunkFrame.Size = UDim2.new(0.82, 0, 0.66, 0)
        JunkTopBar.Size = UDim2.new(1, -16, 0, 38)
        JunkTopBar.Position = UDim2.new(0, 8, 0, 8)
        JunkScroll.Size = UDim2.new(1, -16, 0, 0.62)
        JunkScroll.Position = UDim2.new(0, 8, 0, 54)
        JunkCopyBtn.Size = UDim2.new(0.48, -10, 0, 32)
        JunkCopyBtn.Position = UDim2.new(0, 8, 1, -40)
        JunkBackBtn.Size = UDim2.new(0.48, -10, 0, 32)
        JunkBackBtn.Position = UDim2.new(0.52, 2, 1, -40)
        JunkTitle.TextSize = 10
        JunkTextLabel.TextSize = 9
    else
        JunkFrame.Size = UDim2.new(0.64, 0, 0.62, 0)
        JunkTopBar.Size = UDim2.new(1, -20, 0, 44)
        JunkTopBar.Position = UDim2.new(0, 10, 0, 10)
        JunkScroll.Size = UDim2.new(1, -20, 0, 0.70)
        JunkScroll.Position = UDim2.new(0, 10, 0, 64)
        JunkCopyBtn.Size = UDim2.new(0.46, -15, 0, 36)
        JunkCopyBtn.Position = UDim2.new(0, 10, 1, -48)
        JunkBackBtn.Size = UDim2.new(0.46, -15, 0, 36)
        JunkBackBtn.Position = UDim2.new(0.54, 5, 1, -48)
        JunkTitle.TextSize = 13
        JunkTextLabel.TextSize = 11
    end
end

-- เรียกหลังประกาศฟังก์ชันแล้วเท่านั้น
updateJunkResponsive()
if Camera then
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateJunkResponsive)
end

local function toggleJunkUI(isOpen)
    if not ScriptStarted then
        if JunkFrame and JunkFrame.Parent then
            JunkFrame.Visible = false
        end
        return
    end
    if isOpen then
        JunkFrame.Visible = true
        TweenService:Create(JunkFrame, tweenInfo, {BackgroundTransparency = 0.1}):Play()
        TweenService:Create(jStroke, tweenInfo, {Transparency = 0.02}):Play()
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
            -- RAW/Instant ใช้ source เดียวกับปุ่มฟัง: เสียงที่ client กำลังได้ยินจริง
            -- RAW และ Instant ต้องใช้เฉพาะเสียงที่กำลังเล่น/ได้ยินจริง
            local soundObjects = getHeardMusicSounds(targetPlayer)

            if CurrentViewMode == 1 then
                JunkTitle.Text = "RAW JUNK VIEWER (ขยะดิบทั้งหมด 100%)"
                jStroke.Color = Color3.fromRGB(140, 20, 230)
                JunkCopyBtn.BackgroundColor3 = Color3.fromRGB(140, 20, 230)
                
                if #soundObjects == 0 then 
                    outputText = "❌ ไม่พบออบเจกต์เสียงบนตัวผู้เล่นนี้"
                else
                    for i, obj in ipairs(soundObjects) do
                        outputText = outputText .. string.format(
                            "[%d] REAL SOUND\nObject: %s\nSoundId: %s\nPlaying: %s | Loudness: %.1f | Volume: %.2f | Time: %.2f\n\n",
                            i, obj:GetFullName(), obj.SoundId, tostring(obj.IsPlaying),
                            tonumber(obj.PlaybackLoudness) or 0, tonumber(obj.Volume) or 0, tonumber(obj.TimePosition) or 0
                        )
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
                        -- เจาะจาก SoundId ของเสียงจริงเท่านั้น
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
                btn.TextSize = 12
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

            local activeSounds = getHeardMusicSounds(p)
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
        StatusLabel.Text = "❌ ไม่สามารถดึงข้อมูลของ ผู้เล่นนี้ได้Protection Admin"
        return
    end

    local targetPlayer = Players:FindFirstChild(CurrentSelectedPlayer.Name)
    if not targetPlayer or not targetPlayer.Character then
        StatusLabel.Text = "❌ ไม่พบผู้เล่นหรือ Boombox"
        return
    end

    StatusLabel.Text = "🔍 กำลังจับเสียงจาก Boombox / รีโมทรถ..."

    -- รีโมท 1NoMoto1rVehicle1s เป็น RemoteEvent สำหรับสั่งเพลงรถ
    -- ฝั่ง client จะไม่สามารถอ่านค่า FireServer ย้อนกลับจาก RemoteEvent ได้โดยตรง
    -- ดังนั้นจับผลของรีโมทจาก Sound ที่กำลังเล่นจริงในรถแทน
    local vehicleRemote = ReplicatedStorage:FindFirstChild("RE")
        and ReplicatedStorage.RE:FindFirstChild("1NoMoto1rVehicle1s")

    -- ใช้ตัวเดียวกับระบบ "ฟังเพลง" แต่จัดอันดับด้วย PlaybackLoudness
    -- เพื่อเอา Sound ที่ client กำลังได้ยินจริงก่อน
    local heardSounds = getHeardMusicSounds(targetPlayer)
    local realSound = heardSounds[1]

    if not realSound then
        StatusLabel.Text = vehicleRemote
            and "❌ ไม่พบเสียงเพลงที่ client กำลังได้ยินจากผู้เล่น/รถ"
            or "❌ ไม่พบเสียงเพลงที่กำลังเล่น"
        return
    end

    -- ใช้ตัวแปร/ระบบเจาะ ID เดิมของคุณ แต่เจาะจากเสียงจริงที่เล่นอยู่เพียงเสียงเดียว
    local rawId = realSound.SoundId or ""
    local decoded = deepDecode(rawId)
    local searchText = (decoded ~= "" and decoded) or rawId
    local extractedIds = extractIDsFromPattern(searchText)

    if #extractedIds == 0 then
        for num in string.gmatch(searchText, "%d+") do
            if not BlockedIDs[num] then
                extractedIds = {num}
                break
            end
        end
    end

    if #extractedIds > 0 then
        local realId = extractedIds[1]
        copyToClipboard(realId)
        StatusLabel.Text = "📋 เจาะเสียงจริงได้ 1 ID แล้ว!"
    else
        StatusLabel.Text = "❌ ไม่สามารถเจาะ ID จากเสียงที่กำลังเล่นได้"
    end
end)

ListenBtn.MouseButton1Click:Connect(function()
    -- ถ้ากำลังฟังอยู่ ให้หยุดด้วยปุ่มเดิมทันที
    if IsListeningToPlayerMusic and PrivateMusicSound then
        PrivateMusicSound:Stop()
        PrivateMusicSound:Destroy()
        PrivateMusicSound = nil
        IsListeningToPlayerMusic = false
        ListenBtn.Text = "🎧 ฟังเพลงผู้เล่น"
        StatusLabel.Text = "⏹️ หยุดฟังเพลงแล้ว"
        return
    end

    if not CurrentSelectedPlayer then
        StatusLabel.Text = "⚠️ โปรดเลือกชื่อผู้เล่นก่อนฟังเพลง!"
        return
    end

    local targetPlayer = Players:FindFirstChild(CurrentSelectedPlayer.Name)
    if not targetPlayer then
        StatusLabel.Text = "❌ ไม่พบผู้เล่น"
        return
    end

    local success, result = listenToPlayerMusic(targetPlayer)
    if success then
        IsListeningToPlayerMusic = true
        ListenBtn.Text = "⏹️ หยุดฟังเพลง"
        StatusLabel.Text = "🎧 กำลังฟังเพลงของ " .. targetPlayer.DisplayName .. " (เฉพาะคุณ)"
    else
        StatusLabel.Text = "❌ " .. result
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
        local soundObjects = getHeardMusicSounds(targetPlayer)
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

local toggleBusy = false

ToggleBtn.MouseButton1Click:Connect(function()
    if not ScriptStarted then
        return
    end
    -- ถ้าเพิ่งลากปุ่ม อย่าถือว่าเป็นการกดเปิด UI
    -- ทำให้ปล่อยนิ้วหลังลากแล้วไม่เปิด/ปิด UI เอง
    if ToggleHolder:GetAttribute("DragMoved") then
        return
    end

    if toggleBusy then
        return
    end
    toggleBusy = true

    if MainFrame.Visible and MainFrame.BackgroundTransparency < 0.5 then
        toggleUI(false)
    else
        toggleUI(true)
        refreshPlayers()
    end

    task.delay(0.18, function()
        toggleBusy = false
    end)
end)

task.spawn(function()
    while true do
        task.wait((JunkFrame and JunkFrame.Visible) and 0.25 or 2)
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
