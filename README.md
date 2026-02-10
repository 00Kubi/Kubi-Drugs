# Kubi-Drugs

Zaawansowany system narkotyków dla FiveM z QBCore Framework.

## 🌟 Funkcje

### 🏭 System Laboratoriów
- Możliwość zakupu laboratoriów w różnych lokalizacjach
- System ulepszeń (sprzęt, bezpieczeństwo, personel)
- Realistyczna produkcja narkotyków
- System jakości produktów
- System rajdów policji
- Możliwość eksplozji podczas produkcji

### 💊 Narkotyki
- Marihuana (uprawa, przetwarzanie, pakowanie)
- Kokaina (zbieranie, przetwarzanie, pakowanie)
- Metaamfetamina (produkcja, pakowanie)
- Heroina (produkcja, pakowanie)
- LSD (produkcja, pakowanie)
- Ecstasy (produkcja, pakowanie)
- Grzyby halucynogenne (zbieranie, przetwarzanie)
- **🆕 Syntetyczne Kannabinoidy** (zaawansowana produkcja wieloetapowa)
  - Najbardziej złożony narkotyk w systemie
  - 5-etapowy proces produkcji: synteza → reakcja → stabilizacja → nasączanie → pakowanie
  - Wymaga laboratorium poziomu 2 lub wyższego
  - Najwyższe ceny sprzedaży ($5000-$7500)
  - Wysoka szansa niepowodzenia (30%) i eksplozji (25%)
  - Wrażliwość na temperaturę podczas produkcji

### 🛠️ System Produkcji
- Wymagane przedmioty do produkcji
- System szans na sukces
- System jakości produktów (słaba, standardowa, wysoka, premium)
- Realistyczne czasy produkcji
- System eksplozji i awarii

### 🏪 System Sprzedaży
- Sprzedaż dealerom
- System jakości i cen
- System szans na sukces
- System wezwań policji
- System rajdów

## 📋 Wymagania
- QBCore Framework
- oxmysql
- qb-target
- qb-menu
- qb-input

## 🔧 Instalacja
1. Pobierz skrypt
2. Umieść folder `kubi-drugs` w `resources`
3. Dodaj `ensure kubi-drugs` do `server.cfg`
4. Zaimportuj `kubi-drugs.sql` do bazy danych
5. Zrestartuj serwer

## ⚙️ Konfiguracja
Skrypt jest w pełni konfigurowalny w pliku `config.lua`. Możesz dostosować:
- Ceny laboratoriów i ulepszeń
- Czasy produkcji
- Szanse na sukces
- Jakość produktów
- Ceny sprzedaży
- I wiele więcej!

## 🎮 Użycie
1. Kup laboratorium w wybranej lokalizacji
2. Ulepsz je według potrzeb
3. Zbierz wymagane przedmioty
4. Rozpocznij produkcję
5. Sprzedawaj produkty dealerom

## 🧪 Syntetyczne Kannabinoidy - Przewodnik

### Wymagania
- Laboratorium poziomu 2 lub wyższego
- Zaawansowany sprzęt laboratoryjny:
  - Zlewki (beaker)
  - Probówki (test_tube)
  - Palnik Bunsena (bunsen_burner)
  - Zestaw do destylacji (distilling_kit)
  - Filtry laboratoryjne (filter)

### Proces Produkcji (5 etapów)

#### Etap 1: Zbieranie Prekursorów
Odwiedź jedną z lokalizacji zbierania:
- Opuszczony magazyn chemiczny
- Stara fabryka
- Ukryte składowisko

Zebrane: `chemical_precursor` (1-3 sztuki)

#### Etap 2: Synteza Podstawowej Struktury
Wymagane przedmioty:
- 3x chemical_precursor
- 2x basic_chemicals
- 2x solvent
- 1x beaker (zwracany)
- 1x test_tube (zwracany)

Rezultat: `synthetic_base`

#### Etap 3: Reakcja Łańcuchowa
Wymagane przedmioty:
- 1x synthetic_base
- 1x lithium
- 1x acetone
- 1x bunsen_burner (zwracany)
- 1x beaker (zwracany)

Rezultat: `synthetic_compound`

⚠️ **UWAGA**: Ten etap jest niebezpieczny! Ryzyko eksplozji 25%

#### Etap 4: Stabilizacja i Oczyszczanie
Wymagane przedmioty:
- 1x synthetic_compound
- 1x lye
- 1x filter
- 1x distilling_kit (zwracany)

Rezultat: `synthetic_pure`

#### Etap 5: Aplikacja na Nośnik
Wymagane przedmioty:
- 1x synthetic_pure
- 1x solvent
- 5x carrier_herb

Rezultat: `synthetic_infused` (3 sztuki)

#### Etap 6: Pakowanie
##### Standardowe:
- 2x synthetic_infused
- 1x plastic_bag

Rezultat: `synthetic_packaged`

##### Premium (E-liquid):
- 1x synthetic_pure
- 3x vape_liquid_base
- 1x vacuum_bag
- 1x beaker (zwracany)

Rezultat: `synthetic_vape`

### Wskazówki
- Zawsze miej zapasowy sprzęt - eksplozje są częste!
- Lepszy poziom laboratorium zmniejsza ryzyko niepowodzenia
- Premium pakowanie (vape) osiąga najwyższe ceny
- Proces wymaga cierpliwości - łączny czas produkcji to około 5-6 minut

## 📸 Zrzuty ekranu
*Dodaj zrzuty ekranu z gry*

## 🤝 Wsparcie
W razie problemów lub pytań, skontaktuj się z nami na Discordzie.

## 📜 Licencja
Ten projekt jest objęty licencją MIT. Zobacz plik `LICENSE` aby uzyskać więcej informacji.

## 👥 Autorzy
- Kubi
- *Dodaj innych autorów jeśli są*

## 🙏 Podziękowania
- QBCore Team
- Wszystkim testerom i osobom, które pomogły w rozwoju skryptu 