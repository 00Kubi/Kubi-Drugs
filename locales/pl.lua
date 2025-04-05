local Translations = {
    error = {
        not_enough_police = 'Za mało policjantów na służbie',
        no_required_items = 'Brakuje Ci wymaganych przedmiotów',
        no_space_inventory = 'Nie masz wystarczająco miejsca w ekwipunku',
        already_harvesting = 'Już zbierasz narkotyki',
        already_processing = 'Już przetwarzasz narkotyki',
        already_packaging = 'Już pakujesz narkotyki',
        process_canceled = 'Przerwano proces',
        not_enough_materials = 'Nie masz wystarczającej ilości materiałów',
        no_drugs_to_sell = 'Nie masz żadnych narkotyków na sprzedaż',
        nobody_wants_to_buy = 'Nikt nie chce teraz kupić narkotyków',
        dealer_unavailable = 'Dealer nie jest obecnie dostępny',
        invalid_security_token = 'Błąd bezpieczeństwa: nieprawidłowy token',
        security_error = 'Wykryto próbę manipulacji. Zgłoszono do administracji.',
        dealer_busy = 'Ten dealer jest zajęty. Spróbuj ponownie za chwilę.',
        not_in_zone = 'Nie jesteś w odpowiedniej strefie'
    },
    success = {
        harvested = 'Zebrałeś %{amount}x %{item}',
        processed = 'Przetworzyłeś %{amount}x %{item}',
        packaged = 'Zapakowałeś %{amount}x %{item}',
        sold_drugs = 'Sprzedałeś %{amount}x %{item} za $%{money}'
    },
    info = {
        harvesting = 'Zbieranie...',
        processing = 'Przetwarzanie...',
        packaging = 'Pakowanie...',
        drug_deal = 'Negocjowanie ceny...',
        dealer_blip = 'Dealer narkotyków',
        harvest_blip = 'Miejsce zbioru',
        process_blip = 'Miejsce przetwarzania',
        package_blip = 'Miejsce pakowania',
    },
    target = {
        harvest = 'Zbieraj',
        process = 'Przetwarzaj',
        package = 'Pakuj',
        talk_dealer = 'Rozmawiaj z dealerem'
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
}) 