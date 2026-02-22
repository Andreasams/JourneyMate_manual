
-- ============================================================
-- Phase 7.3.2: Search Page Keys (15 keys × 7 languages = 105 rows)
-- Added: 2026-02-22
-- ============================================================

-- Search bar and placeholders (5 keys)
INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('search_placeholder', 'en', 'Search for restaurants...', 'ui'),
  ('search_placeholder', 'da', 'Søg efter restauranter...', 'ui'),
  ('search_placeholder', 'de', 'Nach Restaurants suchen...', 'ui'),
  ('search_placeholder', 'fr', 'Rechercher des restaurants...', 'ui'),
  ('search_placeholder', 'it', 'Cerca ristoranti...', 'ui'),
  ('search_placeholder', 'no', 'Søk etter restauranter...', 'ui'),
  ('search_placeholder', 'sv', 'Sök efter restauranger...', 'ui')
;

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('search_no_results', 'en', 'No search results', 'ui'),
  ('search_no_results', 'da', 'Ingen søgeresultater', 'ui'),
  ('search_no_results', 'de', 'Keine Suchergebnisse', 'ui'),
  ('search_no_results', 'fr', 'Aucun résultat de recherche', 'ui'),
  ('search_no_results', 'it', 'Nessun risultato di ricerca', 'ui'),
  ('search_no_results', 'no', 'Ingen søkeresultater', 'ui'),
  ('search_no_results', 'sv', 'Inga sökresultat', 'ui')
;

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('search_error_retry', 'en', 'Try again', 'ui'),
  ('search_error_retry', 'da', 'Prøv igen', 'ui'),
  ('search_error_retry', 'de', 'Erneut versuchen', 'ui'),
  ('search_error_retry', 'fr', 'Réessayer', 'ui'),
  ('search_error_retry', 'it', 'Riprova', 'ui'),
  ('search_error_retry', 'no', 'Prøv igjen', 'ui'),
  ('search_error_retry', 'sv', 'Försök igen', 'ui')
;

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('search_clear_text', 'en', 'Clear text', 'ui'),
  ('search_clear_text', 'da', 'Ryd tekst', 'ui'),
  ('search_clear_text', 'de', 'Text löschen', 'ui'),
  ('search_clear_text', 'fr', 'Effacer le texte', 'ui'),
  ('search_clear_text', 'it', 'Cancella testo', 'ui'),
  ('search_clear_text', 'no', 'Fjern tekst', 'ui'),
  ('search_clear_text', 'sv', 'Rensa text', 'ui')
;

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('search_no_results_with_query', 'en', 'No results for ''{query}''', 'ui'),
  ('search_no_results_with_query', 'da', 'Ingen resultater for ''{query}''', 'ui'),
  ('search_no_results_with_query', 'de', 'Keine Ergebnisse für ''{query}''', 'ui'),
  ('search_no_results_with_query', 'fr', 'Aucun résultat pour ''{query}''', 'ui'),
  ('search_no_results_with_query', 'it', 'Nessun risultato per ''{query}''', 'ui'),
  ('search_no_results_with_query', 'no', 'Ingen resultater for ''{query}''', 'ui'),
  ('search_no_results_with_query', 'sv', 'Inga resultat för ''{query}''', 'ui')
;

-- Location permission (2 keys)
INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('location_permission_denied', 'en', 'Enable location to see distances', 'ui'),
  ('location_permission_denied', 'da', 'Aktiver placering for at se afstand', 'ui'),
  ('location_permission_denied', 'de', 'Standort aktivieren, um Entfernungen zu sehen', 'ui'),
  ('location_permission_denied', 'fr', 'Activez la localisation pour voir les distances', 'ui'),
  ('location_permission_denied', 'it', 'Attiva la posizione per vedere le distanze', 'ui'),
  ('location_permission_denied', 'no', 'Aktiver plassering for å se avstander', 'ui'),
  ('location_permission_denied', 'sv', 'Aktivera plats för att se avstånd', 'ui')
;

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('location_permission_enable', 'en', 'Enable', 'ui'),
  ('location_permission_enable', 'da', 'Aktiver', 'ui'),
  ('location_permission_enable', 'de', 'Aktivieren', 'ui'),
  ('location_permission_enable', 'fr', 'Activer', 'ui'),
  ('location_permission_enable', 'it', 'Attiva', 'ui'),
  ('location_permission_enable', 'no', 'Aktiver', 'ui'),
  ('location_permission_enable', 'sv', 'Aktivera', 'ui')
;

-- Sort options (8 keys)
INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('sort_match', 'en', 'Best match', 'ui'),
  ('sort_match', 'da', 'Bedst match', 'ui'),
  ('sort_match', 'de', 'Beste Übereinstimmung', 'ui'),
  ('sort_match', 'fr', 'Meilleure correspondance', 'ui'),
  ('sort_match', 'it', 'Miglior corrispondenza', 'ui'),
  ('sort_match', 'no', 'Beste treff', 'ui'),
  ('sort_match', 'sv', 'Bästa matchning', 'ui')
;

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('sort_nearest', 'en', 'Nearest', 'ui'),
  ('sort_nearest', 'da', 'Nærmest', 'ui'),
  ('sort_nearest', 'de', 'Nächste', 'ui'),
  ('sort_nearest', 'fr', 'Le plus proche', 'ui'),
  ('sort_nearest', 'it', 'Più vicino', 'ui'),
  ('sort_nearest', 'no', 'Nærmest', 'ui'),
  ('sort_nearest', 'sv', 'Närmaste', 'ui')
;

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('sort_station', 'en', 'Nearest train station', 'ui'),
  ('sort_station', 'da', 'Nærmest togstation', 'ui'),
  ('sort_station', 'de', 'Nächster Bahnhof', 'ui'),
  ('sort_station', 'fr', 'Gare la plus proche', 'ui'),
  ('sort_station', 'it', 'Stazione ferroviaria più vicina', 'ui'),
  ('sort_station', 'no', 'Nærmeste togstasjon', 'ui'),
  ('sort_station', 'sv', 'Närmaste tågstation', 'ui')
;

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('sort_price_low', 'en', 'Price: Low to high', 'ui'),
  ('sort_price_low', 'da', 'Pris: Lav til høj', 'ui'),
  ('sort_price_low', 'de', 'Preis: Niedrig bis hoch', 'ui'),
  ('sort_price_low', 'fr', 'Prix: Bas à élevé', 'ui'),
  ('sort_price_low', 'it', 'Prezzo: Basso ad alto', 'ui'),
  ('sort_price_low', 'no', 'Pris: Lav til høy', 'ui'),
  ('sort_price_low', 'sv', 'Pris: Låg till hög', 'ui')
;

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('sort_price_high', 'en', 'Price: High to low', 'ui'),
  ('sort_price_high', 'da', 'Pris: Høj til lav', 'ui'),
  ('sort_price_high', 'de', 'Preis: Hoch bis niedrig', 'ui'),
  ('sort_price_high', 'fr', 'Prix: Élevé à bas', 'ui'),
  ('sort_price_high', 'it', 'Prezzo: Alto a basso', 'ui'),
  ('sort_price_high', 'no', 'Pris: Høy til lav', 'ui'),
  ('sort_price_high', 'sv', 'Pris: Hög till låg', 'ui')
;

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('sort_newest', 'en', 'Newest', 'ui'),
  ('sort_newest', 'da', 'Nyeste', 'ui'),
  ('sort_newest', 'de', 'Neueste', 'ui'),
  ('sort_newest', 'fr', 'Le plus récent', 'ui'),
  ('sort_newest', 'it', 'Più recente', 'ui'),
  ('sort_newest', 'no', 'Nyeste', 'ui'),
  ('sort_newest', 'sv', 'Nyaste', 'ui')
;

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('sort_sheet_title', 'en', 'Sort by', 'ui'),
  ('sort_sheet_title', 'da', 'Sortér efter', 'ui'),
  ('sort_sheet_title', 'de', 'Sortieren nach', 'ui'),
  ('sort_sheet_title', 'fr', 'Trier par', 'ui'),
  ('sort_sheet_title', 'it', 'Ordina per', 'ui'),
  ('sort_sheet_title', 'no', 'Sorter etter', 'ui'),
  ('sort_sheet_title', 'sv', 'Sortera efter', 'ui')
;

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('filter_only_open', 'en', 'Only open places', 'ui'),
  ('filter_only_open', 'da', 'Kun åbne steder', 'ui'),
  ('filter_only_open', 'de', 'Nur geöffnete Orte', 'ui'),
  ('filter_only_open', 'fr', 'Uniquement les lieux ouverts', 'ui'),
  ('filter_only_open', 'it', 'Solo luoghi aperti', 'ui'),
  ('filter_only_open', 'no', 'Kun åpne steder', 'ui'),
  ('filter_only_open', 'sv', 'Endast öppna ställen', 'ui')
;
