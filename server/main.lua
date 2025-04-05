local QBCore = exports['qb-core']:GetCoreObject()

-- Tabela przechowująca lokalizacje narkotyków - dostępna TYLKO po stronie serwera
local DrugLocations = {
    ['weed'] = {
        harvest = {
            {coords = vector3(2222.710, 5577.859, 53.84), radius = 20.0},
            {coords = vector3(2213.098, 5577.585, 53.89), radius = 15.0}
        },
        process = {
            {coords = vector3(1391.943, 3605.709, 38.94), radius = 10.0}
        },
        package = {
            {coords = vector3(1465.949, 6344.453, 23.83), radius = 10.0}
        }
    },
    ['cocaine'] = {
        harvest = {
            {coords = vector3(5433.478, -5156.901, 78.92), radius = 20.0}
        },
        process = {
            {coords = vector3(1087.141, -3195.921, -38.99), radius = 10.0}
        },
        package = {
            {coords = vector3(1090.766, -3196.646, -38.99), radius = 10.0}
        }
    },
    ['meth'] = {
        harvest = {
            {coords = vector3(1454.222, -1651.491, 68.15), radius = 20.0}
        },
        process = {
            {coords = vector3(978.150, -147.438, 74.23), radius = 10.0}
        },
        package = {
            {coords = vector3(982.359, -145.292, 74.23), radius = 10.0}
        }
    }
}

-- Funkcja do prostego szyfrowania koordynatów (dla utrudnienia dump'owania)
local function EncryptCoords(coords, salt)
    local encryptedCoords = {}
    local saltValue = string.byte(salt, 1, 1) or 10
    
    encryptedCoords.x = coords.x + saltValue
    encryptedCoords.y = coords.y - saltValue
    encryptedCoords.z = coords.z * (saltValue * 0.01)
    
    return encryptedCoords
end

-- Funkcja deszyfrująca koordynaty
local function DecryptCoords(coords, salt)
    local decryptedCoords = {}
    local saltValue = string.byte(salt, 1, 1) or 10
    
    decryptedCoords.x = coords.x - saltValue
    decryptedCoords.y = coords.y + saltValue
    decryptedCoords.z = coords.z / (saltValue * 0.01)
    
    return vector3(decryptedCoords.x, decryptedCoords.y, decryptedCoords.z)
end

-- Funkcja generująca unikalny salt dla każdego gracza (dla dodatkowego bezpieczeństwa)
local function GeneratePlayerSalt(playerId)
    local player = QBCore.Functions.GetPlayer(playerId)
    if not player then return "defaultsalt" end
    
    local license = QBCore.Functions.GetIdentifier(playerId, 'license') or ""
    local uniqueSalt = license:sub(-10) .. playerId
    
    return uniqueSalt
end

-- Funkcja wysyłająca zaszyfrowane lokalizacje do klienta
local function SendEncryptedLocationToClient(playerId, drugType, locationType, locationIndex)
    local salt = GeneratePlayerSalt(playerId)
    
    if not DrugLocations[drugType] or not DrugLocations[drugType][locationType] then return end
    
    local location = DrugLocations[drugType][locationType][locationIndex]
    if not location then return end
    
    local encryptedCoords = EncryptCoords(location.coords, salt)
    
    -- Wysyłamy tylko tę jedną lokalizację, której gracz potrzebuje
    TriggerClientEvent('kubi-drugs:client:receiveLocation', playerId, {
        drugType = drugType,
        locationType = locationType,
        locationIndex = locationIndex,
        coords = encryptedCoords,
        radius = location.radius,
        salt = salt
    })
end

-- Callback zwracający zaszyfrowane lokalizacje
QBCore.Functions.CreateCallback('kubi-drugs:server:requestLocations', function(source, callback, drugType)
    local salt = GeneratePlayerSalt(source)
    local encryptedLocations = {}
    
    if not DrugLocations[drugType] then
        callback(false)
        return
    end
    
    -- Przygotowujemy tablicę zawierającą TYLKO typy lokalizacji i ilość punktów (bez koordynatów)
    for locationType, locations in pairs(DrugLocations[drugType]) do
        encryptedLocations[locationType] = {}
        for i = 1, #locations do
            -- Wysyłamy tylko informację o istnieniu punktu, bez koordynatów
            encryptedLocations[locationType][i] = {
                exists = true,
                index = i
            }
        end
    end
    
    callback(encryptedLocations, salt)
end)

-- Callback do sprawdzania czy gracz jest w odpowiedniej strefie
QBCore.Functions.CreateCallback('kubi-drugs:server:checkPlayerInZone', function(source, callback, drugType, locationType, locationIndex, reportedPosition)
    local salt = GeneratePlayerSalt(source)
    
    if not DrugLocations[drugType] or not DrugLocations[drugType][locationType] or not DrugLocations[drugType][locationType][locationIndex] then
        callback(false)
        return
    end
    
    local location = DrugLocations[drugType][locationType][locationIndex]
    local actualPosition = GetEntityCoords(GetPlayerPed(source))
    
    -- Sprawdzamy czy raportowana pozycja jest bliska faktycznej pozycji (anti-cheat)
    local positionDifference = #(vector3(reportedPosition.x, reportedPosition.y, reportedPosition.z) - actualPosition)
    if positionDifference > 5.0 then
        LogSecurityViolation(source, "Fałszywe raportowanie pozycji przy sprawdzaniu strefy")
        callback(false)
        return
    end
    
    -- Sprawdzamy czy gracz jest w strefie
    local distance = #(actualPosition - location.coords)
    callback(distance <= location.radius)
end)

-- Sprawdzanie ilości policjantów na służbie
local function GetCopCount()
    local count = 0
    local players = QBCore.Functions.GetQBPlayers()
    
    for _, player in pairs(players) do
        if player.PlayerData.job.name == "police" and player.PlayerData.job.onduty then
            count = count + 1
        end
    end
    
    return count
end

-- Callback pobierający token bezpieczeństwa dla klienta
QBCore.Functions.CreateCallback('kubi-drugs:server:getSecurityToken', function(source, callback)
    local token = GenerateSecurityToken(source)
    callback(token)
end)

-- Callback pobierający konkretną lokalizację po podaniu indeksu
QBCore.Functions.CreateCallback('kubi-drugs:server:getLocationByIndex', function(source, callback, token, drugType, locationType, locationIndex)
    -- Weryfikacja tokenu bezpieczeństwa
    if not VerifySecurityToken(source, token) then
        callback(false)
        return
    end
    
    -- Resetujemy token po użyciu
    ResetSecurityToken(source)
    
    -- Wysyłamy zaszyfrowaną lokalizację
    SendEncryptedLocationToClient(source, drugType, locationType, locationIndex)
    callback(true)
end)

-- Zmodyfikowana funkcja weryfikacji strefy używająca nowego systemu
function IsPlayerInZone(playerId, drugType, zoneType, locationIndex)
    local player = QBCore.Functions.GetPlayer(playerId)
    if not player then return false end
    
    if not DrugLocations[drugType] or not DrugLocations[drugType][zoneType] then return false end
    
    -- Jeśli nie podano konkretnego indeksu, sprawdzamy wszystkie lokalizacje tego typu
    if not locationIndex then
        local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
        local inZone = false
        
        for idx, location in ipairs(DrugLocations[drugType][zoneType]) do
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
    else
        -- Sprawdzamy konkretną lokalizację po indeksie
        local location = DrugLocations[drugType][zoneType][locationIndex]
        if not location then return false end
        
        local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
        local distance = #(playerCoords - location.coords)
        local inZone = distance <= location.radius
        
        if not inZone then
            LogSecurityViolation(playerId, "Próba akcji " .. zoneType .. " dla " .. drugType .. " poza wyznaczoną strefą (indeks: " .. locationIndex .. ")")
        end
        
        return inZone
    end
end

-- Event do zbierania narkotyków
RegisterSecuredEvent('kubi-drugs:server:harvestDrug', function(source, drugType, locationIndex)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    -- Sprawdzanie wymaganej ilości policjantów
    if GetCopCount() < Config.MinCops then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.not_enough_police"), "error")
        return
    end
    
    -- Sprawdzanie czy gracz jest w odpowiedniej strefie
    if not IsPlayerInZone(source, drugType, "harvest", locationIndex) then
        return
    end
    
    -- Pobieranie informacji o nagrodzie
    local drugData = Config.Drugs[drugType]
    if not drugData then return end
    
    local rewardItem = drugData.rewardItems.harvest[1]
    if not rewardItem then return end
    
    -- Losowanie ilości
    local amount = math.random(rewardItem.amount.min, rewardItem.amount.max)
    
    -- Sprawdzanie miejsca w ekwipunku
    if not Player.Functions.AddItem(rewardItem.name, amount) then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.no_space_inventory"), "error")
        return
    end
    
    -- Notyfikacja o sukcesie
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[rewardItem.name], "add")
    TriggerClientEvent('QBCore:Notify', source, Lang:t("success.harvested", {
        amount = amount,
        item = QBCore.Shared.Items[rewardItem.name].label
    }), "success")
end)

-- Event do przetwarzania narkotyków
RegisterSecuredEvent('kubi-drugs:server:processDrug', function(source, drugType, locationIndex)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    -- Sprawdzanie wymaganej ilości policjantów
    if GetCopCount() < Config.MinCops then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.not_enough_police"), "error")
        return
    end
    
    -- Sprawdzanie czy gracz jest w odpowiedniej strefie
    if not IsPlayerInZone(source, drugType, "process", locationIndex) then
        return
    end
    
    -- Pobieranie informacji o procesie
    local drugData = Config.Drugs[drugType]
    if not drugData then return end
    
    -- Sprawdzanie czy gracz ma wymagane przedmioty
    local hasAllItems = true
    for _, requiredItem in ipairs(drugData.requiredItems.process) do
        if Player.Functions.GetItemByName(requiredItem.name).amount < requiredItem.amount then
            hasAllItems = false
            break
        end
    end
    
    if not hasAllItems then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.no_required_items"), "error")
        return
    end
    
    -- Usuwanie wymaganych przedmiotów
    for _, requiredItem in ipairs(drugData.requiredItems.process) do
        Player.Functions.RemoveItem(requiredItem.name, requiredItem.amount)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[requiredItem.name], "remove")
    end
    
    -- Dodawanie nagrody
    local rewardItem = drugData.rewardItems.process[1]
    Player.Functions.AddItem(rewardItem.name, rewardItem.amount)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[rewardItem.name], "add")
    
    -- Notyfikacja o sukcesie
    TriggerClientEvent('QBCore:Notify', source, Lang:t("success.processed", {
        amount = rewardItem.amount,
        item = QBCore.Shared.Items[rewardItem.name].label
    }), "success")
end)

-- Event do pakowania narkotyków
RegisterSecuredEvent('kubi-drugs:server:packageDrug', function(source, drugType, locationIndex)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    -- Sprawdzanie wymaganej ilości policjantów
    if GetCopCount() < Config.MinCops then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.not_enough_police"), "error")
        return
    end
    
    -- Sprawdzanie czy gracz jest w odpowiedniej strefie
    if not IsPlayerInZone(source, drugType, "package", locationIndex) then
        return
    end
    
    -- Pobieranie informacji o procesie
    local drugData = Config.Drugs[drugType]
    if not drugData then return end
    
    -- Sprawdzanie czy gracz ma wymagane przedmioty
    local hasAllItems = true
    for _, requiredItem in ipairs(drugData.requiredItems.package) do
        if Player.Functions.GetItemByName(requiredItem.name).amount < requiredItem.amount then
            hasAllItems = false
            break
        end
    end
    
    if not hasAllItems then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.no_required_items"), "error")
        return
    end
    
    -- Usuwanie wymaganych przedmiotów
    for _, requiredItem in ipairs(drugData.requiredItems.package) do
        Player.Functions.RemoveItem(requiredItem.name, requiredItem.amount)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[requiredItem.name], "remove")
    end
    
    -- Dodawanie nagrody
    local rewardItem = drugData.rewardItems.package[1]
    Player.Functions.AddItem(rewardItem.name, rewardItem.amount)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[rewardItem.name], "add")
    
    -- Notyfikacja o sukcesie
    TriggerClientEvent('QBCore:Notify', source, Lang:t("success.packaged", {
        amount = rewardItem.amount,
        item = QBCore.Shared.Items[rewardItem.name].label
    }), "success")
end)

-- Event do sprzedaży narkotyków
RegisterSecuredEvent('kubi-drugs:server:sellDrugs', function(source, drugType, dealerId)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    -- Sprawdzanie wymaganej ilości policjantów
    if GetCopCount() < Config.MinCops then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.not_enough_police"), "error")
        return
    end
    
    -- Pobieranie informacji o dealerze
    local dealer = Config.Dealers[dealerId]
    if not dealer then return end
    
    -- Sprawdzanie czy dealer obsługuje ten rodzaj narkotyku
    local supportsThisDrug = false
    for _, drug in ipairs(dealer.drugs) do
        if drug == drugType then
            supportsThisDrug = true
            break
        end
    end
    
    if not supportsThisDrug then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.dealer_unavailable"), "error")
        return
    end
    
    -- Sprawdzanie godzin pracy dealera
    local currentHour = tonumber(os.date("%H"))
    if currentHour < dealer.hours.from or currentHour >= dealer.hours.to then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.dealer_unavailable"), "error")
        return
    end
    
    -- Sprawdzanie czy gracz ma narkotyko do sprzedania
    local drugData = Config.Drugs[drugType]
    if not drugData then return end
    
    local packagedItemName = drugData.rewardItems.package[1].name
    local item = Player.Functions.GetItemByName(packagedItemName)
    
    if not item or item.amount <= 0 then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.no_drugs_to_sell"), "error")
        return
    end
    
    -- Losowanie ceny w zakresie
    local price = math.random(drugData.sellPrice.min, drugData.sellPrice.max)
    
    -- Usuwanie narkotyku z ekwipunku
    Player.Functions.RemoveItem(packagedItemName, 1)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[packagedItemName], "remove")
    
    -- Dodawanie pieniędzy
    Player.Functions.AddMoney("cash", price)
    
    -- Notyfikacja o sukcesie
    TriggerClientEvent('QBCore:Notify', source, Lang:t("success.sold_drugs", {
        amount = 1,
        item = QBCore.Shared.Items[packagedItemName].label,
        money = price
    }), "success")
    
    -- Szansa na wezwanie policji
    if math.random(1, 100) <= Config.PoliceCallChance then
        local playerCoords = GetEntityCoords(GetPlayerPed(source))
        -- Alert dla policji
        for _, v in pairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(v)
            if Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty then
                TriggerClientEvent('kubi-drugs:client:policeAlert', v, playerCoords, Lang:t("info.drug_deal"))
            end
        end
    end
end)

-- Rejestracja przedmiotów przy starcie skryptu
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    
    -- Sprawdzamy czy przedmioty istnieją w QBCore, jeśli nie - dodajemy je
    local items = {
        -- Surowce
        ['weed_leaf'] = {
            name = 'weed_leaf',
            label = 'Liść marihuany',
            weight = 100,
            type = 'item',
            image = 'weed_leaf.png',
            unique = false,
            useable = false,
            shouldClose = false,
            combinable = nil,
            description = 'Surowy liść marihuany.'
        },
        ['cocaine_leaf'] = {
            name = 'cocaine_leaf',
            label = 'Liść koki',
            weight = 100,
            type = 'item',
            image = 'cocaine_leaf.png',
            unique = false,
            useable = false,
            shouldClose = false,
            combinable = nil,
            description = 'Liść rośliny koki.'
        },
        ['meth_raw'] = {
            name = 'meth_raw',
            label = 'Surowa metamfetamina',
            weight = 100,
            type = 'item',
            image = 'meth_raw.png',
            unique = false,
            useable = false,
            shouldClose = false,
            combinable = nil,
            description = 'Surowy produkt do przygotowania metamfetaminy.'
        },
        
        -- Przetworzone
        ['weed_processed'] = {
            name = 'weed_processed',
            label = 'Przetworzona marihuana',
            weight = 50,
            type = 'item',
            image = 'weed_processed.png',
            unique = false,
            useable = false,
            shouldClose = false,
            combinable = nil,
            description = 'Marihuana gotowa do pakowania.'
        },
        ['cocaine_processed'] = {
            name = 'cocaine_processed',
            label = 'Przetworzona kokaina',
            weight = 50,
            type = 'item',
            image = 'cocaine_processed.png',
            unique = false,
            useable = false,
            shouldClose = false,
            combinable = nil,
            description = 'Kokaina gotowa do pakowania.'
        },
        ['meth_processed'] = {
            name = 'meth_processed',
            label = 'Przetworzona metamfetamina',
            weight = 50,
            type = 'item',
            image = 'meth_processed.png',
            unique = false,
            useable = false,
            shouldClose = false,
            combinable = nil,
            description = 'Metamfetamina gotowa do pakowania.'
        },
        
        -- Zapakowane (gotowe do sprzedaży)
        ['weed_packaged'] = {
            name = 'weed_packaged',
            label = 'Zapakowana marihuana',
            weight = 10,
            type = 'item',
            image = 'weed_packaged.png',
            unique = false,
            useable = false,
            shouldClose = false,
            combinable = nil,
            description = 'Zapakowana marihuana gotowa do sprzedaży.'
        },
        ['cocaine_packaged'] = {
            name = 'cocaine_packaged',
            label = 'Zapakowana kokaina',
            weight = 10,
            type = 'item',
            image = 'cocaine_packaged.png',
            unique = false,
            useable = false,
            shouldClose = false,
            combinable = nil,
            description = 'Zapakowana kokaina gotowa do sprzedaży.'
        },
        ['meth_packaged'] = {
            name = 'meth_packaged',
            label = 'Zapakowana metamfetamina',
            weight = 10,
            type = 'item',
            image = 'meth_packaged.png',
            unique = false,
            useable = false,
            shouldClose = false,
            combinable = nil,
            description = 'Zapakowana metamfetamina gotowa do sprzedaży.'
        },
        
        -- Dodatkowe przedmioty
        ['plastic_bag'] = {
            name = 'plastic_bag',
            label = 'Woreczek foliowy',
            weight = 1,
            type = 'item',
            image = 'plastic_bag.png',
            unique = false,
            useable = false,
            shouldClose = false,
            combinable = nil,
            description = 'Woreczek foliowy do pakowania substancji.'
        },
        ['chemicals'] = {
            name = 'chemicals',
            label = 'Chemikalia',
            weight = 100,
            type = 'item',
            image = 'chemicals.png',
            unique = false,
            useable = false,
            shouldClose = false,
            combinable = nil,
            description = 'Chemikalia używane do produkcji narkotyków.'
        }
    }
    
    for name, data in pairs(items) do
        QBCore.Functions.AddItem(name, data)
        print('Zarejestrowano przedmiot: ' .. name)
    end
end) 