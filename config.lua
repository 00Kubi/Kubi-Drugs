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
    },
    ['chemical_precursor'] = {
        label = 'Prekursor chemiczny',
        weight = 75,
        description = 'Rzadki prekursor używany do syntezy zaawansowanych substancji.'
    },
    ['carrier_herb'] = {
        label = 'Zioło nośnikowe',
        weight = 30,
        description = 'Neutralne zioło używane jako nośnik dla substancji aktywnych.'
    },
    ['vape_liquid_base'] = {
        label = 'Baza do e-liquidu',
        weight = 100,
        description = 'Płynna baza używana do tworzenia e-liquidów.'
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
    },
    ['synthetic_cannabinoids'] = {
        label = 'Syntetyczne Kannabinoidy',
        harvestTime = 60,
        processTime = 150, -- Bardzo długi proces z powodu złożoności
        packageTime = 35,
        sellPrice = {min = 5000, max = 7500}, -- Najwyższe ceny ze względu na zaawansowanie
        requiredItems = {
            -- Krok 1: Zbieranie prekursorów chemicznych
            harvest = {
                {name = 'chemical_precursor', amount = 1}
            },
            -- Krok 2: Synteza podstawowej struktury
            synthesize = {
                {name = 'chemical_precursor', amount = 3},
                {name = 'basic_chemicals', amount = 2},
                {name = 'solvent', amount = 2},
                {name = 'beaker', amount = 1, return = true},
                {name = 'test_tube', amount = 1, return = true}
            },
            -- Krok 3: Reakcja łańcuchowa
            react = {
                {name = 'synthetic_base', amount = 1},
                {name = 'lithium', amount = 1},
                {name = 'acetone', amount = 1},
                {name = 'bunsen_burner', amount = 1, return = true},
                {name = 'beaker', amount = 1, return = true}
            },
            -- Krok 4: Stabilizacja i oczyszczanie
            stabilize = {
                {name = 'synthetic_compound', amount = 1},
                {name = 'lye', amount = 1},
                {name = 'filter', amount = 1},
                {name = 'distilling_kit', amount = 1, return = true}
            },
            -- Krok 5: Aplikacja na nośnik
            infuse = {
                {name = 'synthetic_pure', amount = 1},
                {name = 'solvent', amount = 1},
                {name = 'carrier_herb', amount = 5}
            },
            -- Krok 6: Pakowanie standardowe
            package = {
                {name = 'synthetic_infused', amount = 2},
                {name = 'plastic_bag', amount = 1}
            },
            -- Krok 7: Pakowanie premium (w formie e-liquidu)
            premium_package = {
                {name = 'synthetic_pure', amount = 1},
                {name = 'vape_liquid_base', amount = 3},
                {name = 'vacuum_bag', amount = 1},
                {name = 'beaker', amount = 1, return = true}
            }
        },
        rewardItems = {
            harvest = {
                {name = 'chemical_precursor', amount = {min = 1, max = 3}}
            },
            synthesize = {
                {name = 'synthetic_base', amount = 1}
            },
            react = {
                {name = 'synthetic_compound', amount = 1}
            },
            stabilize = {
                {name = 'synthetic_pure', amount = 1}
            },
            infuse = {
                {name = 'synthetic_infused', amount = 3}
            },
            package = {
                {name = 'synthetic_packaged', amount = 1}
            },
            premium_package = {
                {name = 'synthetic_vape', amount = 1}
            }
        },
        failChance = 30, -- Bardzo wysoka szansa na niepowodzenie
        labRequired = true, -- Wymaga zaawansowanego laboratorium
        quality = true,
        explodeChance = 25, -- Wysoka szansa na eksplozję z powodu niestabilnych chemikaliów
        temperatureSensitive = true, -- Nowa cecha - wrażliwość na temperaturę
        minLabLevel = 2 -- Wymaga laboratorium poziomu 2 lub wyższego
    }
}

-- Konfiguracja laboratoriów
Config.Labs = {
    {
        name = "lab_1",
        label = "Laboratorium w Sandy Shores",
        coords = vector3(1968.0, 3819.0, 33.0),
        price = 1000000,
        upgrades = {
            {
                name = "equipment",
                label = "Sprzęt laboratoryjny",
                levels = {
                    {
                        level = 1,
                        price = 500000,
                        benefits = {
                            processSpeed = 1.0,
                            qualityBoost = 0,
                            failChanceReduction = 0,
                            explosionChanceReduction = 0
                        }
                    },
                    {
                        level = 2,
                        price = 1000000,
                        benefits = {
                            processSpeed = 1.2,
                            qualityBoost = 10,
                            failChanceReduction = 10,
                            explosionChanceReduction = 10
                        }
                    },
                    {
                        level = 3,
                        price = 2000000,
                        benefits = {
                            processSpeed = 1.4,
                            qualityBoost = 20,
                            failChanceReduction = 20,
                            explosionChanceReduction = 20
                        }
                    }
                }
            },
            {
                name = "security",
                label = "System bezpieczeństwa",
                levels = {
                    {
                        level = 1,
                        price = 300000,
                        benefits = {
                            policeAlertChance = 0.5,
                            raidChance = 0.3,
                            securityTime = 30
                        }
                    },
                    {
                        level = 2,
                        price = 600000,
                        benefits = {
                            policeAlertChance = 0.3,
                            raidChance = 0.2,
                            securityTime = 45
                        }
                    },
                    {
                        level = 3,
                        price = 1200000,
                        benefits = {
                            policeAlertChance = 0.1,
                            raidChance = 0.1,
                            securityTime = 60
                        }
                    }
                }
            },
            {
                name = "staff",
                label = "Personel",
                levels = {
                    {
                        level = 1,
                        price = 400000,
                        benefits = {
                            productionSpeed = 1.0,
                            autoProduction = false,
                            staffEfficiency = 0.8
                        }
                    },
                    {
                        level = 2,
                        price = 800000,
                        benefits = {
                            productionSpeed = 1.2,
                            autoProduction = true,
                            staffEfficiency = 0.9
                        }
                    },
                    {
                        level = 3,
                        price = 1600000,
                        benefits = {
                            productionSpeed = 1.4,
                            autoProduction = true,
                            staffEfficiency = 1.0
                        }
                    }
                }
            }
        },
        equipmentRequired = {
            "basic_chemicals",
            "acid",
            "beaker",
            "distilling_kit"
        },
        drugs = {
            "weed",
            "cocaine",
            "meth",
            "heroin",
            "lsd",
            "ecstasy",
            "synthetic_cannabinoids"
        }
    },
    {
        name = "lab_2",
        label = "Laboratorium w Grapeseed",
        coords = vector3(1687.0, 4865.0, 42.0),
        price = 1500000,
        upgrades = {
            {
                name = "equipment",
                label = "Sprzęt laboratoryjny",
                levels = {
                    {
                        level = 1,
                        price = 750000,
                        benefits = {
                            processSpeed = 1.1,
                            qualityBoost = 5,
                            failChanceReduction = 5,
                            explosionChanceReduction = 5
                        }
                    },
                    {
                        level = 2,
                        price = 1500000,
                        benefits = {
                            processSpeed = 1.3,
                            qualityBoost = 15,
                            failChanceReduction = 15,
                            explosionChanceReduction = 15
                        }
                    },
                    {
                        level = 3,
                        price = 3000000,
                        benefits = {
                            processSpeed = 1.5,
                            qualityBoost = 25,
                            failChanceReduction = 25,
                            explosionChanceReduction = 25
                        }
                    }
                }
            },
            {
                name = "security",
                label = "System bezpieczeństwa",
                levels = {
                    {
                        level = 1,
                        price = 450000,
                        benefits = {
                            policeAlertChance = 0.4,
                            raidChance = 0.25,
                            securityTime = 35
                        }
                    },
                    {
                        level = 2,
                        price = 900000,
                        benefits = {
                            policeAlertChance = 0.2,
                            raidChance = 0.15,
                            securityTime = 50
                        }
                    },
                    {
                        level = 3,
                        price = 1800000,
                        benefits = {
                            policeAlertChance = 0.05,
                            raidChance = 0.05,
                            securityTime = 75
                        }
                    }
                }
            },
            {
                name = "staff",
                label = "Personel",
                levels = {
                    {
                        level = 1,
                        price = 600000,
                        benefits = {
                            productionSpeed = 1.1,
                            autoProduction = false,
                            staffEfficiency = 0.85
                        }
                    },
                    {
                        level = 2,
                        price = 1200000,
                        benefits = {
                            productionSpeed = 1.3,
                            autoProduction = true,
                            staffEfficiency = 0.95
                        }
                    },
                    {
                        level = 3,
                        price = 2400000,
                        benefits = {
                            productionSpeed = 1.5,
                            autoProduction = true,
                            staffEfficiency = 1.1
                        }
                    }
                }
            }
        },
        equipmentRequired = {
            "basic_chemicals",
            "acid",
            "beaker",
            "distilling_kit",
            "advanced_chemicals",
            "vacuum_bag"
        },
        drugs = {
            "weed",
            "cocaine",
            "meth",
            "heroin",
            "lsd",
            "ecstasy",
            "mushrooms",
            "synthetic_cannabinoids"
        }
    }
}

-- Konfiguracja sprzedawców
Config.Dealers = {
    {
        name = "dealer_1",
        label = "Dealer 1",
        coords = vector3(123.0, 456.0, 789.0),
        heading = 90.0,
        model = "g_m_y_mexgoon_01",
        workingHours = {
            start = 20, -- 20:00
            finish = 4   -- 04:00
        },
        drugs = {
            "weed",
            "coke",
            "meth"
        },
        qualityCheck = true,
        priceBoost = 1.2,
        stealChance = 0.15, -- 15% szansa na kradzież
        stealAmount = {
            min = 1,
            max = 3
        },
        runSpeed = 1.0, -- Prędkość ucieczki dealera
        surrenderDistance = 10.0, -- Odległość w której dealer się podda
        searchItems = { -- Przedmioty które dealer może mieć przy sobie
            "weed",
            "coke",
            "meth",
            "money",
            "phone"
        }
    },
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
        drugs = {'cocaine', 'meth', 'heroin', 'lsd', 'ecstasy', 'synthetic_cannabinoids'},
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

-- System reputacji z dealerami
Config.Reputation = {
    -- Poziomy reputacji
    levels = {
        {name = "Nieznany", minPoints = 0, priceMultiplier = 1.0, maxItems = 1},
        {name = "Nowy klient", minPoints = 100, priceMultiplier = 1.1, maxItems = 2},
        {name = "Stały klient", minPoints = 500, priceMultiplier = 1.2, maxItems = 3},
        {name = "Zaufany klient", minPoints = 1000, priceMultiplier = 1.3, maxItems = 4},
        {name = "VIP", minPoints = 2000, priceMultiplier = 1.5, maxItems = 5}
    },
    -- Punkty za różne akcje
    points = {
        successfulSale = 10,
        failedSale = -5,
        attemptedScam = -50,
        largeSale = 25, -- za sprzedaż powyżej 10 sztuk
        regularCustomer = 5 -- bonus za regularne transakcje
    }
}

-- System transportu
Config.Transport = {
    -- Kurierzy
    couriers = {
        {
            name = "courier_1",
            label = "Początkujący kurier",
            price = 1000,
            capacity = 5,
            speed = 1.0,
            reliability = 0.7
        },
        {
            name = "courier_2",
            label = "Doświadczony kurier",
            price = 2500,
            capacity = 10,
            speed = 1.2,
            reliability = 0.85
        },
        {
            name = "courier_3",
            label = "Profesjonalny kurier",
            price = 5000,
            capacity = 20,
            speed = 1.5,
            reliability = 0.95
        }
    },
    -- Konwoje
    convoys = {
        {
            name = "convoy_1",
            label = "Mały konwój",
            price = 5000,
            capacity = 30,
            guards = 2,
            vehicles = 1,
            reliability = 0.8
        },
        {
            name = "convoy_2",
            label = "Średni konwój",
            price = 10000,
            capacity = 60,
            guards = 4,
            vehicles = 2,
            reliability = 0.9
        },
        {
            name = "convoy_3",
            label = "Duży konwój",
            price = 20000,
            capacity = 100,
            guards = 6,
            vehicles = 3,
            reliability = 0.95
        }
    },
    -- Kontrole policyjne
    policeChecks = {
        chance = 0.2, -- 20% szansa na kontrolę
        checkPoints = {
            vector3(123.0, 456.0, 789.0),
            vector3(234.0, 567.0, 890.0),
            vector3(345.0, 678.0, 901.0)
        },
        detectionChance = {
            noHide = 1.0, -- 100% szansa wykrycia bez ukrycia
            basicHide = 0.5, -- 50% szansa przy podstawowym ukryciu
            advancedHide = 0.2 -- 20% szansa przy zaawansowanym ukryciu
        }
    },
    -- Miejsca ukrycia w pojeździe
    hidingSpots = {
        {
            name = "basic_hide",
            label = "Podstawowe ukrycie",
            price = 1000,
            detectionChance = 0.5,
            capacity = 5
        },
        {
            name = "advanced_hide",
            label = "Zaawansowane ukrycie",
            price = 5000,
            detectionChance = 0.2,
            capacity = 15
        },
        {
            name = "professional_hide",
            label = "Profesjonalne ukrycie",
            price = 15000,
            detectionChance = 0.1,
            capacity = 30
        }
    }
}

-- System bezpieczeństwa
Config.Security = {
    -- Alarmy
    alarms = {
        {
            name = "basic_alarm",
            label = "Podstawowy alarm",
            price = 5000,
            detectionRange = 30.0,
            policeAlertChance = 0.7,
            alertTime = 300 -- 5 minut
        },
        {
            name = "advanced_alarm",
            label = "Zaawansowany alarm",
            price = 15000,
            detectionRange = 50.0,
            policeAlertChance = 0.9,
            alertTime = 600 -- 10 minut
        },
        {
            name = "professional_alarm",
            label = "Profesjonalny alarm",
            price = 30000,
            detectionRange = 100.0,
            policeAlertChance = 1.0,
            alertTime = 900 -- 15 minut
        }
    },
    -- Ochrona
    guards = {
        {
            name = "guard_1",
            label = "Początkujący ochroniarz",
            price = 1000,
            skill = 0.7,
            weapons = {"WEAPON_PISTOL"}
        },
        {
            name = "guard_2",
            label = "Doświadczony ochroniarz",
            price = 2500,
            skill = 0.85,
            weapons = {"WEAPON_PISTOL", "WEAPON_SMG"}
        },
        {
            name = "guard_3",
            label = "Elitarny ochroniarz",
            price = 5000,
            skill = 1.0,
            weapons = {"WEAPON_PISTOL", "WEAPON_SMG", "WEAPON_CARBINERIFLE"}
        }
    },
    -- Monitoring
    cameras = {
        {
            name = "basic_camera",
            label = "Podstawowa kamera",
            price = 2000,
            range = 20.0,
            nightVision = false,
            motionDetection = false
        },
        {
            name = "advanced_camera",
            label = "Zaawansowana kamera",
            price = 5000,
            range = 40.0,
            nightVision = true,
            motionDetection = true
        },
        {
            name = "professional_camera",
            label = "Profesjonalna kamera",
            price = 10000,
            range = 60.0,
            nightVision = true,
            motionDetection = true,
            facialRecognition = true
        }
    },
    -- Pułapki
    traps = {
        {
            name = "gas_trap",
            label = "Pułapka gazowa",
            price = 3000,
            damage = 50,
            range = 10.0,
            cooldown = 300 -- 5 minut
        },
        {
            name = "electric_trap",
            label = "Pułapka elektryczna",
            price = 5000,
            damage = 75,
            range = 15.0,
            cooldown = 600 -- 10 minut
        },
        {
            name = "explosive_trap",
            label = "Pułapka wybuchowa",
            price = 10000,
            damage = 100,
            range = 20.0,
            cooldown = 900 -- 15 minut
        }
    }
} 
-- Konfiguracja lokalizacji zbierania i przetwarzania
Config.Locations = {
    ['synthetic_cannabinoids'] = {
        harvest = {
            -- Lokalizacje zbierania prekursorów chemicznych (tajne laboratoria chemiczne, magazyny)
            {
                coords = vector3(1905.32, 4925.45, 48.87),
                label = "Opuszczony magazyn chemiczny"
            },
            {
                coords = vector3(2433.75, 4969.22, 46.81),
                label = "Stara fabryka"
            },
            {
                coords = vector3(1569.11, 2220.77, 78.82),
                label = "Ukryte składowisko"
            }
        },
        process = {
            -- Lokalizacje przetwarzania (wymaga laboratorium)
            -- Przetwarzanie odbywa się głównie w laboratoriach graczy
        },
        package = {
            -- Lokalizacje pakowania
            {
                coords = vector3(1971.22, 3816.38, 33.43),
                label = "Punkt pakowania - Sandy Shores"
            },
            {
                coords = vector3(1653.89, 4853.27, 42.02),
                label = "Punkt pakowania - Grapeseed"
            }
        }
    }
}
