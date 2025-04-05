Config = {}

-- Ogólne ustawienia
Config.Debug = false -- Tryb debugowania
Config.UseTarget = true -- Używa qb-target zamiast tekstu 3D

-- Chemikalia i sprzęt
Config.Chemicals = {
    ['basic_chemicals'] = {
        label = 'Podstawowe chemikalia',
        weight = 100,
        description = 'Podstawowe chemikalia używane w produkcji narkotyków.'
    },
    ['acid'] = {
        label = 'Kwas',
        weight = 100,
        description = 'Silny kwas używany w produkcji narkotyków.'
    },
    ['solvent'] = {
        label = 'Rozpuszczalnik',
        weight = 100,
        description = 'Rozpuszczalnik używany do ekstrakcji substancji czynnych.'
    },
    ['baking_soda'] = {
        label = 'Soda oczyszczona',
        weight = 50,
        description = 'Używana do przetwarzania kokainy.'
    },
    ['acetone'] = {
        label = 'Aceton',
        weight = 200,
        description = 'Rozpuszczalnik używany w produkcji metamfetaminy.'
    },
    ['lithium'] = {
        label = 'Lit',
        weight = 100,
        description = 'Reaktywny metal używany w syntezie metamfetaminy.'
    },
    ['ergot_fungus'] = {
        label = 'Sporysz',
        weight = 50,
        description = 'Grzyb używany do produkcji LSD.'
    },
    ['lye'] = {
        label = 'Wodorotlenek sodu',
        weight = 100,
        description = 'Silna zasada używana w produkcji narkotyków.'
    },
    ['liquid_mercury'] = {
        label = 'Ciekła rtęć',
        weight = 200,
        description = 'Toksyczny metal używany w niektórych procesach chemicznych.'
    }
}

Config.LabEquipment = {
    ['beaker'] = {
        label = 'Zlewka',
        weight = 150,
        description = 'Podstawowe naczynie laboratoryjne.'
    },
    ['test_tube'] = {
        label = 'Probówka',
        weight = 50,
        description = 'Małe naczynie do mieszania małych ilości substancji.'
    },
    ['bunsen_burner'] = {
        label = 'Palnik Bunsena',
        weight = 500,
        description = 'Używany do podgrzewania substancji.'
    },
    ['scale'] = {
        label = 'Waga laboratoryjna',
        weight = 300,
        description = 'Precyzyjna waga do odmierzania substancji.'
    },
    ['filter'] = {
        label = 'Filtr laboratoryjny',
        weight = 50,
        description = 'Używany do filtrowania mieszanin.'
    },
    ['distilling_kit'] = {
        label = 'Zestaw do destylacji',
        weight = 1000,
        description = 'Używany do destylacji i oczyszczania substancji.'
    }
}

Config.PackagingMaterials = {
    ['plastic_bag'] = {
        label = 'Woreczek foliowy',
        weight = 1,
        description = 'Podstawowy woreczek do pakowania.'
    },
    ['vacuum_bag'] = {
        label = 'Worek próżniowy',
        weight = 2,
        description = 'Lepsze opakowanie, zmniejszające ryzyko wykrycia.'
    },
    ['pill_press'] = {
        label = 'Prasa do tabletek',
        weight = 2000,
        description = 'Używana do produkcji tabletek i pigułek.'
    },
    ['pill_casing'] = {
        label = 'Otoczka kapsułki',
        weight = 5,
        description = 'Otoczka do tabletek.'
    },
    ['blotter_paper'] = {
        label = 'Papier LSD',
        weight = 10,
        description = 'Arkusze papieru do nasączania LSD.'
    },
    ['pill_binder'] = {
        label = 'Substancja wiążąca',
        weight = 50,
        description = 'Substancja używana do spajania składników w tabletkach.'
    }
}

-- System jakości narkotyków
Config.QualityLevels = {
    {
        name = 'poor',
        label = 'Słaba jakość',
        priceMultiplier = 0.7,
        successChance = 90
    },
    {
        name = 'standard',
        label = 'Standardowa jakość',
        priceMultiplier = 1.0,
        successChance = 75
    },
    {
        name = 'high',
        label = 'Wysoka jakość',
        priceMultiplier = 1.5,
        successChance = 50
    },
    {
        name = 'premium',
        label = 'Premium',
        priceMultiplier = 2.0,
        successChance = 25
    }
}

-- Ustawienia narkotyków
Config.Drugs = {
    -- Istniejące narkotyki z dodatkowymi parametrami
    ['weed'] = {
        label = 'Marihuana',
        harvestTime = 30, -- Czas zbierania w sekundach
        processTime = 45, -- Czas przetwarzania w sekundach
        packageTime = 20, -- Czas pakowania w sekundach
        sellPrice = {min = 800, max = 1200}, -- Zakres cen sprzedaży
        requiredItems = {
            process = {
                {name = 'weed_leaf', amount = 5}
            },
            concentrate = {
                {name = 'weed_processed', amount = 3},
                {name = 'solvent', amount = 1},
                {name = 'beaker', amount = 1, return = true}
            },
            package = {
                {name = 'weed_processed', amount = 3},
                {name = 'plastic_bag', amount = 1}
            },
            premium_package = {
                {name = 'weed_concentrate', amount = 2},
                {name = 'vacuum_bag', amount = 1}
            }
        },
        rewardItems = {
            harvest = {
                {name = 'weed_leaf', amount = {min = 2, max = 5}}
            },
            process = {
                {name = 'weed_processed', amount = 3}
            },
            concentrate = {
                {name = 'weed_concentrate', amount = 1}
            },
            package = {
                {name = 'weed_packaged', amount = 1}
            },
            premium_package = {
                {name = 'weed_premium', amount = 1}
            }
        },
        failChance = 5, -- Szansa na niepowodzenie w %
        labRequired = false, -- Czy potrzebne jest laboratorium
        quality = true, -- Czy narkotyk ma różne poziomy jakości
        explodeChance = 0 -- Szansa na eksplozję/pożar przy produkcji
    },
    ['cocaine'] = {
        label = 'Kokaina',
        harvestTime = 40,
        processTime = 60,
        packageTime = 25,
        sellPrice = {min = 1200, max = 1800},
        requiredItems = {
            process = {
                {name = 'cocaine_leaf', amount = 4}
            },
            purify = {
                {name = 'cocaine_processed', amount = 2},
                {name = 'baking_soda', amount = 1},
                {name = 'solvent', amount = 1},
                {name = 'beaker', amount = 1, return = true}
            },
            crack = {
                {name = 'cocaine_pure', amount = 1},
                {name = 'baking_soda', amount = 2},
                {name = 'beaker', amount = 1, return = true}
            },
            package = {
                {name = 'cocaine_processed', amount = 2},
                {name = 'plastic_bag', amount = 1}
            },
            premium_package = {
                {name = 'cocaine_pure', amount = 1},
                {name = 'vacuum_bag', amount = 1}
            }
        },
        rewardItems = {
            harvest = {
                {name = 'cocaine_leaf', amount = {min = 2, max = 4}}
            },
            process = {
                {name = 'cocaine_processed', amount = 2}
            },
            purify = {
                {name = 'cocaine_pure', amount = 1}
            },
            crack = {
                {name = 'crack', amount = 3}
            },
            package = {
                {name = 'cocaine_packaged', amount = 1}
            },
            premium_package = {
                {name = 'cocaine_premium', amount = 1}
            }
        },
        failChance = 10,
        labRequired = true,
        quality = true,
        explodeChance = 5
    },
    ['meth'] = {
        label = 'Metamfetamina',
        harvestTime = 45,
        processTime = 75,
        packageTime = 30,
        sellPrice = {min = 1500, max = 2200},
        requiredItems = {
            process = {
                {name = 'meth_raw', amount = 3},
                {name = 'basic_chemicals', amount = 2}
            },
            crystallize = {
                {name = 'meth_processed', amount = 2},
                {name = 'acetone', amount = 1},
                {name = 'beaker', amount = 1, return = true},
                {name = 'bunsen_burner', amount = 1, return = true}
            },
            blue_meth = {
                {name = 'meth_crystal', amount = 1},
                {name = 'basic_chemicals', amount = 1},
                {name = 'beaker', amount = 1, return = true}
            },
            package = {
                {name = 'meth_processed', amount = 2},
                {name = 'plastic_bag', amount = 1}
            },
            premium_package = {
                {name = 'meth_crystal', amount = 1},
                {name = 'vacuum_bag', amount = 1}
            }
        },
        rewardItems = {
            harvest = {
                {name = 'meth_raw', amount = {min = 2, max = 4}}
            },
            process = {
                {name = 'meth_processed', amount = 2}
            },
            crystallize = {
                {name = 'meth_crystal', amount = 1}
            },
            blue_meth = {
                {name = 'blue_meth', amount = 1}
            },
            package = {
                {name = 'meth_packaged', amount = 1}
            },
            premium_package = {
                {name = 'meth_premium', amount = 1}
            }
        },
        failChance = 15,
        labRequired = true,
        quality = true,
        explodeChance = 20
    },
    
    -- Nowe narkotyki
    ['heroin'] = {
        label = 'Heroina',
        harvestTime = 50,
        processTime = 90,
        packageTime = 30,
        sellPrice = {min = 2000, max = 3000},
        requiredItems = {
            process = {
                {name = 'poppy', amount = 5},
                {name = 'beaker', amount = 1, return = true}
            },
            refine = {
                {name = 'opium', amount = 2},
                {name = 'acid', amount = 1},
                {name = 'beaker', amount = 1, return = true},
                {name = 'bunsen_burner', amount = 1, return = true}
            },
            inject = {
                {name = 'heroin_refined', amount = 1},
                {name = 'syringe', amount = 5}
            },
            package = {
                {name = 'opium', amount = 2},
                {name = 'plastic_bag', amount = 1}
            },
            premium_package = {
                {name = 'heroin_refined', amount = 1},
                {name = 'vacuum_bag', amount = 1}
            }
        },
        rewardItems = {
            harvest = {
                {name = 'poppy', amount = {min = 3, max = 6}}
            },
            process = {
                {name = 'opium', amount = 2}
            },
            refine = {
                {name = 'heroin_refined', amount = 1}
            },
            inject = {
                {name = 'heroin_syringe', amount = 5}
            },
            package = {
                {name = 'heroin_packaged', amount = 1}
            },
            premium_package = {
                {name = 'heroin_premium', amount = 1}
            }
        },
        failChance = 15,
        labRequired = true,
        quality = true,
        explodeChance = 10
    },
    ['lsd'] = {
        label = 'LSD',
        harvestTime = 35,
        processTime = 120,
        packageTime = 20,
        sellPrice = {min = 3000, max = 4500},
        requiredItems = {
            process = {
                {name = 'ergot_fungus', amount = 3},
                {name = 'acid', amount = 2},
                {name = 'beaker', amount = 1, return = true},
                {name = 'test_tube', amount = 1, return = true}
            },
            distill = {
                {name = 'lsd_liquid', amount = 1},
                {name = 'distilling_kit', amount = 1, return = true},
                {name = 'filter', amount = 1}
            },
            blotter = {
                {name = 'lsd_pure', amount = 1},
                {name = 'blotter_paper', amount = 1}
            },
            package = {
                {name = 'lsd_blotter', amount = 1},
                {name = 'plastic_bag', amount = 1}
            }
        },
        rewardItems = {
            harvest = {
                {name = 'ergot_fungus', amount = {min = 1, max = 3}}
            },
            process = {
                {name = 'lsd_liquid', amount = 1}
            },
            distill = {
                {name = 'lsd_pure', amount = 1}
            },
            blotter = {
                {name = 'lsd_blotter', amount = 10}
            },
            package = {
                {name = 'lsd_packaged', amount = 1}
            }
        },
        failChance = 25,
        labRequired = true,
        quality = true,
        explodeChance = 5
    },
    ['ecstasy'] = {
        label = 'Ecstasy',
        harvestTime = 0, -- Brak zbierania, tworzone z chemikaliów
        processTime = 100,
        packageTime = 30,
        sellPrice = {min = 2500, max = 3500},
        requiredItems = {
            process = {
                {name = 'basic_chemicals', amount = 2},
                {name = 'solvent', amount = 1},
                {name = 'lithium', amount = 1},
                {name = 'beaker', amount = 1, return = true}
            },
            press = {
                {name = 'mdma_powder', amount = 2},
                {name = 'pill_binder', amount = 1},
                {name = 'pill_press', amount = 1, return = true}
            },
            color = {
                {name = 'ecstasy_pill', amount = 10},
                {name = 'basic_chemicals', amount = 1}
            },
            package = {
                {name = 'ecstasy_pill', amount = 5},
                {name = 'plastic_bag', amount = 1}
            },
            premium_package = {
                {name = 'ecstasy_colored', amount = 10},
                {name = 'pill_casing', amount = 10}
            }
        },
        rewardItems = {
            process = {
                {name = 'mdma_powder', amount = 2}
            },
            press = {
                {name = 'ecstasy_pill', amount = 10}
            },
            color = {
                {name = 'ecstasy_colored', amount = 10}
            },
            package = {
                {name = 'ecstasy_packaged', amount = 1}
            },
            premium_package = {
                {name = 'ecstasy_premium', amount = 1}
            }
        },
        failChance = 20,
        labRequired = true,
        quality = true,
        explodeChance = 15
    },
    ['mushrooms'] = {
        label = 'Grzyby halucynogenne',
        harvestTime = 25,
        processTime = 40,
        packageTime = 15,
        sellPrice = {min = 1000, max = 1500},
        requiredItems = {
            process = {
                {name = 'raw_mushrooms', amount = 5}
            },
            dry = {
                {name = 'mushrooms_cleaned', amount = 3},
                {name = 'bunsen_burner', amount = 1, return = true}
            },
            grind = {
                {name = 'mushrooms_dried', amount = 2}
            },
            package = {
                {name = 'mushrooms_cleaned', amount = 2},
                {name = 'plastic_bag', amount = 1}
            },
            capsule = {
                {name = 'mushrooms_ground', amount = 2},
                {name = 'pill_casing', amount = 5}
            }
        },
        rewardItems = {
            harvest = {
                {name = 'raw_mushrooms', amount = {min = 3, max = 7}}
            },
            process = {
                {name = 'mushrooms_cleaned', amount = 3}
            },
            dry = {
                {name = 'mushrooms_dried', amount = 2}
            },
            grind = {
                {name = 'mushrooms_ground', amount = 2}
            },
            package = {
                {name = 'mushrooms_packaged', amount = 1}
            },
            capsule = {
                {name = 'mushrooms_capsules', amount = 5}
            }
        },
        failChance = 5,
        labRequired = false,
        quality = true,
        explodeChance = 0
    }
}

-- Konfiguracja laboratoriów
Config.Labs = {
    {
        name = "small_lab",
        label = "Małe laboratorium",
        location = vector4(1012.7, -3195.6, -38.99, 6.32),
        level = 1,
        drugs = {"weed", "cocaine", "mushrooms"},
        equipmentRequired = {"beaker", "test_tube"},
        failChanceReduction = 5,
        qualityBoost = 1,
        unlockPrice = 0 -- Za darmo
    },
    {
        name = "medium_lab",
        label = "Średnie laboratorium",
        location = vector4(998.9, -3199.8, -38.99, 2.5),
        level = 2,
        drugs = {"weed", "cocaine", "meth", "mushrooms"},
        equipmentRequired = {"beaker", "test_tube", "bunsen_burner", "scale"},
        failChanceReduction = 10,
        qualityBoost = 2,
        unlockPrice = 50000
    },
    {
        name = "big_lab",
        label = "Duże laboratorium",
        location = vector4(1003.0, -3201.4, -38.99, 180.37),
        level = 3,
        drugs = {"weed", "cocaine", "meth", "heroin", "ecstasy"},
        equipmentRequired = {"beaker", "test_tube", "bunsen_burner", "scale", "filter"},
        failChanceReduction = 15,
        qualityBoost = 3,
        unlockPrice = 150000
    },
    {
        name = "premium_lab",
        label = "Profesjonalne laboratorium",
        location = vector4(969.5, -147.0, 74.23, 54.7),
        level = 4,
        drugs = {"weed", "cocaine", "meth", "heroin", "lsd", "ecstasy"},
        equipmentRequired = {"beaker", "test_tube", "bunsen_burner", "scale", "filter", "distilling_kit"},
        failChanceReduction = 20,
        qualityBoost = 4,
        unlockPrice = 500000
    }
}

-- Konfiguracja sprzedawców
Config.Dealers = {
    {
        coords = vector4(384.52, -761.65, 29.29, 359.26),
        ped = 'a_m_y_downtown_01',
        scenario = 'WORLD_HUMAN_SMOKING',
        drugs = {'weed', 'mushrooms'},
        hours = {
            from = 18,
            to = 23
        },
        qualityCheck = false,
        priceBoost = 0
    },
    {
        coords = vector4(-1190.25, -397.74, 37.01, 264.53),
        ped = 'a_m_y_hipster_01',
        scenario = 'WORLD_HUMAN_LEANING',
        drugs = {'weed', 'cocaine', 'mushrooms', 'ecstasy'},
        hours = {
            from = 9,
            to = 18
        },
        qualityCheck = true,
        priceBoost = 5
    },
    {
        coords = vector4(974.77, -1711.97, 30.89, 352.91),
        ped = 's_m_y_dealer_01',
        scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        drugs = {'cocaine', 'meth', 'heroin'},
        hours = {
            from = 0,
            to = 24
        },
        qualityCheck = true,
        priceBoost = 10
    },
    {
        coords = vector4(2358.37, 3135.03, 48.21, 170.45),
        ped = 'g_m_y_mexgoon_03',
        scenario = 'WORLD_HUMAN_DRUG_DEALER',
        drugs = {'cocaine', 'meth', 'heroin', 'lsd', 'ecstasy'},
        hours = {
            from = 22,
            to = 6
        },
        qualityCheck = true,
        priceBoost = 20,
        reputation = true
    }
}

-- Konfiguracja policji
Config.MinCops = 2 -- Minimalna liczba policjantów online, aby można było zbierać/przetwarzać/sprzedawać narkotyki
Config.PoliceCallChance = 35 -- Szansa na wezwanie policji podczas sprzedaży (w procentach)

-- Konfiguracja anty-cheat
Config.SecurityTokenExpiry = 5 * 60 -- 5 minut
Config.SecurityTokenLength = 32 -- Długość tokenu bezpieczeństwa
Config.MaxAllowedErrors = 3 -- Maksymalna liczba błędów przed wyrzuceniem gracza
Config.BanOnSuspectedCheating = true -- Czy banować gracza przy podejrzeniu o oszukiwanie 