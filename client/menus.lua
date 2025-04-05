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

-- Funkcja do pobierania tokenu bezpieczeństwa
local function GetSecurityToken(cb)
    QBCore.Functions.TriggerCallback('kubi-drugs:server:getSecurityToken', function(token)
        cb(token)
    end)
end

-- Funkcja do resetowania tokenu bezpieczeństwa
local function ResetSecurityToken()
    securityToken = nil
end

-- Funkcja otwierająca menu produkcji narkotyków
function OpenProductionMenu(drugType, locationType, locationIndex)
    -- Pobierz token bezpieczeństwa
    GetSecurityToken(function(securityToken)
        -- Sprawdź czy dane narkotyku istnieją
        local drugData = Config.Drugs[drugType]
        if not drugData then
            QBCore.Functions.Notify(Lang:t("error.invalid_drug"), "error")
            return
        end
        
        -- Przygotowanie opcji menu
        local options = {}
        
        -- Dodaj tytuł i nagłówek
        table.insert(options, {
            header = drugData.label,
            isMenuHeader = true
        })
        
        -- Opcje dla zbierania (tylko w lokacjach zbiorów)
        if locationType == "harvest" then
            table.insert(options, {
                title = Lang:t("menu.harvest"),
                description = Lang:t("menu.harvest_desc", {drug = drugData.label}),
                event = "kubi-drugs:client:startProcess",
                args = {
                    drugType = drugType,
                    processType = "harvest",
                    locationIndex = locationIndex
                }
            })
        end
        
        -- Opcje dla przetwarzania (tylko w lokacjach przetwarzania)
        if locationType == "process" then
            -- Podstawowe przetwarzanie
            if drugData.requiredItems["process"] then
                table.insert(options, {
                    title = Lang:t("menu.process"),
                    description = Lang:t("menu.process_desc", {drug = drugData.label}),
                    event = "kubi-drugs:client:startProcess",
                    args = {
                        drugType = drugType,
                        processType = "process",
                        locationIndex = locationIndex
                    }
                })
            end
            
            -- Zaawansowane opcje przetwarzania dostępne dla określonych narkotyków
            if drugType == "weed" then
                if drugData.requiredItems["dry"] then
                    table.insert(options, {
                        title = Lang:t("menu.dry_weed"),
                        description = Lang:t("menu.dry_desc"),
                        event = "kubi-drugs:client:startProcess",
                        args = {
                            drugType = drugType,
                            processType = "dry",
                            locationIndex = locationIndex
                        }
                    })
                end
            elseif drugType == "cocaine" then
                if drugData.requiredItems["refine"] then
                    table.insert(options, {
                        title = Lang:t("menu.refine_cocaine"),
                        description = Lang:t("menu.refine_desc"),
                        event = "kubi-drugs:client:startProcess",
                        args = {
                            drugType = drugType,
                            processType = "refine",
                            locationIndex = locationIndex
                        }
                    })
                end
            elseif drugType == "meth" then
                if drugData.requiredItems["crystallize"] then
                    table.insert(options, {
                        title = Lang:t("menu.crystallize_meth"),
                        description = Lang:t("menu.crystallize_desc"),
                        event = "kubi-drugs:client:startProcess",
                        args = {
                            drugType = drugType,
                            processType = "crystallize",
                            locationIndex = locationIndex
                        }
                    })
                end
                
                if drugData.requiredItems["blue_meth"] then
                    table.insert(options, {
                        title = Lang:t("menu.blue_meth"),
                        description = Lang:t("menu.blue_meth_desc"),
                        event = "kubi-drugs:client:startProcess",
                        args = {
                            drugType = drugType,
                            processType = "blue_meth",
                            locationIndex = locationIndex
                        }
                    })
                end
            elseif drugType == "heroin" then
                if drugData.requiredItems["purify"] then
                    table.insert(options, {
                        title = Lang:t("menu.purify_heroin"),
                        description = Lang:t("menu.purify_desc"),
                        event = "kubi-drugs:client:startProcess",
                        args = {
                            drugType = drugType,
                            processType = "purify",
                            locationIndex = locationIndex
                        }
                    })
                end
            elseif drugType == "lsd" then
                if drugData.requiredItems["concentrate"] then
                    table.insert(options, {
                        title = Lang:t("menu.concentrate_lsd"),
                        description = Lang:t("menu.concentrate_desc"),
                        event = "kubi-drugs:client:startProcess",
                        args = {
                            drugType = drugType,
                            processType = "concentrate",
                            locationIndex = locationIndex
                        }
                    })
                end
            elseif drugType == "ecstasy" then
                if drugData.requiredItems["press"] then
                    table.insert(options, {
                        title = Lang:t("menu.press_ecstasy"),
                        description = Lang:t("menu.press_desc"),
                        event = "kubi-drugs:client:startProcess",
                        args = {
                            drugType = drugType,
                            processType = "press",
                            locationIndex = locationIndex
                        }
                    })
                end
                
                if drugData.requiredItems["color"] then
                    table.insert(options, {
                        title = Lang:t("menu.color_ecstasy"),
                        description = Lang:t("menu.color_desc"),
                        event = "kubi-drugs:client:startProcess",
                        args = {
                            drugType = drugType,
                            processType = "color",
                            locationIndex = locationIndex
                        }
                    })
                end
            elseif drugType == "mushrooms" then
                if drugData.requiredItems["grind"] then
                    table.insert(options, {
                        title = Lang:t("menu.grind_mushrooms"),
                        description = Lang:t("menu.grind_desc"),
                        event = "kubi-drugs:client:startProcess",
                        args = {
                            drugType = drugType,
                            processType = "grind",
                            locationIndex = locationIndex
                        }
                    })
                end
                
                if drugData.requiredItems["distill"] then
                    table.insert(options, {
                        title = Lang:t("menu.distill_mushrooms"),
                        description = Lang:t("menu.distill_desc"),
                        event = "kubi-drugs:client:startProcess",
                        args = {
                            drugType = drugType,
                            processType = "distill",
                            locationIndex = locationIndex
                        }
                    })
                end
            end
        end
        
        -- Opcje dla pakowania (tylko w lokacjach pakowania)
        if locationType == "package" then
            -- Standardowe pakowanie
            if drugData.requiredItems["package"] then
                table.insert(options, {
                    title = Lang:t("menu.package"),
                    description = Lang:t("menu.package_desc", {drug = drugData.label}),
                    event = "kubi-drugs:client:startProcess",
                    args = {
                        drugType = drugType,
                        processType = "package",
                        locationIndex = locationIndex
                    }
                })
            end
            
            -- Zaawansowane opcje pakowania dla określonych narkotyków
            if drugType == "lsd" and drugData.requiredItems["blotter"] then
                table.insert(options, {
                    title = Lang:t("menu.blotter_lsd"),
                    description = Lang:t("menu.blotter_desc"),
                    event = "kubi-drugs:client:startProcess",
                    args = {
                        drugType = drugType,
                        processType = "blotter",
                        locationIndex = locationIndex
                    }
                })
            elseif drugType == "heroin" and drugData.requiredItems["inject"] then
                table.insert(options, {
                    title = Lang:t("menu.inject_heroin"),
                    description = Lang:t("menu.inject_desc"),
                    event = "kubi-drugs:client:startProcess",
                    args = {
                        drugType = drugType,
                        processType = "inject",
                        locationIndex = locationIndex
                    }
                })
            elseif drugType == "mushrooms" and drugData.requiredItems["capsule"] then
                table.insert(options, {
                    title = Lang:t("menu.capsule_mushrooms"),
                    description = Lang:t("menu.capsule_desc"),
                    event = "kubi-drugs:client:startProcess",
                    args = {
                        drugType = drugType,
                        processType = "capsule",
                        locationIndex = locationIndex
                    }
                })
            end
        end
        
        -- Dodaj opcję zamknięcia menu
        table.insert(options, {
            title = Lang:t("menu.close"),
            description = Lang:t("menu.close_desc"),
            event = "qb-menu:closeMenu"
        })
        
        -- Otwórz menu
        exports['qb-menu']:openMenu(options)
    end)
end

-- Funkcja otwierająca menu dealera
function OpenDealerMenu(dealerId, dealer)
    -- Pobierz token bezpieczeństwa
    GetSecurityToken(function(securityToken)
        -- Sprawdź czy dealer istnieje
        local dealerData = Config.Dealers[dealerId]
        if not dealerData then
            QBCore.Functions.Notify(Lang:t("error.invalid_dealer"), "error")
            return
        end
        
        -- Sprawdź godziny pracy dealera
        local currentHour = tonumber(os.date("%H"))
        if currentHour < dealerData.hours.from or currentHour >= dealerData.hours.to then
            QBCore.Functions.Notify(Lang:t("error.dealer_closed", {from = dealerData.hours.from, to = dealerData.hours.to}), "error")
            return
        end
        
        -- Przygotowanie opcji menu
        local options = {}
        
        -- Dodaj tytuł i nagłówek
        table.insert(options, {
            header = Lang:t("menu.dealer_header"),
            isMenuHeader = true
        })
        
        -- Dodaj opcje dla każdego narkotyku, który dealer obsługuje
        for _, drugType in ipairs(dealerData.drugs) do
            local drugData = Config.Drugs[drugType]
            if drugData then
                -- Standardowa jakość
                table.insert(options, {
                    title = Lang:t("menu.sell_drug", {drug = drugData.label}),
                    description = Lang:t("menu.sell_desc", {min = drugData.sellPrice.min, max = drugData.sellPrice.max}),
                    event = "kubi-drugs:client:sellDrug",
                    args = {
                        drugType = drugType,
                        dealerId = dealerId,
                        quality = "standard"
                    }
                })
                
                -- Premium jakość (tylko jeśli dealer sprawdza jakość)
                if dealerData.qualityCheck then
                    table.insert(options, {
                        title = Lang:t("menu.sell_premium", {drug = drugData.label}),
                        description = Lang:t("menu.sell_premium_desc", {min = drugData.sellPrice.min * 2, max = drugData.sellPrice.max * 2}),
                        event = "kubi-drugs:client:sellDrug",
                        args = {
                            drugType = drugType,
                            dealerId = dealerId,
                            quality = "premium"
                        }
                    })
                end
            end
        end
        
        -- Opcje kupna materiałów
        if dealerData.sellsMaterials then
            table.insert(options, {
                title = Lang:t("menu.buy_materials"),
                description = Lang:t("menu.materials_desc"),
                event = "kubi-drugs:client:openBuyMenu",
                args = {
                    dealerId = dealerId
                }
            })
        end
        
        -- Dodaj opcję zamknięcia menu
        table.insert(options, {
            title = Lang:t("menu.close"),
            description = Lang:t("menu.close_desc"),
            event = "qb-menu:closeMenu"
        })
        
        -- Otwórz menu
        exports['qb-menu']:openMenu(options)
    end)
end

-- Funkcja otwierająca menu laboratorium
function OpenLabMenu(labName)
    -- Pobierz token bezpieczeństwa
    GetSecurityToken(function(securityToken)
        -- Sprawdź czy laboratorium istnieje
        local lab = nil
        for _, v in ipairs(Config.Labs) do
            if v.name == labName then
                lab = v
                break
            end
        end
        
        if not lab then
            QBCore.Functions.Notify(Lang:t("error.invalid_lab"), "error")
            return
        end
        
        -- Sprawdź czy gracz ma dostęp do laboratorium
        QBCore.Functions.TriggerCallback('kubi-drugs:server:checkLabAccess', function(hasAccess)
            -- Przygotowanie opcji menu
            local options = {}
            
            -- Dodaj tytuł i nagłówek
            table.insert(options, {
                header = lab.label,
                isMenuHeader = true
            })
            
            -- Informacje o laboratorium
            table.insert(options, {
                header = Lang:t("menu.lab_info"),
                txt = Lang:t("menu.lab_level", {level = lab.level}) .. "<br>" ..
                      Lang:t("menu.lab_drugs", {drugs = table.concat(GetDrugLabels(lab.drugs), ", ")}) .. "<br>" ..
                      Lang:t("menu.lab_equipment", {equipment = table.concat(GetLabEquipmentLabels(lab.equipmentRequired), ", ")}),
                isMenuHeader = true
            })
            
            -- Jeśli gracz ma dostęp do laboratorium
            if hasAccess then
                -- Dodaj opcje dla każdego narkotyku, który można produkować w tym laboratorium
                for _, drugType in ipairs(lab.drugs) do
                    local drugData = Config.Drugs[drugType]
                    if drugData then
                        table.insert(options, {
                            title = drugData.label,
                            description = Lang:t("menu.produce_drug", {drug = drugData.label}),
                            event = "kubi-drugs:client:openLabDrugMenu",
                            args = {
                                labName = labName,
                                drugType = drugType
                            }
                        })
                    end
                end
            else
                -- Opcja kupna dostępu
                table.insert(options, {
                    title = Lang:t("menu.buy_access"),
                    description = Lang:t("menu.access_desc", {price = lab.unlockPrice}),
                    event = "kubi-drugs:client:buyLabAccess",
                    args = {
                        labName = labName
                    }
                })
            end
            
            -- Dodaj opcję zamknięcia menu
            table.insert(options, {
                title = Lang:t("menu.close"),
                description = Lang:t("menu.close_desc"),
                event = "qb-menu:closeMenu"
            })
            
            -- Otwórz menu
            exports['qb-menu']:openMenu(options)
        end, securityToken, labName)
    end)
end

-- Funkcja otwierająca menu produkcji narkotyku w laboratorium
function OpenLabDrugMenu(labName, drugType)
    -- Pobierz token bezpieczeństwa
    GetSecurityToken(function(securityToken)
        -- Sprawdź czy laboratorium może być używane do produkcji tego narkotyku
        QBCore.Functions.TriggerCallback('kubi-drugs:server:canUseLab', function(canUse, labLevel)
            if not canUse then return end
            
            -- Pobierz dane o narkotyku
            local drugData = Config.Drugs[drugType]
            if not drugData then return end
            
            -- Przygotowanie opcji menu
            local options = {}
            
            -- Dodaj tytuł i nagłówek
            table.insert(options, {
                header = Lang:t("menu.lab_production", {drug = drugData.label}),
                isMenuHeader = true
            })
            
            -- Podstawowe przetwarzanie
            if drugData.requiredItems["process"] then
                table.insert(options, {
                    title = Lang:t("menu.process"),
                    description = Lang:t("menu.process_desc", {drug = drugData.label}),
                    event = "kubi-drugs:client:startLabProcess",
                    args = {
                        drugType = drugType,
                        labName = labName,
                        processType = "process",
                        labLevel = labLevel
                    }
                })
            end
            
            -- Zaawansowane opcje przetwarzania w zależności od narkotyku
            if drugType == "weed" then
                if drugData.requiredItems["dry"] then
                    table.insert(options, {
                        title = Lang:t("menu.dry_weed"),
                        description = Lang:t("menu.dry_desc"),
                        event = "kubi-drugs:client:startLabProcess",
                        args = {
                            drugType = drugType,
                            labName = labName,
                            processType = "dry",
                            labLevel = labLevel
                        }
                    })
                end
            elseif drugType == "cocaine" then
                if drugData.requiredItems["refine"] then
                    table.insert(options, {
                        title = Lang:t("menu.refine_cocaine"),
                        description = Lang:t("menu.refine_desc"),
                        event = "kubi-drugs:client:startLabProcess",
                        args = {
                            drugType = drugType,
                            labName = labName,
                            processType = "refine",
                            labLevel = labLevel
                        }
                    })
                end
            elseif drugType == "meth" then
                if drugData.requiredItems["crystallize"] then
                    table.insert(options, {
                        title = Lang:t("menu.crystallize_meth"),
                        description = Lang:t("menu.crystallize_desc"),
                        event = "kubi-drugs:client:startLabProcess",
                        args = {
                            drugType = drugType,
                            labName = labName,
                            processType = "crystallize",
                            labLevel = labLevel
                        }
                    })
                end
                
                if drugData.requiredItems["blue_meth"] then
                    table.insert(options, {
                        title = Lang:t("menu.blue_meth"),
                        description = Lang:t("menu.blue_meth_desc"),
                        event = "kubi-drugs:client:startLabProcess",
                        args = {
                            drugType = drugType,
                            labName = labName,
                            processType = "blue_meth",
                            labLevel = labLevel
                        }
                    })
                end
            elseif drugType == "heroin" then
                if drugData.requiredItems["purify"] then
                    table.insert(options, {
                        title = Lang:t("menu.purify_heroin"),
                        description = Lang:t("menu.purify_desc"),
                        event = "kubi-drugs:client:startLabProcess",
                        args = {
                            drugType = drugType,
                            labName = labName,
                            processType = "purify",
                            labLevel = labLevel
                        }
                    })
                end
            elseif drugType == "lsd" then
                if drugData.requiredItems["concentrate"] then
                    table.insert(options, {
                        title = Lang:t("menu.concentrate_lsd"),
                        description = Lang:t("menu.concentrate_desc"),
                        event = "kubi-drugs:client:startLabProcess",
                        args = {
                            drugType = drugType,
                            labName = labName,
                            processType = "concentrate",
                            labLevel = labLevel
                        }
                    })
                end
            elseif drugType == "ecstasy" then
                if drugData.requiredItems["press"] then
                    table.insert(options, {
                        title = Lang:t("menu.press_ecstasy"),
                        description = Lang:t("menu.press_desc"),
                        event = "kubi-drugs:client:startLabProcess",
                        args = {
                            drugType = drugType,
                            labName = labName,
                            processType = "press",
                            labLevel = labLevel
                        }
                    })
                end
                
                if drugData.requiredItems["color"] then
                    table.insert(options, {
                        title = Lang:t("menu.color_ecstasy"),
                        description = Lang:t("menu.color_desc"),
                        event = "kubi-drugs:client:startLabProcess",
                        args = {
                            drugType = drugType,
                            labName = labName,
                            processType = "color",
                            labLevel = labLevel
                        }
                    })
                end
            elseif drugType == "mushrooms" then
                if drugData.requiredItems["grind"] then
                    table.insert(options, {
                        title = Lang:t("menu.grind_mushrooms"),
                        description = Lang:t("menu.grind_desc"),
                        event = "kubi-drugs:client:startLabProcess",
                        args = {
                            drugType = drugType,
                            labName = labName,
                            processType = "grind",
                            labLevel = labLevel
                        }
                    })
                end
                
                if drugData.requiredItems["distill"] then
                    table.insert(options, {
                        title = Lang:t("menu.distill_mushrooms"),
                        description = Lang:t("menu.distill_desc"),
                        event = "kubi-drugs:client:startLabProcess",
                        args = {
                            drugType = drugType,
                            labName = labName,
                            processType = "distill",
                            labLevel = labLevel
                        }
                    })
                end
            end
            
            -- Opcje pakowania premium
            if drugData.requiredItems["premium_package"] then
                table.insert(options, {
                    title = Lang:t("menu.premium_package"),
                    description = Lang:t("menu.premium_desc", {drug = drugData.label}),
                    event = "kubi-drugs:client:startLabProcess",
                    args = {
                        drugType = drugType,
                        labName = labName,
                        processType = "premium_package",
                        labLevel = labLevel
                    }
                })
            end
            
            -- Specjalne opcje pakowania
            if drugType == "lsd" and drugData.requiredItems["blotter"] then
                table.insert(options, {
                    title = Lang:t("menu.blotter_lsd"),
                    description = Lang:t("menu.blotter_desc"),
                    event = "kubi-drugs:client:startLabProcess",
                    args = {
                        drugType = drugType,
                        labName = labName,
                        processType = "blotter",
                        labLevel = labLevel
                    }
                })
            elseif drugType == "heroin" and drugData.requiredItems["inject"] then
                table.insert(options, {
                    title = Lang:t("menu.inject_heroin"),
                    description = Lang:t("menu.inject_desc"),
                    event = "kubi-drugs:client:startLabProcess",
                    args = {
                        drugType = drugType,
                        labName = labName,
                        processType = "inject",
                        labLevel = labLevel
                    }
                })
            elseif drugType == "mushrooms" and drugData.requiredItems["capsule"] then
                table.insert(options, {
                    title = Lang:t("menu.capsule_mushrooms"),
                    description = Lang:t("menu.capsule_desc"),
                    event = "kubi-drugs:client:startLabProcess",
                    args = {
                        drugType = drugType,
                        labName = labName,
                        processType = "capsule",
                        labLevel = labLevel
                    }
                })
            end
            
            -- Dodaj opcję zamknięcia menu
            table.insert(options, {
                title = Lang:t("menu.close"),
                description = Lang:t("menu.close_desc"),
                event = "qb-menu:closeMenu"
            })
            
            -- Otwórz menu
            exports['qb-menu']:openMenu(options)
        end, securityToken, labName, drugType)
    end)
end

-- Funkcja pomocnicza do pobrania etykiet sprzętu
function GetLabEquipmentLabels(equipmentList)
    local labels = {}
    
    for _, equipment in ipairs(equipmentList) do
        if Config.LabEquipment[equipment] then
            table.insert(labels, Config.LabEquipment[equipment].label)
        end
    end
    
    return labels
end

-- Funkcja pomocnicza do pobrania etykiet narkotyków
function GetDrugLabels(drugList)
    local labels = {}
    
    for _, drug in ipairs(drugList) do
        if Config.Drugs[drug] then
            table.insert(labels, Config.Drugs[drug].label)
        end
    end
    
    return labels
end

-- Rejestracja eventów dla menu
RegisterNetEvent('kubi-drugs:client:openProductionMenu', function(data)
    OpenProductionMenu(data.drugType, data.locationType, data.locationIndex)
end)

RegisterNetEvent('kubi-drugs:client:openDealerMenu', function(data)
    OpenDealerMenu(data.dealerId, data.dealer)
end)

RegisterNetEvent('kubi-drugs:client:openLabMenu', function(data)
    OpenLabMenu(data.labName)
end)

RegisterNetEvent('kubi-drugs:client:openLabDrugMenu', function(data)
    OpenLabDrugMenu(data.labName, data.drugType)
end)

RegisterNetEvent('kubi-drugs:client:buyLabAccess', function(data)
    -- Pobierz token bezpieczeństwa
    GetSecurityToken(function(token)
        -- Wyślij żądanie kupna dostępu do laboratorium
        TriggerServerEvent('kubi-drugs:server:buyLabAccess', token, data.labName)
        
        -- Resetuj token po użyciu
        ResetSecurityToken()
    end)
end)

-- Event do otwierania menu kupna materiałów
RegisterNetEvent('kubi-drugs:client:openBuyMenu', function(data)
    -- Przygotowanie opcji menu
    local options = {}
    
    -- Dodaj tytuł i nagłówek
    table.insert(options, {
        header = Lang:t("menu.buy_materials_header"),
        isMenuHeader = true
    })
    
    -- Dodaj opcje dla chemikaliów
    for itemName, itemData in pairs(Config.Chemicals) do
        table.insert(options, {
            title = itemData.label,
            description = Lang:t("menu.buy_item_desc", {price = itemData.price}),
            event = "kubi-drugs:client:buyMaterial",
            args = {
                item = itemName,
                price = itemData.price,
                dealerId = data.dealerId
            }
        })
    end
    
    -- Dodaj opcje dla sprzętu laboratoryjnego
    for itemName, itemData in pairs(Config.LabEquipment) do
        table.insert(options, {
            title = itemData.label,
            description = Lang:t("menu.buy_item_desc", {price = itemData.price}),
            event = "kubi-drugs:client:buyMaterial",
            args = {
                item = itemName,
                price = itemData.price,
                dealerId = data.dealerId
            }
        })
    end
    
    -- Dodaj opcje dla materiałów do pakowania
    for itemName, itemData in pairs(Config.PackagingMaterials) do
        table.insert(options, {
            title = itemData.label,
            description = Lang:t("menu.buy_item_desc", {price = itemData.price}),
            event = "kubi-drugs:client:buyMaterial",
            args = {
                item = itemName,
                price = itemData.price,
                dealerId = data.dealerId
            }
        })
    end
    
    -- Dodaj opcję zamknięcia menu
    table.insert(options, {
        title = Lang:t("menu.close"),
        description = Lang:t("menu.close_desc"),
        event = "qb-menu:closeMenu"
    })
    
    -- Otwórz menu
    exports['qb-menu']:openMenu(options)
end)

-- Event do kupowania materiałów
RegisterNetEvent('kubi-drugs:client:buyMaterial', function(data)
    -- Pobierz token bezpieczeństwa
    GetSecurityToken(function(token)
        -- Wyślij żądanie kupna materiału
        TriggerServerEvent('kubi-drugs:server:buyMaterial', token, data.item, data.price, data.dealerId)
        
        -- Resetuj token po użyciu
        ResetSecurityToken()
    end)
end)

-- Eventy do obsługi procesów
RegisterNetEvent('kubi-drugs:client:startProcess', function(data)
    StartProcess(data.drugType, data.processType, data.locationIndex)
end)

RegisterNetEvent('kubi-drugs:client:startLabProcess', function(data)
    StartLabProcess(data.drugType, data.labName, data.processType, data.labLevel)
end)

RegisterNetEvent('kubi-drugs:client:sellDrug', function(data)
    SellDrug(data.drugType, data.dealerId, data.quality)
end) 