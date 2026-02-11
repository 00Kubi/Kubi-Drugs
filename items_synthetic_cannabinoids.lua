-- Items dla Syntetycznych Kannabinoidów
-- Dodaj te przedmioty do qb-core/shared/items.lua

-- CHEMIKALIA I SKŁADNIKI
['chemical_precursor'] = {
    name = 'chemical_precursor',
    label = 'Prekursor chemiczny',
    weight = 75,
    type = 'item',
    image = 'chemical_precursor.png',
    unique = false,
    useable = false,
    shouldClose = false,
    combinable = nil,
    description = 'Rzadki prekursor używany do syntezy zaawansowanych substancji.'
},
['carrier_herb'] = {
    name = 'carrier_herb',
    label = 'Zioło nośnikowe',
    weight = 30,
    type = 'item',
    image = 'carrier_herb.png',
    unique = false,
    useable = false,
    shouldClose = false,
    combinable = nil,
    description = 'Neutralne zioło używane jako nośnik dla substancji aktywnych.'
},
['vape_liquid_base'] = {
    name = 'vape_liquid_base',
    label = 'Baza do e-liquidu',
    weight = 100,
    type = 'item',
    image = 'vape_liquid_base.png',
    unique = false,
    useable = false,
    shouldClose = false,
    combinable = nil,
    description = 'Płynna baza używana do tworzenia e-liquidów.'
},

-- PRODUKTY POŚREDNIE
['synthetic_base'] = {
    name = 'synthetic_base',
    label = 'Podstawa syntetyczna',
    weight = 50,
    type = 'item',
    image = 'synthetic_base.png',
    unique = false,
    useable = false,
    shouldClose = false,
    combinable = nil,
    description = 'Podstawowa struktura syntetycznych kannabinoidów.'
},
['synthetic_compound'] = {
    name = 'synthetic_compound',
    label = 'Związek syntetyczny',
    weight = 60,
    type = 'item',
    image = 'synthetic_compound.png',
    unique = false,
    useable = false,
    shouldClose = false,
    combinable = nil,
    description = 'Niestabilny związek syntetyczny po reakcji łańcuchowej.'
},
['synthetic_pure'] = {
    name = 'synthetic_pure',
    label = 'Czysty syntetyczny kannabinoid',
    weight = 40,
    type = 'item',
    image = 'synthetic_pure.png',
    unique = false,
    useable = false,
    shouldClose = false,
    combinable = nil,
    description = 'Wysoce oczyszczona substancja syntetyczna.'
},
['synthetic_infused'] = {
    name = 'synthetic_infused',
    label = 'Nasączone zioło syntetyczne',
    weight = 45,
    type = 'item',
    image = 'synthetic_infused.png',
    unique = false,
    useable = false,
    shouldClose = false,
    combinable = nil,
    description = 'Zioło nośnikowe nasączone syntetycznymi kannabinoidami.'
},

-- PRODUKTY FINALNE
['synthetic_packaged'] = {
    name = 'synthetic_packaged',
    label = 'Syntetyczne kannabinoidy',
    weight = 50,
    type = 'item',
    image = 'synthetic_packaged.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Zapakowane syntetyczne kannabinoidy gotowe do sprzedaży.'
},
['synthetic_vape'] = {
    name = 'synthetic_vape',
    label = 'E-liquid syntetyczny (Premium)',
    weight = 60,
    type = 'item',
    image = 'synthetic_vape.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Premium e-liquid z syntetycznymi kannabinoidami. Najwyższa jakość.'
},
