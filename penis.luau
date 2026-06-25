-- Ghost Notifier Scanner - WebSocket (Local) + Discord Webhooks
-- WebSocket: ws://localhost:8080
-- FIXED: Proper LocalPlayer handling

local WS_URL = "ws://localhost:8080"  -- Local WebSocket

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

-- =============================================
-- FIX: Wait for LocalPlayer to exist
-- =============================================
local player = Players.LocalPlayer
if not player then
    print("[WAIT] Waiting for LocalPlayer...")
    player = Players:WaitForChild("LocalPlayer", 10)
    if not player then
        error("LocalPlayer not found after 10 seconds")
    end
end

local BOT_USERNAME = player.Name
local PLACE_ID = game.PlaceId
local JOB_ID = game.JobId

local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- =============================================
-- DISCORD WEBHOOKS (TIERED)
-- =============================================
local WEBHOOKS = {
    LOW = "https://discordapp.com/api/webhooks/1519171506209427588/UeMFq02Tc89pRXUSrtWpgoqgshXhXwL5M2ow6wo4x6JkSH541KJbm57nPxYs3ArAl88u",
    MID = "https://discordapp.com/api/webhooks/1519171634307665971/czrchPDlOXll6TD4fcdto4fc_VynLrgFcUMjoyd5NOusKHwWZspJJ2aNjn7qVm81ekXF",
    HIGH = "https://discordapp.com/api/webhooks/1519171826448597043/UhZdWeALFz3Tl2SXJxtuLeBOygH3B-r7KQRoWPfgFowh5gL9OST7hyP37OrbpRONFBgK",
    OG = "https://discordapp.com/api/webhooks/1519171958778892329/ikWhGcR1UCrQE_LnFYGI3Mf7U3Oh9H_n20SoC0ugDqJFqDzfAE32V0k148xmI_NWu5YN",
}

-- =============================================
-- TARGET NAMES (5M+ ONLY) - FULL LIST
-- =============================================
local TARGET_NAMES = {
    -- OG TIER (450M+)
    "Skibidi Toilet", "Strawberry Elephant", "Spyder Elephant", "Headless Horseman", "Meowl", "John Pork",
    
    -- HIGH TIER (250M-449.9M)
    "Dragon Cannelloni", "Dragon Gingerini", "Hydra Dragon Cannelloni", "Griffin", "Dragon Aquanini",
    "La Supreme Combinasion", "Signore Carapace", "Love Love Bear", "Digi Narwhal",
    
    -- MID TIER (50M-249.9M)
    "Garama and Madundung", "La Secret Combinasion", "Burguro And Fryuro", "Capitano Moby",
    "Cooki and Milki", "Cerberus", "Los Sekolahs", "Los Amigos", "Celestial Pegasus",
    "La Grande Combinasion", "Nuclearo Dinossauro", "Los Combinasionas", "Los Hotspotsitos",
    "Esok Sekolah", "Ketupat Kepat", "Ketchuru and Musturu", "Spaghetti Tualetti",
    "Fragola La La La", "Tralaledon", "Los Bros", "67", "Las Sis", "Celularcini Viciosini",
    "La Extinct Grande", "Tacorita Bicicleta", "Mariachi Corazoni", "Los Tacoritas",
    "Tictac Sahur", "Money Money Puggy", "Los Primos", "Tang Tang Keletang", "Chillin Chili",
    "Los 67", "Eviledon", "La Spooky Grande", "Los Mobilis", "Spooky and Pumpky",
    "Mieteteira Bicicleteira", "Los Spooky Combinasionas", "La Casa Boo", "La Taco Combinasion",
    "Guest 666", "Los Puggies", "Los Spaghettis", "Fragrama and Chocrama", "Swag Soda",
    "Orcaledon", "Fishino Clownino", "Los Planitos", "W or L", "Lavadorito Spinito",
    "Gobblino Uniciclino", "Chicleteira Noelteira", "La Jolly Grande", "Los Candies",
    "La Ginger Sekolah", "Reinito Sleighito", "Los 25", "Chimnino", "Festive 67",
    "Swaggy Bros", "Money Money Reindeer", "Los Jolly Combinasionas", "Jolly Jolly Sahur",
    "Ginger Gerat", "Tuff Toucan", "Spinny Hammy", "Bacuru and Egguru", "Ketupat Bros",
    "Los Mi Gatitos", "Popcuru and Fizzuru", "Chicleteira Cupideira", "Lovin Rose",
    "La Romantic Grande", "Rosetti Tualetti", "Rosey and Teddy", "Los Sweethearts",
    "Sammyni Fattini", "La Food Combinasion", "Tirilikalika Tirilikalako", "Antonio",
    "Elefanto Frigo", "Ventoliero Pavonero", "Tacorillo Crocodillo", "Nacho Spyder",
    "Cigno Fulgoro", "Los Cupids", "Fortunu and Cashuru", "Cloverat Clapat", "Dug dug dug",
    "La Lucky Grande", "Foxini Lanternini", "La Easter Grande", "Quackini Snackini",
    "Hopilikalika Hopilikalako", "Boppin Bunny", "Hydra Bunny", "Bunny and Eggy",
    "Globa Steppa", "Rico Dinero", "Pancake and Syrup", "Arcadragon", "Cash or Card",
    "Los Mariachis", "Gym Bros", "Money Money Bros", "Los Chillis", "Los Hackers",
    "Duggy Bros", "Kalika Bros", "La Anniversary Grande", "Sammyni Cakini", "Jelly Moby",
    "Rubrikiko", "Coco and Mango", "Steakini Fattini", "Caylusaurus", "Bearito Cabinito",
    "Venuspino", "Kraken", "La Summer Grande",
}

local TAG_MAP = {
    ["Ventoliero Pavonero"] = "Cyber",
    ["Futbolini Skatini"] = "Cyber",
    ["Triplito Tralaleritos"] = "Diamond",
    ["Mieteteira Bicicleteira"] = "Lava",
    ["Chicleteira Cupideira"] = "Lava",
    ["Los Chicleteiras"] = "Lava",
    ["Nuclearo Dinossauro"] = "Gold",
    ["Gold Gold Gold"] = "Gold",
    ["Dug dug dug"] = "Gold",
    ["La Lucky Grande"] = "Gold",
    ["Cloverat Clapat"] = "Gold",
    ["Tictac Sahur"] = "Gold",
    ["Ketchuru and Musturu"] = "Diamond",
}

local TARGET_SET = {}
local OG_SET = {
    ["Skibidi Toilet"] = true,
    ["Strawberry Elephant"] = true,
    ["Spyder Elephant"] = true,
    ["Headless Horseman"] = true,
    ["Meowl"] = true,
    ["John Pork"] = true,
}

for _, name in ipairs(TARGET_NAMES) do
    TARGET_SET[name] = true
end

print(string.format("[LOADED] %d brainrots (5M+ only)", #TARGET_NAMES))

-- =============================================
-- DETERMINE TIER BASED ON INCOME
-- =============================================
local function getTier(income)
    if income >= 450000000 then
        return "OG", WEBHOOKS.OG, "🔴"
    elseif income >= 250000000 then
        return "HIGH", WEBHOOKS.HIGH, "🟠"
    elseif income >= 50000000 then
        return "MID", WEBHOOKS.MID, "🟡"
    else
        return "LOW", WEBHOOKS.LOW, "⚪"
    end
end

-- =============================================
-- FORMAT MONEY
-- =============================================
local function fmtMoney(n)
    if n >= 1e9 then return string.format("$%.2fB", n/1e9)
    elseif n >= 1e6 then return string.format("$%.2fM", n/1e6)
    elseif n >= 1e3 then return string.format("$%.1fK", n/1e3)
    end
    return "$"..tostring(n)
end

-- =============================================
-- SEND TO DISCORD WEBHOOK (NEW EMBED FORMAT)
-- =============================================
local function sendToDiscord(foundTargets, allBrainrotsInServer, playerCount, playerStr)
    if not httpRequest then
        print("[!] No HTTP request, webhook not sent")
        return
    end

    if #foundTargets == 0 then
        print("[!] No targets found to send")
        return
    end

    local best = foundTargets[1]
    for _, t in ipairs(foundTargets) do
        if t.gen > best.gen then best = t end
    end

    local tier, webhookUrl, emoji = getTier(best.gen)
    
    local bestTag = TAG_MAP[best.name] or "Normal"
    
    local description = ""
    
    local sorted = {}
    for _, b in ipairs(allBrainrotsInServer) do
        table.insert(sorted, b)
    end
    table.sort(sorted, function(a, b) return a.gen > b.gen end)
    
    for i, b in ipairs(sorted) do
        if i > 10 then break end
        local tag = TAG_MAP[b.name] or ""
        local tagText = tag ~= "" and "[" .. tag .. "] " or ""
        description = description .. "• " .. tagText .. b.name .. " | " .. fmtMoney(b.gen) .. "\n"
    end
    
    local embed = {
        title = "👻 Ghost Notifier [" .. tier .. " TIER]",
        color = tier == "OG" and 16711680 or tier == "HIGH" and 16753920 or tier == "MID" and 16776960 or 8421504,
        description = "✨ **Highest Value Sighted:** " .. best.name .. " [" .. bestTag .. "]\n" ..
                      "💵 **Best Gen Value**\n" ..
                      "**" .. fmtMoney(best.gen) .. "** (" .. best.genText .. ")\n" ..
                      "🧬 **Best Unit Mutation**\n" ..
                      "**" .. bestTag .. "**\n" ..
                      "👥 **Active Players**\n" ..
                      "**" .. playerStr .. "**\n\n" ..
                      "🏡 **Other Base Brainrots (Up to 10)**\n" ..
                      description,
        footer = {
            text = "👻 Ghost Analytics Engine Active • " .. os.date("%H:%M")
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }

    pcall(function()
        httpRequest({
            Url = webhookUrl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({
                username = "👻 Ghost Notifier",
                embeds = { embed },
            }),
        })
        print(string.format("[WEBHOOK] Sent to %s tier: %s (%s) | %s", tier, best.name, fmtMoney(best.gen), playerStr))
    end)
end

-- =============================================
-- WEBSOCKET CONNECTION (Local)
-- =============================================
local wsConnection

local function connectWS()
    local connector = (WebSocket and WebSocket.connect) or (syn and syn.websocket and syn.websocket.connect) or (websocket and websocket.connect)
    if not connector then
        print("[!] WebSocket NOT supported in this executor")
        return
    end
    
    print("[WS] Connecting to", WS_URL)
    local ok, sock = pcall(connector, WS_URL)
    if not ok or not sock then
        print("[WS] Connection failed, retrying in 5s...")
        task.wait(5)
        return connectWS()
    end
    
    wsConnection = sock
    print("[WS] ✅ Connected to local server!")
    
    sock.OnClose:Connect(function()
        print("[WS] Disconnected, reconnecting...")
        task.wait(5)
        connectWS()
    end)
end

-- =============================================
-- DISABLE RENDERING (performance)
-- =============================================
local function disableRendering()
    pcall(function()
        if Workspace and Workspace.CurrentCamera then
            Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            Workspace.CurrentCamera.CFrame = CFrame.new(1e9, 1e9, 1e9)
        end
        local lighting = game:GetService("Lighting")
        if lighting then
            lighting.Brightness = 0
            lighting.GlobalShadows = false
        end
        Workspace.StreamingEnabled = true
        Workspace.StreamingTargetRadius = 0
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if pg then pg.Enabled = false end
    end)
end

disableRendering()
spawn(function()
    while true do
        task.wait(1)
        disableRendering()
    end
end)

-- =============================================
-- GENERATION EXTRACTION
-- =============================================
local function extractGenerationFromPet(petModel)
    local debris = Workspace:FindFirstChild("Debris")
    if not debris then return 0, "N/A" end

    for _, part in pairs(debris:GetChildren()) do
        if part.Name == "FastOverheadTemplate" and part:IsA("BasePart") then
            local animalOverhead = part:FindFirstChild("AnimalOverhead")
            if animalOverhead and animalOverhead:IsA("SurfaceGui") then
                local generationLabel  = animalOverhead:FindFirstChild("Generation")
                local displayNameLabel = animalOverhead:FindFirstChild("DisplayName")
                if generationLabel and displayNameLabel then
                    local displayName = displayNameLabel.Text or ""
                    if displayName == petModel.Name then
                        local generationText = generationLabel.Text or ""
                        if generationText ~= "" then
                            local stripped = generationText:gsub("^%$", "")
                            local firstValue = stripped:match("^([^%s/]+)")
                            if firstValue then
                                local cleanText  = firstValue:gsub(" ", "")
                                local multiplier = 1
                                local value      = cleanText
                                if cleanText:find("T") then
                                    multiplier = 1e12; value = cleanText:gsub("T","")
                                elseif cleanText:find("B") then
                                    multiplier = 1e9;  value = cleanText:gsub("B","")
                                elseif cleanText:find("M") then
                                    multiplier = 1e6;  value = cleanText:gsub("M","")
                                elseif cleanText:find("K") then
                                    multiplier = 1e3;  value = cleanText:gsub("K","")
                                end
                                local numValue = tonumber(value)
                                local earningValue = numValue and (numValue * multiplier) or 0
                                return earningValue, stripped
                            end
                        end
                    end
                end
            end
        end
    end
    return 0, "N/A"
end

-- =============================================
-- SEND TO WEBSOCKET
-- =============================================
local sentCache = {}

local function sendToWebSocket(foundTargets, plotName, allBrainrotsInServer, playerCount, playerStr)
    if not wsConnection then
        print("[WS] Not connected, can't send")
        return
    end
    
    if #foundTargets == 0 then
        return
    end
    
    local best = foundTargets[1]
    for _, t in ipairs(foundTargets) do
        if t.gen > best.gen then best = t end
    end
    
    local brainrotsList = {}
    for _, b in ipairs(allBrainrotsInServer) do
        local tag = TAG_MAP[b.name]
        local line = tag and string.format("[%s] %s | $%s", tag, b.name, b.genText) or string.format("%s | $%s", b.name, b.genText)
        table.insert(brainrotsList, line)
    end
    
    local hasOG = false
    for _, t in ipairs(foundTargets) do
        if OG_SET[t.name] then hasOG = true; break end
    end
    
    local message = {
        op = "brainrot/sighting",
        data = {
            jobId = JOB_ID,
            placeId = PLACE_ID,
            players = playerCount,
            playerLimit = 8,
            playerString = playerStr,
            hasOG = hasOG,
            brainrots = {},
            allBrainrots = brainrotsList,
            plotName = plotName,
            botName = BOT_USERNAME,
            timestamp = os.time()
        }
    }
    
    for _, t in ipairs(foundTargets) do
        table.insert(message.data.brainrots, {
            brainrotName = t.name,
            value = t.gen,
            valueFormatted = fmtMoney(t.gen),
            generationText = t.genText,
            isOG = t.isOG or false,
            tag = TAG_MAP[t.name] or "Normal"
        })
    end
    
    local success, err = pcall(function()
        wsConnection:Send(HttpService:JSONEncode(message))
    end)
    
    if success then
        print(string.format("[SENT] %s | %s | %s", best.name, fmtMoney(best.gen), playerStr))
    else
        print("[ERROR] Failed to send:", err)
    end
end

-- =============================================
-- SCAN PLOTS
-- =============================================
local function isPlayerBase(plot)
    local sign = plot:FindFirstChild("PlotSign")
    return sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled
end

local lastScanned = {}
local SCAN_INTERVAL = 0.2
local SERVER_HOP_INTERVAL = 15
local hopTimer = 0

local function scanPlots()
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then return end

    local currentTime = tick()
    local playerCount = #Players:GetPlayers()
    local playerStr = string.format("%d/%d", playerCount, 8)

    for _, plot in ipairs(plotsFolder:GetChildren()) do
        if plot:IsA("Model") and not isPlayerBase(plot) then
            local lastTime = lastScanned[plot.Name] or 0
            if currentTime - lastTime >= 0.5 then
                lastScanned[plot.Name] = currentTime

                local foundTargets = {}
                local seenTargets = {}
                local allBrainrotsInServer = {}
                local seenAll = {}

                for _, desc in ipairs(plot:GetDescendants()) do
                    if desc:IsA("Model") and TARGET_SET[desc.Name] and not seenTargets[desc.Name] then
                        seenTargets[desc.Name] = true
                        local gen, genText = extractGenerationFromPet(desc)
                        if gen > 0 then
                            table.insert(foundTargets, {
                                name = desc.Name,
                                isOG = OG_SET[desc.Name] or false,
                                gen = gen,
                                genText = genText,
                                model = desc,
                            })
                        end
                    end
                end

                for _, desc in ipairs(plot:GetDescendants()) do
                    if desc:IsA("Model") and TARGET_SET[desc.Name] and not seenAll[desc.Name] then
                        seenAll[desc.Name] = true
                        local gen, genText = extractGenerationFromPet(desc)
                        if gen > 0 then
                            table.insert(allBrainrotsInServer, {
                                name = desc.Name,
                                gen = gen,
                                genText = genText,
                            })
                        end
                    end
                end

                if #foundTargets > 0 then
                    local anyNew = false
                    for _, t in ipairs(foundTargets) do
                        local key = t.name .. JOB_ID
                        if not sentCache[key] then
                            anyNew = true
                            sentCache[key] = true
                            print(string.format("[%s] 🎯 FOUND: %s ($%s)", BOT_USERNAME, t.name, t.genText))
                        end
                    end

                    if anyNew then
                        if wsConnection then
                            sendToWebSocket(foundTargets, plot.Name, allBrainrotsInServer, playerCount, playerStr)
                        end
                        
                        sendToDiscord(foundTargets, allBrainrotsInServer, playerCount, playerStr)
                        
                        task.wait(0.3)
                    end
                end
            end
        end
    end
end

-- =============================================
-- BOT PRIORITY (avoid conflicts)
-- =============================================
local BOT_PRIORITY = {
    "timmy236NDqyqK",
    "asdjasdjasddas",
    "dsjkfkhlnjsdlfsdlf",
    "asdasdansbkdmnas",
    "jsjdjsadsad",
}

local function getPriority(name)
    for i, bot in ipairs(BOT_PRIORITY) do
        if bot == name then return i end
    end
    return 999
end

local function shouldLeave()
    local myPriority = getPriority(BOT_USERNAME)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name ~= BOT_USERNAME then
            if getPriority(player.Name) < myPriority then
                print(string.format("[%s] Higher priority bot %s found, leaving", BOT_USERNAME, player.Name))
                return true
            end
        end
    end
    return false
end

-- =============================================
-- MAIN LOOP
-- =============================================
print(string.rep("=", 50))
print("👻 GHOST NOTIFIER SCANNER")
print(string.rep("=", 50))
print(string.format("Bot:      %s", BOT_USERNAME))
print(string.format("Interval: %.1fs", SCAN_INTERVAL))
print(string.format("Targets:  %d brainrots (5M+)", #TARGET_NAMES))
print(string.format("WS Server: %s", WS_URL))
print(string.rep("=", 50))

connectWS()
task.wait(2)

if shouldLeave() then
    print(string.format("[%s] Leaving to avoid conflict...", BOT_USERNAME))
    task.wait(1)
    TeleportService:Teleport(PLACE_ID)
    return
end

local lastScan = tick()

while true do
    local now = tick()
    if now - lastScan >= SCAN_INTERVAL then
        lastScan = now
        pcall(scanPlots)
        hopTimer = hopTimer + SCAN_INTERVAL
        if hopTimer >= SERVER_HOP_INTERVAL then
            hopTimer = 0
            print(string.format("[%s] 🔄 Server hopping...", BOT_USERNAME))
            task.wait(1)
            TeleportService:Teleport(PLACE_ID)
            break
        end
    end
    task.wait()
end
