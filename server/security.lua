local QBCore = exports['qb-core']:GetCoreObject()

-- System tokenów bezpieczeństwa
local SecurityTokens = {}

-- Funkcja generująca losowy string
local function GenerateRandomString(length)
    local characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    
    for i = 1, length do
        local randomIndex = math.random(1, #characters)
        result = result .. string.sub(characters, randomIndex, randomIndex)
    end
    
    return result
end

-- Generowanie i przechowywanie tokenu bezpieczeństwa dla gracza
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

-- Weryfikacja tokenu bezpieczeństwa
function VerifySecurityToken(playerId, token)
    local tokenData = SecurityTokens[playerId]
    
    -- Brak tokenu lub token wygasł
    if not tokenData or tokenData.expiry < os.time() then
        LogSecurityViolation(playerId, "Token wygasł lub nie istnieje")
        SecurityTokens[playerId] = {
            token = "",
            expiry = 0,
            errorCount = (tokenData and tokenData.errorCount or 0) + 1
        }
        return false
    end
    
    -- Niezgodny token
    if tokenData.token ~= token then
        LogSecurityViolation(playerId, "Niepoprawny token bezpieczeństwa")
        SecurityTokens[playerId].errorCount = SecurityTokens[playerId].errorCount + 1
        return false
    end
    
    -- Resetujemy licznik błędów gdy token jest poprawny
    SecurityTokens[playerId].errorCount = 0
    return true
end

-- Resetowanie tokenu bezpieczeństwa (np. po użyciu)
function ResetSecurityToken(playerId)
    if SecurityTokens[playerId] then
        SecurityTokens[playerId].token = ""
        SecurityTokens[playerId].expiry = 0
    end
end

-- Logowanie naruszeń bezpieczeństwa
function LogSecurityViolation(playerId, reason)
    local playerName = GetPlayerName(playerId) or "Nieznany"
    local playerIdentifier = QBCore.Functions.GetIdentifier(playerId, 'license') or "Nieznany"
    local playerIp = GetPlayerEndpoint(playerId) or "Nieznany"
    
    print(string.format("[KUBI-DRUGS] [SECURITY WARNING] Gracz: %s (ID: %s, License: %s, IP: %s) - %s", 
        playerName, playerId, playerIdentifier, playerIp, reason))
        
    -- Zapisujemy do pliku
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logMessage = string.format("[%s] [SECURITY WARNING] Gracz: %s (ID: %s, License: %s, IP: %s) - %s\n", 
        timestamp, playerName, playerId, playerIdentifier, playerIp, reason)
    
    local logFile = io.open("security_logs.txt", "a")
    if logFile then
        logFile:write(logMessage)
        logFile:close()
    end
    
    -- Sprawdzamy czy gracz powinien zostać wyrzucony/zbanowany
    local tokenData = SecurityTokens[playerId]
    if tokenData and tokenData.errorCount >= Config.MaxAllowedErrors then
        if Config.BanOnSuspectedCheating then
            -- Ban gracza
            print(string.format("[KUBI-DRUGS] [SECURITY ACTION] Gracz: %s (ID: %s) został zbanowany za podejrzenie o oszustwo.", 
                playerName, playerId))
            
            -- Przykład integracji z systemem banów
            exports.qbcore:Execute('INSERT INTO bans (name, license, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?)', {
                playerName,
                playerIdentifier,
                "Podejrzenie o oszustwo w systemie narkotyków",
                2147483647, -- Bardzo odległy czas (semi-permanent)
                "SYSTEM KUBI-DRUGS"
            })
            
            -- Wyrzucenie gracza z serwera
            DropPlayer(playerId, "Wykryto próbę manipulacji. Zostałeś zbanowany.")
        else
            -- Wyrzucenie gracza bez bana
            DropPlayer(playerId, "Wykryto próbę manipulacji. Zostałeś wyrzucony z serwera.")
        end
    end
end

-- Weryfikacja czy gracz jest w odpowiedniej strefie
function IsPlayerInZone(playerId, drugType, zoneType)
    local player = QBCore.Functions.GetPlayer(playerId)
    if not player then return false end
    
    local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
    local inZone = false
    
    local locations = Config.Locations[drugType]
    if not locations or not locations[zoneType] then return false end
    
    for _, location in ipairs(locations[zoneType]) do
        local distance = #(playerCoords - location.coords)
        if distance <= location.radius then
            inZone = true
            break
        end
    end
    
    if not inZone then
        LogSecurityViolation(playerId, "Próba akcji " .. zoneType .. " dla " .. drugType .. " poza wyznaczoną strefą")
    end
    
    return inZone
end

-- Tworzenie zabezpieczonych callbacków serwerowych
function CreateSecuredCallback(name, cb)
    QBCore.Functions.CreateCallback(name, function(source, callback, ...)
        local args = {...}
        
        -- Sprawdzamy token bezpieczeństwa (powinien być pierwszym argumentem)
        if not args[1] or not VerifySecurityToken(source, args[1]) then
            callback(false, "invalid_token")
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.invalid_security_token"), "error")
            return
        end
        
        -- Resetujemy token po użyciu
        ResetSecurityToken(source)
        
        -- Usuńmy token z argumentów
        table.remove(args, 1)
        
        -- Wywołujemy właściwy callback
        cb(source, callback, table.unpack(args))
    end)
end

-- Tworzenie zabezpieczonych eventów serwerowych
function RegisterSecuredEvent(name, cb)
    RegisterNetEvent(name, function(...)
        local args = {...}
        local source = source
        
        -- Sprawdzamy token bezpieczeństwa (powinien być pierwszym argumentem)
        if not args[1] or not VerifySecurityToken(source, args[1]) then
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.invalid_security_token"), "error")
            return
        end
        
        -- Resetujemy token po użyciu
        ResetSecurityToken(source)
        
        -- Usuńmy token z argumentów
        table.remove(args, 1)
        
        -- Wywołujemy właściwy event
        cb(source, table.unpack(args))
    end)
end

-- Cleanup przy rozłączeniu gracza
AddEventHandler('playerDropped', function()
    local source = source
    SecurityTokens[source] = nil
end) 