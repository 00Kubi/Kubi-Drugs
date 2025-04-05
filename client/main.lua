local QBCore = exports['qb-core']:GetCoreObject()

-- Zmienne lokalne
local isHarvesting = false
local isProcessing = false
local isPackaging = false
local processingDrug = nil
local processingType = nil
local processingLabName = nil
local processingLabLevel = nil
local securityToken = nil

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

-- Funkcja rozpoczynająca zbieranie narkotyków
local function StartHarvesting(drugType, coords)
    -- Sprawdź czy gracz już nie zbiera
    if isHarvesting then
        QBCore.Functions.Notify(Lang:t("error.already_harvesting"), "error")
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
            
            -- Wyślij event do serwera z tokenem bezpieczeństwa
            TriggerServerEvent('kubi-drugs:server:harvestDrug', token, drugType)
            
            -- Resetuj token po użyciu
            ResetSecurityToken()
        end, function() -- Anulowano
            ClearPedTasks(PlayerPedId())
            isHarvesting = false
            QBCore.Functions.Notify(Lang:t("error.process_canceled"), "error")
        end)
    end)
end

-- Funkcja rozpoczynająca przetwarzanie narkotyków
local function StartProcessing(drugType, coords)
    -- Sprawdź czy gracz już nie przetwarza
    if isProcessing then
        QBCore.Functions.Notify(Lang:t("error.already_processing"), "error")
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
            
            -- Wyślij event do serwera z tokenem bezpieczeństwa
            TriggerServerEvent('kubi-drugs:server:processDrug', token, drugType)
            
            -- Resetuj token po użyciu
            ResetSecurityToken()
        end, function() -- Anulowano
            ClearPedTasks(PlayerPedId())
            isProcessing = false
            QBCore.Functions.Notify(Lang:t("error.process_canceled"), "error")
        end)
    end)
end

-- Funkcja rozpoczynająca pakowanie narkotyków
local function StartPackaging(drugType, coords)
    -- Sprawdź czy gracz już nie pakuje
    if isPackaging then
        QBCore.Functions.Notify(Lang:t("error.already_packaging"), "error")
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
            
            -- Wyślij event do serwera z tokenem bezpieczeństwa
            TriggerServerEvent('kubi-drugs:server:packageDrug', token, drugType)
            
            -- Resetuj token po użyciu
            ResetSecurityToken()
        end, function() -- Anulowano
            ClearPedTasks(PlayerPedId())
            isPackaging = false
            QBCore.Functions.Notify(Lang:t("error.process_canceled"), "error")
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

-- Ustawienie punktów zbierania na mapie
local function SetupDrugLocations()
    -- Iteruj przez wszystkie narkotyki w konfiguracji
    for drugType, locations in pairs(Config.Locations) do
        -- Dodawanie blipów i targetów dla zbierania
        for _, harvestSpot in ipairs(locations.harvest or {}) do
            -- Dodaj blip na mapie
            local blip = AddBlipForCoord(harvestSpot.coords.x, harvestSpot.coords.y, harvestSpot.coords.z)
            SetBlipSprite(blip, 51)
            SetBlipColour(blip, 2)
            SetBlipScale(blip, 0.6)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Lang:t("info.harvest_blip") .. " - " .. Config.Drugs[drugType].label)
            EndTextCommandSetBlipName(blip)
            
            -- Dodaj target (opcjonalnie, jeśli włączony w konfiguracji)
            if Config.UseTarget then
                exports['qb-target']:AddCircleZone("harvest_" .. drugType .. "_" .. _,
                    harvestSpot.coords,
                    1.5,
                    {
                        name = "harvest_" .. drugType .. "_" .. _,
                        debugPoly = Config.Debug,
                    },
                    {
                        options = {
                            {
                                type = "client",
                                icon = "fas fa-hand",
                                label = Lang:t("target.harvest") .. " " .. Config.Drugs[drugType].label,
                                action = function()
                                    StartHarvesting(drugType, harvestSpot.coords)
                                end
                            },
                        },
                        distance = 2.0
                    }
                )
            end
        end
        
        -- Dodawanie blipów i targetów dla przetwarzania
        for _, processSpot in ipairs(locations.process or {}) do
            -- Dodaj blip na mapie
            local blip = AddBlipForCoord(processSpot.coords.x, processSpot.coords.y, processSpot.coords.z)
            SetBlipSprite(blip, 51)
            SetBlipColour(blip, 3)
            SetBlipScale(blip, 0.6)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Lang:t("info.process_blip") .. " - " .. Config.Drugs[drugType].label)
            EndTextCommandSetBlipName(blip)
            
            -- Dodaj target (opcjonalnie, jeśli włączony w konfiguracji)
            if Config.UseTarget then
                exports['qb-target']:AddCircleZone("process_" .. drugType .. "_" .. _,
                    processSpot.coords,
                    1.5,
                    {
                        name = "process_" .. drugType .. "_" .. _,
                        debugPoly = Config.Debug,
                    },
                    {
                        options = {
                            {
                                type = "client",
                                icon = "fas fa-hand",
                                label = Lang:t("target.process") .. " " .. Config.Drugs[drugType].label,
                                action = function()
                                    StartProcessing(drugType, processSpot.coords)
                                end
                            },
                        },
                        distance = 2.0
                    }
                )
            end
        end
        
        -- Dodawanie blipów i targetów dla pakowania
        for _, packageSpot in ipairs(locations.package or {}) do
            -- Dodaj blip na mapie
            local blip = AddBlipForCoord(packageSpot.coords.x, packageSpot.coords.y, packageSpot.coords.z)
            SetBlipSprite(blip, 51)
            SetBlipColour(blip, 4)
            SetBlipScale(blip, 0.6)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Lang:t("info.package_blip") .. " - " .. Config.Drugs[drugType].label)
            EndTextCommandSetBlipName(blip)
            
            -- Dodaj target (opcjonalnie, jeśli włączony w konfiguracji)
            if Config.UseTarget then
                exports['qb-target']:AddCircleZone("package_" .. drugType .. "_" .. _,
                    packageSpot.coords,
                    1.5,
                    {
                        name = "package_" .. drugType .. "_" .. _,
                        debugPoly = Config.Debug,
                    },
                    {
                        options = {
                            {
                                type = "client",
                                icon = "fas fa-hand",
                                label = Lang:t("target.package") .. " " .. Config.Drugs[drugType].label,
                                action = function()
                                    StartPackaging(drugType, packageSpot.coords)
                                end
                            },
                        },
                        distance = 2.0
                    }
                )
            end
        end
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
    processingDrug = nil
    processingType = nil
    processingLabName = nil
    processingLabLevel = nil
    securityToken = nil
end)

-- Funkcja inicjująca proces przetwarzania narkotyków w standardowej lokalizacji
function StartProcess(drugType, processType, locationIndex)
    if isProcessing then
        QBCore.Functions.Notify(Lang:t("error.already_processing"), "error")
        return
    end
    
    if not securityToken then
        GetSecurityToken(function(token)
            TriggerServerEvent('kubi-drugs:server:startProcess', token, drugType, processType, locationIndex)
        end)
    else
        TriggerServerEvent('kubi-drugs:server:startProcess', securityToken, drugType, processType, locationIndex)
        ResetSecurityToken()
    end
end

-- Funkcja inicjująca proces przetwarzania narkotyków w laboratorium
function StartLabProcess(drugType, labName, processType, labLevel)
    if isProcessing then
        QBCore.Functions.Notify(Lang:t("error.already_processing"), "error")
        return
    end
    
    if not securityToken then
        GetSecurityToken(function(token)
            TriggerServerEvent('kubi-drugs:server:startLabProcess', token, drugType, labName, processType, labLevel)
        end)
    else
        TriggerServerEvent('kubi-drugs:server:startLabProcess', securityToken, drugType, labName, processType, labLevel)
        ResetSecurityToken()
    end
end

-- Funkcja do sprzedaży narkotyków
function SellDrug(drugType, dealerId, quality)
    if isProcessing then
        QBCore.Functions.Notify(Lang:t("error.already_processing"), "error")
        return
    end
    
    if not securityToken then
        GetSecurityToken(function(token)
            TriggerServerEvent('kubi-drugs:server:sellDrug', token, drugType, dealerId, quality)
        end)
    else
        TriggerServerEvent('kubi-drugs:server:sellDrug', securityToken, drugType, dealerId, quality)
        ResetSecurityToken()
    end
end

-- Funkcja do zakupu materiałów/sprzętu
function BuyMaterial(item, price, dealerId)
    if isProcessing then
        QBCore.Functions.Notify(Lang:t("error.already_processing"), "error")
        return
    end
    
    if not securityToken then
        GetSecurityToken(function(token)
            TriggerServerEvent('kubi-drugs:server:buyMaterial', token, item, price, dealerId)
        end)
    else
        TriggerServerEvent('kubi-drugs:server:buyMaterial', securityToken, item, price, dealerId)
        ResetSecurityToken()
    end
end

-- Event obsługujący procesowanie narkotyków
RegisterNetEvent('kubi-drugs:client:processing', function(drugType, time, processType, labName, labLevel)
    isProcessing = true
    processingDrug = drugType
    processingType = processType
    processingLabName = labName
    processingLabLevel = labLevel
    
    -- Wybierz odpowiednią nazwę procesu w zależności od typu procesu
    local processName = ""
    if processType == "harvest" then
        processName = Lang:t("info.harvesting")
    elseif processType == "process" then
        processName = Lang:t("info.processing")
    elseif processType == "package" or processType == "premium_package" then
        processName = Lang:t("info.packaging")
    elseif processType == "concentrate" then
        processName = Lang:t("info.concentrating")
    elseif processType == "purify" then
        processName = Lang:t("info.purifying")
    elseif processType == "crystallize" then
        processName = Lang:t("info.crystallizing")
    elseif processType == "refine" then
        processName = Lang:t("info.refining")
    elseif processType == "distill" then
        processName = Lang:t("info.distilling")
    elseif processType == "dry" then
        processName = Lang:t("info.drying")
    elseif processType == "grind" then
        processName = Lang:t("info.grinding")
    elseif processType == "press" then
        processName = Lang:t("info.pressing")
    elseif processType == "color" then
        processName = Lang:t("info.coloring")
    elseif processType == "inject" then
        processName = Lang:t("info.preparing_inject")
    elseif processType == "blotter" then
        processName = Lang:t("info.preparing_blotter")
    elseif processType == "capsule" then
        processName = Lang:t("info.filling_capsules")
    end
    
    -- Pobierz dane o narkotyku
    local drugData = Config.Drugs[drugType]
    if not drugData then return end
    
    -- Wyświetl ostrzeżenie o wybuchu dla niebezpiecznych narkotyków
    if drugData.explodeChance and drugData.explodeChance > 10 then
        QBCore.Functions.Notify(Lang:t("info.explosion_warning"), "error")
    end
    
    -- Pasek postępu
    QBCore.Functions.Progressbar("drug_processing", processName, time * 1000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_ped",
        flags = 16,
    }, {}, {}, function() -- Done
        -- Zatrzymanie animacji
        StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
        
        -- Uzyskanie nowego tokenu bezpieczeństwa
        GetSecurityToken(function(token)
            -- Poinformowanie serwera o zakończeniu procesu
            TriggerServerEvent('kubi-drugs:server:finishProcess', token, processingDrug, processingType, processingLabName, processingLabLevel)
            
            -- Resetowanie zmiennych
            isProcessing = false
            processingDrug = nil
            processingType = nil
            processingLabName = nil
            processingLabLevel = nil
            ResetSecurityToken()
        end)
    end, function() -- Cancel
        -- Zatrzymanie animacji
        StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
        
        -- Resetowanie zmiennych
        isProcessing = false
        processingDrug = nil
        processingType = nil
        processingLabName = nil
        processingLabLevel = nil
        
        QBCore.Functions.Notify(Lang:t("error.process_canceled"), "error")
    end)
end)

-- Event do obsługi eksplozji w laboratorium
RegisterNetEvent('kubi-drugs:client:labExplosion', function()
    -- Efekt eksplozji
    local coords = GetEntityCoords(PlayerPedId())
    
    -- Efekt wizualny eksplozji
    AddExplosion(coords.x, coords.y, coords.z, 7, 1.0, true, false, 1.0)
    
    -- Efekt obrażeń dla gracza (50% zdrowia)
    local health = GetEntityHealth(PlayerPedId())
    local newHealth = math.max(100, health - 100) -- Minimum 100 (granica śmierci w FiveM)
    SetEntityHealth(PlayerPedId(), newHealth)
    
    -- Powiadomienie
    QBCore.Functions.Notify("Nastąpiła eksplozja w laboratorium!", "error")
end)

-- Event do tworzenia blipów na mapie dla laboratoriów i dealerów
RegisterNetEvent('kubi-drugs:client:createBlips', function()
    -- Usuwanie starych blipów
    local existingBlips = exports['qb-core']:GetBlips()
    for _, blip in ipairs(existingBlips) do
        if DoesBlipExist(blip) and GetBlipSprite(blip) == 140 then -- 140 to id ikony narkotyków
            RemoveBlip(blip)
        end
    end
    
    -- Tworzenie blipów dla laboratoriów
    if Config.ShowLabBlips then
        for _, lab in ipairs(Config.Labs) do
            local blip = AddBlipForCoord(lab.coords.x, lab.coords.y, lab.coords.z)
            SetBlipSprite(blip, 499) -- Lab icon
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.7)
            SetBlipColour(blip, 5) -- Yellow
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Lang:t("info.lab_blip"))
            EndTextCommandSetBlipName(blip)
        end
    end
    
    -- Tworzenie blipów dla dealerów
    if Config.ShowDealerBlips then
        for i, dealer in ipairs(Config.Dealers) do
            local blip = AddBlipForCoord(dealer.coords.x, dealer.coords.y, dealer.coords.z)
            SetBlipSprite(blip, 140) -- Drug dealer icon
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.7)
            SetBlipColour(blip, 2) -- Green
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Lang:t("info.dealer_blip"))
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- Event do rejestracji targetów dla laboratoriów i dealerów
RegisterNetEvent('kubi-drugs:client:registerTargets', function()
    -- Rejestracja targetów dla laboratoriów
    for i, lab in ipairs(Config.Labs) do
        exports['qb-target']:AddBoxZone("lab_" .. i, vector3(lab.coords.x, lab.coords.y, lab.coords.z), 2.0, 2.0, {
            name = "lab_" .. i,
            heading = lab.coords.w,
            debugPoly = false,
            minZ = lab.coords.z - 1.0,
            maxZ = lab.coords.z + 1.0,
        }, {
            options = {
                {
                    type = "client",
                    event = "kubi-drugs:client:openLabMenu",
                    icon = "fas fa-flask",
                    label = Lang:t("target.access_lab"),
                    lab = lab,
                    labName = lab.name
                }
            },
            distance = 2.5
        })
    end
    
    -- Rejestracja targetów dla dealerów
    for i, dealer in ipairs(Config.Dealers) do
        exports['qb-target']:AddBoxZone("dealer_" .. i, vector3(dealer.coords.x, dealer.coords.y, dealer.coords.z), 1.0, 1.0, {
            name = "dealer_" .. i,
            heading = dealer.coords.w,
            debugPoly = false,
            minZ = dealer.coords.z - 1.0,
            maxZ = dealer.coords.z + 1.0,
        }, {
            options = {
                {
                    type = "client",
                    event = "kubi-drugs:client:openDealerMenu",
                    icon = "fas fa-user-secret",
                    label = Lang:t("target.talk_dealer"),
                    dealer = dealer,
                    dealerId = i
                }
            },
            distance = 2.0
        })
    end
end)

-- Event do tworzenia pedów dealerów
RegisterNetEvent('kubi-drugs:client:spawnDealers', function()
    -- Tworzenie pedów dla dealerów
    for i, dealer in ipairs(Config.Dealers) do
        RequestModel(dealer.model)
        while not HasModelLoaded(dealer.model) do
            Wait(0)
        end
        
        local ped = CreatePed(4, dealer.model, dealer.coords.x, dealer.coords.y, dealer.coords.z - 1.0, dealer.coords.w, false, true)
        SetEntityHeading(ped, dealer.coords.w)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        
        -- Dodanie scenariusza dla peda
        if dealer.scenario then
            TaskStartScenarioInPlace(ped, dealer.scenario, 0, true)
        end
    end
end)

-- Eventy dla obsługi menu
RegisterNetEvent('kubi-drugs:client:startProcess', function(data)
    StartProcess(data.drugType, data.processType, data.locationIndex)
end)

RegisterNetEvent('kubi-drugs:client:startLabProcess', function(data)
    StartLabProcess(data.drugType, data.labName, data.processType, data.labLevel)
end)

RegisterNetEvent('kubi-drugs:client:sellDrug', function(data)
    SellDrug(data.drugType, data.dealerId, data.quality)
end)

RegisterNetEvent('kubi-drugs:client:buyMaterial', function(data)
    BuyMaterial(data.item, data.price, data.dealerId)
end) 