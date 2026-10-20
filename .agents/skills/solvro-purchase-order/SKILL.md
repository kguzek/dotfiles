---
name: solvro-purchase-order
description: >-
  Draft Polish purchase order requests to PWr (zamówienia zakupu) only when
  requested for KN Solvro, explicitly or in established context. Use for emails
  to zamowienia.dst@pwr.edu.pl based on an obtained supplier offer. Not for
  quotation requests, direct orders to suppliers, or other organizations.
---

# Zamówienia zakupu przez PWr dla KN Solvro

## Zakres

Stosuj ten skill do przygotowania lub poprawienia maila o realizację zakupu
dla Koła Naukowego Solvro z budżetu przechowywanego na Politechnice
Wrocławskiej, z reguły rozliczanego przez DWAS. Sama wzmianka o Solvro albo
prośba o zamówienie bez ustalonego kontekstu Solvro nie wystarcza do aktywacji.
Nie stosuj go do zamówień z innego budżetu ani zamówień bezpośrednio u dostawcy.

To etap po uzyskaniu oferty od kontrahenta. Jeśli użytkownik dopiero chce
uzyskać wycenę, zastosuj skill `solvro-request-for-quotation`.

Pisz po polsku, zwięźle, uprzejmie i rzeczowo. Przygotowanie wiadomości nie
oznacza zgody na jej wysłanie, zaciągnięcie zobowiązania ani dokonanie zakupu.
Nie przedstawiaj przygotowanego maila jako oficjalnego „Zamówienia zakupu”
wystawionego przez PWr ani potwierdzenia akceptacji wydatku.

## Źródło i podstawa szablonu

Korzystaj z formułki w punkcie 4 „Złożenie zamówienia” procedury Solvro:
https://docs.solvro.pl/sections/management/processes/purchase-pwr/#procedura

Zachowaj jej strukturę z dostosowaniami użytkownika: projekt i uzasadnienie,
informacja o ofercie i załącznikach, podmiot, finansowanie, pozycja budżetowa,
kontrahent, dostawa, warunki płatności i ważność oferty. Nie wymagaj wskazania
osoby odpowiedzialnej za rozliczenie ani jej danych i nie dodawaj tego pola
domyślnie. Pozycje zakupowe, ilości, ceny i VAT mają znajdować się w załączniku
PDF, bez przepisywania ich do maila. Są to dostosowania tego skilla, nie opis
wymogów procedury PWr. Nie zastępuj formułki ogólnym mailem zakupowym.

Numery finansowania w poradniku są przykładami. W tym skillu zawsze używaj
projektu `91KS/0030/26` i zadania `0000360/2026`, zgodnie z ustaleniem
użytkownika, zamiast kopiować przykładowe numery ze źródła.

W razie potrzeby weryfikacji aktualności sprawdź również oficjalne źródła:
- https://dwas.pwr.edu.pl/finansowanie/dofinansowanie/jak-wydatkowac-otrzymane-srodki
- https://dwas.pwr.edu.pl/finansowanie/dokumenty-i-wzory-wnioskow

## Przygotowanie

1. Wykorzystaj dane użytkownika oraz dostarczoną ofertę lub proformę. Zbierz:
   - nazwę projektu, przedmiot zakupu i jego uzasadnienie;
   - ewentualny dodatkowy numer wniosku lub dofinansowania; zawsze stosuj
     numer projektu `91KS/0030/26` i numer zadania `0000360/2026`;
   - nazwę, adres, NIP, telefon i e-mail firmy realizującej zamówienie;
   - pozycję budżetową z tabeli „Środki w ramach budżetu Koła Strategicznego”
     zgodnie z sekcją poniżej;
   - koszt i formę dostawy, warunki płatności oraz ważność oferty;
   - potwierdzenie, że PDF z pozycjami zakupowymi, ilościami, cenami netto
     i brutto, sumami oraz VAT będzie załączony, i ewentualne załączniki specjalne.
2. Jeśli brakuje danych koniecznych do przygotowania kompletnego maila,
   zadaj krótkie, zbiorcze pytanie. Jeśli użytkownik chce szablon, użyj
   czytelnych pól do uzupełnienia zamiast wymyślać dane.
3. Nie dopisuj niepodanych cen, numerów finansowania, uzasadnień, terminów,
   danych kontaktowych, uzyskanych zgód ani załączników. Nie twierdź,
   że plik został załączony, jeśli nie został dostarczony lub potwierdzony.
4. Domyślnie przyjmij, że szczegółowe pozycje i kwoty będą w załączniku PDF,
   a nie w treści maila. Upewnij się u użytkownika, że dołączy taki PDF,
   lub przypomnij mu o jego dołączeniu przed wysłaniem. Nie wymagaj podania
   każdej pozycji i kwoty w rozmowie, jeśli potwierdzono ich obecność w PDF.
   Jeśli ofertę udostępniono, sprawdź ilości, ceny, VAT, sumy i ujęcie dostawy;
   rozbieżności wyjaśnij z użytkownikiem, bez samodzielnego poprawiania oferty.
5. Warunki płatności i termin ważności odczytaj z oferty, jeśli została
   udostępniona. Jeśli jej nie ma, jest nieczytelna lub brakuje tych informacji,
   zapytaj użytkownika o brakujące dane. Nie przyjmuj wartości domyślnych.
   Procedura preferuje przelew 14 dni
   od otrzymania faktury i ważność oferty co najmniej 14 dni. Nie zamieniaj
   innych warunków na preferowane bez potwierdzenia kontrahenta. W razie
   przedpłaty, wygasłej oferty lub krótszych terminów wskaż problem przed
   przygotowaniem finalnego maila i ustal dalsze postępowanie.
6. Wydatek wymaga konsultacji z osobą uprawnioną do wydatkowania budżetu
   (np. zarządem). Nie zakładaj, że taka konsultacja już nastąpiła.
   Procedura zaleca rozpoczęcie zakupu co najmniej miesiąc wcześniej;
   nie obiecuj daty realizacji przez PWr.

## Wybór pozycji budżetowej

Przed przypisaniem wydatku odczytaj aktualną tabelę pod nagłówkiem
„Środki w ramach budżetu Koła Strategicznego” na stronie:
https://docs.solvro.pl/solvro/ix_board

Wybierz pozycję wyłącznie z tej tabeli, nie z części dotyczącej MNiSW ani
innych źródeł finansowania. W mailu podaj numer i dokładną nazwę pozycji;
uwzględnij kontekst grupy (np. projekt lub wyjazd), jeśli jest potrzebny do
jednoznacznego wskazania. Nie myl pozycji budżetowej z pozycją oferty dostawcy.

Możesz samodzielnie dopasować pozycję do opisu i celu zakupu, jeśli jesteś
pewien jednoznacznego dopasowania. Przy kilku możliwych pozycjach, braku
dopasowania lub niedostępnej tabeli poproś użytkownika o wybór lub jej treść.
Nie wymyślaj numerów ani kategorii. Kwota w tabeli to planowany budżet,
nie cena zakupu ani potwierdzenie pozostałych do wydania środków.

## Załączniki specjalne

- **Każdy zakup:** oferta w PDF — eksport korespondencji, dokument ofertowy
  lub faktura proforma. Nie traktuj proformy jako faktury VAT do opłacenia.
- **Merch, wydruki i materiały promocyjne:** projekt graficzny z logotypami
  KN Solvro i PWr oraz potwierdzenie akceptacji przez `logotyp@pwr.edu.pl`.
- **Wyjazdy:** miejsce i data wyjazdu oraz lista osób z numerami indeksów.
  Zgodnie z procedurą dla każdego uczestnika potrzebne są dokumenty w wersji
  fizycznej i PDF: skierowanie na wyjazd, oświadczenie o zaniechaniu poboru
  podatku dochodowego, oświadczenie o miejscu zamieszkania do celów podatkowych
  oraz — dla biletów PKP/PKS — lista do wypłat. Dla wyjazdu powyżej 15 osób
  procedura dopuszcza skierowanie grupowe. Aktualne formularze sprawdź
  w źródłach zamiast wymyślać ich treść lub linki.

Nie dodawaj załączników specjalnych do zwykłego zakupu, którego nie dotyczą.

## Adresat i temat

Do: `zamowienia.dst@pwr.edu.pl`

Domyślny temat: `Zamówienie zakupu - {przedmiot zakupu} dla KN Solvro`

Używaj krótkiej nazwy przedmiotu i zwykłego łącznika `-`, analogicznie do
skilla zapytań ofertowych. To konwencja tego skilla, nie wymóg procedury PWr.
Jeśli użytkownik odpowiada w istniejącym wątku, zachowaj jego temat.

## Podstawa treści maila

Poniższy szablon uzupełnij rzeczywistymi danymi. Warianty w nawiasach
kwadratowych zastąp treścią lub usuń, jeśli nie dotyczą zakupu. Pola do
uzupełnienia pozostaw tylko wtedy, gdy użytkownik prosi o szablon.

```text
Szanowna Pani,

W ramach projektu {nazwa projektu} planujemy zakup {przedmiot zakupu}, który posłuży {uzasadnienie zakupu}.

W załączniku znajdą Państwo ofertę od wybranego kontrahenta w PDF, zawierającą pozycje zamówienia, ilości, ceny netto i brutto oraz VAT [oraz wymienione wymagane załączniki]. Szczegóły zamówienia:

Podmiot: Koło Naukowe Solvro

Numer projektu: 91KS/0030/26
Numer zadania: 0000360/2026
Pozycja budżetowa: {numer i dokładna nazwa z tabeli budżetu Koła Strategicznego}
[Numer wniosku i dofinansowania: dodatkowe dane, jeśli podano]
Firma realizująca zamówienie: {nazwa, adres, NIP, telefon, e-mail}

Koszt i forma dostawy: {koszt i sposób dostawy}
Warunki płatności: {warunki z oferty}
Ważność oferty: {termin z oferty}

[Dla wyjazdu: miejsce, data oraz lista osób z numerami indeksów.]

Z poważaniem,
```

Nie dodawaj tabeli pozycji zakupowych ani zestawienia kwot w treści maila —
odsyłaj do załączonego PDF. Dostosuj gramatykę wstępu do przedmiotu zakupu.

Jeżeli potrzebny jest adres dostawy kurierskiej, procedura wskazuje:
ul. Wybrzeże Stanisława Wyspiańskiego 40, 50-370 Wrocław, bud. H-14,
pok. 1.07. Nie myl go z adresem do faktury i nie nadpisuj innego adresu
wskazanego przez użytkownika bez wyjaśnienia.

## Zakończenie i format odpowiedzi

Zwróć adresata, temat oraz gotową do skopiowania treść maila, bez zbędnego
komentarza. Oddziel je od siebie. Nie umieszczaj instrukcji redakcyjnych
w gotowej wiadomości ani nie deklaruj, że mail został wysłany.

Ostatnia linia treści to dokładnie `Z poważaniem,`, poprzedzona pustą linią.
Nie dodawaj podpisu, linku do stopki Solvro ani placeholdera podpisu poniżej;
podpis automatycznie dodaje klient pocztowy, tak jak w skillu zapytań ofertowych.
Jeżeli potrzebne jest przypomnienie o PDF, umieść je krótko poza treścią maila,
nie poniżej „Z poważaniem,” wewnątrz wiadomości.

## Dalszy proces — tylko gdy użytkownik o niego pyta

Po przyjęciu wniosku PWr przekazuje numer procedowanego wniosku, a po ścieżce
administracyjnej oficjalne „Zamówienie zakupu”. Dopiero ten dokument przekazuje
się kontrahentowi jako podstawę realizacji i wystawienia faktury VAT.
Fakturę VAT przesyła się w wątku zamówienia. Brak odpowiedzi powyżej tygodnia
jest według procedury wskazaniem do przypomnienia się w tym samym wątku.
Nie twierdź, że którykolwiek z tych etapów nastąpił bez potwierdzenia.

## Kontrola przed oddaniem

- Czy zakup dotyczy Solvro i budżetu PWr, a nie dopiero uzyskania oferty?
- Czy mail bazuje na formułce z punktu 4 procedury, z właściwym adresatem?
- Czy są projekt, uzasadnienie, finansowanie i kontrahent, bez wymagania danych
  osoby rozliczającej?
- Czy podano dokładnie numer projektu `91KS/0030/26` i zadanie `0000360/2026`,
  bez pytania użytkownika o te stałe dane?
- Czy wybrano numer i nazwę pozycji z właściwej tabeli budżetu Koła Strategicznego,
  a w razie niepewności zapytano użytkownika?
- Czy szczegółowe pozycje i kwoty pozostają w PDF, a użytkownik potwierdził
  jego dołączenie lub otrzymał przypomnienie?
- Czy warunki płatności i ważność odczytano z udostępnionej oferty lub uzyskano
  od użytkownika, bez przyjmowania wartości domyślnych?
- Czy wskazane załączniki rzeczywiście istnieją i uwzględniono te specjalne?
- Czy nie zasugerowano, że mail jest już oficjalnym zamówieniem PWr?
- Czy treść kończy się osobną linią „Z poważaniem,” bez podpisu?
