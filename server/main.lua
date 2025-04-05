local QBCore = exports['qb-core']:GetCoreObject()

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

-- Event do zbierania narkotyków
RegisterSecuredEvent('kubi-drugs:server:harvestDrug', function(source, drugType)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    -- Sprawdzanie wymaganej ilości policjantów
    if GetCopCount() < Config.MinCops then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.not_enough_police"), "error")
        return
    end
    
    -- Sprawdzanie czy gracz jest w odpowiedniej strefie
    if not IsPlayerInZone(source, drugType, "harvest") then
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
RegisterSecuredEvent('kubi-drugs:server:processDrug', function(source, drugType)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    -- Sprawdzanie wymaganej ilości policjantów
    if GetCopCount() < Config.MinCops then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.not_enough_police"), "error")
        return
    end
    
    -- Sprawdzanie czy gracz jest w odpowiedniej strefie
    if not IsPlayerInZone(source, drugType, "process") then
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
RegisterSecuredEvent('kubi-drugs:server:packageDrug', function(source, drugType)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    -- Sprawdzanie wymaganej ilości policjantów
    if GetCopCount() < Config.MinCops then
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.not_enough_police"), "error")
        return
    end
    
    -- Sprawdzanie czy gracz jest w odpowiedniej strefie
    if not IsPlayerInZone(source, drugType, "package") then
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