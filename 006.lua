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
    ["00110336014635746"] = true,
["00121652614070954"] = true,
["0080069998728269"] = true,
["00120164064225769"] = true,
["0091859155312932"] = true,
["00129045578991245"] = true,
["0089473100926016"] = true,
["00118351471702293"] = true,
["0098715293175671"] = true,
["00122559725856366"] = true,
["00100859018858272"] = true,
["0081351546670055"] = true,
["00109322835351432"] = true,
["00100920432178512"] = true,
["74203452628378"] = true,
["12752632647422"] = true,
["0"] = true,
["465261752"] = true,
["00145691574"] = true,
["002134675"] = true,
["007424884225"] = true,
["00716271224"] = true,
["134366188285514"] = true,
["0082966767543133"] = true,
["102174134709231"] = true,
["0071983146788880"] = true,
["115967348422331"] = true,
["0074137426221090"] = true,
["393896046549901"] = true,
["00139229782932442"] = true,
["0097699114114271"] = true,
["00138118304933431"] = true,
["127515921586975"] = true,
["00124769473122070"] = true,
["109356885030613"] = true,
["00138407858204990"] = true,
["118939739460633"] = true,
["00104445637963020"] = true,
["0093844053292914"] = true,
["0097188886257764"] = true,
["0071934965392436"] = true,
["00111560286322896"] = true,
["122933134275091"] = true,
["0095796504549340"] = true,
["0075485931767123"] = true,
["0082815462229216"] = true,
["2805"] = true,
["79"] = true,
["00136511263491635"] = true,
["00115820239234050"] = true,
["0074612331354602"] = true,
["0086367285840389"] = true,
["588"] = true,
["35"] = true,
["21"] = true,
["001"] = true,
["1"] = true,
["12"] = true,
["13"] = true,
["3"] = true,
["0097191657611517"] = true,
["65"] = true,
["0956"] = true,
["2"] = true,
["0085970658794633"] = true,
["0097285892199649"] = true,
["16"] = true,
["15"] = true,
["121"] = true,
["0546"] = true,
["117847"] = true,
["6"] = true,
["5"] = true,
["62"] = true,
["69560000"] = true,
["00015"] = true,
["0085970658794633418"] = true,
["1001"] = true,
["101"] = true,
["1533442192"] = true,
["60"] = true,
["10010"] = true,
["7505150"] = true,
["32"] = true,
["66"] = true,
["0085373130121712"] = true,
["3961"] = true,
["10"] = true,
["00692930"] = true,
["1001001"] = true,
["178"] = true,
["607"] = true,
["546"] = true,
["00115440201770223"] = true,
["0072151193134083"] = true,
["0012433692789387"] = true,
["63"] = true,
["1101"] = true,
["19"] = true,
["8"] = true,
["4"] = true,
["11001"] = true,
["111"] = true,
["0011"] = true,
["110"] = true,
["11"] = true,
["100"] = true,
["04"] = true,
["84"] = true,
["4294967215"] = true,
["1000"] = true,
["10100"] = true,
["182147483648"] = true,
["51550"] = true,
["57"] = true,
["89932"] = true,
["7184"] = true,
["06"] = true,
["260"] = true,
["47"] = true,
["4294606930"] = true,
["22"] = true,
["73"] = true,
["22883320886"] = true,
["41"] = true,
["00124336927893877"] = true,
["0607"] = true,
["14"] = true,
["01"] = true,
["01000111"] = true,
["2774945595"] = true,
["0036"] = true,
["30"] = true,
["0099445078556609"] = true,
["1100011"] = true,
["1000111"] = true,
["11100"] = true,
["81"] = true,
["00395796504549340"] = true,
["4503599627370496"] = true,
["11111111"] = true,
["20"] = true,
["0016"] = true,
["10111"] = true,
["18"] = true,
["11010"] = true,
["20447"] = true,
["9892"] = true,
["20487"] = true,
["23"] = true,
["37"] = true,
["250"] = true,
["1101100"] = true,
["570"] = true,
["40"] = true,
["480"] = true,
["34405"] = true,
["119"] = true,
["179"] = true,
["1110111"] = true,
["1000011"] = true,
["1101010"] = true,
["170"] = true,
["1111101"] = true,
["56"] = true,
["38"] = true,
["1710"] = true,
["1100"] = true,
["64"] = true,
["24"] = true,
["59"] = true,
["996"] = true,
["25"] = true,
["10101000"] = true,
["101000110"] = true,
["54"] = true,
["74"] = true,
["370"] = true,
["1001101"] = true,
["629"] = true,
["124312171567179"] = true,
["7702"] = true,
["002171567179"] = true,
["53"] = true,
["7941"] = true,
["0029077"] = true,
["230"] = true,
["265"] = true,
["1011011"] = true,
["05"] = true,
["1111110"] = true,
["0170"] = true,
["02"] = true,
["0082789416532034"] = true,
["0075700757370379"] = true,
["125960324833353"] = true,
["00131245885742260"] = true,
["0098562734934611"] = true,
["00129007389933701"] = true,
["133019184040350"] = true,
["0096988334455221"] = true,
["0076968950248241"] = true,
["00100621854951891"] = true,
["00119979660910986"] = true,
["0092243196265637"] = true,
["00105500425448833"] = true,
["0085413961594803"] = true,
["00124878745102520"] = true,
["0072711472062688"] = true,
["00121002202972474"] = true,
["00138487360713460"] = true,
["00129375108229179"] = true,
["00132162863553054"] = true,
["00117784978719124"] = true,
["0087561619643473"] = true,
["00106411575986508"] = true,
["00112430971967717"] = true,
["114849282762896"] = true,
["000074773082528950"] = true,
["00123695551548069"] = true,
["0000139217596062629"] = true,
["000083333464189701"] = true,
["0000127067247750124"] = true,
["00127310494243201"] = true,
["0000102449914659158"] = true,
["00104795305072330"] = true,
["00131489285474468"] = true,
["0000116876116040463"] = true,
["000078613960279188"] = true,
["000073001636074714"] = true,
["00104009312561952"] = true,
["0000102762173302964"] = true,
["000098721047139851"] = true,
["000094462863633197"] = true,
["00134764433458542"] = true,
["0000135334785125493"] = true,
["00122682054852344"] = true,
["0000119837621597588"] = true,
["000093602974995833"] = true,
["0000107769391019887"] = true,
["000090398320883813"] = true,
["000087871612084824"] = true,
["00123994197918972"] = true,
["0000125332244898885"] = true,
["000082633490322194"] = true,
["00140439256760765"] = true,
["0000138801603792399"] = true,
["00135209837340816"] = true,
["000072653741821355"] = true,
["00140667339171815"] = true,
["0000140580823167015"] = true,
["00139694762285253"] = true,
["0000140504265985079"] = true,
["00111109407506851"] = true,
["0000103415930328599"] = true,
["00136974179670066"] = true,
["0000139815305627554"] = true,
["00140245756477343"] = true,
["0000129098116998483"] = true,
["00125476440612900"] = true,
["0000138391671909650"] = true,
["000095131770144654"] = true,
["00140691985128867"] = true,
["000074203452628378"] = true,
["00140521045204459"] = true,
["00125498129824026"] = true,
["00136350225160627"] = true,
["0085290495098172"] = true,
["0073326647630445"] = true,
["0089824897586105"] = true,
["0093203762220779"] = true,
["00139161205970637"] = true,
["00105529482486905"] = true,
["00136579058345590"] = true,
["00137940368194253"] = true,
["00134366188285514"] = true,
["0090441404910975"] = true,
["00136062265232554"] = true,
["00139959590610806"] = true,
["00101326109963284"] = true,
["00104596909675653"] = true,
["00120889371113999"] = true,
["00123636731441495"] = true,
["00139266399633943"] = true,
["00136757074728111"] = true,
["0071837666565538"] = true,
["00136932193331774"] = true,
["0083348506277910"] = true,
["0096461852889782"] = true,
["0086179292245507"] = true,
["00138399043067580"] = true,
["00127315787641662"] = true,
["0084503240750324"] = true,
["00118339473142000"] = true,
["0079571017056912"] = true,
["0098910096907752"] = true,
["0081992647194094"] = true,
["00109581571958419"] = true,
["00127289079588211"] = true,
["00115606425940542"] = true,
["00125090424621204"] = true,
["00123474312447314"] = true,
["0098155494442325"] = true,
["00140296092797647"] = true,
["00108211664913950"] = true,
["00123823314330690"] = true,
["00108056646532188"] = true,
["00124193226114157"] = true,
["00115446662072635"] = true,
["00101760421194464"] = true,
["00103402787024962"] = true,
["0097897942456798"] = true,
["0082888827832410"] = true,
["00103809997061892"] = true,
["0095889361909779"] = true,
["0099422904146760"] = true,
["00123425337183359"] = true,
["00129077599796011"] = true,
["0090701582514077"] = true,
["00111627867939528"] = true,
["0081355270308649"] = true,
["0081705440813716"] = true,
["0096395535687059"] = true,
["0076048463716951"] = true,
["0095577097594900"] = true,
["00102702303078593"] = true,
["0080333459269707"] = true,
["0097584707475905"] = true,
["0099361303588615"] = true,
["00134343859574189"] = true,
["00126682658892737"] = true,
["00128634723207816"] = true,
["0091264696507045"] = true,
["00138037623365631"] = true,
["00139395401122965"] = true,
["00104230825046245"] = true,
["00104077124078631"] = true,
["00123534092796832"] = true,
["0087415049311278"] = true,
["0012775958738550"] = true,
["00123737637951887"] = true,
["00130346431704382"] = true,
["0090585193615009"] = true,
["0098863008630838"] = true,
["00124426539686830"] = true,
["00110122106797311"] = true,
["00113837123012140"] = true,
["00113411766260595"] = true,
["00116383183705339"] = true,
["00103357368997534"] = true,
["00121862530410345"] = true,
["00137616557917808"] = true,
["00127462218946500"] = true,
["00101507055632088"] = true,
["00104786050847710"] = true,
["0011474483333642"] = true,
["0070568680894993"] = true,
["0091545761620604"] = true,
["00109835723023185"] = true,
["0087608243293465"] = true,
["0085625929400145"] = true,
["00114828440569394"] = true,
["00104612375485278"] = true,
["00105264579352785"] = true,
["00119106215830784"] = true,
["0090254083797643"] = true,
["00110141734769896"] = true,
["00104813679280626"] = true,
["0097237249928046"] = true,
["0088667487587801"] = true,
["00128777766515549"] = true,
["00116686381071002"] = true,
["0096542798078469"] = true,
["0076417682878166"] = true,
["00136973007686148"] = true,
["00114554380923706"] = true,
["00102485938050877"] = true,
["00135234204533669"] = true,
["00118971348848680"] = true,
["0095108082745202"] = true,
["0093671565377873"] = true,
["0079270862381408"] = true,
["0082309139265849"] = true,
["00115830122213410"] = true,
["0083656958514876"] = true,
["00114806738525296"] = true,
["00136874824183635"] = true,
["00133126608942370"] = true,
["0095088091559645"] = true,
["00102497371799554"] = true,
["0085942233954814"] = true,
["0090742923481853"] = true,
["0095392769579201"] = true,
["0083669515195163"] = true,
["0076149615519675"] = true,
["0076457034190332"] = true,
["0071514227382040"] = true,
["00115466730049370"] = true,
["00124699466351940"] = true,
["00131086745089963"] = true,
["00138959218019034"] = true,
["00113708431312824"] = true,
["00128391107406515"] = true,
["0078807203933082"] = true,
["0091721865318808"] = true,
["00126567899569006"] = true,
["0070947865591456"] = true,
["00122035444947643"] = true,
["0086764246880240"] = true,
["00104894120097922"] = true,
["00106772019844966"] = true,
["00117634634591039"] = true,
["00107143608209389"] = true,
["0082424759268177"] = true,
["00131139299124772"] = true,
["0071432615843298"] = true,
["0096154653832996"] = true,
["00125973553630773"] = true,
["00132061090277129"] = true,
["00125219014357719"] = true,
["00117062443746231"] = true,
["0082674301501810"] = true,
["00128113724387839"] = true,
["00110962515921222"] = true,
["00108068940955970"] = true,
["0072308904534702"] = true,
["0088670635268455"] = true,
["00135202722115116"] = true,
["00888323577612"] = true,
["0073707236391323"] = true,
["00124820753278184"] = true,
["0081216023390838"] = true,
["00114672908275107"] = true,
["0085820121717014"] = true,
["00110618781138167"] = true,
["00110613753488201"] = true,
["0085597585401083"] = true,
["0083473842847103"] = true,
["00116240544074002"] = true,
["0090107480434549"] = true,
["00104234965592144"] = true,
["0078805159241063"] = true,
["00132420732877381"] = true,
["00131143755040526"] = true,
["00114064492245102"] = true,
["00133979364692900"] = true,
["0074267636880133"] = true,
["00133880908787012"] = true,
["00104235464927884"] = true,
["0084669681338096"] = true,
["00140453847194846"] = true,
["00120669769444694"] = true,
["00136698972019783"] = true,
["00118266158429780"] = true,
["00100830375199274"] = true,
["00104325119460463"] = true,
["007362736577575"] = true,
["0088746529029966"] = true,
["00118699053628089"] = true,
["00133479095135151"] = true,
["00137257796564642"] = true,
["0082391848399268"] = true,
["00132623398262383"] = true,
["00133444429613614"] = true,
["00115629676001931"] = true,
["00124191075632403"] = true,
["0091062548843133"] = true,
["00138393863666252"] = true,
["00132846836090502"] = true,
["0089435534172093"] = true,
["00110964191928058"] = true,
["0087241464962093"] = true,
["0080402698169927"] = true,
["00133243435779297"] = true,
["00118387927595281"] = true,
["00108018168907361"] = true,
["00113056999168002"] = true,
["00137322571774836"] = true,
["00103598862854562"] = true,
["00102329579897685"] = true,
["0094727105847714"] = true,
["0077069296950230"] = true,
["0093190914500256"] = true,
["0085534373580637"] = true,
["00109953842941933"] = true,
["0074128711771126"] = true,
["0079678311293554"] = true,
["0076997740381152"] = true,
["0081749376038345"] = true,
["00126641700011130"] = true,
["0090151672719176"] = true,
["00116333662357487"] = true,
["00108928222652048"] = true,
["0091456371817023"] = true,
["00103155068832191"] = true,
["00103081103536555"] = true,
["0096540815514800"] = true,
["00139359317402819"] = true,
["00123236758922318"] = true,
["00121617102691813"] = true,
["00117333403954836"] = true,
["00126411033764888"] = true,
["00116479820973610"] = true,
["00138717091447788"] = true,
["0094395124894477"] = true,
["0072555884173119"] = true,
["00126558650536458"] = true,
["00107107549934157"] = true,
["0074581904229415"] = true,
["0097855473483590"] = true,
["00119910036458479"] = true,
["0078468822186438"] = true,
["0088919949215409"] = true,
["00137143501535847"] = true,
["0096737342531440"] = true,
["0080269293665003"] = true,
["0079620593334097"] = true,
["00128309630542156"] = true,
["00122674424907236"] = true,
["0098525124776892"] = true,
["00134221527252870"] = true,
["0077169011779599"] = true,
["00104789505300672"] = true,
["00107487586476838"] = true,
["00121623512956535"] = true,
["00109016107917495"] = true,
["0093354915992906"] = true,
["0087803356437995"] = true,
["00131505790191818"] = true,
["00101586648551910"] = true,
["00103769853562513"] = true,
["00106193042584515"] = true,
["00140710206173088"] = true,
["0093156460169780"] = true,
["00106632755105094"] = true,
["00140478677819080"] = true,
["0091546355467819"] = true,
["00112903829300305"] = true,
["00134676909592986"] = true,
["00118259702345183"] = true,
["00125498953914924"] = true,
["0095222069043236"] = true,
["0094206298176538"] = true,
["00103546993303156"] = true,
["0083634737719773"] = true,
["00100580763248940"] = true,
["00103694954912089"] = true,
["0072381211861070"] = true,
["0072506213404217"] = true,
["00131731503356014"] = true,
["00115080448118582"] = true,
["00100161795018029"] = true,
["00105633527837545"] = true,
["00110197823072659"] = true,
["00110165928834824"] = true,
["00125114170815867"] = true,
["0090666139918149"] = true,
["0072261377504687"] = true,
["0082707306283924"] = true,
["00103692241167571"] = true,
["0087781715932470"] = true,
["00130044744780775"] = true,
["00123058585128898"] = true,
["00114234529741436"] = true,
["00137878826993639"] = true,
["00115739286543007"] = true,
["0079254254013081"] = true,
["00100359624298228"] = true,
["0098105554853143"] = true,
["0089257596238015"] = true,
["0089826231913622"] = true,
["00138980252123452"] = true,
["00116116166314896"] = true,
["00132637734452348"] = true,
["00131180502129249"] = true,
["0094860513850725"] = true,
["0079985328619202"] = true,
["0078605175341037"] = true,
["00132927948675014"] = true,
["00128195507229583"] = true,
["0091535513304979"] = true,
["00123113777302849"] = true,
["00103983210840248"] = true,
["00113700137073551"] = true,
["00116577663391502"] = true,
["0084573258982113"] = true,
["00129391326211876"] = true,
["00105563156228360"] = true,
["0076865967982478"] = true,
["00116024789468683"] = true,
["0087988252339262"] = true,
["00117039686830458"] = true,
["00127154853054958"] = true,
["00125250880837970"] = true,
["0081897538594330"] = true,
["00129693251198950"] = true,
["00130775879035709"] = true,
["0088949801287594"] = true,
["0073370592794056"] = true,
["0087968195504938"] = true,
["00128534750062152"] = true,
["00106661099930720"] = true,
["0099406185535504"] = true,
["0075987066575210"] = true,
["00107076786829604"] = true,
["00108420669126506"] = true,
["00134534535618466"] = true,
["00102842842650450"] = true,
["0070753495080939"] = true,
["0098840865352421"] = true,
["0074442105890577"] = true,
["00127015973133359"] = true,
["00124568531711859"] = true,
["0084857857403884"] = true,
["00111748834783512"] = true,
["00113159075008445"] = true,
["0098063440816588"] = true,
["0078728248733196"] = true,
["0070863734476636"] = true,
["00129184577703912"] = true,
["00107037033069983"] = true,
["0014807319708485"] = true,
["0071448202704453"] = true,
["0085114306130754"] = true,
["0086667810333926"] = true,
["00117424973211276"] = true,
["00116913760583110"] = true,
["0070817906617641"] = true,
["00118322804860765"] = true,
["0089916479216661"] = true,
["00100915381861429"] = true,
["00100768796538324"] = true,
["00119259527722708"] = true,
["00117804239569119"] = true,
["0086891813489187"] = true,
["0096973761488792"] = true,
["00132379122257771"] = true,
["00105260126340320"] = true,
["00140471972250023"] = true,
["00137218295624201"] = true,
["0081496152119327"] = true,
["00129157939019963"] = true,
["00128473727801746"] = true,
["0081958695504947"] = true,
["00110122923211017"] = true,
["00104563328265832"] = true,
["0070447847496490"] = true,
["0092593821007431"] = true,
["0072750621826221"] = true,
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
