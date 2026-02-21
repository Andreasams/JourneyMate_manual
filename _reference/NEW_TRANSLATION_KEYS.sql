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
