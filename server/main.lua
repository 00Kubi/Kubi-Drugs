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

-- Tabela przechowująca informacje o laboratoriach graczy
local PlayerLabs = {}

-- Funkcja do kupowania laboratorium
function BuyLab(source, labName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    -- Znajdź laboratorium w konfiguracji
    local lab = nil
    for _, v in ipairs(Config.Labs) do
        if v.name == labName then
            lab = v
            break
        end
    end
    
    if not lab then return false end
    
    -- Sprawdź czy gracz ma wystarczająco pieniędzy
    if Player.PlayerData.money.bank < lab.price then
        TriggerClientEvent('QBCore:Notify', source, "Nie masz wystarczająco pieniędzy", "error")
        return false
    end
    
    -- Sprawdź czy gracz już nie ma tego laboratorium
    if PlayerLabs[source] and PlayerLabs[source][labName] then
        TriggerClientEvent('QBCore:Notify', source, "Już posiadasz to laboratorium", "error")
        return false
    end
    
    -- Pobierz opłatę
    Player.Functions.RemoveMoney('bank', lab.price)
    
    -- Dodaj laboratorium do gracza
    if not PlayerLabs[source] then
        PlayerLabs[source] = {}
    end
    
    PlayerLabs[source][labName] = {
        name = labName,
        upgrades = {
            equipment = 1,
            security = 1,
            staff = 1
        },
        production = {
            active = false,
            currentDrug = nil,
            startTime = nil,
            endTime = nil
        }
    }
    
    -- Zapisz w bazie danych
    local citizenid = Player.PlayerData.citizenid
    exports.oxmysql:execute('INSERT INTO player_labs (citizenid, lab_name, upgrades) VALUES (?, ?, ?)',
        {citizenid, labName, json.encode(PlayerLabs[source][labName].upgrades)})
    
    TriggerClientEvent('QBCore:Notify', source, "Kupiłeś laboratorium: " .. lab.label, "success")
    return true
end

-- Funkcja do ulepszania laboratorium
function UpgradeLab(source, labName, upgradeType)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    -- Sprawdź czy gracz ma laboratorium
    if not PlayerLabs[source] or not PlayerLabs[source][labName] then
        TriggerClientEvent('QBCore:Notify', source, "Nie posiadasz tego laboratorium", "error")
        return false
    end
    
    -- Znajdź laboratorium w konfiguracji
    local lab = nil
    for _, v in ipairs(Config.Labs) do
        if v.name == labName then
            lab = v
            break
        end
    end
    
    if not lab then return false end
    
    -- Znajdź ulepszenie
    local upgrade = nil
    for _, v in ipairs(lab.upgrades) do
        if v.name == upgradeType then
            upgrade = v
            break
        end
    end
    
    if not upgrade then return false end
    
    -- Sprawdź aktualny poziom
    local currentLevel = PlayerLabs[source][labName].upgrades[upgradeType]
    if currentLevel >= #upgrade.levels then
        TriggerClientEvent('QBCore:Notify', source, "Osiągnąłeś maksymalny poziom tego ulepszenia", "error")
        return false
    end
    
    -- Sprawdź koszt następnego poziomu
    local nextLevel = upgrade.levels[currentLevel + 1]
    if Player.PlayerData.money.bank < nextLevel.price then
        TriggerClientEvent('QBCore:Notify', source, "Nie masz wystarczająco pieniędzy", "error")
        return false
    end
    
    -- Pobierz opłatę
    Player.Functions.RemoveMoney('bank', nextLevel.price)
    
    -- Zaktualizuj poziom ulepszenia
    PlayerLabs[source][labName].upgrades[upgradeType] = currentLevel + 1
    
    -- Zapisz w bazie danych
    local citizenid = Player.PlayerData.citizenid
    exports.oxmysql:execute('UPDATE player_labs SET upgrades = ? WHERE citizenid = ? AND lab_name = ?',
        {json.encode(PlayerLabs[source][labName].upgrades), citizenid, labName})
    
    TriggerClientEvent('QBCore:Notify', source, "Ulepszyłeś " .. upgrade.label .. " do poziomu " .. (currentLevel + 1), "success")
    return true
end

-- Funkcja do rozpoczynania produkcji
function StartProduction(source, labName, drugType)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    -- Sprawdź czy gracz ma laboratorium
    if not PlayerLabs[source] or not PlayerLabs[source][labName] then
        TriggerClientEvent('QBCore:Notify', source, "Nie posiadasz tego laboratorium", "error")
        return false
    end
    
    -- Sprawdź czy laboratorium nie jest już w produkcji
    if PlayerLabs[source][labName].production.active then
        TriggerClientEvent('QBCore:Notify', source, "Laboratorium jest już w produkcji", "error")
        return false
    end
    
    -- Znajdź laboratorium w konfiguracji
    local lab = nil
    for _, v in ipairs(Config.Labs) do
        if v.name == labName then
            lab = v
            break
        end
    end
    
    if not lab then return false end
    
    -- Sprawdź czy narkotyk może być produkowany w tym laboratorium
    local canProduceDrug = false
    for _, labDrug in ipairs(lab.drugs) do
        if labDrug == drugType then
            canProduceDrug = true
            break
        end
    end
    
    if not canProduceDrug then
        TriggerClientEvent('QBCore:Notify', source, "Ten narkotyk nie może być produkowany w tym laboratorium", "error")
        return false
    end
    
    -- Sprawdź czy gracz ma wymagane przedmioty
    local drugData = Config.Drugs[drugType]
    if not drugData then return false end
    
    local canProcess = true
    local removeItems = {}
    
    for _, itemData in ipairs(drugData.requiredItems.process) do
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
        TriggerClientEvent('QBCore:Notify', source, "Nie masz wymaganych przedmiotów", "error")
        return false
    end
    
    -- Usuń wymagane przedmioty
    for _, item in ipairs(removeItems) do
        Player.Functions.RemoveItem(item.name, item.amount)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item.name], "remove", item.amount)
    end
    
    -- Oblicz czas produkcji
    local processTime = drugData.processTime
    local equipmentLevel = PlayerLabs[source][labName].upgrades.equipment
    local staffLevel = PlayerLabs[source][labName].upgrades.staff
    
    -- Zastosuj bonusy z ulepszeń
    local equipmentBonus = lab.upgrades[1].levels[equipmentLevel].benefits.processSpeed
    local staffBonus = lab.upgrades[3].levels[staffLevel].benefits.productionSpeed
    
    processTime = math.floor(processTime / (equipmentBonus * staffBonus))
    
    -- Rozpocznij produkcję
    PlayerLabs[source][labName].production = {
        active = true,
        currentDrug = drugType,
        startTime = os.time(),
        endTime = os.time() + processTime
    }
    
    -- Zapisz w bazie danych
    local citizenid = Player.PlayerData.citizenid
    exports.oxmysql:execute('UPDATE player_labs SET production = ? WHERE citizenid = ? AND lab_name = ?',
        {json.encode(PlayerLabs[source][labName].production), citizenid, labName})
    
    -- Uruchom timer produkcji
    SetTimeout(processTime * 1000, function()
        if PlayerLabs[source] and PlayerLabs[source][labName] and PlayerLabs[source][labName].production.active then
            FinishProduction(source, labName)
        end
    end)
    
    TriggerClientEvent('QBCore:Notify', source, "Rozpoczęto produkcję " .. drugData.label, "success")
    return true
end

-- Funkcja do kończenia produkcji
function FinishProduction(source, labName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    -- Sprawdź czy gracz ma laboratorium
    if not PlayerLabs[source] or not PlayerLabs[source][labName] then
        return false
    end
    
    local production = PlayerLabs[source][labName].production
    if not production.active then return false end
    
    -- Znajdź laboratorium w konfiguracji
    local lab = nil
    for _, v in ipairs(Config.Labs) do
        if v.name == labName then
            lab = v
            break
        end
    end
    
    if not lab then return false end
    
    -- Pobierz dane o narkotyku
    local drugData = Config.Drugs[production.currentDrug]
    if not drugData then return false end
    
    -- Sprawdź czy produkcja się powiodła
    local success = CheckProcessSuccess(source, production.currentDrug, lab.upgrades[1].levels[PlayerLabs[source][labName].upgrades.equipment].benefits.failChanceReduction)
    
    if not success then
        -- Sprawdź czy nastąpi eksplozja
        if CheckExplosion(source, production.currentDrug) then
            TriggerClientEvent('kubi-drugs:client:labExplosion', source)
        end
        
        PlayerLabs[source][labName].production = {
            active = false,
            currentDrug = nil,
            startTime = nil,
            endTime = nil
        }
        
        -- Zapisz w bazie danych
        local citizenid = Player.PlayerData.citizenid
        exports.oxmysql:execute('UPDATE player_labs SET production = ? WHERE citizenid = ? AND lab_name = ?',
            {json.encode(PlayerLabs[source][labName].production), citizenid, labName})
        
        return false
    end
    
    -- Generuj jakość narkotyku
    local drugQuality = GenerateDrugQuality(source, production.currentDrug, PlayerLabs[source][labName].upgrades.equipment)
    
    -- Przyznaj nagrody
    if drugData.rewardItems.process then
        for _, rewardItem in ipairs(drugData.rewardItems.process) do
            local amount = rewardItem.amount
            
            -- Jeśli ilość jest zakresem, losuj wartość
            if type(amount) == "table" and amount.min and amount.max then
                amount = math.random(amount.min, amount.max)
            end
            
            -- Zastosuj bonusy z ulepszeń
            local staffBonus = lab.upgrades[3].levels[PlayerLabs[source][labName].upgrades.staff].benefits.staffEfficiency
            amount = math.floor(amount * staffBonus)
            
            -- Dodaj przedmiot
            if Player.Functions.AddItem(rewardItem.name, amount) then
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[rewardItem.name], "add", amount)
            end
        end
    end
    
    -- Zresetuj produkcję
    PlayerLabs[source][labName].production = {
        active = false,
        currentDrug = nil,
        startTime = nil,
        endTime = nil
    }
    
    -- Zapisz w bazie danych
    local citizenid = Player.PlayerData.citizenid
    exports.oxmysql:execute('UPDATE player_labs SET production = ? WHERE citizenid = ? AND lab_name = ?',
        {json.encode(PlayerLabs[source][labName].production), citizenid, labName})
    
    -- Powiadom gracza
    TriggerClientEvent('QBCore:Notify', source, "Produkcja zakończona. Jakość: " .. drugQuality.label, "success")
    return true
end

-- Funkcja do wczytywania laboratoriów gracza
function LoadPlayerLabs(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    
    exports.oxmysql:execute('SELECT * FROM player_labs WHERE citizenid = ?', {citizenid}, function(result)
        if result and #result > 0 then
            PlayerLabs[source] = {}
            
            for _, v in ipairs(result) do
                PlayerLabs[source][v.lab_name] = {
                    name = v.lab_name,
                    upgrades = json.decode(v.upgrades),
                    production = json.decode(v.production)
                }
            end
        end
    end)
end

-- Event wywoływany po zalogowaniu gracza
RegisterNetEvent('QBCore:Server:PlayerLoaded', function()
    local src = source
    LoadPlayerLabs(src)
end)

-- Event wywoływany po wylogowaniu gracza
RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
    local src = source
    PlayerLabs[src] = nil
end)

-- Event do kupowania laboratorium
RegisterNetEvent('kubi-drugs:server:buyLab', function(labName)
    local src = source
    BuyLab(src, labName)
end)

-- Event do ulepszania laboratorium
RegisterNetEvent('kubi-drugs:server:upgradeLab', function(labName, upgradeType)
    local src = source
    UpgradeLab(src, labName, upgradeType)
end)

-- Event do rozpoczynania produkcji
RegisterNetEvent('kubi-drugs:server:startProduction', function(labName, drugType)
    local src = source
    StartProduction(src, labName, drugType)
end)

-- Tworzenie tabeli w bazie danych przy uruchomieniu skryptu
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Tworzenie tabeli dla laboratoriów
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS player_labs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50) NOT NULL,
            lab_name VARCHAR(50) NOT NULL,
            upgrades LONGTEXT NOT NULL,
            production LONGTEXT NOT NULL,
            UNIQUE(citizenid, lab_name)
        )
    ]])
end)

-- Funkcja do obsługi kradzieży przez dealera
function HandleDealerSteal(source, dealerName, drugType, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    -- Znajdź dealera w konfiguracji
    local dealer = nil
    for _, v in ipairs(Config.Dealers) do
        if v.name == dealerName then
            dealer = v
            break
        end
    end
    
    if not dealer then return false end
    
    -- Sprawdź czy dealer może ukraść
    if math.random() > dealer.stealChance then
        return false
    end
    
    -- Oblicz ile sztuk zostanie ukradzionych
    local stolenAmount = math.random(dealer.stealAmount.min, dealer.stealAmount.max)
    if stolenAmount > amount then
        stolenAmount = amount
    end
    
    -- Usuń przedmioty z ekwipunku gracza
    Player.Functions.RemoveItem(drugType, stolenAmount)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[drugType], "remove", stolenAmount)
    
    -- Powiadom gracza
    TriggerClientEvent('QBCore:Notify', source, "Dealer ukradł Ci " .. stolenAmount .. " sztuk " .. QBCore.Shared.Items[drugType].label, "error")
    
    -- Uruchom ucieczkę dealera
    TriggerClientEvent('kubi-drugs:client:dealerRun', source, dealerName, dealer.runSpeed, dealer.surrenderDistance)
    
    return true
end

-- Funkcja do przeszukiwania dealera
function SearchDealer(source, dealerName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    -- Znajdź dealera w konfiguracji
    local dealer = nil
    for _, v in ipairs(Config.Dealers) do
        if v.name == dealerName then
            dealer = v
            break
        end
    end
    
    if not dealer then return false end
    
    -- Losuj przedmioty które dealer ma przy sobie
    local foundItems = {}
    for _, item in ipairs(dealer.searchItems) do
        if math.random() < 0.5 then -- 50% szansa na znalezienie każdego przedmiotu
            local amount = math.random(1, 3)
            table.insert(foundItems, {
                name = item,
                amount = amount
            })
        end
    end
    
    -- Dodaj znalezione przedmioty do ekwipunku gracza
    for _, item in ipairs(foundItems) do
        if Player.Functions.AddItem(item.name, item.amount) then
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item.name], "add", item.amount)
        end
    end
    
    -- Powiadom gracza
    if #foundItems > 0 then
        TriggerClientEvent('QBCore:Notify', source, "Znalazłeś przedmioty przy dealerze", "success")
    else
        TriggerClientEvent('QBCore:Notify', source, "Nie znalazłeś nic wartościowego", "error")
    end
    
    return true
end

-- Event do obsługi kradzieży przez dealera
RegisterNetEvent('kubi-drugs:server:dealerSteal', function(dealerName, drugType, amount)
    local src = source
    HandleDealerSteal(src, dealerName, drugType, amount)
end)

-- Event do przeszukiwania dealera
RegisterNetEvent('kubi-drugs:server:searchDealer', function(dealerName)
    local src = source
    SearchDealer(src, dealerName)
end)

-- System reputacji
local PlayerReputation = {}

-- Funkcja do aktualizacji reputacji gracza u dealera
function UpdatePlayerReputation(source, dealerName, points)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    if not PlayerReputation[source] then
        PlayerReputation[source] = {}
    end
    
    if not PlayerReputation[source][dealerName] then
        PlayerReputation[source][dealerName] = 0
    end
    
    PlayerReputation[source][dealerName] = PlayerReputation[source][dealerName] + points
    
    -- Zapisz reputację w bazie danych
    MySQL.Async.execute('INSERT INTO player_reputation (citizenid, dealer_name, points) VALUES (@citizenid, @dealerName, @points) ON DUPLICATE KEY UPDATE points = @points', {
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@dealerName'] = dealerName,
        ['@points'] = PlayerReputation[source][dealerName]
    })
end

-- Funkcja do pobierania poziomu reputacji
function GetReputationLevel(points)
    for i = #Config.Reputation.levels, 1, -1 do
        if points >= Config.Reputation.levels[i].minPoints then
            return Config.Reputation.levels[i]
        end
    end
    return Config.Reputation.levels[1]
end

-- System transportu
local ActiveTransports = {}

-- Funkcja do rozpoczynania transportu
function StartTransport(source, transportType, transportName, items)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local transportConfig
    if transportType == 'courier' then
        transportConfig = Config.Transport.couriers[transportName]
    elseif transportType == 'convoy' then
        transportConfig = Config.Transport.convoys[transportName]
    end
    
    if not transportConfig then return false end
    
    -- Sprawdź czy gracz ma wystarczająco pieniędzy
    if not Player.Functions.RemoveMoney('cash', transportConfig.price) then
        return false
    end
    
    -- Utwórz nowy transport
    local transportId = #ActiveTransports + 1
    ActiveTransports[transportId] = {
        source = source,
        type = transportType,
        config = transportConfig,
        items = items,
        startTime = os.time(),
        status = 'in_progress'
    }
    
    -- Rozpocznij proces transportu
    Citizen.CreateThread(function()
        local transportTime = math.random(300, 600) -- 5-10 minut
        Citizen.Wait(transportTime * 1000)
        
        if ActiveTransports[transportId] then
            -- Sprawdź czy transport się powiódł
            if math.random() <= transportConfig.reliability then
                -- Transport udany
                GiveTransportItems(source, items)
                TriggerClientEvent('QBCore:Notify', source, 'Transport zakończony pomyślnie!', 'success')
            else
                -- Transport nieudany
                TriggerClientEvent('QBCore:Notify', source, 'Transport został przechwycony!', 'error')
            end
            
            ActiveTransports[transportId] = nil
        end
    end)
    
    return true
end

-- System bezpieczeństwa
local LabSecurity = {}

-- Funkcja do instalowania systemu bezpieczeństwa
function InstallSecurity(source, labId, securityType, securityName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local securityConfig
    if securityType == 'alarm' then
        securityConfig = Config.Security.alarms[securityName]
    elseif securityType == 'camera' then
        securityConfig = Config.Security.cameras[securityName]
    elseif securityType == 'trap' then
        securityConfig = Config.Security.traps[securityName]
    end
    
    if not securityConfig then return false end
    
    -- Sprawdź czy gracz ma wystarczająco pieniędzy
    if not Player.Functions.RemoveMoney('cash', securityConfig.price) then
        return false
    end
    
    -- Zainstaluj system bezpieczeństwa
    if not LabSecurity[labId] then
        LabSecurity[labId] = {}
    end
    
    LabSecurity[labId][securityType] = LabSecurity[labId][securityType] or {}
    LabSecurity[labId][securityType][securityName] = {
        config = securityConfig,
        installed = true,
        lastUsed = 0
    }
    
    return true
end

-- Funkcja do sprawdzania bezpieczeństwa laboratorium
function CheckLabSecurity(labId, intruderSource)
    if not LabSecurity[labId] then return false end
    
    local securityTriggered = false
    
    -- Sprawdź alarmy
    if LabSecurity[labId].alarm then
        for alarmName, alarm in pairs(LabSecurity[labId].alarm) do
            if alarm.installed and math.random() <= alarm.config.policeAlertChance then
                TriggerClientEvent('kubi-drugs:client:policeAlert', -1, labId)
                securityTriggered = true
            end
        end
    end
    
    -- Sprawdź pułapki
    if LabSecurity[labId].trap then
        for trapName, trap in pairs(LabSecurity[labId].trap) do
            if trap.installed and os.time() - trap.lastUsed >= trap.config.cooldown then
                if math.random() <= 0.7 then -- 70% szansa na aktywację pułapki
                    ApplyDamage(intruderSource, trap.config.damage)
                    trap.lastUsed = os.time()
                    securityTriggered = true
                end
            end
        end
    end
    
    return securityTriggered
end

-- Eventy
RegisterNetEvent('kubi-drugs:server:updateReputation', function(dealerName, points)
    local source = source
    UpdatePlayerReputation(source, dealerName, points)
end)

RegisterNetEvent('kubi-drugs:server:startTransport', function(transportType, transportName, items)
    local source = source
    StartTransport(source, transportType, transportName, items)
end)

RegisterNetEvent('kubi-drugs:server:installSecurity', function(labId, securityType, securityName)
    local source = source
    InstallSecurity(source, labId, securityType, securityName)
end)

RegisterNetEvent('kubi-drugs:server:checkLabSecurity', function(labId)
    local source = source
    CheckLabSecurity(labId, source)
end) 