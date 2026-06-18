-- ════════════════════════════════════════════════════════════════
-- 🧨 PL7 HUB - 99 NIGHTS IN THE FOREST (CONVERSÃO COMPLETA) 🧨
-- Todas as abas e funções do script original
-- ════════════════════════════════════════════════════════════════

local PL7 = loadstring(game:HttpGet("https://pastebin.com/raw/TAVpDWLt"))()

-- ═══════════════════ TELA DE CARREGAMENTO ═══════════════════
local Loader = PL7:CreateLoader({
    Title = "PL7 HUB - 99 NIGHTS",
    Subtitle = "Carregando módulos...",
    Theme = "Black",
})

task.spawn(function()
    for i = 1, 10 do
        Loader:SetStatus("Carregando " .. i*10 .. "%")
        Loader:SetProgress(i * 10)
        task.wait(0.1)
    end
    Loader:Finish(function()
        criarUI()
    end)
end)

-- ═══════════════════ VARIÁVEIS E FUNÇÕES AUXILIARES ═══════════════════
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local itemFolder = Workspace:WaitForChild("Items")
local characterFolder = Workspace:WaitForChild("Characters")

-- Variáveis globais
local hackedWalkSpeed = 16
local espEnabled = false
local chamsEnabled = false
local killAuraToggle = false
local killAuraRadius = 200
local autoEatEnabled = false
local autoEatHPEnabled = false
local autoBreakEnabled = false
local treesBrought = false
local originalTreeCFrames = {}

local alwaysFeedEnabled = {}
local autoFuelEnabled = {}
local autoCookEnabled = {}
local autoGrindEnabled = {}
local autoBiofuelEnabled = {}

-- Listas
local campfireFuel = {"Log", "Coal", "Fuel Canister", "Oil Barrel", "Biofuel"}
local cookItems = {"Morsel", "Steak"}
local grindItems = {"UFO Junk", "UFO Component", "Old Car Engine", "Broken Fan", "Old Microwave", "Bolt", "Log", "Cultist Gem", "Sheet Metal", "Old Radio","Tyre","Washing Machine", "Cultist Experiment", "Cultist Component", "Gem of the Forest Fragment", "Broken Microwave"}
local biofuelItems = {"Carrot", "Cooked Morsel", "Morsel", "Steak", "Cooked Steak", "Log"}
local eatFoods = {"Cooked Steak", "Cooked Morsel", "Berry", "Carrot", "Apple"}
local tpItemNames = {"Revolver", "Medkit", "Alien Chest", "Berry", "Bolt", "Broken Fan", "Carrot", "Coal", "Coin Stack", "Hologram Emitter", "Item Chest", "Laser Fence Blueprint", "Log", "Old Flashlight", "Old Radio", "Sheet Metal", "Bandage", "Rifle"}
local possibleItems = {"Alien Chest","Alpha Wolf Pelt","Anvil Front","Anvil Back","Apple","Bandage","Bear Corpse","Bear Pelt","Berry","Biofuel","Bolt","Broken Fan","Bunny Foot","Carrot","Coal","Coin Stack","Cooked Morsel","Cooked Steak","Chainsaw","Cultist","Cultist Gem","Flower","Fuel Canister","Hologram Emitter","Item Chest","Laser Fence Blueprint","Leather Body","Iron Body","Thorn Body","Log","MedKit","Morsel","Old Flashlight","Old Radio","Good Sack","Good Axe","Raygun","Giant Sack","Strong Axe","Oil Barrel","Old Car Engine","Rifle","Rifle Ammo","Revolver","Revolver Ammo","Sapling","Sheet Metal","Steak","Wolf Pelt","Gem of the Forest Fragment","Tyre","Washing Machine","Broken Microwave"}
local possibleMobs = {"Alpha Wolf","Bear","Lost Child","Lost Child2","Lost Child3","Lost Child4","Wolf","Bunny","Cultist","Alien"}

-- Funções auxiliares (idênticas ao original)
local function getCharacter() return LocalPlayer.Character end
local function getRootPart() local char = getCharacter(); return char and char:FindFirstChild("HumanoidRootPart") end
local function applyWalkSpeedToCharacter()
    local char = getCharacter()
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = hackedWalkSpeed
            hum.Changed:Connect(function(prop)
                if prop == "WalkSpeed" and hum.WalkSpeed ~= hackedWalkSpeed then
                    hum.WalkSpeed = hackedWalkSpeed
                end
            end)
        end
    end
end

-- Safe zone baseplates
local safezoneBaseplates = {}
local baseplateSize = Vector3.new(2048, 1, 2048)
local baseY = 100
local centerPos = Vector3.new(0, baseY, 0)
for dx = -1, 1 do
    for dz = -1, 1 do
        local pos = centerPos + Vector3.new(dx * baseplateSize.X, 0, dz * baseplateSize.Z)
        local baseplate = Instance.new("Part")
        baseplate.Name = "SafeZoneBaseplate"
        baseplate.Size = baseplateSize
        baseplate.Position = pos
        baseplate.Anchored = true
        baseplate.CanCollide = true
        baseplate.Transparency = 1
        baseplate.Color = Color3.fromRGB(255, 255, 255)
        baseplate.Parent = workspace
        table.insert(safezoneBaseplates, baseplate)
    end
end

-- Teleportes
local function teleportToTarget(cf) local hrp = getRootPart(); if hrp then hrp.CFrame = cf end end
local function stringToCFrame(str) local x,y,z = str:match("([^,]+),%s*([^,]+),%s*([^,]+)"); return CFrame.new(tonumber(x), tonumber(y), tonumber(z)) end

-- Item ESP
local function createItemESP(model)
    if not model:IsA("Model") or not model.PrimaryPart or model:FindFirstChild("ESP") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.Adornee = model.PrimaryPart
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1; label.TextColor3 = Color3.new(1,1,1); label.TextStrokeTransparency = 0.5; label.TextScaled = true; label.Font = Enum.Font.GothamSemibold; label.Text = model.Name
    billboard.Parent = model
end
local function removeAllItemESP() for _, model in itemFolder:GetChildren() do local esp = model:FindFirstChild("ESP"); if esp then esp:Destroy() end end end

-- Teleporte aleatório para item
local function teleportToRandomItem(itemName)
    local candidates = {}
    for _, model in itemFolder:GetChildren() do if model.Name == itemName then local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart"); if part then table.insert(candidates, part) end end end
    if #candidates == 0 then return end
    local target = candidates[math.random(#candidates)]; local hrp = getRootPart(); if hrp then hrp.CFrame = target.CFrame + Vector3.new(0,5,0) end
end

-- Trazer item bulk
local function teleportItem(itemName)
    local root = getRootPart(); if not root then return end
    local count = 0
    local sources = { itemFolder, ReplicatedStorage:WaitForChild("TempStorage") }
    for _, source in ipairs(sources) do
        for _, item in source:GetChildren() do
            if item.Name == itemName then
                local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
                if part then
                    remoteEvents.RequestStartDraggingItem:FireServer(item); task.wait(0.05)
                    part.CFrame = root.CFrame + Vector3.new(0, count * 2, 0)
                    remoteEvents.StopDraggingItem:FireServer(item); count = count + 1
                end
            end
        end
    end
end

-- Trazer mob
local function teleportCharacter(characterName)
    local root = getRootPart(); if not root then return end
    local count = 0
    for _, model in characterFolder:GetChildren() do
        if model.Name == characterName then
            local mainPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            if mainPart then
                local targetCF = root.CFrame + Vector3.new(0, count * 3, 0)
                if model.PrimaryPart then model:SetPrimaryPartCFrame(targetCF) else mainPart.CFrame = targetCF end
                count = count + 1
            end
        end
    end
end

-- Movimentar itens para posição (fogo, máquina)
local function moveItemToPos(item, position)
    if not item or not item:IsDescendantOf(Workspace) then return end
    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
    if not part then return end
    if not item.PrimaryPart then pcall(function() item.PrimaryPart = part end) end
    pcall(function()
        remoteEvents.RequestStartDraggingItem:FireServer(item); task.wait(0.05)
        item:SetPrimaryPartCFrame(CFrame.new(position)); task.wait(0.05)
        remoteEvents.StopDraggingItem:FireServer(item)
    end)
end
local campfireDropPos = Vector3.new(0, 19, 0)
local machineDropPos = Vector3.new(21, 16, -5)

-- Kill Aura
local toolsDamageIDs = { ["Old Axe"] = "1_8982038982", ["Good Axe"] = "112_8982038982", ["Strong Axe"] = "116_8982038982", ["Chainsaw"] = "647_8992824875", ["Spear"] = "196_8999010016" }
local function getAnyToolWithDamageID() for toolName, damageID in pairs(toolsDamageIDs) do local tool = LocalPlayer.Inventory:FindFirstChild(toolName); if tool then return tool, damageID end end; return nil, nil end
local function equipTool(tool) if tool then remoteEvents.EquipItemHandle:FireServer("FireAllClients", tool) end end
local function unequipTool(tool) if tool then remoteEvents.UnequipItemHandle:FireServer("FireAllClients", tool) end end

local killAuraThread = nil
local function startKillAura()
    if killAuraThread then task.cancel(killAuraThread) end
    killAuraThread = task.spawn(function()
        while killAuraToggle do
            local char = getCharacter(); local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local tool, damageID = getAnyToolWithDamageID()
                if tool and damageID then
                    equipTool(tool)
                    for _, mob in ipairs(characterFolder:GetChildren()) do
                        if mob:IsA("Model") then
                            local part = mob:FindFirstChildWhichIsA("BasePart")
                            if part and (part.Position - hrp.Position).Magnitude <= killAuraRadius then
                                pcall(function() remoteEvents.ToolDamageObject:InvokeServer(mob, tool, damageID, CFrame.new(part.Position)) end)
                            end
                        end
                    end
                    task.wait(0.1)
                else task.wait(1) end
            else task.wait(0.5) end
        end
    end)
end

-- Círculo 3D
local circlePart = nil
local function updateCircleRadius()
    if not killAuraToggle then
        if circlePart then circlePart:Destroy(); circlePart = nil end
        return
    end
    local hrp = getRootPart()
    if not hrp then return end
    if not circlePart then
        circlePart = Instance.new("Part")
        circlePart.Name = "KillAuraRange"
        circlePart.Size = Vector3.new(killAuraRadius * 2, 0.2, killAuraRadius * 2)
        circlePart.Shape = Enum.PartType.Cylinder
        circlePart.Anchored = true
        circlePart.CanCollide = false
        circlePart.Transparency = 0.6
        circlePart.Color = Color3.fromRGB(255, 80, 80)
        circlePart.Material = Enum.Material.Neon
        circlePart.Parent = workspace
        local att = Instance.new("Attachment", circlePart)
        local light = Instance.new("PointLight", att)
        light.Color = Color3.fromRGB(255, 80, 80)
        light.Brightness = 0.5
    end
    circlePart.Size = Vector3.new(killAuraRadius * 2, 0.2, killAuraRadius * 2)
    circlePart.CFrame = hrp.CFrame - Vector3.new(0, hrp.Size.Y / 2, 0)
    local light = circlePart:FindFirstChildWhichIsA("PointLight")
    if light then light.Range = killAuraRadius end
end
RunService.RenderStepped:Connect(updateCircleRadius)

-- Visuals (ESP, Chams, FOV)
local BillboardESPs = {}; local ESPConnections = {}; local ChamsESPs = {}
local customFont = Font.new("rbxassetid://16658246179", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

local function createBillboardESP(plr)
    if BillboardESPs[plr] or plr == LocalPlayer then return end
    if not plr.Character or not plr.Character:FindFirstChild("Head") then return end
    local gui = Instance.new("BillboardGui")
    gui.Name = "Billboard_ESP"; gui.Adornee = plr.Character.Head; gui.Parent = plr.Character.Head
    gui.Size = UDim2.new(0, 100, 0, 40); gui.AlwaysOnTop = true; gui.StudsOffset = Vector3.new(0,2,0)
    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(1,0,1,0); label.BackgroundTransparency = 1; label.TextColor3 = Color3.new(1,1,1); label.TextStrokeTransparency = 0.5; label.TextScaled = true; label.FontFace = customFont
    local conn = RunService.RenderStepped:Connect(function()
        if not plr.Character or not plr.Character:FindFirstChild("Humanoid") then
            gui:Destroy(); conn:Disconnect(); BillboardESPs[plr] = nil; ESPConnections[plr] = nil; return
        end
        local hp = math.floor(plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth * 100)
        label.Text = plr.Name .. " | " .. hp .. "%"
    end)
    BillboardESPs[plr] = gui; ESPConnections[plr] = conn
end
local function cleanupBillboardESP() for _, gui in pairs(BillboardESPs) do gui:Destroy() end; for _, conn in pairs(ESPConnections) do conn:Disconnect() end; BillboardESPs = {}; ESPConnections = {} end

local function createChamsESP(plr)
    if ChamsESPs[plr] or plr == LocalPlayer then return end
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    local folder = Instance.new("Folder"); folder.Name = "Chams_ESP"; folder.Parent = CoreGui; ChamsESPs[plr] = folder
    for _, part in pairs(plr.Character:GetChildren()) do
        if part:IsA("BasePart") then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "Cham_" .. plr.Name; box.Adornee = part; box.AlwaysOnTop = true; box.Size = part.Size; box.Transparency = 0.4
            box.Color = BrickColor.new(plr.TeamColor == LocalPlayer.TeamColor and "Bright green" or "Bright red")
            box.Parent = folder
        end
    end
end
local function cleanupChamsESP() for _, folder in pairs(ChamsESPs) do folder:Destroy() end; ChamsESPs = {} end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false; FOVCircle.Color = Color3.fromRGB(255,255,255); FOVCircle.Transparency = 1; FOVCircle.Thickness = 1; FOVCircle.Filled = false
RunService.RenderStepped:Connect(function() if FOVCircle.Visible then FOVCircle.Radius = 100; FOVCircle.Position = UserInputService:GetMouseLocation() end end)

-- Árvores
local function getAllSmallTrees()
    local trees = {}
    local function scan(folder) if folder then for _, obj in pairs(folder:GetChildren()) do if obj:IsA("Model") and obj.Name == "Small Tree" then table.insert(trees, obj) end end end end
    local map = Workspace:FindFirstChild("Map")
    if map then
        if map:FindFirstChild("Foliage") then scan(map.Foliage) end
        if map:FindFirstChild("Landmarks") then scan(map.Landmarks) end
    end
    return trees
end
local function findTrunk(tree) for _, part in tree:GetDescendants() do if part:IsA("BasePart") and part.Name == "Trunk" then return part end end end
local function bringAllTrees()
    local root = getRootPart(); if not root then return end
    local target = CFrame.new(root.Position + root.CFrame.LookVector * 10)
    for _, tree in ipairs(getAllSmallTrees()) do
        local trunk = findTrunk(tree)
        if trunk then
            if not originalTreeCFrames[tree] then originalTreeCFrames[tree] = trunk.CFrame end
            tree.PrimaryPart = trunk; trunk.Anchored = false; trunk.CanCollide = false; task.wait()
            tree:SetPrimaryPartCFrame(target + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))
            trunk.Anchored = true
        end
    end
    treesBrought = true
end
local function restoreTrees()
    for tree, cframe in pairs(originalTreeCFrames) do
        local trunk = findTrunk(tree)
        if trunk then
            tree.PrimaryPart = trunk; tree:SetPrimaryPartCFrame(cframe); trunk.Anchored = true; trunk.CanCollide = true
        end
    end
    originalTreeCFrames = {}; treesBrought = false
end

-- Stronghold timer
local function getStrongholdTimerLabel()
    local functional = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Landmarks") and Workspace.Map.Landmarks:FindFirstChild("Stronghold") and Workspace.Map.Landmarks.Stronghold:FindFirstChild("Functional")
    local sign = functional and functional:FindFirstChild("Sign")
    local sg = sign and sign:FindFirstChild("SurfaceGui"); local frame = sg and sg:FindFirstChild("Frame")
    return frame and frame:FindFirstChild("Body")
end

-- Coroutines de automação (idênticas ao original)
coroutine.wrap(function() while true do for itemName,enabled in pairs(alwaysFeedEnabled) do if enabled then for _,item in itemFolder:GetChildren() do if item.Name == itemName then moveItemToPos(item, campfireDropPos) end end end end; task.wait(2) end end)()
coroutine.wrap(function() local function getFillFrame() local campfire = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Campground") and Workspace.Map.Campground:FindFirstChild("MainFire"); local fill = campfire and campfire:FindFirstChild("Center") and campfire.Center:FindFirstChild("BillboardGui") and campfire.Center.BillboardGui:FindFirstChild("Frame") and campfire.Center.BillboardGui.Frame:FindFirstChild("Background") and campfire.Center.BillboardGui.Frame.Background:FindFirstChild("Fill"); return fill end; while true do local fill = getFillFrame(); if fill and fill.Size.X.Scale < 0.7 then repeat for itemName,enabled in pairs(autoFuelEnabled) do if enabled then for _,item in itemFolder:GetChildren() do if item.Name == itemName then moveItemToPos(item, campfireDropPos) end end end end; task.wait(0.5); fill = getFillFrame() until not fill or fill.Size.X.Scale >= 1 end; task.wait(2) end end)()
coroutine.wrap(function() while true do for itemName,enabled in pairs(autoCookEnabled) do if enabled then for _,item in itemFolder:GetChildren() do if item.Name == itemName then moveItemToPos(item, campfireDropPos) end end end end; task.wait(2.5) end end)()
coroutine.wrap(function() while true do for itemName,enabled in pairs(autoGrindEnabled) do if enabled then for _,item in itemFolder:GetChildren() do if item.Name == itemName then moveItemToPos(item, machineDropPos) end end end end; task.wait(2.5) end end)()
coroutine.wrap(function() while true do if autoEatEnabled then local available={}; for _,item in itemFolder:GetChildren() do if table.find(eatFoods, item.Name) then table.insert(available,item) end end; if #available>0 then local food=available[math.random(#available)]; pcall(function() remoteEvents.RequestConsumeItem:InvokeServer(food) end) end end; task.wait(3) end end)()
local hungerBar = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("StatBars"):WaitForChild("HungerBar"):WaitForChild("Bar")
coroutine.wrap(function() while true do if autoEatHPEnabled then if hungerBar.Size.X.Scale <= 0.5 then repeat local available={}; for _,item in itemFolder:GetChildren() do if table.find(eatFoods, item.Name) then table.insert(available,item) end end; if #available>0 then local food=available[math.random(#available)]; pcall(function() remoteEvents.RequestConsumeItem:InvokeServer(food) end) else break end; task.wait(1) until hungerBar.Size.X.Scale >= 0.99 or not autoEatHPEnabled end end; task.wait(3) end end)()
coroutine.wrap(function() local biofuelProcessorPos = nil; while true do if not biofuelProcessorPos then local processor = Workspace:FindFirstChild("Structures") and Workspace.Structures:FindFirstChild("Biofuel Processor"); local part = processor and processor:FindFirstChild("Part"); if part then biofuelProcessorPos = part.Position + Vector3.new(0,5,0) end end; if biofuelProcessorPos then for itemName,enabled in pairs(autoBiofuelEnabled) do if enabled then for _,item in itemFolder:GetChildren() do if item.Name == itemName then moveItemToPos(item, biofuelProcessorPos) end end end end end; task.wait(2) end end)()

-- ═══════════════════ CRIAÇÃO DA INTERFACE PL7 ═══════════════════
function criarUI()
    local Window = PL7:CreateWindow({
        Title = "PL7 HUB - 99 Nights",
        Theme = "Black",
        Size = {420, 580},
        FloatText = "⚡ PL7 HUB"
    })

    -- ABAS
    local TabMain = Window:AddTab("Main")
    local TabAuto = Window:AddTab("Auto")
    local TabItemTP = Window:AddTab("Item TP")
    local TabGameTP = Window:AddTab("Game TP")
    local TabMobTP = Window:AddTab("Mob TP")
    local TabPlayer = Window:AddTab("Player")
    local TabVisuals = Window:AddTab("Visuals")
    local TabMisc = Window:AddTab("Misc")

    -- ========== MAIN ==========
    local SecKill = TabMain:AddSection("💀 Kill Aura")
    local killToggle = SecKill:AddToggle("Kill Aura", false, function(val)
        killAuraToggle = val
        if val then
            startKillAura()
        else
            if killAuraThread then task.cancel(killAuraThread); killAuraThread = nil end
            local tool,_ = getAnyToolWithDamageID()
            unequipTool(tool)
        end
    end)
    local radiusSlider = SecKill:AddSlider("Kill Aura Radius", 20, 500, killAuraRadius, function(val)
        killAuraRadius = val
        updateCircleRadius()
    end)

    local SecTele = TabMain:AddSection("📍 Teleportes Rápidos")
    SecTele:AddButton("Teleport to Stronghold", function()
        local doorRight = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Landmarks") and Workspace.Map.Landmarks:FindFirstChild("Stronghold") and Workspace.Map.Landmarks.Stronghold:FindFirstChild("Functional") and Workspace.Map.Landmarks.Stronghold.Functional:FindFirstChild("EntryDoors") and Workspace.Map.Landmarks.Stronghold.Functional.EntryDoors:FindFirstChild("DoorRight")
        local targetPart = doorRight and doorRight:FindFirstChild("Model")
        if targetPart then
            local children = targetPart:GetChildren()
            local dest = children[5]
            if dest and dest:IsA("BasePart") then
                teleportToTarget(dest.CFrame + Vector3.new(0,5,0))
            end
        end
    end)
    SecTele:AddButton("Teleport to Diamond Chest", function()
        local chest = itemFolder and itemFolder:FindFirstChild("Stronghold Diamond Chest")
        if chest then
            local lid = chest:FindFirstChild("ChestLid")
            local mesh = lid and lid:FindFirstChild("Meshes/diamondchest_Cube.002")
            if mesh then teleportToTarget(mesh.CFrame + Vector3.new(0,5,0)) end
        end
    end)
    local timerLabel = SecTele:AddLabel("Stronghold Timer: Loading...")
    task.spawn(function()
        while true do
            local label = getStrongholdTimerLabel()
            timerLabel:Set("Stronghold Timer: " .. (label and label.ContentText or "N/A"))
            task.wait(0.5)
        end
    end)

    -- ========== AUTO ==========
    local function createAutoSection(sec, itemList, enabledTable, bulkName)
        local savedToggles = {}
        for _, item in ipairs(itemList) do
            local tog = sec:AddToggle(item, false, function(val)
                enabledTable[item] = val
            end)
            savedToggles[item] = tog
        end
        sec:AddButton(bulkName or "► Bulk (All)", function()
            local anyOn = false
            for _, item in ipairs(itemList) do
                if enabledTable[item] then anyOn = true; break end
            end
            local newState = not anyOn
            for _, item in ipairs(itemList) do
                enabledTable[item] = newState
                if savedToggles[item] then savedToggles[item]:Set(newState) end
            end
        end)
    end

    local sec1 = TabAuto:AddSection("🔥 Auto Feed Campfire (ignores HP)")
    createAutoSection(sec1, campfireFuel, alwaysFeedEnabled, "► Bulk (All)")

    local sec2 = TabAuto:AddSection("🔥 Auto Feed Campfire (HP Based)")
    createAutoSection(sec2, campfireFuel, autoFuelEnabled, "► Bulk (All)")

    local sec3 = TabAuto:AddSection("🍳 Auto Cook Food")
    createAutoSection(sec3, cookItems, autoCookEnabled, "► Bulk (All)")

    local sec4 = TabAuto:AddSection("🛠️ Auto Machine Grind")
    createAutoSection(sec4, grindItems, autoGrindEnabled, "► Bulk (All)")

    local sec5 = TabAuto:AddSection("⚗️ Auto Biofuel Processor")
    createAutoSection(sec5, biofuelItems, autoBiofuelEnabled, "► Bulk (All)")

    local secEat = TabAuto:AddSection("🍎 Auto Eat")
    local eatTimer = secEat:AddToggle("Auto Eat (3 sec)", false, function(v) autoEatEnabled = v end)
    local eatHP = secEat:AddToggle("Auto Eat (HP Based)", false, function(v) autoEatHPEnabled = v end)

    local secTrees = TabAuto:AddSection("🌲 Árvores")
    local treeToggle = secTrees:AddToggle("Auto Bring All Small Trees", false, function(v)
        autoBreakEnabled = v
        if v and not treesBrought then bringAllTrees()
        elseif not v and treesBrought then restoreTrees() end
    end)

    -- ========== ITEM TP ==========
    local secItemESP = TabItemTP:AddSection("🔍 Item ESP")
    local espToggle = secItemESP:AddToggle("Item ESP", false, function(v)
        espEnabled = v
        if v then
            for _, model in itemFolder:GetChildren() do createItemESP(model) end
            itemFolder.ChildAdded:Connect(function(m) if m:IsA("Model") then createItemESP(m) end end)
        else
            removeAllItemESP()
        end
    end)

    local secTPItem = TabItemTP:AddSection("📦 Teleport to Item (random)")
    for _, item in ipairs(tpItemNames) do
        secTPItem:AddButton("TP to " .. item, function() teleportToRandomItem(item) end)
    end

    local secBringItem = TabItemTP:AddSection("🎁 Bring Item to You (Bulk)")
    for _, item in ipairs(possibleItems) do
        secBringItem:AddButton("Bring " .. item, function() teleportItem(item) end)
    end

    -- ========== GAME TP ==========
    local secSafe = TabGameTP:AddSection("🏠 Safe Zone")
    local szToggle = secSafe:AddToggle("Show Safe Zone", false, function(v)
        for _, bp in ipairs(safezoneBaseplates) do
            bp.Transparency = v and 0.8 or 1
            bp.CanCollide = v
        end
    end)
    local coordsList = {{"[campsite] camp site","0,8,-0"},{"[safezone] safe zone","0,110,-0"}}
    for _, entry in ipairs(coordsList) do
        secSafe:AddButton(entry[1], function() teleportToTarget(stringToCFrame(entry[2])) end)
    end

    -- ========== MOB TP ==========
    for _, mob in ipairs(possibleMobs) do
        TabMobTP:AddButton("Bring " .. mob, function() teleportCharacter(mob) end)
    end

    -- ========== PLAYER ==========
    local secMove = TabPlayer:AddSection("🏃 Movimento")
    local jpSlider = secMove:AddSlider("Jump Power", 50, 700, 50, function(v)
        local hum = getCharacter() and getCharacter():FindFirstChild("Humanoid")
        if hum then hum.JumpPower = v end
    end)
    local jpText = secMove:AddTextbox("Jump Power (valor)", "50", "50", function(val, enter)
        if enter then
            local num = tonumber(val) or 50
            jpSlider:Set(num)
            local hum = getCharacter() and getCharacter():FindFirstChild("Humanoid")
            if hum then hum.JumpPower = num end
        end
    end)

    local wsSlider = secMove:AddSlider("Walk Speed", 16, 700, 16, function(v)
        hackedWalkSpeed = v
        applyWalkSpeedToCharacter()
    end)
    local wsText = secMove:AddTextbox("Walk Speed (valor)", "16", "16", function(val, enter)
        if enter then
            local num = tonumber(val) or 16
            wsSlider:Set(num)
            hackedWalkSpeed = num
            applyWalkSpeedToCharacter()
        end
    end)
    local speedToggle = secMove:AddToggle("Walk Speed Toggle (50)", false, function(v)
        hackedWalkSpeed = v and 50 or 16
        wsSlider:Set(hackedWalkSpeed)
        wsText:Set(tostring(hackedWalkSpeed))
        applyWalkSpeedToCharacter()
    end)

    -- ========== VISUALS ==========
    local espPlayerToggle = TabVisuals:AddToggle("ESP (Players)", false, function(v)
        if v then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then createBillboardESP(plr) end
            end
            Players.PlayerAdded:Connect(function(plr) if espEnabled then createBillboardESP(plr) end end)
        else
            cleanupBillboardESP()
        end
        espEnabled = v
    end)
    local chamsToggle = TabVisuals:AddToggle("Chams", false, function(v)
        if v then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then createChamsESP(plr) end
            end
            Players.PlayerAdded:Connect(function(plr) if chamsEnabled then createChamsESP(plr) end end)
        else
            cleanupChamsESP()
        end
        chamsEnabled = v
    end)
    local fovToggle = TabVisuals:AddToggle("FOV Circle", false, function(v) FOVCircle.Visible = v end)

    -- ========== MISC ==========
    local scriptsList = {
        {"infinite yield", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"},
        {"emote gui", "https://raw.githubusercontent.com/dimension-sources/random-scripts-i-found/refs/heads/main/r6%20animations"},
        {"turtle spy", "https://raw.githubusercontent.com/Turtle-Brand/Turtle-Spy/main/source.lua"}
    }
    for _, scr in ipairs(scriptsList) do
        TabMisc:AddButton(scr[1], function() loadstring(game:HttpGet(scr[2]))() end)
    end

    TabMisc:AddButton("Anti AFK", function()
        local gui = Instance.new("ScreenGui")
        gui.Parent = CoreGui
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0,200,0,80); frame.Position = UDim2.new(0.5,-100,0.5,-40)
        frame.BackgroundColor3 = Color3.fromRGB(20,20,20); Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
        frame.Parent = gui
        local label = Instance.new("TextLabel"); label.Size = UDim2.new(1,0,0.5,0); label.Position = UDim2.new(0,0,0,10)
        label.BackgroundTransparency = 1; label.Text = "Anti AFK Active"; label.TextColor3 = Color3.fromRGB(0,255,0)
        label.Font = Enum.Font.GothamBold; label.Parent = frame
        local vb = Instance.new("TextLabel"); vb.Size = UDim2.new(1,0,0.5,0); vb.Position = UDim2.new(0,0,0.5,0)
        vb.BackgroundTransparency = 1; vb.Text = "Status: Protecting"; vb.TextColor3 = Color3.fromRGB(200,200,200)
        vb.Font = Enum.Font.Gotham; vb.Parent = frame
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            vb.Text = "Kick prevented!"
            task.wait(2)
            vb.Text = "Status: Protecting"
        end)
        task.delay(5, function() gui:Destroy() end)
    end)

    PL7:Notify({Title = "PL7 HUB", Text = "Todas as funções carregadas!", Type = "success", Duration = 5})
end

print("✅ PL7 HUB - 99 Nights convertido completamente!")