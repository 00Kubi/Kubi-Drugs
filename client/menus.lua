local QBCore = exports['qb-core']:GetCoreObject()

-- Funkcja sprawdzająca inventarz gracza dla określonego narkotyku
local function CheckPlayerInventoryForDrug(drugType, stage)
    local Player = QBCore.Functions.GetPlayerData()
    local drugData = Config.Drugs[drugType]
    local items = {}
    
    if stage == "process" then
        for _, item in pairs(drugData.requiredItems.process) do
            items[item.name] = {
                label = QBCore.Shared.Items[item.name].label,
                required = item.amount,
                has = 0
            }
        end
    elseif stage == "package" then
        for _, item in pairs(drugData.requiredItems.package) do
            items[item.name] = {
                label = QBCore.Shared.Items[item.name].label,
                required = item.amount,
                has = 0
            }
        end
    end
    
    -- Sprawdzamy ile z wymaganych przedmiotów gracz posiada
    for _, item in pairs(Player.items) do
        if item and items[item.name] then
            items[item.name].has = items[item.name].has + item.amount
        end
    end
    
    return items
end

-- Funkcja sprawdzająca czy gracz ma wystarczającą ilość przedmiotów
local function HasRequiredItems(items)
    for _, item in pairs(items) do
        if item.has < item.required then
            return false
        end
    end
    return true
end

-- Funkcja tworząca menu informacyjne dla procesu zbierania/przetwarzania/pakowania
function CreateDrugProcessMenu(drugType, processType)
    local drugData = Config.Drugs[drugType]
    local menuItems = {}
    
    -- Tytuł menu
    local title = ""
    if processType == "harvest" then
        title = "Zbieranie - " .. drugData.label
    elseif processType == "process" then
        title = "Przetwarzanie - " .. drugData.label
    elseif processType == "package" then
        title = "Pakowanie - " .. drugData.label
    end
    
    -- Dodajemy informacje o procesie
    table.insert(menuItems, {
        title = title,
        description = "Informacje o procesie",
        isMenuHeader = true
    })
    
    -- Jeśli to przetwarzanie lub pakowanie, pokazujemy wymagane przedmioty
    if processType == "process" or processType == "package" then
        local items = CheckPlayerInventoryForDrug(drugType, processType)
        
        table.insert(menuItems, {
            title = "Wymagane przedmioty:",
            isMenuHeader = true
        })
        
        for name, item in pairs(items) do
            local color = item.has >= item.required and "green" or "red"
            table.insert(menuItems, {
                title = item.label,
                description = "Wymagane: " .. item.required .. " | Posiadane: " .. item.has,
                titleColor = color,
                isMenuHeader = true
            })
        end
        
        -- Przycisk do rozpoczęcia procesu
        table.insert(menuItems, {
            title = "Rozpocznij proces",
            description = "Czas trwania: " .. (processType == "process" and drugData.processTime or drugData.packageTime) .. " sekund",
            disabled = not HasRequiredItems(items),
            event = "kubi-drugs:client:start" .. string.upper(string.sub(processType, 1, 1)) .. string.sub(processType, 2),
            args = {
                drugType = drugType
            }
        })
    else
        -- Dla zbierania, pokazujemy tylko czas trwania i przycisk do rozpoczęcia
        table.insert(menuItems, {
            title = "Czas zbierania",
            description = drugData.harvestTime .. " sekund",
            isMenuHeader = true
        })
        
        table.insert(menuItems, {
            title = "Rozpocznij zbieranie",
            event = "kubi-drugs:client:startHarvest",
            args = {
                drugType = drugType
            }
        })
    end
    
    -- Przycisk do zamknięcia menu
    table.insert(menuItems, {
        title = "Zamknij",
        event = "qb-menu:closeMenu"
    })
    
    -- Wyświetlenie menu
    exports['qb-menu']:openMenu(menuItems)
end

-- Event dla rozpoczęcia zbierania
RegisterNetEvent('kubi-drugs:client:startHarvest', function(data)
    -- Funkcja z main.lua
    StartHarvesting(data.drugType)
end)

-- Event dla rozpoczęcia przetwarzania
RegisterNetEvent('kubi-drugs:client:startProcess', function(data)
    -- Funkcja z main.lua
    StartProcessing(data.drugType)
end)

-- Event dla rozpoczęcia pakowania
RegisterNetEvent('kubi-drugs:client:startPackage', function(data)
    -- Funkcja z main.lua
    StartPackaging(data.drugType)
end)

-- Funkcja tworząca menu informacyjne dla dealera
function CreateDealerInfoMenu(dealerId)
    local dealer = Config.Dealers[dealerId]
    local menuItems = {}
    
    -- Nagłówek
    table.insert(menuItems, {
        title = "Informacje o dealerze",
        isMenuHeader = true
    })
    
    -- Godziny pracy
    table.insert(menuItems, {
        title = "Godziny pracy",
        description = "Od " .. dealer.hours.from .. ":00 do " .. dealer.hours.to .. ":00",
        isMenuHeader = true
    })
    
    -- Obsługiwane narkotyki
    table.insert(menuItems, {
        title = "Obsługiwane narkotyki",
        isMenuHeader = true
    })
    
    for _, drugType in ipairs(dealer.drugs) do
        local drugData = Config.Drugs[drugType]
        table.insert(menuItems, {
            title = drugData.label,
            description = "Cena: $" .. drugData.sellPrice.min .. " - $" .. drugData.sellPrice.max,
            isMenuHeader = true
        })
    end
    
    -- Przycisk do rozpoczęcia sprzedaży
    table.insert(menuItems, {
        title = "Sprzedaj narkotyki",
        event = "kubi-drugs:client:openDealerMenu",
        args = {
            dealerId = dealerId
        }
    })
    
    -- Przycisk do zamknięcia menu
    table.insert(menuItems, {
        title = "Zamknij",
        event = "qb-menu:closeMenu"
    })
    
    -- Wyświetlenie menu
    exports['qb-menu']:openMenu(menuItems)
end

-- Event dla otwierania menu dealera
RegisterNetEvent('kubi-drugs:client:openDealerMenu', function(data)
    -- Funkcja z main.lua
    OpenDealerMenu(data.dealerId, Config.Dealers[data.dealerId])
end)

-- Event dla otwierania menu informacyjnego o dealerze
RegisterNetEvent('kubi-drugs:client:openDealerInfo', function(data)
    CreateDealerInfoMenu(data.dealerId)
end)

-- Event dla otwierania menu informacyjnego o procesie
RegisterNetEvent('kubi-drugs:client:openProcessInfo', function(data)
    CreateDrugProcessMenu(data.drugType, data.processType)
end) 