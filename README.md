# Kubi-Drugs

System narkotyków dla serwera FiveM opartego na frameworku QBCore, umożliwiający zbieranie, przetwarzanie, pakowanie i sprzedaż różnych rodzajów narkotyków z zabezpieczeniami po stronie serwera.

## Funkcje

- **Zaawansowane zabezpieczenia serwerowe**: 
  - System tokenów bezpieczeństwa zapobiegający oszustwom i wstrzykiwaniu eventów
  - Zaszyfrowane lokalizacje przechowywane wyłącznie po stronie serwera
  - Indywidualny klucz szyfrowania dla każdego gracza
  - Ochrona przed dump'owaniem lokalizacji
- **Trzy rodzaje narkotyków**: Marihuana, Kokaina i Metamfetamina
- **Pełny cykl produkcyjny**: Zbieranie, przetwarzanie, pakowanie i sprzedaż
- **Konfigurowalny system dealerów**: Dealerzy z własnymi godzinami pracy i obsługiwanymi narkotykami
- **Integracja z policją**: Możliwość wezwania policji podczas sprzedaży narkotyków
- **Interaktywne menu**: Proste w obsłudze menu dla wszystkich interakcji
- **Wsparcie dla qb-target**: Łatwe używanie systemu docelowania
- **W pełni konfigurowalne**: Łatwa zmiana wszystkich parametrów w pliku konfiguracyjnym

## Instalacja

1. Pobierz lub sklonuj repozytorium
2. Umieść folder `kubi-drugs` w katalogu `resources` serwera
3. Dodaj `ensure kubi-drugs` do pliku `server.cfg`
4. Opcjonalnie: Dostosuj ustawienia w pliku `config.lua`
5. Uruchom serwer

## Zależności

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/qbcore-framework/qb-target) (opcjonalnie, ale zalecane)
- [qb-menu](https://github.com/qbcore-framework/qb-menu)
- [oxmysql](https://github.com/overextended/oxmysql)

## Użytkowanie

### Zbieranie

1. Udaj się do jednej z lokalizacji zbierania zaznaczonych na mapie
2. Użyj systemu targetowania lub menu kontekstowego, aby rozpocząć zbieranie
3. Poczekaj, aż pasek postępu się zakończy
4. Otrzymasz surowe materiały do dalszej obróbki

### Przetwarzanie

1. Udaj się do jednej z lokalizacji przetwarzania zaznaczonych na mapie
2. Upewnij się, że masz wystarczającą ilość surowych materiałów
3. Użyj systemu targetowania lub menu kontekstowego, aby rozpocząć przetwarzanie
4. Poczekaj, aż pasek postępu się zakończy
5. Surowe materiały zostaną przetworzone

### Pakowanie

1. Udaj się do jednej z lokalizacji pakowania zaznaczonych na mapie
2. Upewnij się, że masz wystarczającą ilość przetworzonych narkotyków i woreczków foliowych
3. Użyj systemu targetowania lub menu kontekstowego, aby rozpocząć pakowanie
4. Poczekaj, aż pasek postępu się zakończy
5. Otrzymasz zapakowane narkotyki gotowe do sprzedaży

### Sprzedaż

1. Udaj się do jednego z dealerów zaznaczonych na mapie
2. Upewnij się, że jest w godzinach pracy dealera
3. Rozpocznij rozmowę z dealerem
4. Wybierz narkotyk, który chcesz sprzedać
5. Ukończ transakcję i otrzymaj pieniądze

## Konfiguracja

Wszystkie ustawienia można modyfikować w pliku `config.lua`:

- **Config.Debug** - Tryb debugowania
- **Config.UseTarget** - Używa qb-target zamiast tekstu 3D
- **Config.Drugs** - Konfiguracja narkotyków (czasy, ceny, itd.)
- **Config.Dealers** - Konfiguracja dealerów
- **Config.MinCops** - Minimalna liczba policjantów na służbie
- **Config.PoliceCallChance** - Szansa na wezwanie policji
- **Config.SecurityTokenExpiry** - Czas ważności tokenu bezpieczeństwa
- **Config.MaxAllowedErrors** - Maksymalna liczba błędów przed wyrzuceniem gracza
- **Config.BanOnSuspectedCheating** - Czy banować za próby oszustwa

## Zabezpieczenia

Skrypt zawiera zaawansowane zabezpieczenia po stronie serwera:

- System tokenów bezpieczeństwa do autoryzacji każdego żądania
- Lokalizacje narkotyków przechowywane wyłącznie po stronie serwera
- Dynamiczne szyfrowanie współrzędnych z unikalnym kluczem dla każdego gracza
- Pobieranie tylko niezbędnych danych lokalizacji na żądanie
- Weryfikacja pozycji gracza w momencie wykonywania akcji
- Wykrywanie i logowanie prób manipulacji
- Automatyczne wyrzucanie/banowanie graczy próbujących oszukiwać
- Pełne logowanie incydentów bezpieczeństwa
- Ochrona przed dump'owaniem danych serwera

## Autorzy

- **Kubi** - Główny twórca

## Licencja

Ten projekt jest objęty licencją MIT - szczegóły w pliku LICENSE. 