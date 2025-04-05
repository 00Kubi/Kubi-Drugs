Config = {}

-- Ogólne ustawienia
Config.Debug = false -- Tryb debugowania
Config.UseTarget = true -- Używa qb-target zamiast tekstu 3D

-- Ustawienia narkotyków
Config.Drugs = {
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
            package = {
                {name = 'weed_processed', amount = 3},
                {name = 'plastic_bag', amount = 1}
            }
        },
        rewardItems = {
            harvest = {
                {name = 'weed_leaf', amount = {min = 2, max = 5}}
            },
            process = {
                {name = 'weed_processed', amount = 3}
            },
            package = {
                {name = 'weed_packaged', amount = 1}
            }
        }
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
            package = {
                {name = 'cocaine_processed', amount = 2},
                {name = 'plastic_bag', amount = 1}
            }
        },
        rewardItems = {
            harvest = {
                {name = 'cocaine_leaf', amount = {min = 2, max = 4}}
            },
            process = {
                {name = 'cocaine_processed', amount = 2}
            },
            package = {
                {name = 'cocaine_packaged', amount = 1}
            }
        }
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
                {name = 'chemicals', amount = 2}
            },
            package = {
                {name = 'meth_processed', amount = 2},
                {name = 'plastic_bag', amount = 1}
            }
        },
        rewardItems = {
            harvest = {
                {name = 'meth_raw', amount = {min = 2, max = 4}}
            },
            process = {
                {name = 'meth_processed', amount = 2}
            },
            package = {
                {name = 'meth_packaged', amount = 1}
            }
        }
    }
}

-- Konfiguracja sprzedawców
Config.Dealers = {
    {
        coords = vector4(384.52, -761.65, 29.29, 359.26),
        ped = 'a_m_y_downtown_01',
        scenario = 'WORLD_HUMAN_SMOKING',
        drugs = {'weed', 'cocaine', 'meth'},
        hours = {
            from = 18,
            to = 23
        }
    },
    {
        coords = vector4(-1190.25, -397.74, 37.01, 264.53),
        ped = 'a_m_y_hipster_01',
        scenario = 'WORLD_HUMAN_LEANING',
        drugs = {'weed', 'cocaine'},
        hours = {
            from = 9,
            to = 18
        }
    },
    {
        coords = vector4(974.77, -1711.97, 30.89, 352.91),
        ped = 's_m_y_dealer_01',
        scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        drugs = {'cocaine', 'meth'},
        hours = {
            from = 0,
            to = 24
        }
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