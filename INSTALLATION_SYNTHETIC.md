# Instalacja Syntetycznych Kannabinoidów

Ten przewodnik opisuje jak zainstalować nowy zaawansowany system syntetycznych kannabinoidów w Twoim serwerze FiveM.

## Krok 1: Aktualizacja items.lua w QBCore

Otwórz plik `qb-core/shared/items.lua` i dodaj zawartość z pliku `items_synthetic_cannabinoids.lua` do Twojej listy items.

Możesz skopiować całą zawartość i wkleić ją w odpowiednim miejscu w pliku items.lua.

## Krok 2: Dodanie obrazków przedmiotów

Musisz dodać obrazki dla nowych przedmiotów do folderu `qb-inventory/html/images/`:

Wymagane obrazki:
- `chemical_precursor.png` - Prekursor chemiczny
- `carrier_herb.png` - Zioło nośnikowe
- `vape_liquid_base.png` - Baza do e-liquidu
- `synthetic_base.png` - Podstawa syntetyczna
- `synthetic_compound.png` - Związek syntetyczny
- `synthetic_pure.png` - Czysty syntetyczny kannabinoid
- `synthetic_infused.png` - Nasączone zioło syntetyczne
- `synthetic_packaged.png` - Syntetyczne kannabinoidy (zapakowane)
- `synthetic_vape.png` - E-liquid syntetyczny (Premium)

**Wskazówka:** Możesz użyć istniejących obrazków jako tymczasowe placeholdery lub stworzyć własne grafiki.

## Krok 3: Restart serwera

Po dodaniu items i obrazków, zrestartuj serwer:
```
restart qb-core
restart qb-inventory
restart kubi-drugs
```

## Krok 4: Weryfikacja

Po restarcie sprawdź czy:
1. Wszystkie przedmioty są dostępne w grze
2. Obrazki wyświetlają się prawidłowo
3. Lokalizacje zbierania są dostępne na mapie
4. Menu laboratorium pokazuje opcje dla syntetycznych kannabinoidów

## Znane problemy i rozwiązania

### Problem: Przedmioty nie pojawiają się w ekwipunku
**Rozwiązanie:** Upewnij się, że dodałeś wszystkie items do `qb-core/shared/items.lua` i zrestartowałeś `qb-core`.

### Problem: Brak obrazków w ekwipunku
**Rozwiązanie:** Sprawdź czy obrazki znajdują się w `qb-inventory/html/images/` i mają poprawne nazwy.

### Problem: Menu laboratorium nie pokazuje syntetycznych kannabinoidów
**Rozwiązanie:** 
1. Sprawdź czy Twoje laboratorium ma poziom 2 lub wyższy
2. Upewnij się, że `kubi-drugs` został poprawnie zrestartowany
3. Sprawdź logi serwera pod kątem błędów

## Konfiguracja (opcjonalna)

Możesz dostosować parametry syntetycznych kannabinoidów w pliku `config.lua`:

- `failChance` - Szansa na niepowodzenie produkcji (domyślnie 30%)
- `explodeChance` - Szansa na eksplozję (domyślnie 25%)
- `processTime` - Czas przetwarzania w sekundach (domyślnie 150s)
- `sellPrice` - Zakres cen sprzedaży (domyślnie $5000-$7500)
- `minLabLevel` - Minimalny poziom laboratorium (domyślnie 2)

## Wsparcie

Jeśli napotkasz problemy podczas instalacji, sprawdź:
1. Logi serwera (`server.log` i `F8 console`)
2. Czy wszystkie zależności są zainstalowane (qb-core, qb-target, qb-menu, qb-input)
3. Czy skrypt `kubi-drugs` jest poprawnie dodany do `server.cfg`

## Changelog

### v1.0.0 (2026-02-10)
- ✅ Dodano syntetyczne kannabinoidy jako nowy zaawansowany narkotyk
- ✅ 5-etapowy proces produkcji
- ✅ Wymóg laboratorium poziomu 2+
- ✅ Najwyższe ceny sprzedaży w systemie
- ✅ System wrażliwości na temperaturę
- ✅ Wysokie ryzyko eksplozji i niepowodzenia
