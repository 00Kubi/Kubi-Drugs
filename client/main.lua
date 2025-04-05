local QBCore = exports['qb-core']:GetCoreObject()

-- Zmienne lokalne
local isHarvesting = false
local isProcessing = false
local isPackaging = false
local securityToken = nil

-- Tabela na zaszyfrowane lokalizacje otrzymane z serwera
local EncryptedLocations = {}
local PlayerSalt = nil
local LocationBlips = {}

-- Funkcja do pobierania i deszyfrowania lokalizacji
local function DecryptCoords(coords, salt)
    if not coords or not salt then return vector3(0, 0, 0) end
    
    local decryptedCoords = {}
    local saltValue = string.byte(salt, 1, 1) or 10
    
    decryptedCoords.x = coords.x - saltValue
    decryptedCoords.y = coords.y + saltValue
    decryptedCoords.z = coords.z / (saltValue * 0.01)
    
    return vector3(decryptedCoords.x, decryptedCoords.y, decryptedCoords.z)
end

-- Funkcja pobierająca token bezpieczeństwa z serwera
local function GetSecurityToken(cb)
    if securityToken then
        cb(securityToken)
        return
    end

    QBCore.Functions.TriggerCallback('kubi-drugs:server:getSecurityToken', function(token)
        securityToken = token
        cb(token)
    end)
end

-- Funkcja resetująca token bezpieczeństwa
local function ResetSecurityToken()
    securityToken = nil
end

-- Funkcja pobierająca strukturę lokalizacji dla danego narkotyku (bez koordynatów)
local function RequestDrugLocationsStructure(drugType, cb)
    QBCore.Functions.TriggerCallback('kubi-drugs:server:requestLocations', function(locations, salt)
        if not locations then
            cb(false)
            return
        end
        
        -- Zapisujemy salt do późniejszego odszyfrowania
        PlayerSalt = salt
        
        -- Zapisujemy strukturę (nie ma tu koordynatów, tylko informację o ilości lokalizacji)
        EncryptedLocations[drugType] = locations
        
        cb(true)
    end, drugType)
end

-- Funkcja pobierająca konkretne koordynaty lokalizacji z serwera
local function RequestSpecificLocation(drugType, locationType, locationIndex, cb)
    -- Pobierz token bezpieczeństwa
    GetSecurityToken(function(token)
        QBCore.Functions.TriggerCallback('kubi-drugs:server:getLocationByIndex', function(success)
            if not success then
                cb(false)
                return
            end
            cb(true)
        end, token, drugType, locationType, locationIndex)
    end)
end

-- Event do odbierania zaszyfrowanej lokalizacji z serwera
RegisterNetEvent('kubi-drugs:client:receiveLocation', function(data)
    if not EncryptedLocations[data.drugType] then
        EncryptedLocations[data.drugType] = {}
    end
    
    if not EncryptedLocations[data.drugType][data.locationType] then
        EncryptedLocations[data.drugType][data.locationType] = {}
    end
    
    -- Zapisujemy zaszyfrowane koordynaty
    EncryptedLocations[data.drugType][data.locationType][data.locationIndex] = {
        coords = data.coords,
        radius = data.radius,
        salt = data.salt
    }
end)

-- Funkcja sprawdzająca czy gracz jest w odpowiedniej strefie, weryfikuje po stronie serwera
local function IsPlayerInLocation(drugType, locationType, locationIndex, cb)
    -- Jeśli brakuje danych do sprawdzenia lokalizacji, najpierw je pobierz
    if not EncryptedLocations[drugType] or not EncryptedLocations[drugType][locationType] or not EncryptedLocations[drugType][locationType][locationIndex] then
        -- Najpierw pobierz strukturę lokalizacji jeśli jej nie ma
        if not EncryptedLocations[drugType] then
            RequestDrugLocationsStructure(drugType, function(success)
                if not success then
                    cb(false)
                    return
                end
                
                -- Następnie pobierz konkretną lokalizację
                RequestSpecificLocation(drugType, locationType, locationIndex, function(success)
                    if not success then
                        cb(false)
                        return
                    end
                    
                    -- Sprawdź czy gracz jest w strefie
                    CheckPlayerZone(drugType, locationType, locationIndex, cb)
                end)
            end)
        else
            -- Jeśli struktura istnieje, pobierz tylko konkretną lokalizację
            RequestSpecificLocation(drugType, locationType, locationIndex, function(success)
                if not success then
                    cb(false)
                    return
                end
                
                -- Sprawdź czy gracz jest w strefie
                CheckPlayerZone(drugType, locationType, locationIndex, cb)
            end)
        end
    else
        -- Jeśli mamy już dane, sprawdź czy gracz jest w strefie
        CheckPlayerZone(drugType, locationType, locationIndex, cb)
    end
end

-- Funkcja sprawdzająca czy gracz jest w strefie (wysyła zapytanie do serwera)
function CheckPlayerZone(drugType, locationType, locationIndex, cb)
    local coords = GetEntityCoords(PlayerPedId())
    
    QBCore.Functions.TriggerCallback('kubi-drugs:server:checkPlayerInZone', function(isInZone)
        cb(isInZone)
    end, drugType, locationType, locationIndex, coords)
end

-- Funkcja rozpoczynająca zbieranie narkotyków
local function StartHarvesting(drugType, locationIndex)
    -- Sprawdź czy gracz już nie zbiera
    if isHarvesting then
        QBCore.Functions.Notify(Lang:t("error.already_harvesting"), "error")
        return
    end
    
    -- Sprawdź czy gracz jest w odpowiedniej strefie
    IsPlayerInLocation(drugType, "harvest", locationIndex, function(isInZone)
        if not isInZone then
            QBCore.Functions.Notify(Lang:t("error.not_in_zone"), "error")
            return
        end
        
        -- Pobierz token bezpieczeństwa
        GetSecurityToken(function(token)
            isHarvesting = true
            
            -- Rozpocznij animację
            TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
            
            -- Rozpocznij pasek postępu
            local drugData = Config.Drugs[drugType]
            QBCore.Functions.Progressbar("harvest_drugs", Lang:t("info.harvesting"), drugData.harvestTime * 1000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Ukończono
                ClearPedTasks(PlayerPedId())
                isHarvesting = false
                
                -- Wyślij event do serwera z tokenem bezpieczeństwa i indeksem lokalizacji
                TriggerServerEvent('kubi-drugs:server:harvestDrug', token, drugType, locationIndex)
                
                -- Resetuj token po użyciu
                ResetSecurityToken()
            end, function() -- Anulowano
                ClearPedTasks(PlayerPedId())
                isHarvesting = false
                QBCore.Functions.Notify(Lang:t("error.process_canceled"), "error")
            end)
        end)
    end)
end

-- Funkcja rozpoczynająca przetwarzanie narkotyków
local function StartProcessing(drugType, locationIndex)
    -- Sprawdź czy gracz już nie przetwarza
    if isProcessing then
        QBCore.Functions.Notify(Lang:t("error.already_processing"), "error")
        return
    end
    
    -- Sprawdź czy gracz jest w odpowiedniej strefie
    IsPlayerInLocation(drugType, "process", locationIndex, function(isInZone)
        if not isInZone then
            QBCore.Functions.Notify(Lang:t("error.not_in_zone"), "error")
            return
        end
        
        -- Pobierz token bezpieczeństwa
        GetSecurityToken(function(token)
            isProcessing = true
            
            -- Rozpocznij animację
            TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
            
            -- Rozpocznij pasek postępu
            local drugData = Config.Drugs[drugType]
            QBCore.Functions.Progressbar("process_drugs", Lang:t("info.processing"), drugData.processTime * 1000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Ukończono
                ClearPedTasks(PlayerPedId())
                isProcessing = false
                
                -- Wyślij event do serwera z tokenem bezpieczeństwa i indeksem lokalizacji
                TriggerServerEvent('kubi-drugs:server:processDrug', token, drugType, locationIndex)
                
                -- Resetuj token po użyciu
                ResetSecurityToken()
            end, function() -- Anulowano
                ClearPedTasks(PlayerPedId())
                isProcessing = false
                QBCore.Functions.Notify(Lang:t("error.process_canceled"), "error")
            end)
        end)
    end)
end

-- Funkcja rozpoczynająca pakowanie narkotyków
local function StartPackaging(drugType, locationIndex)
    -- Sprawdź czy gracz już nie pakuje
    if isPackaging then
        QBCore.Functions.Notify(Lang:t("error.already_packaging"), "error")
        return
    end
    
    -- Sprawdź czy gracz jest w odpowiedniej strefie
    IsPlayerInLocation(drugType, "package", locationIndex, function(isInZone)
        if not isInZone then
            QBCore.Functions.Notify(Lang:t("error.not_in_zone"), "error")
            return
        end
        
        -- Pobierz token bezpieczeństwa
        GetSecurityToken(function(token)
            isPackaging = true
            
            -- Rozpocznij animację
            TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_PARKING_METER", 0, true)
            
            -- Rozpocznij pasek postępu
            local drugData = Config.Drugs[drugType]
            QBCore.Functions.Progressbar("package_drugs", Lang:t("info.packaging"), drugData.packageTime * 1000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Ukończono
                ClearPedTasks(PlayerPedId())
                isPackaging = false
                
                -- Wyślij event do serwera z tokenem bezpieczeństwa i indeksem lokalizacji
                TriggerServerEvent('kubi-drugs:server:packageDrug', token, drugType, locationIndex)
                
                -- Resetuj token po użyciu
                ResetSecurityToken()
            end, function() -- Anulowano
                ClearPedTasks(PlayerPedId())
                isPackaging = false
                QBCore.Functions.Notify(Lang:t("error.process_canceled"), "error")
            end)
        end)
    end)
end

-- Funkcja obsługująca sprzedaż narkotyków
local function SellDrugs(drugType, dealerId)
    -- Pobierz token bezpieczeństwa
    GetSecurityToken(function(token)
        -- Rozpocznij animację
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
        
        -- Rozpocznij pasek postępu
        QBCore.Functions.Progressbar("sell_drugs", Lang:t("info.drug_deal"), 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Ukończono
            ClearPedTasks(PlayerPedId())
            
            -- Wyślij event do serwera z tokenem bezpieczeństwa
            TriggerServerEvent('kubi-drugs:server:sellDrugs', token, drugType, dealerId)
            
            -- Resetuj token po użyciu
            ResetSecurityToken()
        end, function() -- Anulowano
            ClearPedTasks(PlayerPedId())
            QBCore.Functions.Notify(Lang:t("error.process_canceled"), "error")
        end)
    end)
end

-- Funkcja tworząca blipa dla lokalizacji po jej odszyfrowaniu
local function CreateLocationBlip(drugType, locationType, locationIndex)
    -- Pobieramy lokalizację
    local locationData = EncryptedLocations[drugType][locationType][locationIndex]
    if not locationData or not locationData.coords or not locationData.salt then return end
    
    -- Odszyfrowanie koordynatów
    local coords = DecryptCoords(locationData.coords, locationData.salt)
    
    -- Utworzenie blipa
    local blipId = drugType .. "_" .. locationType .. "_" .. locationIndex
    
    -- Sprawdzamy czy blip już istnieje
    if LocationBlips[blipId] then
        RemoveBlip(LocationBlips[blipId])
    end
    
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    
    -- Ustawienie wyglądu blipa zależnie od typu lokalizacji
    SetBlipSprite(blip, 51)
    if locationType == "harvest" then
        SetBlipColour(blip, 2) -- Zielony
    elseif locationType == "process" then
        SetBlipColour(blip, 3) -- Niebieski
    elseif locationType == "package" then
        SetBlipColour(blip, 1) -- Czerwony
    end
    
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    
    local blipName = ""
    if locationType == "harvest" then
        blipName = Lang:t("info.harvest_blip")
    elseif locationType == "process" then
        blipName = Lang:t("info.process_blip")
    elseif locationType == "package" then
        blipName = Lang:t("info.package_blip")
    end
    
    AddTextComponentString(blipName .. " - " .. Config.Drugs[drugType].label)
    EndTextCommandSetBlipName(blip)
    
    -- Zapisujemy utworzony blip
    LocationBlips[blipId] = blip
    
    -- Dodaj target (opcjonalnie, jeśli włączony w konfiguracji)
    if Config.UseTarget then
        exports['qb-target']:AddCircleZone(blipId,
            coords,
            1.5,
            {
                name = blipId,
                debugPoly = Config.Debug,
            },
            {
                options = {
                    {
                        type = "client",
                        icon = "fas fa-hand",
                        label = GetTargetLabel(drugType, locationType),
                        action = function()
                            if locationType == "harvest" then
                                StartHarvesting(drugType, locationIndex)
                            elseif locationType == "process" then
                                StartProcessing(drugType, locationIndex)
                            elseif locationType == "package" then
                                StartPackaging(drugType, locationIndex)
                            end
                        end
                    },
                },
                distance = 2.0
            }
        )
    end
end

-- Funkcja zwracająca etykietę dla targetu
function GetTargetLabel(drugType, locationType)
    local targetLabel = ""
    if locationType == "harvest" then
        targetLabel = Lang:t("target.harvest")
    elseif locationType == "process" then
        targetLabel = Lang:t("target.process")
    elseif locationType == "package" then
        targetLabel = Lang:t("target.package")
    end
    
    return targetLabel .. " " .. Config.Drugs[drugType].label
end

-- Inicjalizacja systemu lokalizacji dla danego narkotyku
local function InitializeDrugLocations(drugType)
    -- Pobierz strukturę lokalizacji dla narkotyku
    RequestDrugLocationsStructure(drugType, function(success)
        if not success then return end
        
        -- Dla każdego typu lokalizacji i każdej lokalizacji w tym typie
        for locationType, locations in pairs(EncryptedLocations[drugType]) do
            for locationIndex, _ in ipairs(locations) do
                -- Pobierz konkretną lokalizację
                RequestSpecificLocation(drugType, locationType, locationIndex, function(success)
                    if success then
                        -- Utwórz blipa i target
                        CreateLocationBlip(drugType, locationType, locationIndex)
                    end
                end)
            end
        end
    end)
end

-- Ustawienie punktów zbierania na mapie
local function SetupDrugLocations()
    -- Iteruj przez wszystkie narkotyki w konfiguracji
    for drugType, _ in pairs(Config.Drugs) do
        InitializeDrugLocations(drugType)
    end
end

-- Ustawienie dealerów narkotyków na mapie
local function SetupDealers()
    -- Tworzenie pedów
    local dealerPeds = {}
    
    -- Iteracja przez wszystkich dealerów
    for dealerId, dealer in ipairs(Config.Dealers) do
        -- Sprawdzanie czy ped nie istnieje
        if not DoesEntityExist(dealerPeds[dealerId]) then
            -- Ładowanie modelu
            RequestModel(GetHashKey(dealer.ped))
            while not HasModelLoaded(GetHashKey(dealer.ped)) do
                Wait(1)
            end
            
            -- Tworzenie peda
            dealerPeds[dealerId] = CreatePed(4, GetHashKey(dealer.ped), dealer.coords.x, dealer.coords.y, dealer.coords.z - 1.0, dealer.coords.w, false, true)
            SetEntityHeading(dealerPeds[dealerId], dealer.coords.w)
            FreezeEntityPosition(dealerPeds[dealerId], true)
            SetEntityInvincible(dealerPeds[dealerId], true)
            SetBlockingOfNonTemporaryEvents(dealerPeds[dealerId], true)
            
            -- Dodanie scenariusza
            if dealer.scenario then
                TaskStartScenarioInPlace(dealerPeds[dealerId], dealer.scenario, 0, true)
            end
            
            -- Dodanie blipa
            local blip = AddBlipForCoord(dealer.coords.x, dealer.coords.y, dealer.coords.z)
            SetBlipSprite(blip, 140)
            SetBlipColour(blip, 1)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Lang:t("info.dealer_blip"))
            EndTextCommandSetBlipName(blip)
            
            -- Dodanie targetów
            if Config.UseTarget then
                exports['qb-target']:AddTargetEntity(dealerPeds[dealerId], {
                    options = {
                        {
                            type = "client",
                            icon = "fas fa-user-secret",
                            label = Lang:t("target.talk_dealer"),
                            action = function()
                                -- Otwórz menu dealera
                                OpenDealerMenu(dealerId, dealer)
                            end
                        }
                    },
                    distance = 2.0
                })
            end
        end
    end
end

-- Otwieranie menu dealera
function OpenDealerMenu(dealerId, dealer)
    -- Sprawdzanie godziny
    local currentHour = GetClockHours()
    if currentHour < dealer.hours.from or currentHour >= dealer.hours.to then
        QBCore.Functions.Notify(Lang:t("error.dealer_unavailable"), "error")
        return
    end
    
    -- Tworzymy opcje menu na podstawie narkotyków obsługiwanych przez dealera
    local options = {}
    
    for _, drugType in ipairs(dealer.drugs) do
        local drugData = Config.Drugs[drugType]
        if drugData then
            table.insert(options, {
                title = "Sprzedaj " .. drugData.label,
                description = "Cena: $" .. drugData.sellPrice.min .. " - $" .. drugData.sellPrice.max,
                event = "kubi-drugs:client:sellDrug",
                args = {
                    drugType = drugType,
                    dealerId = dealerId
                }
            })
        end
    end
    
    -- Dodajemy opcję zamknięcia
    table.insert(options, {
        title = "Zamknij",
        description = "Zakończ rozmowę",
        event = "qb-menu:closeMenu"
    })
    
    -- Wyświetlamy menu
    exports['qb-menu']:openMenu(options)
end

-- Event wywoływany po wybraniu opcji sprzedaży narkotyku
RegisterNetEvent('kubi-drugs:client:sellDrug', function(data)
    SellDrugs(data.drugType, data.dealerId)
end)

-- Event do alertu policyjnego
RegisterNetEvent('kubi-drugs:client:policeAlert', function(coords, message)
    -- Alert dla policji
    local street1, street2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street1Name = GetStreetNameFromHashKey(street1)
    local street2Name = street2 ~= 0 and GetStreetNameFromHashKey(street2) or ''
    local streetLabel = street1Name
    if street2Name ~= '' then streetLabel = streetLabel .. ' ' .. street2Name end
    
    -- Wyświetlenie powiadomienia
    TriggerEvent('qb-phone:client:addPoliceAlert', {
        title = "Podejrzana aktywność",
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = message .. " na " .. streetLabel
    })
    
    -- Dodanie blipa na mapie
    local transG = 250
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 51)
    SetBlipColour(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipAlpha(blip, transG)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("Podejrzana aktywność")
    EndTextCommandSetBlipName(blip)
    
    -- Migający blip
    while transG ~= 0 do
        Wait(180 * 4)
        transG = transG - 1
        SetBlipAlpha(blip, transG)
        if transG == 0 then
            RemoveBlip(blip)
            return
        end
    end
end)

-- Czyszczenie blipów
local function ClearAllBlips()
    for id, blip in pairs(LocationBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    LocationBlips = {}
end

-- Event wywoływany po załadowaniu skryptu
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Tworzenie obiektów na mapie
    SetupDrugLocations()
    SetupDealers()
end)

-- Event wywoływany przy zalogowaniu gracza
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    SetupDrugLocations()
    SetupDealers()
end)

-- Event wywoływany przy wylogowaniu gracza
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    -- Resetowanie zmiennych
    isHarvesting = false
    isProcessing = false
    isPackaging = false
    securityToken = nil
    ClearAllBlips()
end)

-- Event wywoływany przy wyładowaniu zasobu
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Czyszczenie blipów
    ClearAllBlips()
end) 