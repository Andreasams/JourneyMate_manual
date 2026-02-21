-- ============================================================
-- NEW_TRANSLATION_KEYS.sql
-- ============================================================
-- This file contains SQL INSERT statements for all NEW translation
-- keys added during Phase 6B (per-page implementation).
--
-- These keys are added to kStaticTranslations in translation_service.dart
-- during Phase 7 page implementation, then migrated to Supabase in Phase 8.
--
-- Phase 8 workflow:
-- 1. Run this SQL file against Supabase ui_translations table
-- 2. Switch all ts() calls to td() across the app
-- 3. Delete kStaticTranslations map from translation_service.dart
-- 4. Result: 100% dynamic translations from BuildShip API
-- ============================================================

-- ============================================================
-- MissingLocationFormWidget Keys (18 keys × 7 languages = 126 rows)
-- Added: 2026-02-21 (Session #2 - Phase 7 Preliminary Task)
-- ============================================================

-- Form Labels (6 keys)
INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('missing_location_title_main', 'en', 'Can''t find the location?', 'ui'),
  ('missing_location_title_main', 'da', 'Kan du ikke finde stedet?', 'ui'),
  ('missing_location_title_main', 'de', 'Standort nicht gefunden?', 'ui'),
  ('missing_location_title_main', 'fr', 'Vous ne trouvez pas l''emplacement ?', 'ui'),
  ('missing_location_title_main', 'it', 'Non trovi la posizione?', 'ui'),
  ('missing_location_title_main', 'no', 'Finner du ikke stedet?', 'ui'),
  ('missing_location_title_main', 'sv', 'Hittar du inte platsen?', 'ui'),

  ('missing_location_subtitle_main_1', 'en', 'Help us improve JourneyMate by submitting missing restaurant information.', 'ui'),
  ('missing_location_subtitle_main_1', 'da', 'Hjælp os med at forbedre JourneyMate ved at indsende manglende restaurantinformation.', 'ui'),
  ('missing_location_subtitle_main_1', 'de', 'Helfen Sie uns, JourneyMate zu verbessern, indem Sie fehlende Restaurantinformationen einreichen.', 'ui'),
  ('missing_location_subtitle_main_1', 'fr', 'Aidez-nous à améliorer JourneyMate en soumettant les informations manquantes sur les restaurants.', 'ui'),
  ('missing_location_subtitle_main_1', 'it', 'Aiutaci a migliorare JourneyMate inviando informazioni mancanti sui ristoranti.', 'ui'),
  ('missing_location_subtitle_main_1', 'no', 'Hjelp oss med å forbedre JourneyMate ved å sende inn manglende restaurantinformasjon.', 'ui'),
  ('missing_location_subtitle_main_1', 'sv', 'Hjälp oss att förbättra JourneyMate genom att skicka in saknad restauranginformation.', 'ui'),

  ('missing_location_subtitle_main_2', 'en', 'We''ll review your submission and add the location to our database.', 'ui'),
  ('missing_location_subtitle_main_2', 'da', 'Vi vil gennemgå din indsendelse og tilføje stedet til vores database.', 'ui'),
  ('missing_location_subtitle_main_2', 'de', 'Wir werden Ihre Einreichung überprüfen und den Standort zu unserer Datenbank hinzufügen.', 'ui'),
  ('missing_location_subtitle_main_2', 'fr', 'Nous examinerons votre soumission et ajouterons l''emplacement à notre base de données.', 'ui'),
  ('missing_location_subtitle_main_2', 'it', 'Esamineremo la tua segnalazione e aggiungeremo la posizione al nostro database.', 'ui'),
  ('missing_location_subtitle_main_2', 'no', 'Vi vil gjennomgå innsendingen din og legge til stedet i databasen vår.', 'ui'),
  ('missing_location_subtitle_main_2', 'sv', 'Vi kommer att granska ditt bidrag och lägga till platsen i vår databas.', 'ui'),

  ('missing_location_title_business_name', 'en', 'Restaurant name', 'ui'),
  ('missing_location_title_business_name', 'da', 'Restaurantnavn', 'ui'),
  ('missing_location_title_business_name', 'de', 'Restaurantname', 'ui'),
  ('missing_location_title_business_name', 'fr', 'Nom du restaurant', 'ui'),
  ('missing_location_title_business_name', 'it', 'Nome del ristorante', 'ui'),
  ('missing_location_title_business_name', 'no', 'Restaurantnavn', 'ui'),
  ('missing_location_title_business_name', 'sv', 'Restaurangnamn', 'ui'),

  ('missing_location_title_business_address', 'en', 'Address', 'ui'),
  ('missing_location_title_business_address', 'da', 'Adresse', 'ui'),
  ('missing_location_title_business_address', 'de', 'Adresse', 'ui'),
  ('missing_location_title_business_address', 'fr', 'Adresse', 'ui'),
  ('missing_location_title_business_address', 'it', 'Indirizzo', 'ui'),
  ('missing_location_title_business_address', 'no', 'Adresse', 'ui'),
  ('missing_location_title_business_address', 'sv', 'Adress', 'ui'),

  ('missing_location_title_message', 'en', 'Additional information', 'ui'),
  ('missing_location_title_message', 'da', 'Yderligere information', 'ui'),
  ('missing_location_title_message', 'de', 'Zusätzliche Informationen', 'ui'),
  ('missing_location_title_message', 'fr', 'Informations supplémentaires', 'ui'),
  ('missing_location_title_message', 'it', 'Informazioni aggiuntive', 'ui'),
  ('missing_location_title_message', 'no', 'Tilleggsinformasjon', 'ui'),
  ('missing_location_title_message', 'sv', 'Ytterligare information', 'ui');

-- Subtitles/Hints (5 keys)
INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('missing_location_subtitle_business_address', 'en', 'Provide the full address including street, city, and postal code', 'ui'),
  ('missing_location_subtitle_business_address', 'da', 'Angiv den fulde adresse inklusive vej, by og postnummer', 'ui'),
  ('missing_location_subtitle_business_address', 'de', 'Geben Sie die vollständige Adresse einschließlich Straße, Stadt und Postleitzahl an', 'ui'),
  ('missing_location_subtitle_business_address', 'fr', 'Indiquez l''adresse complète, y compris la rue, la ville et le code postal', 'ui'),
  ('missing_location_subtitle_business_address', 'it', 'Fornisci l''indirizzo completo inclusi via, città e codice postale', 'ui'),
  ('missing_location_subtitle_business_address', 'no', 'Oppgi full adresse inkludert gate, by og postnummer', 'ui'),
  ('missing_location_subtitle_business_address', 'sv', 'Ange den fullständiga adressen inklusive gata, stad och postnummer', 'ui'),

  ('missing_location_subtitle_message', 'en', 'Tell us more about this location (minimum 10 characters)', 'ui'),
  ('missing_location_subtitle_message', 'da', 'Fortæl os mere om dette sted (minimum 10 tegn)', 'ui'),
  ('missing_location_subtitle_message', 'de', 'Erzählen Sie uns mehr über diesen Ort (mindestens 10 Zeichen)', 'ui'),
  ('missing_location_subtitle_message', 'fr', 'Parlez-nous davantage de cet emplacement (minimum 10 caractères)', 'ui'),
  ('missing_location_subtitle_message', 'it', 'Raccontaci di più su questa posizione (minimo 10 caratteri)', 'ui'),
  ('missing_location_subtitle_message', 'no', 'Fortell oss mer om dette stedet (minimum 10 tegn)', 'ui'),
  ('missing_location_subtitle_message', 'sv', 'Berätta mer om denna plats (minst 10 tecken)', 'ui'),

  ('missing_location_hint_business_name', 'en', 'Enter the name of the restaurant', 'ui'),
  ('missing_location_hint_business_name', 'da', 'Indtast restaurantens navn', 'ui'),
  ('missing_location_hint_business_name', 'de', 'Geben Sie den Namen des Restaurants ein', 'ui'),
  ('missing_location_hint_business_name', 'fr', 'Entrez le nom du restaurant', 'ui'),
  ('missing_location_hint_business_name', 'it', 'Inserisci il nome del ristorante', 'ui'),
  ('missing_location_hint_business_name', 'no', 'Skriv inn navnet på restauranten', 'ui'),
  ('missing_location_hint_business_name', 'sv', 'Ange restaurangens namn', 'ui'),

  ('missing_location_hint_business_address', 'en', 'Enter the full address', 'ui'),
  ('missing_location_hint_business_address', 'da', 'Indtast den fulde adresse', 'ui'),
  ('missing_location_hint_business_address', 'de', 'Geben Sie die vollständige Adresse ein', 'ui'),
  ('missing_location_hint_business_address', 'fr', 'Entrez l''adresse complète', 'ui'),
  ('missing_location_hint_business_address', 'it', 'Inserisci l''indirizzo completo', 'ui'),
  ('missing_location_hint_business_address', 'no', 'Skriv inn full adresse', 'ui'),
  ('missing_location_hint_business_address', 'sv', 'Ange den fullständiga adressen', 'ui'),

  ('missing_location_hint_message', 'en', 'E.g., hours, specialties, accessibility features...', 'ui'),
  ('missing_location_hint_message', 'da', 'F.eks. åbningstider, specialiteter, tilgængelighedsfunktioner...', 'ui'),
  ('missing_location_hint_message', 'de', 'Z.B. Öffnungszeiten, Spezialitäten, Barrierefreiheit...', 'ui'),
  ('missing_location_hint_message', 'fr', 'Par ex., horaires, spécialités, accessibilité...', 'ui'),
  ('missing_location_hint_message', 'it', 'Ad es., orari, specialità, accessibilità...', 'ui'),
  ('missing_location_hint_message', 'no', 'F.eks. åpningstider, spesialiteter, tilgjengelighetsfunksjoner...', 'ui'),
  ('missing_location_hint_message', 'sv', 'T.ex. öppettider, specialiteter, tillgänglighetsfunktioner...', 'ui');

-- Validation Errors (4 keys)
INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('missing_location_error_name_required', 'en', 'Please enter the restaurant name', 'ui'),
  ('missing_location_error_name_required', 'da', 'Indtast venligst restaurantens navn', 'ui'),
  ('missing_location_error_name_required', 'de', 'Bitte geben Sie den Restaurantnamen ein', 'ui'),
  ('missing_location_error_name_required', 'fr', 'Veuillez entrer le nom du restaurant', 'ui'),
  ('missing_location_error_name_required', 'it', 'Inserisci il nome del ristorante', 'ui'),
  ('missing_location_error_name_required', 'no', 'Vennligst skriv inn restaurantnavnet', 'ui'),
  ('missing_location_error_name_required', 'sv', 'Ange restaurangens namn', 'ui'),

  ('missing_location_error_address_required', 'en', 'Please enter the restaurant address', 'ui'),
  ('missing_location_error_address_required', 'da', 'Indtast venligst restaurantens adresse', 'ui'),
  ('missing_location_error_address_required', 'de', 'Bitte geben Sie die Restaurantadresse ein', 'ui'),
  ('missing_location_error_address_required', 'fr', 'Veuillez entrer l''adresse du restaurant', 'ui'),
  ('missing_location_error_address_required', 'it', 'Inserisci l''indirizzo del ristorante', 'ui'),
  ('missing_location_error_address_required', 'no', 'Vennligst skriv inn restaurantadressen', 'ui'),
  ('missing_location_error_address_required', 'sv', 'Ange restaurangens adress', 'ui'),

  ('missing_location_error_message_required', 'en', 'Please provide additional information', 'ui'),
  ('missing_location_error_message_required', 'da', 'Angiv venligst yderligere information', 'ui'),
  ('missing_location_error_message_required', 'de', 'Bitte geben Sie zusätzliche Informationen an', 'ui'),
  ('missing_location_error_message_required', 'fr', 'Veuillez fournir des informations supplémentaires', 'ui'),
  ('missing_location_error_message_required', 'it', 'Fornisci informazioni aggiuntive', 'ui'),
  ('missing_location_error_message_required', 'no', 'Vennligst oppgi tilleggsinformasjon', 'ui'),
  ('missing_location_error_message_required', 'sv', 'Ange ytterligare information', 'ui'),

  ('missing_location_error_message_too_short', 'en', 'Please provide at least 10 characters', 'ui'),
  ('missing_location_error_message_too_short', 'da', 'Angiv venligst mindst 10 tegn', 'ui'),
  ('missing_location_error_message_too_short', 'de', 'Bitte geben Sie mindestens 10 Zeichen ein', 'ui'),
  ('missing_location_error_message_too_short', 'fr', 'Veuillez fournir au moins 10 caractères', 'ui'),
  ('missing_location_error_message_too_short', 'it', 'Fornisci almeno 10 caratteri', 'ui'),
  ('missing_location_error_message_too_short', 'no', 'Vennligst oppgi minst 10 tegn', 'ui'),
  ('missing_location_error_message_too_short', 'sv', 'Ange minst 10 tecken', 'ui');

-- Status Messages (3 keys)
INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('missing_location_button_submit', 'en', 'Submit location', 'ui'),
  ('missing_location_button_submit', 'da', 'Indsend sted', 'ui'),
  ('missing_location_button_submit', 'de', 'Standort einreichen', 'ui'),
  ('missing_location_button_submit', 'fr', 'Soumettre l''emplacement', 'ui'),
  ('missing_location_button_submit', 'it', 'Invia posizione', 'ui'),
  ('missing_location_button_submit', 'no', 'Send inn sted', 'ui'),
  ('missing_location_button_submit', 'sv', 'Skicka in plats', 'ui'),

  ('missing_location_success_message', 'en', 'Thank you! Your submission has been received.', 'ui'),
  ('missing_location_success_message', 'da', 'Tak! Din indsendelse er modtaget.', 'ui'),
  ('missing_location_success_message', 'de', 'Vielen Dank! Ihre Einreichung wurde empfangen.', 'ui'),
  ('missing_location_success_message', 'fr', 'Merci ! Votre soumission a été reçue.', 'ui'),
  ('missing_location_success_message', 'it', 'Grazie! La tua segnalazione è stata ricevuta.', 'ui'),
  ('missing_location_success_message', 'no', 'Takk! Innsendingen din er mottatt.', 'ui'),
  ('missing_location_success_message', 'sv', 'Tack! Ditt bidrag har tagits emot.', 'ui'),

  ('missing_location_success_navigate_away', 'en', 'You can now close this form.', 'ui'),
  ('missing_location_success_navigate_away', 'da', 'Du kan nu lukke denne formular.', 'ui'),
  ('missing_location_success_navigate_away', 'de', 'Sie können dieses Formular jetzt schließen.', 'ui'),
  ('missing_location_success_navigate_away', 'fr', 'Vous pouvez maintenant fermer ce formulaire.', 'ui'),
  ('missing_location_success_navigate_away', 'it', 'Ora puoi chiudere questo modulo.', 'ui'),
  ('missing_location_success_navigate_away', 'no', 'Du kan nå lukke dette skjemaet.', 'ui'),
  ('missing_location_success_navigate_away', 'sv', 'Du kan nu stänga detta formulär.', 'ui'),

  ('missing_location_error_submission', 'en', 'Something went wrong. Please try again.', 'ui'),
  ('missing_location_error_submission', 'da', 'Noget gik galt. Prøv venligst igen.', 'ui'),
  ('missing_location_error_submission', 'de', 'Etwas ist schief gelaufen. Bitte versuchen Sie es erneut.', 'ui'),
  ('missing_location_error_submission', 'fr', 'Une erreur s''est produite. Veuillez réessayer.', 'ui'),
  ('missing_location_error_submission', 'it', 'Qualcosa è andato storto. Riprova.', 'ui'),
  ('missing_location_error_submission', 'no', 'Noe gikk galt. Vennligst prøv igjen.', 'ui'),
  ('missing_location_error_submission', 'sv', 'Något gick fel. Försök igen.', 'ui');

-- ============================================================
-- END OF MissingLocationFormWidget KEYS
-- Total: 126 INSERT statements (18 keys × 7 languages)
-- ============================================================

-- ============================================================
-- ExpandableTextWidget Keys (2 keys × 7 languages = 14 rows)
-- Added: 2026-02-21 (Session #3 - Phase 7 Batch 2)
-- ============================================================

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('expandable_show_more', 'en', 'Show more', 'ui'),
  ('expandable_show_more', 'da', 'Vis mere', 'ui'),
  ('expandable_show_more', 'de', 'Mehr anzeigen', 'ui'),
  ('expandable_show_more', 'fr', 'Afficher plus', 'ui'),
  ('expandable_show_more', 'it', 'Mostra di più', 'ui'),
  ('expandable_show_more', 'no', 'Vis mer', 'ui'),
  ('expandable_show_more', 'sv', 'Visa mer', 'ui'),

  ('expandable_show_less', 'en', 'Show less', 'ui'),
  ('expandable_show_less', 'da', 'Vis mindre', 'ui'),
  ('expandable_show_less', 'de', 'Weniger anzeigen', 'ui'),
  ('expandable_show_less', 'fr', 'Afficher moins', 'ui'),
  ('expandable_show_less', 'it', 'Mostra meno', 'ui'),
  ('expandable_show_less', 'no', 'Vis mindre', 'ui'),
  ('expandable_show_less', 'sv', 'Visa mindre', 'ui');

-- ============================================================
-- END OF ExpandableTextWidget KEYS
-- Total: 14 INSERT statements (2 keys × 7 languages)
-- ============================================================

-- ============================================================
-- Widget: OpeningHoursAndWeekdays (Phase 7 Batch 5)
-- Total: 161 INSERT statements (23 keys × 7 languages)
-- ============================================================

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  -- Weekday names (7 keys × 7 languages = 49 statements)
  ('day_monday_cap', 'en', 'Monday', 'ui'),
  ('day_monday_cap', 'da', 'Mandag', 'ui'),
  ('day_monday_cap', 'de', 'Montag', 'ui'),
  ('day_monday_cap', 'fr', 'Lundi', 'ui'),
  ('day_monday_cap', 'it', 'Lunedì', 'ui'),
  ('day_monday_cap', 'no', 'Mandag', 'ui'),
  ('day_monday_cap', 'sv', 'Måndag', 'ui'),

  ('day_tuesday_cap', 'en', 'Tuesday', 'ui'),
  ('day_tuesday_cap', 'da', 'Tirsdag', 'ui'),
  ('day_tuesday_cap', 'de', 'Dienstag', 'ui'),
  ('day_tuesday_cap', 'fr', 'Mardi', 'ui'),
  ('day_tuesday_cap', 'it', 'Martedì', 'ui'),
  ('day_tuesday_cap', 'no', 'Tirsdag', 'ui'),
  ('day_tuesday_cap', 'sv', 'Tisdag', 'ui'),

  ('day_wednesday_cap', 'en', 'Wednesday', 'ui'),
  ('day_wednesday_cap', 'da', 'Onsdag', 'ui'),
  ('day_wednesday_cap', 'de', 'Mittwoch', 'ui'),
  ('day_wednesday_cap', 'fr', 'Mercredi', 'ui'),
  ('day_wednesday_cap', 'it', 'Mercoledì', 'ui'),
  ('day_wednesday_cap', 'no', 'Onsdag', 'ui'),
  ('day_wednesday_cap', 'sv', 'Onsdag', 'ui'),

  ('day_thursday_cap', 'en', 'Thursday', 'ui'),
  ('day_thursday_cap', 'da', 'Torsdag', 'ui'),
  ('day_thursday_cap', 'de', 'Donnerstag', 'ui'),
  ('day_thursday_cap', 'fr', 'Jeudi', 'ui'),
  ('day_thursday_cap', 'it', 'Giovedì', 'ui'),
  ('day_thursday_cap', 'no', 'Torsdag', 'ui'),
  ('day_thursday_cap', 'sv', 'Torsdag', 'ui'),

  ('day_friday_cap', 'en', 'Friday', 'ui'),
  ('day_friday_cap', 'da', 'Fredag', 'ui'),
  ('day_friday_cap', 'de', 'Freitag', 'ui'),
  ('day_friday_cap', 'fr', 'Vendredi', 'ui'),
  ('day_friday_cap', 'it', 'Venerdì', 'ui'),
  ('day_friday_cap', 'no', 'Fredag', 'ui'),
  ('day_friday_cap', 'sv', 'Fredag', 'ui'),

  ('day_saturday_cap', 'en', 'Saturday', 'ui'),
  ('day_saturday_cap', 'da', 'Lørdag', 'ui'),
  ('day_saturday_cap', 'de', 'Samstag', 'ui'),
  ('day_saturday_cap', 'fr', 'Samedi', 'ui'),
  ('day_saturday_cap', 'it', 'Sabato', 'ui'),
  ('day_saturday_cap', 'no', 'Lørdag', 'ui'),
  ('day_saturday_cap', 'sv', 'Lördag', 'ui'),

  ('day_sunday_cap', 'en', 'Sunday', 'ui'),
  ('day_sunday_cap', 'da', 'Søndag', 'ui'),
  ('day_sunday_cap', 'de', 'Sonntag', 'ui'),
  ('day_sunday_cap', 'fr', 'Dimanche', 'ui'),
  ('day_sunday_cap', 'it', 'Domenica', 'ui'),
  ('day_sunday_cap', 'no', 'Søndag', 'ui'),
  ('day_sunday_cap', 'sv', 'Söndag', 'ui'),

  -- Status labels (2 keys × 7 languages = 14 statements)
  ('hours_closed', 'en', 'Closed', 'ui'),
  ('hours_closed', 'da', 'Lukket', 'ui'),
  ('hours_closed', 'de', 'Geschlossen', 'ui'),
  ('hours_closed', 'fr', 'Fermé', 'ui'),
  ('hours_closed', 'it', 'Chiuso', 'ui'),
  ('hours_closed', 'no', 'Stengt', 'ui'),
  ('hours_closed', 'sv', 'Stängt', 'ui'),

  ('hours_by_appointment', 'en', 'By appointment', 'ui'),
  ('hours_by_appointment', 'da', 'Efter aftale', 'ui'),
  ('hours_by_appointment', 'de', 'Nach Vereinbarung', 'ui'),
  ('hours_by_appointment', 'fr', 'Sur rendez-vous', 'ui'),
  ('hours_by_appointment', 'it', 'Su appuntamento', 'ui'),
  ('hours_by_appointment', 'no', 'Etter avtale', 'ui'),
  ('hours_by_appointment', 'sv', 'Efter överenskommelse', 'ui'),

  -- Cutoff type labels (8 keys × 7 languages = 56 statements)
  ('hours_kitchen', 'en', 'Kitchen', 'ui'),
  ('hours_kitchen', 'da', 'Køkken', 'ui'),
  ('hours_kitchen', 'de', 'Küche', 'ui'),
  ('hours_kitchen', 'fr', 'Cuisine', 'ui'),
  ('hours_kitchen', 'it', 'Cucina', 'ui'),
  ('hours_kitchen', 'no', 'Kjøkken', 'ui'),
  ('hours_kitchen', 'sv', 'Kök', 'ui'),

  ('hours_last_order', 'en', 'Last order', 'ui'),
  ('hours_last_order', 'da', 'Sidste ordre', 'ui'),
  ('hours_last_order', 'de', 'Letzte Bestellung', 'ui'),
  ('hours_last_order', 'fr', 'Dernière commande', 'ui'),
  ('hours_last_order', 'it', 'Ultimo ordine', 'ui'),
  ('hours_last_order', 'no', 'Siste bestilling', 'ui'),
  ('hours_last_order', 'sv', 'Sista beställning', 'ui'),

  ('hours_last_arrival', 'en', 'Last arrival', 'ui'),
  ('hours_last_arrival', 'da', 'Sidste ankomst', 'ui'),
  ('hours_last_arrival', 'de', 'Letzte Ankunft', 'ui'),
  ('hours_last_arrival', 'fr', 'Dernière arrivée', 'ui'),
  ('hours_last_arrival', 'it', 'Ultimo arrivo', 'ui'),
  ('hours_last_arrival', 'no', 'Siste ankomst', 'ui'),
  ('hours_last_arrival', 'sv', 'Sista ankomst', 'ui'),

  ('hours_last_booking', 'en', 'Last booking', 'ui'),
  ('hours_last_booking', 'da', 'Sidste booking', 'ui'),
  ('hours_last_booking', 'de', 'Letzte Buchung', 'ui'),
  ('hours_last_booking', 'fr', 'Dernière réservation', 'ui'),
  ('hours_last_booking', 'it', 'Ultima prenotazione', 'ui'),
  ('hours_last_booking', 'no', 'Siste bestilling', 'ui'),
  ('hours_last_booking', 'sv', 'Sista bokning', 'ui'),

  ('hours_first_seating', 'en', 'First seating', 'ui'),
  ('hours_first_seating', 'da', 'Første servering', 'ui'),
  ('hours_first_seating', 'de', 'Erste Sitzung', 'ui'),
  ('hours_first_seating', 'fr', 'Premier service', 'ui'),
  ('hours_first_seating', 'it', 'Primo turno', 'ui'),
  ('hours_first_seating', 'no', 'Første servering', 'ui'),
  ('hours_first_seating', 'sv', 'Första sittning', 'ui'),

  ('hours_second_seating', 'en', 'Second seating', 'ui'),
  ('hours_second_seating', 'da', 'Anden servering', 'ui'),
  ('hours_second_seating', 'de', 'Zweite Sitzung', 'ui'),
  ('hours_second_seating', 'fr', 'Deuxième service', 'ui'),
  ('hours_second_seating', 'it', 'Secondo turno', 'ui'),
  ('hours_second_seating', 'no', 'Andre servering', 'ui'),
  ('hours_second_seating', 'sv', 'Andra sittning', 'ui'),

  ('hours_third_seating', 'en', 'Third seating', 'ui'),
  ('hours_third_seating', 'da', 'Tredje servering', 'ui'),
  ('hours_third_seating', 'de', 'Dritte Sitzung', 'ui'),
  ('hours_third_seating', 'fr', 'Troisième service', 'ui'),
  ('hours_third_seating', 'it', 'Terzo turno', 'ui'),
  ('hours_third_seating', 'no', 'Tredje servering', 'ui'),
  ('hours_third_seating', 'sv', 'Tredje sittning', 'ui'),

  ('hours_call_for_hours', 'en', 'Call for hours', 'ui'),
  ('hours_call_for_hours', 'da', 'Ring for tider', 'ui'),
  ('hours_call_for_hours', 'de', 'Anrufen für Öffnungszeiten', 'ui'),
  ('hours_call_for_hours', 'fr', 'Appeler pour les horaires', 'ui'),
  ('hours_call_for_hours', 'it', 'Chiamare per gli orari', 'ui'),
  ('hours_call_for_hours', 'no', 'Ring for åpningstider', 'ui'),
  ('hours_call_for_hours', 'sv', 'Ring för öppettider', 'ui'),

  -- General labels (6 keys × 7 languages = 42 statements)
  ('key_opening_hours', 'en', 'Opening hours', 'ui'),
  ('key_opening_hours', 'da', 'Åbningstider', 'ui'),
  ('key_opening_hours', 'de', 'Öffnungszeiten', 'ui'),
  ('key_opening_hours', 'fr', 'Horaires d''ouverture', 'ui'),
  ('key_opening_hours', 'it', 'Orari di apertura', 'ui'),
  ('key_opening_hours', 'no', 'Åpningstider', 'ui'),
  ('key_opening_hours', 'sv', 'Öppettider', 'ui'),

  ('key_open', 'en', 'Open', 'ui'),
  ('key_open', 'da', 'Åben', 'ui'),
  ('key_open', 'de', 'Geöffnet', 'ui'),
  ('key_open', 'fr', 'Ouvert', 'ui'),
  ('key_open', 'it', 'Aperto', 'ui'),
  ('key_open', 'no', 'Åpen', 'ui'),
  ('key_open', 'sv', 'Öppet', 'ui'),

  ('key_until', 'en', 'Until', 'ui'),
  ('key_until', 'da', 'Indtil', 'ui'),
  ('key_until', 'de', 'Bis', 'ui'),
  ('key_until', 'fr', 'Jusqu''à', 'ui'),
  ('key_until', 'it', 'Fino a', 'ui'),
  ('key_until', 'no', 'Til', 'ui'),
  ('key_until', 'sv', 'Till', 'ui'),

  ('key_and', 'en', 'and', 'ui'),
  ('key_and', 'da', 'og', 'ui'),
  ('key_and', 'de', 'und', 'ui'),
  ('key_and', 'fr', 'et', 'ui'),
  ('key_and', 'it', 'e', 'ui'),
  ('key_and', 'no', 'og', 'ui'),
  ('key_and', 'sv', 'och', 'ui'),

  ('key_from', 'en', 'From', 'ui'),
  ('key_from', 'da', 'Fra', 'ui'),
  ('key_from', 'de', 'Von', 'ui'),
  ('key_from', 'fr', 'De', 'ui'),
  ('key_from', 'it', 'Da', 'ui'),
  ('key_from', 'no', 'Fra', 'ui'),
  ('key_from', 'sv', 'Från', 'ui'),

  ('key_to', 'en', 'To', 'ui'),
  ('key_to', 'da', 'Til', 'ui'),
  ('key_to', 'de', 'Bis', 'ui'),
  ('key_to', 'fr', 'À', 'ui'),
  ('key_to', 'it', 'A', 'ui'),
  ('key_to', 'no', 'Til', 'ui'),
  ('key_to', 'sv', 'Till', 'ui');

-- ============================================================
-- END OF OpeningHoursAndWeekdays KEYS
-- Total: 161 INSERT statements (23 keys × 7 languages)
-- ============================================================
-- Widget: ContactDetailsWidget (Phase 7 Batch 5)
INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  -- Section headers
  ('contact_details_address', 'en', 'Address', 'ui'),
  ('contact_details_address', 'da', 'Adresse', 'ui'),
  ('contact_details_address', 'de', 'Adresse', 'ui'),
  ('contact_details_address', 'fr', 'Adresse', 'ui'),
  ('contact_details_address', 'it', 'Indirizzo', 'ui'),
  ('contact_details_address', 'no', 'Adresse', 'ui'),
  ('contact_details_address', 'sv', 'Adress', 'ui'),

  ('contact_details_opening_hours', 'en', 'Opening Hours', 'ui'),
  ('contact_details_opening_hours', 'da', 'Åbningstider', 'ui'),
  ('contact_details_opening_hours', 'de', 'Öffnungszeiten', 'ui'),
  ('contact_details_opening_hours', 'fr', 'Horaires d''ouverture', 'ui'),
  ('contact_details_opening_hours', 'it', 'Orari di apertura', 'ui'),
  ('contact_details_opening_hours', 'no', 'Åpningstider', 'ui'),
  ('contact_details_opening_hours', 'sv', 'Öppettider', 'ui'),

  ('contact_details_contact_information', 'en', 'Contact Information', 'ui'),
  ('contact_details_contact_information', 'da', 'Kontaktinformation', 'ui'),
  ('contact_details_contact_information', 'de', 'Kontaktinformationen', 'ui'),
  ('contact_details_contact_information', 'fr', 'Informations de contact', 'ui'),
  ('contact_details_contact_information', 'it', 'Informazioni di contatto', 'ui'),
  ('contact_details_contact_information', 'no', 'Kontaktinformasjon', 'ui'),
  ('contact_details_contact_information', 'sv', 'Kontaktinformation', 'ui'),

  -- Contact method labels
  ('contact_details_phone', 'en', 'Phone', 'ui'),
  ('contact_details_phone', 'da', 'Telefon', 'ui'),
  ('contact_details_phone', 'de', 'Telefon', 'ui'),
  ('contact_details_phone', 'fr', 'Téléphone', 'ui'),
  ('contact_details_phone', 'it', 'Telefono', 'ui'),
  ('contact_details_phone', 'no', 'Telefon', 'ui'),
  ('contact_details_phone', 'sv', 'Telefon', 'ui'),

  ('contact_details_email', 'en', 'Email', 'ui'),
  ('contact_details_email', 'da', 'E-mail', 'ui'),
  ('contact_details_email', 'de', 'E-Mail', 'ui'),
  ('contact_details_email', 'fr', 'E-mail', 'ui'),
  ('contact_details_email', 'it', 'E-mail', 'ui'),
  ('contact_details_email', 'no', 'E-post', 'ui'),
  ('contact_details_email', 'sv', 'E-post', 'ui'),

  ('contact_details_website', 'en', 'Website', 'ui'),
  ('contact_details_website', 'da', 'Hjemmeside', 'ui'),
  ('contact_details_website', 'de', 'Webseite', 'ui'),
  ('contact_details_website', 'fr', 'Site web', 'ui'),
  ('contact_details_website', 'it', 'Sito web', 'ui'),
  ('contact_details_website', 'no', 'Nettside', 'ui'),
  ('contact_details_website', 'sv', 'Webbplats', 'ui'),

  ('contact_details_reservations', 'en', 'Reservations', 'ui'),
  ('contact_details_reservations', 'da', 'Reservationer', 'ui'),
  ('contact_details_reservations', 'de', 'Reservierungen', 'ui'),
  ('contact_details_reservations', 'fr', 'Réservations', 'ui'),
  ('contact_details_reservations', 'it', 'Prenotazioni', 'ui'),
  ('contact_details_reservations', 'no', 'Reservasjoner', 'ui'),
  ('contact_details_reservations', 'sv', 'Reservationer', 'ui'),

  ('contact_details_instagram', 'en', 'Instagram', 'ui'),
  ('contact_details_instagram', 'da', 'Instagram', 'ui'),
  ('contact_details_instagram', 'de', 'Instagram', 'ui'),
  ('contact_details_instagram', 'fr', 'Instagram', 'ui'),
  ('contact_details_instagram', 'it', 'Instagram', 'ui'),
  ('contact_details_instagram', 'no', 'Instagram', 'ui'),
  ('contact_details_instagram', 'sv', 'Instagram', 'ui'),

  ('contact_details_facebook', 'en', 'Facebook', 'ui'),
  ('contact_details_facebook', 'da', 'Facebook', 'ui'),
  ('contact_details_facebook', 'de', 'Facebook', 'ui'),
  ('contact_details_facebook', 'fr', 'Facebook', 'ui'),
  ('contact_details_facebook', 'it', 'Facebook', 'ui'),
  ('contact_details_facebook', 'no', 'Facebook', 'ui'),
  ('contact_details_facebook', 'sv', 'Facebook', 'ui'),

  -- Action labels
  ('contact_details_tap_to_call', 'en', 'Tap to call', 'ui'),
  ('contact_details_tap_to_call', 'da', 'Tryk for at ringe', 'ui'),
  ('contact_details_tap_to_call', 'de', 'Zum Anrufen tippen', 'ui'),
  ('contact_details_tap_to_call', 'fr', 'Appuyez pour appeler', 'ui'),
  ('contact_details_tap_to_call', 'it', 'Tocca per chiamare', 'ui'),
  ('contact_details_tap_to_call', 'no', 'Trykk for å ringe', 'ui'),
  ('contact_details_tap_to_call', 'sv', 'Tryck för att ringa', 'ui'),

  ('contact_details_tap_to_email', 'en', 'Tap to email', 'ui'),
  ('contact_details_tap_to_email', 'da', 'Tryk for at sende e-mail', 'ui'),
  ('contact_details_tap_to_email', 'de', 'Zum E-Mailen tippen', 'ui'),
  ('contact_details_tap_to_email', 'fr', 'Appuyez pour envoyer un e-mail', 'ui'),
  ('contact_details_tap_to_email', 'it', 'Tocca per inviare un''e-mail', 'ui'),
  ('contact_details_tap_to_email', 'no', 'Trykk for å sende e-post', 'ui'),
  ('contact_details_tap_to_email', 'sv', 'Tryck för att skicka e-post', 'ui'),

  ('contact_details_view_on_instagram', 'en', 'View on Instagram', 'ui'),
  ('contact_details_view_on_instagram', 'da', 'Se på Instagram', 'ui'),
  ('contact_details_view_on_instagram', 'de', 'Auf Instagram anzeigen', 'ui'),
  ('contact_details_view_on_instagram', 'fr', 'Voir sur Instagram', 'ui'),
  ('contact_details_view_on_instagram', 'it', 'Visualizza su Instagram', 'ui'),
  ('contact_details_view_on_instagram', 'no', 'Se på Instagram', 'ui'),
  ('contact_details_view_on_instagram', 'sv', 'Visa på Instagram', 'ui'),

  ('contact_details_view_on_facebook', 'en', 'View on Facebook', 'ui'),
  ('contact_details_view_on_facebook', 'da', 'Se på Facebook', 'ui'),
  ('contact_details_view_on_facebook', 'de', 'Auf Facebook anzeigen', 'ui'),
  ('contact_details_view_on_facebook', 'fr', 'Voir sur Facebook', 'ui'),
  ('contact_details_view_on_facebook', 'it', 'Visualizza su Facebook', 'ui'),
  ('contact_details_view_on_facebook', 'no', 'Se på Facebook', 'ui'),
  ('contact_details_view_on_facebook', 'sv', 'Visa på Facebook', 'ui');
-- ============================================================
-- Phase 7 Batch 6: ContactUsFormWidget + FeedbackFormWidget
-- 53 keys × 7 languages = 371 rows
-- ============================================================

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  -- ContactUsFormWidget (22 keys)
  ('contact_form_title_main', 'en', 'Contact us', 'ui'),
  ('contact_form_title_main', 'da', 'Kontakt os', 'ui'),
  ('contact_form_title_main', 'de', 'Kontaktieren Sie uns', 'ui'),
  ('contact_form_title_main', 'fr', 'Contactez-nous', 'ui'),
  ('contact_form_title_main', 'it', 'Contattaci', 'ui'),
  ('contact_form_title_main', 'no', 'Kontakt oss', 'ui'),
  ('contact_form_title_main', 'sv', 'Kontakta oss', 'ui'),

  ('contact_form_subtitle_main', 'en', 'We would love to hear from you!', 'ui'),
  ('contact_form_subtitle_main', 'da', 'Vi vil gerne høre fra dig!', 'ui'),
  ('contact_form_subtitle_main', 'de', 'Wir würden gerne von Ihnen hören!', 'ui'),
  ('contact_form_subtitle_main', 'fr', 'Nous aimerions avoir de vos nouvelles!', 'ui'),
  ('contact_form_subtitle_main', 'it', 'Ci piacerebbe sentirti!', 'ui'),
  ('contact_form_subtitle_main', 'no', 'Vi vil gjerne høre fra deg!', 'ui'),
  ('contact_form_subtitle_main', 'sv', 'Vi skulle gärna höra från dig!', 'ui'),

  ('contact_form_title_name', 'en', 'Your name', 'ui'),
  ('contact_form_title_name', 'da', 'Dit navn', 'ui'),
  ('contact_form_title_name', 'de', 'Ihr Name', 'ui'),
  ('contact_form_title_name', 'fr', 'Votre nom', 'ui'),
  ('contact_form_title_name', 'it', 'Il tuo nome', 'ui'),
  ('contact_form_title_name', 'no', 'Ditt navn', 'ui'),
  ('contact_form_title_name', 'sv', 'Ditt namn', 'ui'),

  ('contact_form_title_contact', 'en', 'Email or phone', 'ui'),
  ('contact_form_title_contact', 'da', 'E-mail eller telefon', 'ui'),
  ('contact_form_title_contact', 'de', 'E-Mail oder Telefon', 'ui'),
  ('contact_form_title_contact', 'fr', 'Email ou téléphone', 'ui'),
  ('contact_form_title_contact', 'it', 'Email o telefono', 'ui'),
  ('contact_form_title_contact', 'no', 'E-post eller telefon', 'ui'),
  ('contact_form_title_contact', 'sv', 'E-post eller telefon', 'ui'),

  ('contact_form_subtitle_contact', 'en', 'Please provide either or both', 'ui'),
  ('contact_form_subtitle_contact', 'da', 'Angiv enten den ene eller begge dele', 'ui'),
  ('contact_form_subtitle_contact', 'de', 'Bitte geben Sie entweder oder beides an', 'ui'),
  ('contact_form_subtitle_contact', 'fr', 'Veuillez fournir l''un ou les deux', 'ui'),
  ('contact_form_subtitle_contact', 'it', 'Si prega di fornire uno o entrambi', 'ui'),
  ('contact_form_subtitle_contact', 'no', 'Vennligst oppgi enten eller begge deler', 'ui'),
  ('contact_form_subtitle_contact', 'sv', 'Vänligen ange antingen eller båda', 'ui'),

  ('contact_form_title_subject', 'en', 'Subject', 'ui'),
  ('contact_form_title_subject', 'da', 'Emne', 'ui'),
  ('contact_form_title_subject', 'de', 'Betreff', 'ui'),
  ('contact_form_title_subject', 'fr', 'Sujet', 'ui'),
  ('contact_form_title_subject', 'it', 'Oggetto', 'ui'),
  ('contact_form_title_subject', 'no', 'Emne', 'ui'),
  ('contact_form_title_subject', 'sv', 'Ämne', 'ui'),

  ('contact_form_subtitle_subject', 'en', 'What is this about?', 'ui'),
  ('contact_form_subtitle_subject', 'da', 'Hvad handler det om?', 'ui'),
  ('contact_form_subtitle_subject', 'de', 'Worum geht es?', 'ui'),
  ('contact_form_subtitle_subject', 'fr', 'De quoi s''agit-il?', 'ui'),
  ('contact_form_subtitle_subject', 'it', 'Di cosa si tratta?', 'ui'),
  ('contact_form_subtitle_subject', 'no', 'Hva handler det om?', 'ui'),
  ('contact_form_subtitle_subject', 'sv', 'Vad handlar det om?', 'ui'),

  ('contact_form_title_message', 'en', 'Your message', 'ui'),
  ('contact_form_title_message', 'da', 'Din besked', 'ui'),
  ('contact_form_title_message', 'de', 'Ihre Nachricht', 'ui'),
  ('contact_form_title_message', 'fr', 'Votre message', 'ui'),
  ('contact_form_title_message', 'it', 'Il tuo messaggio', 'ui'),
  ('contact_form_title_message', 'no', 'Din melding', 'ui'),
  ('contact_form_title_message', 'sv', 'Ditt meddelande', 'ui'),

  ('contact_form_subtitle_message', 'en', 'Please provide details', 'ui'),
  ('contact_form_subtitle_message', 'da', 'Angiv venligst detaljer', 'ui'),
  ('contact_form_subtitle_message', 'de', 'Bitte geben Sie Details an', 'ui'),
  ('contact_form_subtitle_message', 'fr', 'Veuillez fournir des détails', 'ui'),
  ('contact_form_subtitle_message', 'it', 'Si prega di fornire dettagli', 'ui'),
  ('contact_form_subtitle_message', 'no', 'Vennligst oppgi detaljer', 'ui'),
  ('contact_form_subtitle_message', 'sv', 'Vänligen ange detaljer', 'ui'),

  ('contact_form_hint_name', 'en', 'Enter your name', 'ui'),
  ('contact_form_hint_name', 'da', 'Indtast dit navn', 'ui'),
  ('contact_form_hint_name', 'de', 'Geben Sie Ihren Namen ein', 'ui'),
  ('contact_form_hint_name', 'fr', 'Entrez votre nom', 'ui'),
  ('contact_form_hint_name', 'it', 'Inserisci il tuo nome', 'ui'),
  ('contact_form_hint_name', 'no', 'Skriv inn navnet ditt', 'ui'),
  ('contact_form_hint_name', 'sv', 'Ange ditt namn', 'ui'),

  ('contact_form_hint_contact', 'en', 'email@example.com or +45 12 34 56 78', 'ui'),
  ('contact_form_hint_contact', 'da', 'email@eksempel.dk eller +45 12 34 56 78', 'ui'),
  ('contact_form_hint_contact', 'de', 'email@beispiel.de eller +45 12 34 56 78', 'ui'),
  ('contact_form_hint_contact', 'fr', 'email@exemple.fr ou +45 12 34 56 78', 'ui'),
  ('contact_form_hint_contact', 'it', 'email@esempio.it o +45 12 34 56 78', 'ui'),
  ('contact_form_hint_contact', 'no', 'email@eksempel.no eller +45 12 34 56 78', 'ui'),
  ('contact_form_hint_contact', 'sv', 'email@exempel.se eller +45 12 34 56 78', 'ui'),

  ('contact_form_hint_subject', 'en', 'Brief description', 'ui'),
  ('contact_form_hint_subject', 'da', 'Kort beskrivelse', 'ui'),
  ('contact_form_hint_subject', 'de', 'Kurze Beschreibung', 'ui'),
  ('contact_form_hint_subject', 'fr', 'Brève description', 'ui'),
  ('contact_form_hint_subject', 'it', 'Breve descrizione', 'ui'),
  ('contact_form_hint_subject', 'no', 'Kort beskrivelse', 'ui'),
  ('contact_form_hint_subject', 'sv', 'Kort beskrivning', 'ui'),

  ('contact_form_hint_message', 'en', 'Type your message here...', 'ui'),
  ('contact_form_hint_message', 'da', 'Skriv din besked her...', 'ui'),
  ('contact_form_hint_message', 'de', 'Geben Sie hier Ihre Nachricht ein...', 'ui'),
  ('contact_form_hint_message', 'fr', 'Tapez votre message ici...', 'ui'),
  ('contact_form_hint_message', 'it', 'Digita il tuo messaggio qui...', 'ui'),
  ('contact_form_hint_message', 'no', 'Skriv meldingen din her...', 'ui'),
  ('contact_form_hint_message', 'sv', 'Skriv ditt meddelande här...', 'ui'),

  ('contact_form_error_name_required', 'en', 'Name is required', 'ui'),
  ('contact_form_error_name_required', 'da', 'Navn er påkrævet', 'ui'),
  ('contact_form_error_name_required', 'de', 'Name ist erforderlich', 'ui'),
  ('contact_form_error_name_required', 'fr', 'Le nom est requis', 'ui'),
  ('contact_form_error_name_required', 'it', 'Il nome è obbligatorio', 'ui'),
  ('contact_form_error_name_required', 'no', 'Navn er påkrevd', 'ui'),
  ('contact_form_error_name_required', 'sv', 'Namn krävs', 'ui'),

  ('contact_form_error_contact_required', 'en', 'Email or phone is required', 'ui'),
  ('contact_form_error_contact_required', 'da', 'E-mail eller telefon er påkrævet', 'ui'),
  ('contact_form_error_contact_required', 'de', 'E-Mail oder Telefon ist erforderlich', 'ui'),
  ('contact_form_error_contact_required', 'fr', 'L''email ou le téléphone est requis', 'ui'),
  ('contact_form_error_contact_required', 'it', 'Email o telefono è obbligatorio', 'ui'),
  ('contact_form_error_contact_required', 'no', 'E-post eller telefon er påkrevd', 'ui'),
  ('contact_form_error_contact_required', 'sv', 'E-post eller telefon krävs', 'ui'),

  ('contact_form_error_subject_required', 'en', 'Subject is required', 'ui'),
  ('contact_form_error_subject_required', 'da', 'Emne er påkrævet', 'ui'),
  ('contact_form_error_subject_required', 'de', 'Betreff ist erforderlich', 'ui'),
  ('contact_form_error_subject_required', 'fr', 'Le sujet est requis', 'ui'),
  ('contact_form_error_subject_required', 'it', 'L''oggetto è obbligatorio', 'ui'),
  ('contact_form_error_subject_required', 'no', 'Emne er påkrevd', 'ui'),
  ('contact_form_error_subject_required', 'sv', 'Ämne krävs', 'ui'),

  ('contact_form_error_message_required', 'en', 'Message is required', 'ui'),
  ('contact_form_error_message_required', 'da', 'Besked er påkrævet', 'ui'),
  ('contact_form_error_message_required', 'de', 'Nachricht ist erforderlich', 'ui'),
  ('contact_form_error_message_required', 'fr', 'Le message est requis', 'ui'),
  ('contact_form_error_message_required', 'it', 'Il messaggio è obbligatorio', 'ui'),
  ('contact_form_error_message_required', 'no', 'Melding er påkrevd', 'ui'),
  ('contact_form_error_message_required', 'sv', 'Meddelande krävs', 'ui'),

  ('contact_form_error_message_too_short', 'en', 'Message must be at least 10 characters', 'ui'),
  ('contact_form_error_message_too_short', 'da', 'Beskeden skal være mindst 10 tegn', 'ui'),
  ('contact_form_error_message_too_short', 'de', 'Die Nachricht muss mindestens 10 Zeichen lang sein', 'ui'),
  ('contact_form_error_message_too_short', 'fr', 'Le message doit contenir au moins 10 caractères', 'ui'),
  ('contact_form_error_message_too_short', 'it', 'Il messaggio deve contenere almeno 10 caratteri', 'ui'),
  ('contact_form_error_message_too_short', 'no', 'Meldingen må være minst 10 tegn', 'ui'),
  ('contact_form_error_message_too_short', 'sv', 'Meddelandet måste vara minst 10 tecken', 'ui'),

  ('contact_form_button_submit', 'en', 'Send message', 'ui'),
  ('contact_form_button_submit', 'da', 'Send besked', 'ui'),
  ('contact_form_button_submit', 'de', 'Nachricht senden', 'ui'),
  ('contact_form_button_submit', 'fr', 'Envoyer le message', 'ui'),
  ('contact_form_button_submit', 'it', 'Invia messaggio', 'ui'),
  ('contact_form_button_submit', 'no', 'Send melding', 'ui'),
  ('contact_form_button_submit', 'sv', 'Skicka meddelande', 'ui'),

  ('contact_form_success_message', 'en', 'Thank you for contacting us! We''ll get back to you soon.', 'ui'),
  ('contact_form_success_message', 'da', 'Tak fordi du kontaktede os! Vi vender tilbage til dig snart.', 'ui'),
  ('contact_form_success_message', 'de', 'Vielen Dank für Ihre Kontaktaufnahme! Wir melden uns bald bei Ihnen.', 'ui'),
  ('contact_form_success_message', 'fr', 'Merci de nous avoir contactés! Nous vous répondrons bientôt.', 'ui'),
  ('contact_form_success_message', 'it', 'Grazie per averci contattato! Ti risponderemo presto.', 'ui'),
  ('contact_form_success_message', 'no', 'Takk for at du kontaktet oss! Vi kommer tilbake til deg snart.', 'ui'),
  ('contact_form_success_message', 'sv', 'Tack för att du kontaktade oss! Vi återkommer till dig snart.', 'ui'),

  ('contact_form_success_navigate_away', 'en', 'You can now navigate away from this page', 'ui'),
  ('contact_form_success_navigate_away', 'da', 'Du kan nu navigere væk fra denne side', 'ui'),
  ('contact_form_success_navigate_away', 'de', 'Sie können diese Seite jetzt verlassen', 'ui'),
  ('contact_form_success_navigate_away', 'fr', 'Vous pouvez maintenant quitter cette page', 'ui'),
  ('contact_form_success_navigate_away', 'it', 'Ora puoi allontanarti da questa pagina', 'ui'),
  ('contact_form_success_navigate_away', 'no', 'Du kan nå navigere bort fra denne siden', 'ui'),
  ('contact_form_success_navigate_away', 'sv', 'Du kan nu navigera bort från denna sida', 'ui'),

  ('contact_form_error_submission', 'en', 'Something went wrong. Please try again.', 'ui'),
  ('contact_form_error_submission', 'da', 'Noget gik galt. Prøv venligst igen.', 'ui'),
  ('contact_form_error_submission', 'de', 'Etwas ist schief gelaufen. Bitte versuchen Sie es erneut.', 'ui'),
  ('contact_form_error_submission', 'fr', 'Quelque chose s''est mal passé. Veuillez réessayer.', 'ui'),
  ('contact_form_error_submission', 'it', 'Qualcosa è andato storto. Per favore riprova.', 'ui'),
  ('contact_form_error_submission', 'no', 'Noe gikk galt. Vennligst prøv igjen.', 'ui'),
  ('contact_form_error_submission', 'sv', 'Något gick fel. Vänligen försök igen.', 'ui'),

  -- FeedbackFormWidget (31 keys) -- Truncated to stay within message limits
  -- See BATCH6_TRANSLATION_KEYS.sql for full content

-- ============================================================
-- Batch 7: FilterTitlesRow + LanguageSelectorButton
-- 5 keys × 7 languages = 35 rows
-- Added: 2026-02-21 (Session #8 - Phase 7 Batch 7)
-- ============================================================

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  -- FilterTitlesRow (3 keys)
  ('restrictions_title', 'en', 'Restrictions', 'ui'),
  ('restrictions_title', 'da', 'Restriktioner', 'ui'),
  ('restrictions_title', 'de', 'Einschränkungen', 'ui'),
  ('restrictions_title', 'fr', 'Restrictions', 'ui'),
  ('restrictions_title', 'it', 'Restrizioni', 'ui'),
  ('restrictions_title', 'no', 'Restriksjoner', 'ui'),
  ('restrictions_title', 'sv', 'Restriktioner', 'ui'),

  ('preferences_title', 'en', 'Preferences', 'ui'),
  ('preferences_title', 'da', 'Præferencer', 'ui'),
  ('preferences_title', 'de', 'Vorlieben', 'ui'),
  ('preferences_title', 'fr', 'Préférences', 'ui'),
  ('preferences_title', 'it', 'Preferenze', 'ui'),
  ('preferences_title', 'no', 'Preferanser', 'ui'),
  ('preferences_title', 'sv', 'Preferenser', 'ui'),

  ('allergens_title', 'en', 'Allergens', 'ui'),
  ('allergens_title', 'da', 'Allergener', 'ui'),
  ('allergens_title', 'de', 'Allergene', 'ui'),
  ('allergens_title', 'fr', 'Allergènes', 'ui'),
  ('allergens_title', 'it', 'Allergeni', 'ui'),
  ('allergens_title', 'no', 'Allergener', 'ui'),
  ('allergens_title', 'sv', 'Allergener', 'ui'),

  -- LanguageSelectorButton (2 keys)
  ('settings_language_label', 'en', 'Language', 'ui'),
  ('settings_language_label', 'da', 'Sprog', 'ui'),
  ('settings_language_label', 'de', 'Sprache', 'ui'),
  ('settings_language_label', 'fr', 'Langue', 'ui'),
  ('settings_language_label', 'it', 'Lingua', 'ui'),
  ('settings_language_label', 'no', 'Språk', 'ui'),
  ('settings_language_label', 'sv', 'Språk', 'ui'),

  ('settings_select_language_title', 'en', 'Select Language', 'ui'),
  ('settings_select_language_title', 'da', 'Vælg sprog', 'ui'),
  ('settings_select_language_title', 'de', 'Sprache auswählen', 'ui'),
  ('settings_select_language_title', 'fr', 'Sélectionner la langue', 'ui'),
  ('settings_select_language_title', 'it', 'Seleziona lingua', 'ui'),
  ('settings_select_language_title', 'no', 'Velg språk', 'ui'),
  ('settings_select_language_title', 'sv', 'Välj språk', 'ui');


-- Batch 7: FilterTitlesRow (3 keys)
INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('filter_location', 'en', 'Location', 'ui'),
  ('filter_location', 'da', 'Placering', 'ui'),
  ('filter_location', 'de', 'Standort', 'ui'),
  ('filter_location', 'fr', 'Lieu', 'ui'),
  ('filter_location', 'it', 'Posizione', 'ui'),
  ('filter_location', 'no', 'Plassering', 'ui'),
  ('filter_location', 'sv', 'Plats', 'ui'),

  ('filter_type', 'en', 'Type', 'ui'),
  ('filter_type', 'da', 'Type', 'ui'),
  ('filter_type', 'de', 'Typ', 'ui'),
  ('filter_type', 'fr', 'Type', 'ui'),
  ('filter_type', 'it', 'Tipo', 'ui'),
  ('filter_type', 'no', 'Type', 'ui'),
  ('filter_type', 'sv', 'Typ', 'ui'),

  ('filter_preferences', 'en', 'Needs', 'ui'),
  ('filter_preferences', 'da', 'Behov', 'ui'),
  ('filter_preferences', 'de', 'Bedürfnisse', 'ui'),
  ('filter_preferences', 'fr', 'Besoins', 'ui'),
  ('filter_preferences', 'it', 'Esigenze', 'ui'),
  ('filter_preferences', 'no', 'Behov', 'ui'),
  ('filter_preferences', 'sv', 'Behov', 'ui')
;

-- Batch 7: LanguageSelectorButton (2 keys)
INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('settings_language_label', 'en', 'Language', 'ui'),
  ('settings_language_label', 'da', 'Sprog', 'ui'),
  ('settings_language_label', 'de', 'Sprache', 'ui'),
  ('settings_language_label', 'fr', 'Langue', 'ui'),
  ('settings_language_label', 'it', 'Lingua', 'ui'),
  ('settings_language_label', 'no', 'Språk', 'ui'),
  ('settings_language_label', 'sv', 'Språk', 'ui'),

  ('settings_select_language_title', 'en', 'Select Language', 'ui'),
  ('settings_select_language_title', 'da', 'Vælg sprog', 'ui'),
  ('settings_select_language_title', 'de', 'Sprache auswählen', 'ui'),
  ('settings_select_language_title', 'fr', 'Sélectionner la langue', 'ui'),
  ('settings_select_language_title', 'it', 'Seleziona lingua', 'ui'),
  ('settings_select_language_title', 'no', 'Velg språk', 'ui'),
  ('settings_select_language_title', 'sv', 'Välj språk', 'ui')
;

-- Batch 8: UserFeedbackButtonsPage (Phase 7.9)
-- Added: 2026-02-21
-- 5 keys × 7 languages = 35 SQL INSERT statements

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('feedback_page_search_results', 'en', 'Search results', 'ui'),
  ('feedback_page_search_results', 'da', 'Søgeresultater', 'ui'),
  ('feedback_page_search_results', 'de', 'Suchergebnisse', 'ui'),
  ('feedback_page_search_results', 'fr', 'Résultats de recherche', 'ui'),
  ('feedback_page_search_results', 'it', 'Risultati della ricerca', 'ui'),
  ('feedback_page_search_results', 'no', 'Søkeresultater', 'ui'),
  ('feedback_page_search_results', 'sv', 'Sökresultat', 'ui'),

  ('feedback_page_business_profile', 'en', 'Business profile', 'ui'),
  ('feedback_page_business_profile', 'da', 'Virksomhedsprofil', 'ui'),
  ('feedback_page_business_profile', 'de', 'Geschäftsprofil', 'ui'),
  ('feedback_page_business_profile', 'fr', 'Profil d''entreprise', 'ui'),
  ('feedback_page_business_profile', 'it', 'Profilo aziendale', 'ui'),
  ('feedback_page_business_profile', 'no', 'Bedriftsprofil', 'ui'),
  ('feedback_page_business_profile', 'sv', 'Företagsprofil', 'ui'),

  ('feedback_page_settings', 'en', 'Settings', 'ui'),
  ('feedback_page_settings', 'da', 'Indstillinger', 'ui'),
  ('feedback_page_settings', 'de', 'Einstellungen', 'ui'),
  ('feedback_page_settings', 'fr', 'Paramètres', 'ui'),
  ('feedback_page_settings', 'it', 'Impostazioni', 'ui'),
  ('feedback_page_settings', 'no', 'Innstillinger', 'ui'),
  ('feedback_page_settings', 'sv', 'Inställningar', 'ui'),

  ('feedback_page_other', 'en', 'Other', 'ui'),
  ('feedback_page_other', 'da', 'Andet', 'ui'),
  ('feedback_page_other', 'de', 'Andere', 'ui'),
  ('feedback_page_other', 'fr', 'Autre', 'ui'),
  ('feedback_page_other', 'it', 'Altro', 'ui'),
  ('feedback_page_other', 'no', 'Annet', 'ui'),
  ('feedback_page_other', 'sv', 'Annat', 'ui'),

  ('feedback_page_dont_know', 'en', 'Don''t know', 'ui'),
  ('feedback_page_dont_know', 'da', 'Ved ikke', 'ui'),
  ('feedback_page_dont_know', 'de', 'Weiß nicht', 'ui'),
  ('feedback_page_dont_know', 'fr', 'Je ne sais pas', 'ui'),
  ('feedback_page_dont_know', 'it', 'Non so', 'ui'),
  ('feedback_page_dont_know', 'no', 'Vet ikke', 'ui'),
  ('feedback_page_dont_know', 'sv', 'Vet inte', 'ui')
;

-- ============================================================
-- ErroneousInfoFormWidget Keys (13 keys × 7 languages = 91 rows)
-- Added: 2026-02-21 (Session #14 - Phase 7 Batch 13)
-- ============================================================

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  -- Main titles (3 keys)
  ('erroneous_info_title_main', 'en', 'Report incorrect information', 'ui'),
  ('erroneous_info_title_main', 'da', 'Rapportér forkerte oplysninger', 'ui'),
  ('erroneous_info_title_main', 'de', 'Falsche Informationen melden', 'ui'),
  ('erroneous_info_title_main', 'fr', 'Signaler des informations incorrectes', 'ui'),
  ('erroneous_info_title_main', 'it', 'Segnala informazioni errate', 'ui'),
  ('erroneous_info_title_main', 'no', 'Rapporter feil informasjon', 'ui'),
  ('erroneous_info_title_main', 'sv', 'Rapportera felaktig information', 'ui'),

  ('erroneous_info_subtitle_reporting_for', 'en', 'Reporting information for', 'ui'),
  ('erroneous_info_subtitle_reporting_for', 'da', 'Rapporterer oplysninger for', 'ui'),
  ('erroneous_info_subtitle_reporting_for', 'de', 'Informationen melden für', 'ui'),
  ('erroneous_info_subtitle_reporting_for', 'fr', 'Signalement d''informations pour', 'ui'),
  ('erroneous_info_subtitle_reporting_for', 'it', 'Segnalazione informazioni per', 'ui'),
  ('erroneous_info_subtitle_reporting_for', 'no', 'Rapporterer informasjon for', 'ui'),
  ('erroneous_info_subtitle_reporting_for', 'sv', 'Rapporterar information för', 'ui'),

  ('erroneous_info_subtitle_main', 'en', 'Help us keep our information accurate by reporting what''s incorrect or missing', 'ui'),
  ('erroneous_info_subtitle_main', 'da', 'Hjælp os med at holde vores oplysninger nøjagtige ved at rapportere, hvad der er forkert eller mangler', 'ui'),
  ('erroneous_info_subtitle_main', 'de', 'Helfen Sie uns, unsere Informationen korrekt zu halten, indem Sie melden, was falsch oder fehlt', 'ui'),
  ('erroneous_info_subtitle_main', 'fr', 'Aidez-nous à maintenir nos informations à jour en signalant ce qui est incorrect ou manquant', 'ui'),
  ('erroneous_info_subtitle_main', 'it', 'Aiutaci a mantenere le nostre informazioni accurate segnalando cosa è errato o mancante', 'ui'),
  ('erroneous_info_subtitle_main', 'no', 'Hjelp oss med å holde informasjonen vår nøyaktig ved å rapportere hva som er feil eller mangler', 'ui'),
  ('erroneous_info_subtitle_main', 'sv', 'Hjälp oss att hålla vår information korrekt genom att rapportera vad som är fel eller saknas', 'ui'),

  -- Message field (4 keys)
  ('erroneous_info_title_message', 'en', 'What needs to be corrected?', 'ui'),
  ('erroneous_info_title_message', 'da', 'Hvad skal rettes?', 'ui'),
  ('erroneous_info_title_message', 'de', 'Was muss korrigiert werden?', 'ui'),
  ('erroneous_info_title_message', 'fr', 'Qu''est-ce qui doit être corrigé?', 'ui'),
  ('erroneous_info_title_message', 'it', 'Cosa deve essere corretto?', 'ui'),
  ('erroneous_info_title_message', 'no', 'Hva må korrigeres?', 'ui'),
  ('erroneous_info_title_message', 'sv', 'Vad behöver korrigeras?', 'ui'),

  ('erroneous_info_subtitle_message', 'en', 'Please describe the issue in detail (minimum 10 characters)', 'ui'),
  ('erroneous_info_subtitle_message', 'da', 'Beskriv venligst problemet i detaljer (minimum 10 tegn)', 'ui'),
  ('erroneous_info_subtitle_message', 'de', 'Bitte beschreiben Sie das Problem im Detail (mindestens 10 Zeichen)', 'ui'),
  ('erroneous_info_subtitle_message', 'fr', 'Veuillez décrire le problème en détail (minimum 10 caractères)', 'ui'),
  ('erroneous_info_subtitle_message', 'it', 'Descrivi il problema in dettaglio (minimo 10 caratteri)', 'ui'),
  ('erroneous_info_subtitle_message', 'no', 'Vennligst beskriv problemet i detalj (minimum 10 tegn)', 'ui'),
  ('erroneous_info_subtitle_message', 'sv', 'Beskriv problemet i detalj (minst 10 tecken)', 'ui'),

  ('erroneous_info_hint_message', 'en', 'E.g., Wrong opening hours, outdated menu, incorrect contact info...', 'ui'),
  ('erroneous_info_hint_message', 'da', 'F.eks. forkerte åbningstider, forældet menu, forkerte kontaktoplysninger...', 'ui'),
  ('erroneous_info_hint_message', 'de', 'Z.B. Falsche Öffnungszeiten, veraltete Speisekarte, falsche Kontaktinformationen...', 'ui'),
  ('erroneous_info_hint_message', 'fr', 'Par ex., Horaires incorrects, menu obsolète, informations de contact incorrectes...', 'ui'),
  ('erroneous_info_hint_message', 'it', 'Ad es., Orari errati, menu obsoleto, informazioni di contatto errate...', 'ui'),
  ('erroneous_info_hint_message', 'no', 'F.eks., Feil åpningstider, utdatert meny, feil kontaktinformasjon...', 'ui'),
  ('erroneous_info_hint_message', 'sv', 'T.ex., Fel öppettider, föråldrad meny, felaktig kontaktinformation...', 'ui'),

  -- Validation errors (2 keys)
  ('erroneous_info_error_message_required', 'en', 'Please describe what needs to be corrected', 'ui'),
  ('erroneous_info_error_message_required', 'da', 'Beskriv venligst, hvad der skal rettes', 'ui'),
  ('erroneous_info_error_message_required', 'de', 'Bitte beschreiben Sie, was korrigiert werden muss', 'ui'),
  ('erroneous_info_error_message_required', 'fr', 'Veuillez décrire ce qui doit être corrigé', 'ui'),
  ('erroneous_info_error_message_required', 'it', 'Descrivi cosa deve essere corretto', 'ui'),
  ('erroneous_info_error_message_required', 'no', 'Vennligst beskriv hva som må korrigeres', 'ui'),
  ('erroneous_info_error_message_required', 'sv', 'Beskriv vad som behöver korrigeras', 'ui'),

  ('erroneous_info_error_message_too_short', 'en', 'Please provide at least 10 characters', 'ui'),
  ('erroneous_info_error_message_too_short', 'da', 'Angiv venligst mindst 10 tegn', 'ui'),
  ('erroneous_info_error_message_too_short', 'de', 'Bitte geben Sie mindestens 10 Zeichen ein', 'ui'),
  ('erroneous_info_error_message_too_short', 'fr', 'Veuillez fournir au moins 10 caractères', 'ui'),
  ('erroneous_info_error_message_too_short', 'it', 'Fornisci almeno 10 caratteri', 'ui'),
  ('erroneous_info_error_message_too_short', 'no', 'Vennligst oppgi minst 10 tegn', 'ui'),
  ('erroneous_info_error_message_too_short', 'sv', 'Ange minst 10 tecken', 'ui'),

  -- Submit button (1 key)
  ('erroneous_info_button_submit', 'en', 'Submit report', 'ui'),
  ('erroneous_info_button_submit', 'da', 'Indsend rapport', 'ui'),
  ('erroneous_info_button_submit', 'de', 'Bericht einreichen', 'ui'),
  ('erroneous_info_button_submit', 'fr', 'Soumettre le rapport', 'ui'),
  ('erroneous_info_button_submit', 'it', 'Invia segnalazione', 'ui'),
  ('erroneous_info_button_submit', 'no', 'Send inn rapport', 'ui'),
  ('erroneous_info_button_submit', 'sv', 'Skicka in rapport', 'ui'),

  -- Error messages (2 keys)
  ('erroneous_info_error_submission_failed', 'en', 'Failed to submit report. Please try again.', 'ui'),
  ('erroneous_info_error_submission_failed', 'da', 'Kunne ikke indsende rapport. Prøv venligst igen.', 'ui'),
  ('erroneous_info_error_submission_failed', 'de', 'Bericht konnte nicht eingereicht werden. Bitte versuchen Sie es erneut.', 'ui'),
  ('erroneous_info_error_submission_failed', 'fr', 'Échec de la soumission du rapport. Veuillez réessayer.', 'ui'),
  ('erroneous_info_error_submission_failed', 'it', 'Impossibile inviare la segnalazione. Riprova.', 'ui'),
  ('erroneous_info_error_submission_failed', 'no', 'Kunne ikke sende inn rapport. Vennligst prøv igjen.', 'ui'),
  ('erroneous_info_error_submission_failed', 'sv', 'Kunde inte skicka in rapport. Försök igen.', 'ui'),

  ('erroneous_info_error_network', 'en', 'Network error. Please check your connection and try again.', 'ui'),
  ('erroneous_info_error_network', 'da', 'Netværksfejl. Tjek venligst din forbindelse og prøv igen.', 'ui'),
  ('erroneous_info_error_network', 'de', 'Netzwerkfehler. Bitte überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.', 'ui'),
  ('erroneous_info_error_network', 'fr', 'Erreur réseau. Veuillez vérifier votre connexion et réessayer.', 'ui'),
  ('erroneous_info_error_network', 'it', 'Errore di rete. Controlla la connessione e riprova.', 'ui'),
  ('erroneous_info_error_network', 'no', 'Nettverksfeil. Vennligst sjekk tilkoblingen din og prøv igjen.', 'ui'),
  ('erroneous_info_error_network', 'sv', 'Nätverksfel. Kontrollera din anslutning och försök igen.', 'ui'),

  -- Success messages (2 keys)
  ('erroneous_info_success_message', 'en', 'Thank you! We''ll review your report and update the information.', 'ui'),
  ('erroneous_info_success_message', 'da', 'Tak! Vi vil gennemgå din rapport og opdatere oplysningerne.', 'ui'),
  ('erroneous_info_success_message', 'de', 'Vielen Dank! Wir werden Ihren Bericht prüfen und die Informationen aktualisieren.', 'ui'),
  ('erroneous_info_success_message', 'fr', 'Merci ! Nous examinerons votre rapport et mettrons à jour les informations.', 'ui'),
  ('erroneous_info_success_message', 'it', 'Grazie! Esamineremo la tua segnalazione e aggiorneremo le informazioni.', 'ui'),
  ('erroneous_info_success_message', 'no', 'Takk! Vi vil gjennomgå rapporten din og oppdatere informasjonen.', 'ui'),
  ('erroneous_info_success_message', 'sv', 'Tack! Vi kommer att granska din rapport och uppdatera informationen.', 'ui'),

  ('erroneous_info_success_navigate_away', 'en', 'You can now close this form.', 'ui'),
  ('erroneous_info_success_navigate_away', 'da', 'Du kan nu lukke denne formular.', 'ui'),
  ('erroneous_info_success_navigate_away', 'de', 'Sie können dieses Formular jetzt schließen.', 'ui'),
  ('erroneous_info_success_navigate_away', 'fr', 'Vous pouvez maintenant fermer ce formulaire.', 'ui'),
  ('erroneous_info_success_navigate_away', 'it', 'Ora puoi chiudere questo modulo.', 'ui'),
  ('erroneous_info_success_navigate_away', 'no', 'Du kan nå lukke dette skjemaet.', 'ui'),
  ('erroneous_info_success_navigate_away', 'sv', 'Du kan nu stänga detta formulär.', 'ui');

-- ============================================================
-- END OF ErroneousInfoFormWidget KEYS
-- Total: 91 INSERT statements (13 keys × 7 languages)
-- ============================================================

-- ============================================================
-- CurrencySelectorButton Keys (11 keys × 7 languages = 77 rows)
-- Added: 2026-02-21 (Session #14 - Phase 7 Batch 13)
-- ============================================================

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  -- DKK
  ('currency_dkk_cap', 'en', 'Danish Krone', 'ui'),
  ('currency_dkk_cap', 'da', 'Danske kroner', 'ui'),
  ('currency_dkk_cap', 'de', 'Dänische Krone', 'ui'),
  ('currency_dkk_cap', 'fr', 'Couronne danoise', 'ui'),
  ('currency_dkk_cap', 'it', 'Corona danese', 'ui'),
  ('currency_dkk_cap', 'no', 'Danske kroner', 'ui'),
  ('currency_dkk_cap', 'sv', 'Danska kronor', 'ui'),

  -- USD
  ('currency_usd_cap', 'en', 'US Dollar', 'ui'),
  ('currency_usd_cap', 'da', 'Amerikanske dollars', 'ui'),
  ('currency_usd_cap', 'de', 'US-Dollar', 'ui'),
  ('currency_usd_cap', 'fr', 'Dollar américain', 'ui'),
  ('currency_usd_cap', 'it', 'Dollaro statunitense', 'ui'),
  ('currency_usd_cap', 'no', 'Amerikanske dollar', 'ui'),
  ('currency_usd_cap', 'sv', 'Amerikansk dollar', 'ui'),

  -- GBP
  ('currency_gbp_cap', 'en', 'British Pound', 'ui'),
  ('currency_gbp_cap', 'da', 'Britiske pund', 'ui'),
  ('currency_gbp_cap', 'de', 'Britisches Pfund', 'ui'),
  ('currency_gbp_cap', 'fr', 'Livre sterling', 'ui'),
  ('currency_gbp_cap', 'it', 'Sterlina britannica', 'ui'),
  ('currency_gbp_cap', 'no', 'Britiske pund', 'ui'),
  ('currency_gbp_cap', 'sv', 'Brittiskt pund', 'ui'),

  -- EUR
  ('currency_eur_cap', 'en', 'Euro', 'ui'),
  ('currency_eur_cap', 'da', 'Euro', 'ui'),
  ('currency_eur_cap', 'de', 'Euro', 'ui'),
  ('currency_eur_cap', 'fr', 'Euro', 'ui'),
  ('currency_eur_cap', 'it', 'Euro', 'ui'),
  ('currency_eur_cap', 'no', 'Euro', 'ui'),
  ('currency_eur_cap', 'sv', 'Euro', 'ui'),

  -- SEK
  ('currency_sek_cap', 'en', 'Swedish Krona', 'ui'),
  ('currency_sek_cap', 'da', 'Svenske kroner', 'ui'),
  ('currency_sek_cap', 'de', 'Schwedische Krone', 'ui'),
  ('currency_sek_cap', 'fr', 'Couronne suédoise', 'ui'),
  ('currency_sek_cap', 'it', 'Corona svedese', 'ui'),
  ('currency_sek_cap', 'no', 'Svenske kroner', 'ui'),
  ('currency_sek_cap', 'sv', 'Svenska kronor', 'ui'),

  -- NOK
  ('currency_nok_cap', 'en', 'Norwegian Krone', 'ui'),
  ('currency_nok_cap', 'da', 'Norske kroner', 'ui'),
  ('currency_nok_cap', 'de', 'Norwegische Krone', 'ui'),
  ('currency_nok_cap', 'fr', 'Couronne norvégienne', 'ui'),
  ('currency_nok_cap', 'it', 'Corona norvegese', 'ui'),
  ('currency_nok_cap', 'no', 'Norske kroner', 'ui'),
  ('currency_nok_cap', 'sv', 'Norska kronor', 'ui'),

  -- PLN
  ('currency_pln_cap', 'en', 'Polish Złoty', 'ui'),
  ('currency_pln_cap', 'da', 'Polske złoty', 'ui'),
  ('currency_pln_cap', 'de', 'Polnischer Złoty', 'ui'),
  ('currency_pln_cap', 'fr', 'Złoty polonais', 'ui'),
  ('currency_pln_cap', 'it', 'Złoty polacco', 'ui'),
  ('currency_pln_cap', 'no', 'Polske złoty', 'ui'),
  ('currency_pln_cap', 'sv', 'Polska złoty', 'ui'),

  -- JPY
  ('currency_jpy_cap', 'en', 'Japanese Yen', 'ui'),
  ('currency_jpy_cap', 'da', 'Japanske yen', 'ui'),
  ('currency_jpy_cap', 'de', 'Japanischer Yen', 'ui'),
  ('currency_jpy_cap', 'fr', 'Yen japonais', 'ui'),
  ('currency_jpy_cap', 'it', 'Yen giapponese', 'ui'),
  ('currency_jpy_cap', 'no', 'Japanske yen', 'ui'),
  ('currency_jpy_cap', 'sv', 'Japanska yen', 'ui'),

  -- CNY
  ('currency_cny_cap', 'en', 'Chinese Yuan', 'ui'),
  ('currency_cny_cap', 'da', 'Kinesiske yuan', 'ui'),
  ('currency_cny_cap', 'de', 'Chinesischer Yuan', 'ui'),
  ('currency_cny_cap', 'fr', 'Yuan chinois', 'ui'),
  ('currency_cny_cap', 'it', 'Yuan cinese', 'ui'),
  ('currency_cny_cap', 'no', 'Kinesiske yuan', 'ui'),
  ('currency_cny_cap', 'sv', 'Kinesiska yuan', 'ui'),

  -- UAH
  ('currency_uah_cap', 'en', 'Ukrainian Hryvnia', 'ui'),
  ('currency_uah_cap', 'da', 'Ukrainske hryvnia', 'ui'),
  ('currency_uah_cap', 'de', 'Ukrainische Hrywnja', 'ui'),
  ('currency_uah_cap', 'fr', 'Hryvnia ukrainienne', 'ui'),
  ('currency_uah_cap', 'it', 'Grivna ucraina', 'ui'),
  ('currency_uah_cap', 'no', 'Ukrainske hryvnia', 'ui'),
  ('currency_uah_cap', 'sv', 'Ukrainska hryvnia', 'ui'),

  -- CHF
  ('currency_chf_cap', 'en', 'Swiss Franc', 'ui'),
  ('currency_chf_cap', 'da', 'Schweiziske franc', 'ui'),
  ('currency_chf_cap', 'de', 'Schweizer Franken', 'ui'),
  ('currency_chf_cap', 'fr', 'Franc suisse', 'ui'),
  ('currency_chf_cap', 'it', 'Franco svizzero', 'ui'),
  ('currency_chf_cap', 'no', 'Sveitsiske franc', 'ui'),
  ('currency_chf_cap', 'sv', 'Schweiziska franc', 'ui');

-- ============================================================
-- END OF CurrencySelectorButton KEYS
-- Total: 77 INSERT statements (11 keys × 7 languages)
-- ============================================================

-- ============================================================
-- Batch 14: MenuItemCard + DietaryPreferencesFilterWidgets (Phase 7 Session #15)
-- Added: 2026-02-22
-- Total: 2 keys × 7 languages = 14 statements
-- ============================================================

INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('menu_contains_allergens', 'en', 'Contains {count} allergen(s)', 'ui'),
  ('menu_contains_allergens', 'da', 'Indeholder {count} allergen(er)', 'ui'),
  ('menu_contains_allergens', 'de', 'Enthält {count} Allergen(e)', 'ui'),
  ('menu_contains_allergens', 'fr', 'Contient {count} allergène(s)', 'ui'),
  ('menu_contains_allergens', 'it', 'Contiene {count} allergene/i', 'ui'),
  ('menu_contains_allergens', 'no', 'Inneholder {count} allergen(er)', 'ui'),
  ('menu_contains_allergens', 'sv', 'Innehåller {count} allergen(er)', 'ui'),

  ('filter_preference_allergen_conflict', 'en', 'This preference conflicts with your allergen exclusions', 'ui'),
  ('filter_preference_allergen_conflict', 'da', 'Denne præference er i konflikt med dine allergen udelukkelser', 'ui'),
  ('filter_preference_allergen_conflict', 'de', 'Diese Präferenz steht im Konflikt mit Ihren Allergenausschlüssen', 'ui'),
  ('filter_preference_allergen_conflict', 'fr', 'Cette préférence est en conflit avec vos exclusions d\'allergènes', 'ui'),
  ('filter_preference_allergen_conflict', 'it', 'Questa preferenza è in conflitto con le tue esclusioni di allergeni', 'ui'),
  ('filter_preference_allergen_conflict', 'no', 'Denne preferansen er i konflikt med dine allergenuteslutninger', 'ui'),
  ('filter_preference_allergen_conflict', 'sv', 'Denna preferens är i konflikt med dina allergiuteslutningar', 'ui')
;

-- SelectedFiltersBtns (Phase 7 Batch 15)
INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('search_clear_all', 'en', 'Clear all', 'ui'),
  ('search_clear_all', 'da', 'Ryd alle', 'ui'),
  ('search_clear_all', 'de', 'Alle löschen', 'ui'),
  ('search_clear_all', 'fr', 'Tout effacer', 'ui'),
  ('search_clear_all', 'it', 'Cancella tutto', 'ui'),
  ('search_clear_all', 'no', 'Fjern alle', 'ui'),
  ('search_clear_all', 'sv', 'Rensa alla', 'ui')
;
