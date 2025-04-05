local QBCore = exports['qb-core']:GetCoreObject()

-- Tabela do przechowywania tokenów bezpieczeństwa dla graczy
local SecurityTokens = {}

-- Funkcja do generowania losowego ciągu znaków
local function GenerateRandomString(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    
    math.randomseed(os.time())
    for i = 1, length do
        local rand = math.random(1, #charset)
        result = result .. string.sub(charset, rand, rand)
    end
    
    return result
end

-- Funkcja do generowania tokenu bezpieczeństwa
function GenerateSecurityToken(playerId)
    local token = GenerateRandomString(Config.SecurityTokenLength)
    local expiry = os.time() + Config.SecurityTokenExpiry
    
    SecurityTokens[playerId] = {
        token = token,
        expiry = expiry,
        errorCount = 0
    }
    
    return token
end

-- Funkcja do weryfikacji tokenu bezpieczeństwa
function VerifySecurityToken(playerId, token)
    local tokenData = SecurityTokens[playerId]
    
    -- Sprawdzanie czy token istnieje
    if not tokenData then
        LogSecurityViolation(playerId, "Próba użycia niewygenerowanego tokenu")
        return false
    end
    
    -- Sprawdzanie czy token jest prawidłowy
    if tokenData.token ~= token then
        tokenData.errorCount = tokenData.errorCount + 1
        LogSecurityViolation(playerId, "Nieprawidłowy token bezpieczeństwa")
        
        -- Wyrzucanie gracza po przekroczeniu maksymalnej liczby błędów
        if tokenData.errorCount >= Config.MaxAllowedErrors then
            if Config.BanOnSuspectedCheating then
                BanPlayer(playerId, "Podejrzenie oszustwa: wielokrotne próby użycia nieprawidłowego tokenu bezpieczeństwa")
            else
                DropPlayer(playerId, "Zbyt wiele błędów bezpieczeństwa")
            end
        end
        
        return false
    end
    
    -- Sprawdzanie czy token nie wygasł
    if os.time() > tokenData.expiry then
        LogSecurityViolation(playerId, "Próba użycia wygasłego tokenu")
        return false
    end
    
    return true
end

-- Funkcja do resetowania tokenu bezpieczeństwa
function ResetSecurityToken(playerId)
    SecurityTokens[playerId] = nil
end

-- Funkcja do logowania naruszeń bezpieczeństwa
function LogSecurityViolation(playerId, reason)
    local player = QBCore.Functions.GetPlayer(playerId)
    local identifier = "Unknown"
    
    if player then
        identifier = QBCore.Functions.GetIdentifier(playerId, 'license') or "Unknown"
    end
    
    print("^1[KUBI-DRUGS] [SECURITY VIOLATION] Player ID: " .. playerId .. " | Identifier: " .. identifier .. " | Reason: " .. reason .. "^0")
    
    -- Dodatkowe logowanie do pliku
    local logFile = io.open(GetResourcePath(GetCurrentResourceName()) .. "/security_logs.txt", "a")
    if logFile then
        logFile:write("[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] Player ID: " .. playerId .. " | Identifier: " .. identifier .. " | Reason: " .. reason .. "\n")
        logFile:close()
    end
end

-- Funkcja do banowania gracza
function BanPlayer(playerId, reason)
    -- Tutaj możesz zaimplementować logikę banowania gracza używając wybranego systemu banów
    -- Na przykład używając wbudowanego systemu banów QBCore lub zewnętrznej wtyczki
    
    -- Przykład:
    -- exports['qb-admin']:BanPlayer(playerId, reason, 0) -- Ban permanentny
    
    -- Tymczasowo używamy DropPlayer
    DropPlayer(playerId, "Zostałeś zbanowany: " .. reason)
end

-- Funkcja do tworzenia zabezpieczonych callbacków
function CreateSecuredCallback(name, cb)
    QBCore.Functions.CreateCallback(name, function(source, callback, token, ...)
        if not VerifySecurityToken(source, token) then
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.invalid_security_token"), "error")
            callback(false)
            return
        end
        
        -- Resetowanie tokenu po każdym użyciu
        ResetSecurityToken(source)
        
        -- Wywołanie oryginalnego callbacka
        cb(source, callback, ...)
    end)
end

-- Funkcja do rejestrowania zabezpieczonych eventów
function RegisterSecuredEvent(eventName, cb)
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function(token, ...)
        local source = source
        
        if not VerifySecurityToken(source, token) then
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.invalid_security_token"), "error")
            return
        end
        
        -- Resetowanie tokenu po każdym użyciu
        ResetSecurityToken(source)
        
        -- Wywołanie oryginalnego callbacka
        cb(source, ...)
    end)
end

-- Nowe funkcje zabezpieczające dla systemu laboratoriów

-- Tabela przechowująca dostępy do laboratoriów dla graczy
local LabAccess = {}

-- Funkcja sprawdzająca czy gracz ma dostęp do laboratorium
function HasLabAccess(playerId, labName)
    if not LabAccess[playerId] then
        return false
    end
    
    return LabAccess[playerId][labName] or false
end

-- Funkcja przyznająca dostęp do laboratorium
function GrantLabAccess(playerId, labName)
    if not LabAccess[playerId] then
        LabAccess[playerId] = {}
    end
    
    LabAccess[playerId][labName] = true
    
    -- Zapisz dostęp w bazie danych (przykład)
    local player = QBCore.Functions.GetPlayer(playerId)
    if player then
        local citizenid = player.PlayerData.citizenid
        exports.oxmysql:execute('INSERT INTO player_lab_access (citizenid, lab_name) VALUES (?, ?) ON DUPLICATE KEY UPDATE lab_name = VALUES(lab_name)',
            {citizenid, labName})
    end
end

-- Funkcja wczytująca dostępy do laboratoriów dla gracza
function LoadLabAccess(playerId)
    local player = QBCore.Functions.GetPlayer(playerId)
    if not player then return end
    
    local citizenid = player.PlayerData.citizenid
    
    exports.oxmysql:execute('SELECT lab_name FROM player_lab_access WHERE citizenid = ?', {citizenid}, function(result)
        LabAccess[playerId] = {}
        
        if result and #result > 0 then
            for _, v in ipairs(result) do
                LabAccess[playerId][v.lab_name] = true
            end
        end
    end)
end

-- Callback do sprawdzania dostępu do laboratorium
QBCore.Functions.CreateCallback('kubi-drugs:server:checkLabAccess', function(source, callback, token, labName)
    if not VerifySecurityToken(source, token) then
        callback(false)
        return
    end
    
    -- Resetuj token po użyciu
    ResetSecurityToken(source)
    
    -- Sprawdź dostęp
    callback(HasLabAccess(source, labName))
end)

-- Event do kupowania dostępu do laboratorium
RegisterSecuredEvent('kubi-drugs:server:buyLabAccess', function(source, labName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    -- Znajdź laboratorium w konfiguracji
    local lab = nil
    for _, v in ipairs(Config.Labs) do
        if v.name == labName then
            lab = v
            break
        end
    end
    
    if not lab then
        TriggerClientEvent('QBCore:Notify', source, "Laboratorium nie istnieje", "error")
        return
    end
    
    -- Sprawdź czy gracz ma wystarczająco pieniędzy
    if Player.PlayerData.money.cash < lab.unlockPrice then
        TriggerClientEvent('QBCore:Notify', source, "Nie masz wystarczająco pieniędzy", "error")
        return
    end
    
    -- Pobierz opłatę
    Player.Functions.RemoveMoney('cash', lab.unlockPrice)
    
    -- Przyznaj dostęp
    GrantLabAccess(source, labName)
    
    -- Powiadom gracza
    TriggerClientEvent('QBCore:Notify', source, Lang:t("success.lab_accessed", {lab = lab.label}), "success")
end)

-- System jakości narkotyków
local DrugQualities = {}

-- Funkcja generująca losową jakość narkotyku
function GenerateDrugQuality(playerId, drugType, labLevel)
    -- Domyślny poziom jakości - standard
    local defaultQualityIndex = 2
    
    -- Tabela z wagami dla poszczególnych poziomów jakości
    local qualityWeights = {
        [1] = 50,  -- poor
        [2] = 30,  -- standard
        [3] = 15,  -- high
        [4] = 5    -- premium
    }
    
    -- Zwiększenie szansy na lepszą jakość w zależności od poziomu laboratorium
    if labLevel and labLevel > 0 then
        -- Zmniejsz szansę na niską jakość
        qualityWeights[1] = math.max(qualityWeights[1] - (labLevel * 10), 5)
        
        -- Zwiększ szansę na wyższą jakość
        qualityWeights[3] = qualityWeights[3] + (labLevel * 5)
        qualityWeights[4] = qualityWeights[4] + (labLevel * 5)
        
        -- Reszta na standardową jakość
        qualityWeights[2] = 100 - (qualityWeights[1] + qualityWeights[3] + qualityWeights[4])
    end
    
    -- Losowanie jakości na podstawie wag
    local totalWeight = 0
    for _, weight in pairs(qualityWeights) do
        totalWeight = totalWeight + weight
    end
    
    local randomValue = math.random(1, totalWeight)
    local currentWeight = 0
    local selectedQuality = 1
    
    for i, weight in pairs(qualityWeights) do
        currentWeight = currentWeight + weight
        if randomValue <= currentWeight then
            selectedQuality = i
            break
        end
    end
    
    -- Zapisz jakość dla późniejszego użycia
    if not DrugQualities[playerId] then
        DrugQualities[playerId] = {}
    end
    
    if not DrugQualities[playerId][drugType] then
        DrugQualities[playerId][drugType] = {}
    end
    
    DrugQualities[playerId][drugType] = Config.QualityLevels[selectedQuality]
    
    return DrugQualities[playerId][drugType]
end

-- Funkcja pobierająca aktualną jakość narkotyku dla gracza
function GetDrugQuality(playerId, drugType)
    if not DrugQualities[playerId] or not DrugQualities[playerId][drugType] then
        return Config.QualityLevels[2] -- Domyślnie standard
    end
    
    return DrugQualities[playerId][drugType]
end

-- Funkcja sprawdzająca czy proces produkcji się powiódł
function CheckProcessSuccess(playerId, drugType, labLevel)
    local drugData = Config.Drugs[drugType]
    if not drugData then return true end -- Jeśli nie ma danych o narkotyku, zawsze sukces
    
    local failChance = drugData.failChance or 0
    
    -- Zmniejszenie szansy na niepowodzenie w zależności od poziomu laboratorium
    if labLevel and labLevel > 0 then
        local lab = nil
        for _, v in ipairs(Config.Labs) do
            if v.level == labLevel then
                lab = v
                break
            end
        end
        
        if lab then
            failChance = math.max(0, failChance - lab.failChanceReduction)
        end
    end
    
    -- Losowanie
    return math.random(1, 100) > failChance
end

-- Funkcja sprawdzająca czy nastąpi eksplozja/pożar
function CheckExplosion(playerId, drugType)
    local drugData = Config.Drugs[drugType]
    if not drugData then return false end
    
    local explodeChance = drugData.explodeChance or 0
    
    -- Losowanie
    return math.random(1, 100) <= explodeChance
end

-- Funkcja weryfikująca czy gracz ma wymagany sprzęt laboratoryjny
function HasRequiredLabEquipment(playerId, equipmentList)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if not Player then return false end
    
    for _, equipment in ipairs(equipmentList) do
        if Player.Functions.GetItemByName(equipment) == nil then
            return false
        end
    end
    
    return true
end

-- Callback sprawdzający czy laboratorium może być używane do danego narkotyku
QBCore.Functions.CreateCallback('kubi-drugs:server:canUseLab', function(source, callback, token, labName, drugType)
    if not VerifySecurityToken(source, token) then
        callback(false)
        return
    end
    
    -- Resetuj token po użyciu
    ResetSecurityToken(source)
    
    -- Znajdź laboratorium
    local lab = nil
    for _, v in ipairs(Config.Labs) do
        if v.name == labName then
            lab = v
            break
        end
    end
    
    if not lab then
        callback(false)
        return
    end
    
    -- Sprawdź czy gracz ma dostęp do laboratorium
    if not HasLabAccess(source, labName) then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.lab_access_denied"), "error")
        callback(false)
        return
    end
    
    -- Sprawdź czy narkotyk może być produkowany w tym laboratorium
    local canProduceDrug = false
    for _, labDrug in ipairs(lab.drugs) do
        if labDrug == drugType then
            canProduceDrug = true
            break
        end
    end
    
    if not canProduceDrug then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.lab_unavailable"), "error")
        callback(false)
        return
    end
    
    -- Sprawdź czy gracz ma wymagany sprzęt
    if not HasRequiredLabEquipment(source, lab.equipmentRequired) then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.missing_equipment"), "error")
        callback(false)
        return
    end
    
    callback(true, lab.level)
end)

-- Event wywoływany po zalogowaniu gracza
RegisterNetEvent('QBCore:Server:PlayerLoaded', function()
    local src = source
    LoadLabAccess(src)
end)

-- Event wywoływany po wylogowaniu gracza
RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
    local src = source
    SecurityTokens[src] = nil
    LabAccess[src] = nil
    DrugQualities[src] = nil
end)

-- Event wywoływany przy odłączeniu gracza
AddEventHandler('playerDropped', function()
    local src = source
    SecurityTokens[src] = nil
    LabAccess[src] = nil
    DrugQualities[src] = nil
end)

-- Tworzenie tabeli w bazie danych przy uruchomieniu skryptu
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Tworzenie tabeli dla dostępów do laboratoriów
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS player_lab_access (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50) NOT NULL,
            lab_name VARCHAR(50) NOT NULL,
            UNIQUE(citizenid, lab_name)
        )
    ]])
end) 