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

-- Callback do generowania tokenów bezpieczeństwa
QBCore.Functions.CreateCallback('kubi-drugs:server:getSecurityToken', function(source, callback)
    local token = GenerateSecurityToken(source)
    callback(token)
end)

-- Event inicjujący proces przetwarzania narkotyków w standardowej lokalizacji
RegisterSecuredEvent('kubi-drugs:server:startProcess', function(source, drugType, processType, locationIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Sprawdź czy jest wystarczająca liczba policjantów
    local currentCops = QBCore.Functions.GetDutyCount('police')
    if currentCops < Config.MinCops then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.not_enough_police"), "error")
        return
    end
    
    -- Pobierz dane o narkotyku
    local drugData = Config.Drugs[drugType]
    if not drugData then return end
    
    -- Sprawdź czy proces wymaga laboratorium
    if processType ~= "harvest" and drugData.labRequired and processType ~= "package" then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.lab_required"), "error")
        return
    end
    
    -- Sprawdź czy gracz ma wymagane przedmioty
    if processType ~= "harvest" then
        if not drugData.requiredItems[processType] then
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.process_failed"), "error")
            return
        end
        
        local canProcess = true
        local removeItems = {}
        
        for _, itemData in ipairs(drugData.requiredItems[processType]) do
            local item = Player.Functions.GetItemByName(itemData.name)
            if not item or item.amount < itemData.amount then
                canProcess = false
                break
            end
            
            if not itemData.return then
                table.insert(removeItems, {
                    name = itemData.name,
                    amount = itemData.amount
                })
            end
        end
        
        if not canProcess then
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.no_required_items"), "error")
            return
        end
        
        -- Usuń wymagane przedmioty (te które nie są zwracane)
        for _, item in ipairs(removeItems) do
            Player.Functions.RemoveItem(item.name, item.amount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "remove", item.amount)
        end
    end
    
    -- Określenie czasu trwania procesu
    local processTime = 0
    if processType == "harvest" then
        processTime = drugData.harvestTime
    elseif processType == "process" or processType == "concentrate" or processType == "purify" or processType == "crystallize" or processType == "refine" or processType == "distill" or processType == "dry" or processType == "grind" or processType == "press" or processType == "color" or processType == "crack" or processType == "blue_meth" then
        processTime = drugData.processTime
    elseif processType == "package" or processType == "premium_package" or processType == "inject" or processType == "blotter" or processType == "capsule" then
        processTime = drugData.packageTime
    end
    
    -- Wyślij event do klienta aby rozpocząć proces
    TriggerClientEvent('kubi-drugs:client:processing', src, drugType, processTime, processType, nil, nil)
end)

-- Event inicjujący proces przetwarzania narkotyków w laboratorium
RegisterSecuredEvent('kubi-drugs:server:startLabProcess', function(source, drugType, labName, processType, labLevel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Sprawdź czy jest wystarczająca liczba policjantów
    local currentCops = QBCore.Functions.GetDutyCount('police')
    if currentCops < Config.MinCops then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.not_enough_police"), "error")
        return
    end
    
    -- Pobierz dane o narkotyku
    local drugData = Config.Drugs[drugType]
    if not drugData then return end
    
    -- Sprawdź czy gracz ma dostęp do laboratorium
    if not HasLabAccess(src, labName) then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.lab_access_denied"), "error")
        return
    end
    
    -- Znajdź laboratorium
    local lab = nil
    for _, v in ipairs(Config.Labs) do
        if v.name == labName then
            lab = v
            break
        end
    end
    
    if not lab then return end
    
    -- Sprawdź czy narkotyk może być produkowany w tym laboratorium
    local canProduceDrug = false
    for _, labDrug in ipairs(lab.drugs) do
        if labDrug == drugType then
            canProduceDrug = true
            break
        end
    end
    
    if not canProduceDrug then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.lab_unavailable"), "error")
        return
    end
    
    -- Sprawdź czy gracz ma wymagany sprzęt laboratoryjny
    if not HasRequiredLabEquipment(src, lab.equipmentRequired) then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.missing_equipment"), "error")
        return
    end
    
    -- Sprawdź czy gracz ma wymagane przedmioty
    if not drugData.requiredItems[processType] then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.process_failed"), "error")
        return
    end
    
    local canProcess = true
    local removeItems = {}
    
    for _, itemData in ipairs(drugData.requiredItems[processType]) do
        local item = Player.Functions.GetItemByName(itemData.name)
        if not item or item.amount < itemData.amount then
            canProcess = false
            break
        end
        
        if not itemData.return then
            table.insert(removeItems, {
                name = itemData.name,
                amount = itemData.amount
            })
        end
    end
    
    if not canProcess then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.no_required_items"), "error")
        return
    end
    
    -- Usuń wymagane przedmioty (te które nie są zwracane)
    for _, item in ipairs(removeItems) do
        Player.Functions.RemoveItem(item.name, item.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "remove", item.amount)
    end
    
    -- Określenie czasu trwania procesu
    local processTime = 0
    if processType == "process" or processType == "concentrate" or processType == "purify" or processType == "crystallize" or processType == "refine" or processType == "distill" or processType == "dry" or processType == "grind" or processType == "press" or processType == "color" or processType == "crack" or processType == "blue_meth" then
        processTime = drugData.processTime
    elseif processType == "package" or processType == "premium_package" or processType == "inject" or processType == "blotter" or processType == "capsule" then
        processTime = drugData.packageTime
    end
    
    -- Skrócenie czasu procesu w laboratorium (20% szybciej)
    processTime = math.floor(processTime * 0.8)
    
    -- Wyślij event do klienta aby rozpocząć proces
    TriggerClientEvent('kubi-drugs:client:processing', src, drugType, processTime, processType, labName, labLevel)
end)

-- Event kończący proces przetwarzania
RegisterSecuredEvent('kubi-drugs:server:finishProcess', function(source, drugType, processType, labName, labLevel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Pobierz dane o narkotyku
    local drugData = Config.Drugs[drugType]
    if not drugData then return end
    
    -- Sprawdź czy proces zakończył się sukcesem
    local success = CheckProcessSuccess(src, drugType, labLevel)
    
    -- Jeśli proces się nie powiódł
    if not success then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.process_failed"), "error")
        
        -- Sprawdź czy nastąpi eksplozja/pożar
        if processType ~= "harvest" and processType ~= "package" and CheckExplosion(src, drugType) then
            TriggerClientEvent('kubi-drugs:client:labExplosion', src)
        end
        
        return
    end
    
    -- Generowanie jakości narkotyku (tylko dla procesów w laboratorium)
    local drugQuality = nil
    if labName and labLevel and drugData.quality then
        drugQuality = GenerateDrugQuality(src, drugType, labLevel)
    end
    
    -- Przyznawanie nagród
    if drugData.rewardItems[processType] then
        for _, rewardItem in ipairs(drugData.rewardItems[processType]) do
            local amount = rewardItem.amount
            
            -- Jeśli ilość jest zakresem, losuj wartość
            if type(amount) == "table" and amount.min and amount.max then
                amount = math.random(amount.min, amount.max)
            end
            
            -- Dodaj przedmiot
            if Player.Functions.AddItem(rewardItem.name, amount) then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[rewardItem.name], "add", amount)
                
                -- Wyświetl odpowiednią wiadomość
                if processType == "harvest" then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.harvested", {amount = amount, item = QBCore.Shared.Items[rewardItem.name].label}), "success")
                elseif processType == "process" then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.processed", {amount = amount, item = QBCore.Shared.Items[rewardItem.name].label}), "success")
                elseif processType == "package" or processType == "premium_package" then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.packaged", {amount = amount, item = QBCore.Shared.Items[rewardItem.name].label}), "success")
                elseif processType == "concentrate" then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.concentrate_created", {amount = amount, item = QBCore.Shared.Items[rewardItem.name].label}), "success")
                elseif processType == "purify" then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.purified", {amount = amount, item = QBCore.Shared.Items[rewardItem.name].label}), "success")
                elseif processType == "crystallize" then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.crystallized", {amount = amount, item = QBCore.Shared.Items[rewardItem.name].label}), "success")
                elseif processType == "refine" then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.refined", {amount = amount, item = QBCore.Shared.Items[rewardItem.name].label}), "success")
                elseif processType == "distill" then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.distilled", {amount = amount, item = QBCore.Shared.Items[rewardItem.name].label}), "success")
                elseif processType == "dry" then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.dried", {amount = amount, item = QBCore.Shared.Items[rewardItem.name].label}), "success")
                elseif processType == "grind" then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.ground", {amount = amount, item = QBCore.Shared.Items[rewardItem.name].label}), "success")
                elseif processType == "capsule" then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.capsules_filled", {amount = amount, item = QBCore.Shared.Items[rewardItem.name].label}), "success")
                elseif processType == "blotter" then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.blotter_infused", {amount = amount, item = QBCore.Shared.Items[rewardItem.name].label}), "success")
                elseif processType == "press" then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.pill_pressed", {amount = amount, item = QBCore.Shared.Items[rewardItem.name].label}), "success")
                elseif processType == "color" then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.colored", {amount = amount, item = QBCore.Shared.Items[rewardItem.name].label}), "success")
                end
            else
                TriggerClientEvent('QBCore:Notify', src, Lang:t("error.no_space_inventory"), "error")
            end
        end
    end
    
    -- Jeśli proces odbywał się w laboratorium i jakość była generowana, poinformuj gracza
    if drugQuality then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("success.quality_improved", {quality = drugQuality.label}), "success")
    end
end)

-- Event sprzedaży narkotyków
RegisterSecuredEvent('kubi-drugs:server:sellDrug', function(source, drugType, dealerId, quality)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Sprawdź czy jest wystarczająca liczba policjantów
    local currentCops = QBCore.Functions.GetDutyCount('police')
    if currentCops < Config.MinCops then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.not_enough_police"), "error")
        return
    end
    
    -- Pobierz dane o narkotyku
    local drugData = Config.Drugs[drugType]
    if not drugData then return end
    
    -- Pobierz dane o dealerze
    local dealer = Config.Dealers[dealerId]
    if not dealer then return end
    
    -- Sprawdź czy dealer obsługuje ten typ narkotyku
    local canSellDrug = false
    for _, dealerDrug in ipairs(dealer.drugs) do
        if dealerDrug == drugType then
            canSellDrug = true
            break
        end
    end
    
    if not canSellDrug then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.dealer_unavailable"), "error")
        return
    end
    
    -- Sprawdź czy dealer sprawdza jakość (jeśli sprzedajemy premium)
    if quality == "premium" and not dealer.qualityCheck then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.quality_too_low"), "error")
        return
    end
    
    -- Określ nazwę przedmiotu do sprzedaży
    local itemName = ""
    if quality == "premium" then
        if drugType == "weed" then
            itemName = "weed_premium"
        elseif drugType == "cocaine" then
            itemName = "cocaine_premium"
        elseif drugType == "meth" then
            itemName = "meth_premium"
        elseif drugType == "heroin" then
            itemName = "heroin_premium"
        elseif drugType == "ecstasy" then
            itemName = "ecstasy_premium"
        else
            itemName = drugType .. "_packaged" -- Domyślnie
        end
    else
        itemName = drugType .. "_packaged"
    end
    
    -- Sprawdź czy gracz ma narkotyk w ekwipunku
    local drugItem = Player.Functions.GetItemByName(itemName)
    if not drugItem then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.no_drugs_to_sell"), "error")
        return
    end
    
    -- Określ ilość narkotyku do sprzedaży (maksymalnie 5 na raz)
    local amount = math.min(drugItem.amount, 5)
    
    -- Oblicz cenę
    local basePrice = math.random(drugData.sellPrice.min, drugData.sellPrice.max)
    local finalPrice = basePrice
    
    -- Zastosuj modyfikatory ceny
    if quality == "premium" then
        finalPrice = finalPrice * 2 -- Podwójna cena za premium
    end
    
    -- Zastosuj bonus dealera
    if dealer.priceBoost and dealer.priceBoost > 0 then
        finalPrice = finalPrice * (1 + (dealer.priceBoost / 100))
    end
    
    -- Zaokrąglij cenę
    finalPrice = math.floor(finalPrice)
    
    -- Całkowita cena za wszystkie narkotyki
    local totalPrice = finalPrice * amount
    
    -- Usuń narkotyk z ekwipunku
    Player.Functions.RemoveItem(itemName, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "remove", amount)
    
    -- Dodaj pieniądze
    Player.Functions.AddMoney("cash", totalPrice)
    
    -- Powiadom gracza
    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.sold_drugs", {amount = amount, item = QBCore.Shared.Items[itemName].label, money = totalPrice}), "success")
    
    -- Szansa na wezwanie policji
    if math.random(1, 100) <= Config.PoliceCallChance then
        -- Logika wezwania policji (do zaimplementowania)
        local ped = GetPlayerPed(src)
        local coords = GetEntityCoords(ped)
        
        -- Powiadom policję
        local players = QBCore.Functions.GetQBPlayers()
        for _, v in pairs(players) do
            if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
                TriggerClientEvent('police:client:DrugSaleAlert', v.PlayerData.source, coords)
            end
        end
    end
end)

-- Event kupna materiałów/sprzętu
RegisterSecuredEvent('kubi-drugs:server:buyMaterial', function(source, item, price, dealerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Sprawdź czy gracz ma wystarczająco pieniędzy
    if Player.PlayerData.money.cash < price then
        TriggerClientEvent('QBCore:Notify', src, "Nie masz wystarczająco pieniędzy", "error")
        return
    end
    
    -- Sprawdź czy przedmiot istnieje w konfiguracji
    local itemExists = false
    if Config.Chemicals[item] or Config.LabEquipment[item] or Config.PackagingMaterials[item] then
        itemExists = true
    end
    
    if not itemExists then
        TriggerClientEvent('QBCore:Notify', src, "Przedmiot nie istnieje", "error")
        return
    end
    
    -- Pobierz opłatę
    Player.Functions.RemoveMoney('cash', price)
    
    -- Dodaj przedmiot (różna ilość w zależności od przedmiotu)
    local amount = 1
    if item == "plastic_bag" or item == "pill_casing" or item == "blotter_paper" then
        amount = 10 -- Więcej dla małych materiałów
    elseif item == "basic_chemicals" or item == "solvent" or item == "acid" then
        amount = 3 -- Więcej dla podstawowych chemikaliów
    end
    
    -- Dodaj przedmiot
    Player.Functions.AddItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add", amount)
    
    -- Powiadom gracza
    TriggerClientEvent('QBCore:Notify', src, "Kupiłeś " .. amount .. "x " .. QBCore.Shared.Items[item].label, "success")
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