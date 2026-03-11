/// Fallback translations for Business Profile page widgets
/// Used when translation cache is empty or API is unavailable
///
/// Structure: Map of languageCode to Map of translationKey to translationValue
///
/// Categories:
/// - match_card: Filter match card widget
/// - quick_actions: Quick action pills (Call, Website, Booking, Map)
/// - gallery: Inline gallery widget (heading=tab_gallery, tabs=tab_menu/gallery_*)
/// - menu: Inline menu widget
/// - opening_hours: Opening hours & contact widget
/// - section_headings: Section titles
/// - page_level: Business profile page elements
///
/// Languages: en, da, de, fr, it, no, sv (matches app's 7 supported languages)
///
/// Usage: Wired into td() fallback chain in translation_service.dart
const Map<String, Map<String, String>> kBusinessProfileFallbackTranslations = {
  // ============================================================================
  // ENGLISH
  // ============================================================================
  'en': {
    // Match Card
    'match_card_matches': 'Matches {count} of {total} filters',
    'match_card_tap_details': 'Tap for details',

    // Quick Actions
    'action_call': 'Call',
    'action_booking': 'Book',
    'action_map': 'Map',
    'choose_map_app': 'Choose map app',
    'map_select_app': 'Choose navigation',
    'map_app_google': 'Google Maps',
    'map_app_apple': 'Apple Maps',

    // Quick Actions - Error Messages
    'error_cannot_make_call': 'Unable to open phone app',
    'error_cannot_open_website': 'Unable to open website',
    'error_cannot_open_booking': 'Unable to open booking page',
    'error_no_location_data': 'Location not available for this business',
    'error_no_map_app': 'No map app found on your device',
    'error_cannot_open_map': 'Unable to open map',

    // Gallery (keys match code: gallery_food, not gallery_tab_food)
    'tab_gallery': 'Gallery',
    'gallery_view_all': 'View all images',
    'gallery_food': 'Food',
    'tab_menu': 'Menu',
    'gallery_interior': 'Interior',
    'gallery_outdoor': 'Outdoor',
    'gallery_no_images': 'No images available',

    // Menu
    'menu_category_all': 'All',
    'menu_filters_active': '{count} filters active',
    'menu_filters_none': 'No filters active',
    'menu_filters_edit': 'Edit',
    'menu_show_all': 'Show all {count} items',
    'expandable_show_less': 'Show less',
    'menu_view_full_page': 'View full menu',
    'menu_load_error': 'Could not load the menu. Please try again.',
    'menu_last_updated_prefix': 'Last brought up to date on',
    'menu_hide_filters': 'Hide filters',
    'menu_show_filters': 'Show filters',
    'menu_filter_summary': 'Showing {count} items',

    // Opening Hours & Contact
    'opening_hours_and_contact': 'Opening Hours & Contact',
    'opening_hours_label': 'OPENING HOURS',
    'contact_label': 'CONTACT',
    'today_prefix': 'Today: ',
    'closed': 'Closed',
    'phone': 'Phone',
    'phone_number_label': 'Phone Number',
    'email_label': 'Email',
    'facebook_label': 'Facebook',
    'tiktok_label': 'TikTok',
    'send_email_action': 'Send email',
    'visit_website_action': 'Visit website',
    'make_reservation_action': 'Make reservation',
    'view_instagram_action': 'View on Instagram',
    'view_facebook_action': 'View on Facebook',
    'view_tiktok_action': 'View on TikTok',
    'error_cannot_open_email': 'Cannot open email app',
    'website': 'Website',
    'booking': 'Booking',
    'instagram': 'Instagram',
    'copied_to_clipboard': 'Copied to clipboard',

    // Section Headings
    'facilities_heading': 'Facilities',

    // Page-level
    'error_loading_business': 'Could not load business profile',
    'about_payment_options_label': 'Payment Options',
    'about_description_label': 'Description',
    'about_report_incorrect_info': 'Report incorrect information',
    'retry': 'Retry',
    'share_business_text': 'Check out {name} on JourneyMate!',
    'business_type_default': 'Restaurant',

    // Facilities Info
    'no_description_available': 'No description available',
  },

  // ============================================================================
  // DANISH
  // ============================================================================
  'da': {
    // Match Card
    'match_card_matches': 'Matcher {count} af {total} filtre',
    'match_card_tap_details': 'Tryk for detaljer',

    // Quick Actions
    'action_call': 'Ring',
    'action_booking': 'Book',
    'action_map': 'Kort',
    'choose_map_app': 'V\u00e6lg kortapp',
    'map_select_app': 'V\u00e6lg navigation',
    'map_app_google': 'Google Maps',
    'map_app_apple': 'Apple Maps',

    // Quick Actions - Error Messages
    'error_cannot_make_call': 'Kan ikke \u00e5bne telefon-app',
    'error_cannot_open_website': 'Kan ikke \u00e5bne hjemmeside',
    'error_cannot_open_booking': 'Kan ikke \u00e5bne bookingside',
    'error_no_location_data': 'Placering ikke tilg\u00e6ngelig for denne virksomhed',
    'error_no_map_app': 'Ingen kort-app fundet p\u00e5 din enhed',
    'error_cannot_open_map': 'Kan ikke \u00e5bne kort',

    // Gallery
    'tab_gallery': 'Galleri',
    'gallery_view_all': 'Se alle {count} billeder',
    'gallery_food': 'Mad',
    'tab_menu': 'Menu',
    'gallery_interior': 'Inde',
    'gallery_outdoor': 'Ude',
    'gallery_no_images': 'Ingen billeder tilg\u00e6ngelige',

    // Menu
    'menu_category_all': 'Alle',
    'menu_filters_active': '{count} filtre aktive',
    'menu_filters_none': 'Ingen filtre aktive',
    'menu_filters_edit': 'Rediger',
    'menu_show_all': 'Vis alle {count} retter',
    'expandable_show_less': 'Vis mindre',
    'menu_view_full_page': 'Vis p\u00e5 hel side',
    'menu_load_error': 'Kunne ikke indl\u00e6se menuen. Pr\u00f8v igen.',
    'menu_last_updated_prefix': 'Sidst opdateret',
    'menu_hide_filters': 'Skjul filtre',
    'menu_show_filters': 'Vis filtre',
    'menu_filter_summary': 'Viser {count} retter',

    // Opening Hours & Contact
    'opening_hours_and_contact': '\u00c5bningstider og kontakt',
    'opening_hours_label': '\u00c5BNINGSTIDER',
    'contact_label': 'KONTAKT',
    'today_prefix': 'I dag: ',
    'closed': 'Lukket',
    'phone': 'Telefon',
    'phone_number_label': 'Telefonnummer',
    'email_label': 'E-mail',
    'facebook_label': 'Facebook',
    'tiktok_label': 'TikTok',
    'send_email_action': 'Send e-mail',
    'visit_website_action': 'Bes\u00f8g hjemmeside',
    'make_reservation_action': 'Foretag en reservation',
    'view_instagram_action': 'Se p\u00e5 Instagram',
    'view_facebook_action': 'Se p\u00e5 Facebook',
    'view_tiktok_action': 'Se p\u00e5 TikTok',
    'error_cannot_open_email': 'Kan ikke \u00e5bne e-mail app',
    'website': 'Hjemmeside',
    'booking': 'Booking',
    'instagram': 'Instagram',
    'copied_to_clipboard': 'Kopieret til udklipsholder',

    // Section Headings
    'facilities_heading': 'Faciliteter',

    // Page-level
    'error_loading_business': 'Kunne ikke indl\u00e6se virksomhedsprofil',
    'about_payment_options_label': 'Betalingsmuligheder',
    'about_description_label': 'Om',
    'about_report_incorrect_info': 'Rapporter forkerte oplysninger',
    'retry': 'Pr\u00f8v igen',
    'share_business_text': 'Se {name} p\u00e5 JourneyMate!',
    'business_type_default': 'Restaurant',

    // Facilities Info
    'no_description_available': 'Ingen beskrivelse tilg\u00e6ngelig',
  },

  // ============================================================================
  // GERMAN
  // ============================================================================
  'de': {
    // Match Card
    'match_card_matches': 'Entspricht {count} von {total} Filtern',
    'match_card_tap_details': 'Tippen f\u00fcr Details',

    // Quick Actions
    'action_call': 'Anrufen',
    'action_booking': 'Buchen',
    'action_map': 'Karte',
    'choose_map_app': 'Karten-App w\u00e4hlen',
    'map_select_app': 'Navigation w\u00e4hlen',
    'map_app_google': 'Google Maps',
    'map_app_apple': 'Apple Maps',

    // Quick Actions - Error Messages
    'error_cannot_make_call': 'Telefon-App kann nicht ge\u00f6ffnet werden',
    'error_cannot_open_website': 'Webseite kann nicht ge\u00f6ffnet werden',
    'error_cannot_open_booking': 'Buchungsseite kann nicht ge\u00f6ffnet werden',
    'error_no_location_data': 'Standort f\u00fcr dieses Unternehmen nicht verf\u00fcgbar',
    'error_no_map_app': 'Keine Karten-App auf Ihrem Ger\u00e4t gefunden',
    'error_cannot_open_map': 'Karte kann nicht ge\u00f6ffnet werden',

    // Gallery
    'tab_gallery': 'Galerie',
    'gallery_view_all': 'Alle {count} Fotos anzeigen',
    'gallery_food': 'Essen',
    'tab_menu': 'Men\u00fc',
    'gallery_interior': 'Innenraum',
    'gallery_outdoor': 'Au\u00dfenbereich',
    'gallery_no_images': 'Keine Bilder verf\u00fcgbar',

    // Menu
    'menu_category_all': 'Alle',
    'menu_filters_active': '{count} Filter aktiv',
    'menu_filters_none': 'Keine Filter aktiv',
    'menu_filters_edit': 'Bearbeiten',
    'menu_show_all': 'Alle {count} Gerichte anzeigen',
    'expandable_show_less': 'Weniger anzeigen',
    'menu_view_full_page': 'Vollst\u00e4ndige Speisekarte anzeigen',
    'menu_load_error': 'Men\u00fc konnte nicht geladen werden. Bitte versuchen Sie es erneut.',
    'menu_last_updated_prefix': 'Zuletzt aktualisiert',
    'menu_hide_filters': 'Filter ausblenden',
    'menu_show_filters': 'Filter anzeigen',
    'menu_filter_summary': '{count} Gerichte werden angezeigt',

    // Opening Hours & Contact
    'opening_hours_and_contact': '\u00d6ffnungszeiten und Kontakt',
    'opening_hours_label': '\u00d6FFNUNGSZEITEN',
    'contact_label': 'KONTAKT',
    'today_prefix': 'Heute: ',
    'closed': 'Geschlossen',
    'phone': 'Telefon',
    'phone_number_label': 'Telefonnummer',
    'email_label': 'E-Mail',
    'facebook_label': 'Facebook',
    'tiktok_label': 'TikTok',
    'send_email_action': 'E-Mail senden',
    'visit_website_action': 'Webseite besuchen',
    'make_reservation_action': 'Reservierung vornehmen',
    'view_instagram_action': 'Auf Instagram ansehen',
    'view_facebook_action': 'Auf Facebook ansehen',
    'view_tiktok_action': 'Auf TikTok ansehen',
    'error_cannot_open_email': 'E-Mail-App kann nicht ge\u00f6ffnet werden',
    'website': 'Webseite',
    'booking': 'Buchung',
    'instagram': 'Instagram',
    'copied_to_clipboard': 'In die Zwischenablage kopiert',

    // Section Headings
    'facilities_heading': 'Ausstattung',

    // Page-level
    'error_loading_business': 'Unternehmensprofil konnte nicht geladen werden',
    'about_payment_options_label': 'Zahlungsm\u00f6glichkeiten',
    'about_description_label': '\u00dcber',
    'about_report_incorrect_info': 'Falsche Informationen melden',
    'retry': 'Erneut versuchen',
    'share_business_text': 'Schau dir {name} auf JourneyMate an!',
    'business_type_default': 'Restaurant',

    // Facilities Info
    'no_description_available': 'Keine Beschreibung verf\u00fcgbar',
  },

  // ============================================================================
  // FRENCH
  // ============================================================================
  'fr': {
    // Match Card
    'match_card_matches': 'Correspond \u00e0 {count} sur {total} filtres',
    'match_card_tap_details': 'Appuyez pour les d\u00e9tails',

    // Quick Actions
    'action_call': 'Appeler',
    'action_booking': 'R\u00e9server',
    'action_map': 'Carte',
    'choose_map_app': "Choisir l'app de carte",
    'map_select_app': 'Choisir la navigation',
    'map_app_google': 'Google Maps',
    'map_app_apple': 'Apple Maps',

    // Quick Actions - Error Messages
    'error_cannot_make_call': "Impossible d'ouvrir l'application t\u00e9l\u00e9phone",
    'error_cannot_open_website': "Impossible d'ouvrir le site web",
    'error_cannot_open_booking': "Impossible d'ouvrir la page de r\u00e9servation",
    'error_no_location_data': 'Localisation non disponible pour cette entreprise',
    'error_no_map_app': 'Aucune application de carte trouv\u00e9e',
    'error_cannot_open_map': "Impossible d'ouvrir la carte",

    // Gallery
    'tab_gallery': 'Galerie',
    'gallery_view_all': 'Voir les {count} photos',
    'gallery_food': 'Nourriture',
    'tab_menu': 'Menu',
    'gallery_interior': 'Int\u00e9rieur',
    'gallery_outdoor': 'Ext\u00e9rieur',
    'gallery_no_images': 'Aucune image disponible',

    // Menu
    'menu_category_all': 'Tous',
    'menu_filters_active': '{count} filtres actifs',
    'menu_filters_none': 'Aucun filtre actif',
    'menu_filters_edit': 'Modifier',
    'menu_show_all': 'Afficher tous les {count} plats',
    'expandable_show_less': 'Afficher moins',
    'menu_view_full_page': 'Voir le menu complet',
    'menu_load_error': 'Impossible de charger le menu. Veuillez r\u00e9essayer.',
    'menu_last_updated_prefix': 'Derni\u00e8re mise \u00e0 jour',
    'menu_hide_filters': 'Masquer les filtres',
    'menu_show_filters': 'Afficher les filtres',
    'menu_filter_summary': 'Affichage de {count} plats',

    // Opening Hours & Contact
    'opening_hours_and_contact': 'Horaires et contact',
    'opening_hours_label': 'HORAIRES',
    'contact_label': 'CONTACT',
    'today_prefix': "Aujourd'hui : ",
    'closed': 'Ferm\u00e9',
    'phone': 'T\u00e9l\u00e9phone',
    'phone_number_label': 'Num\u00e9ro de t\u00e9l\u00e9phone',
    'email_label': 'E-mail',
    'facebook_label': 'Facebook',
    'tiktok_label': 'TikTok',
    'send_email_action': 'Envoyer un e-mail',
    'visit_website_action': 'Visiter le site web',
    'make_reservation_action': 'Faire une r\u00e9servation',
    'view_instagram_action': 'Voir sur Instagram',
    'view_facebook_action': 'Voir sur Facebook',
    'view_tiktok_action': 'Voir sur TikTok',
    'error_cannot_open_email': "Impossible d'ouvrir l'app e-mail",
    'website': 'Site web',
    'booking': 'R\u00e9servation',
    'instagram': 'Instagram',
    'copied_to_clipboard': 'Copi\u00e9 dans le presse-papiers',

    // Section Headings
    'facilities_heading': '\u00c9quipements',

    // Page-level
    'error_loading_business': "Impossible de charger le profil de l'entreprise",
    'about_payment_options_label': 'Options de paiement',
    'about_description_label': '\u00c0 propos',
    'about_report_incorrect_info': 'Signaler des informations incorrectes',
    'retry': 'R\u00e9essayer',
    'share_business_text': 'D\u00e9couvrez {name} sur JourneyMate !',
    'business_type_default': 'Restaurant',

    // Facilities Info
    'no_description_available': 'Aucune description disponible',
  },

  // ============================================================================
  // ITALIAN
  // ============================================================================
  'it': {
    // Match Card
    'match_card_matches': 'Corrisponde a {count} su {total} filtri',
    'match_card_tap_details': 'Tocca per i dettagli',

    // Quick Actions
    'action_call': 'Chiama',
    'action_booking': 'Prenota',
    'action_map': 'Mappa',
    'choose_map_app': 'Scegli app mappe',
    'map_select_app': 'Scegli navigazione',
    'map_app_google': 'Google Maps',
    'map_app_apple': 'Apple Maps',

    // Quick Actions - Error Messages
    'error_cannot_make_call': "Impossibile aprire l'app telefono",
    'error_cannot_open_website': 'Impossibile aprire il sito web',
    'error_cannot_open_booking': 'Impossibile aprire la pagina di prenotazione',
    'error_no_location_data': 'Posizione non disponibile per questa attivit\u00e0',
    'error_no_map_app': 'Nessuna app mappe trovata sul dispositivo',
    'error_cannot_open_map': 'Impossibile aprire la mappa',

    // Gallery
    'tab_gallery': 'Galleria',
    'gallery_view_all': 'Vedi tutte le {count} foto',
    'gallery_food': 'Cibo',
    'tab_menu': 'Menu',
    'gallery_interior': 'Interno',
    'gallery_outdoor': 'Esterno',
    'gallery_no_images': 'Nessuna immagine disponibile',

    // Menu
    'menu_category_all': 'Tutti',
    'menu_filters_active': '{count} filtri attivi',
    'menu_filters_none': 'Nessun filtro attivo',
    'menu_filters_edit': 'Modifica',
    'menu_show_all': 'Mostra tutti i {count} piatti',
    'expandable_show_less': 'Mostra meno',
    'menu_view_full_page': 'Vedi menu completo',
    'menu_load_error': 'Impossibile caricare il menu. Riprova.',
    'menu_last_updated_prefix': 'Ultimo aggiornamento',
    'menu_hide_filters': 'Nascondi filtri',
    'menu_show_filters': 'Mostra filtri',
    'menu_filter_summary': 'Visualizzazione di {count} piatti',

    // Opening Hours & Contact
    'opening_hours_and_contact': 'Orari e contatto',
    'opening_hours_label': 'ORARI',
    'contact_label': 'CONTATTO',
    'today_prefix': 'Oggi: ',
    'closed': 'Chiuso',
    'phone': 'Telefono',
    'phone_number_label': 'Numero di telefono',
    'email_label': 'E-mail',
    'facebook_label': 'Facebook',
    'tiktok_label': 'TikTok',
    'send_email_action': 'Invia e-mail',
    'visit_website_action': 'Visita il sito web',
    'make_reservation_action': 'Effettua una prenotazione',
    'view_instagram_action': 'Vedi su Instagram',
    'view_facebook_action': 'Vedi su Facebook',
    'view_tiktok_action': 'Vedi su TikTok',
    'error_cannot_open_email': "Impossibile aprire l'app e-mail",
    'website': 'Sito web',
    'booking': 'Prenotazione',
    'instagram': 'Instagram',
    'copied_to_clipboard': 'Copiato negli appunti',

    // Section Headings
    'facilities_heading': 'Servizi',

    // Page-level
    'error_loading_business': "Impossibile caricare il profilo dell'attivit\u00e0",
    'about_payment_options_label': 'Opzioni di pagamento',
    'about_description_label': 'Informazioni',
    'about_report_incorrect_info': 'Segnala informazioni errate',
    'retry': 'Riprova',
    'share_business_text': 'Scopri {name} su JourneyMate!',
    'business_type_default': 'Ristorante',

    // Facilities Info
    'no_description_available': 'Nessuna descrizione disponibile',
  },

  // ============================================================================
  // NORWEGIAN
  // ============================================================================
  'no': {
    // Match Card
    'match_card_matches': 'Matcher {count} av {total} filtre',
    'match_card_tap_details': 'Trykk for detaljer',

    // Quick Actions
    'action_call': 'Ring',
    'action_booking': 'Bestill',
    'action_map': 'Kart',
    'choose_map_app': 'Velg kartapp',
    'map_select_app': 'Velg navigasjon',
    'map_app_google': 'Google Maps',
    'map_app_apple': 'Apple Maps',

    // Quick Actions - Error Messages
    'error_cannot_make_call': 'Kan ikke \u00e5pne telefonappen',
    'error_cannot_open_website': 'Kan ikke \u00e5pne nettstedet',
    'error_cannot_open_booking': 'Kan ikke \u00e5pne bestillingssiden',
    'error_no_location_data': 'Plassering ikke tilgjengelig for denne virksomheten',
    'error_no_map_app': 'Ingen kartapp funnet p\u00e5 enheten',
    'error_cannot_open_map': 'Kan ikke \u00e5pne kartet',

    // Gallery
    'tab_gallery': 'Galleri',
    'gallery_view_all': 'Se alle {count} bilder',
    'gallery_food': 'Mat',
    'tab_menu': 'Meny',
    'gallery_interior': 'Interi\u00f8r',
    'gallery_outdoor': 'Utend\u00f8rs',
    'gallery_no_images': 'Ingen bilder tilgjengelig',

    // Menu
    'menu_category_all': 'Alle',
    'menu_filters_active': '{count} filtre aktive',
    'menu_filters_none': 'Ingen filtre aktive',
    'menu_filters_edit': 'Rediger',
    'menu_show_all': 'Vis alle {count} retter',
    'expandable_show_less': 'Vis mindre',
    'menu_view_full_page': 'Vis hele menyen',
    'menu_load_error': 'Kunne ikke laste menyen. Pr\u00f8v igjen.',
    'menu_last_updated_prefix': 'Sist oppdatert',
    'menu_hide_filters': 'Skjul filtre',
    'menu_show_filters': 'Vis filtre',
    'menu_filter_summary': 'Viser {count} retter',

    // Opening Hours & Contact
    'opening_hours_and_contact': '\u00c5pningstider og kontakt',
    'opening_hours_label': '\u00c5PNINGSTIDER',
    'contact_label': 'KONTAKT',
    'today_prefix': 'I dag: ',
    'closed': 'Stengt',
    'phone': 'Telefon',
    'phone_number_label': 'Telefonnummer',
    'email_label': 'E-post',
    'facebook_label': 'Facebook',
    'tiktok_label': 'TikTok',
    'send_email_action': 'Send e-post',
    'visit_website_action': 'Bes\u00f8k nettsted',
    'make_reservation_action': 'Gj\u00f8r en reservasjon',
    'view_instagram_action': 'Se p\u00e5 Instagram',
    'view_facebook_action': 'Se p\u00e5 Facebook',
    'view_tiktok_action': 'Se p\u00e5 TikTok',
    'error_cannot_open_email': 'Kan ikke \u00e5pne e-postappen',
    'website': 'Nettsted',
    'booking': 'Bestilling',
    'instagram': 'Instagram',
    'copied_to_clipboard': 'Kopiert til utklippstavlen',

    // Section Headings
    'facilities_heading': 'Fasiliteter',

    // Page-level
    'error_loading_business': 'Kunne ikke laste virksomhetsprofil',
    'about_payment_options_label': 'Betalingsalternativer',
    'about_description_label': 'Om',
    'about_report_incorrect_info': 'Rapporter feil informasjon',
    'retry': 'Pr\u00f8v igjen',
    'share_business_text': 'Sjekk ut {name} p\u00e5 JourneyMate!',
    'business_type_default': 'Restaurant',

    // Facilities Info
    'no_description_available': 'Ingen beskrivelse tilgjengelig',
  },

  // ============================================================================
  // SWEDISH
  // ============================================================================
  'sv': {
    // Match Card
    'match_card_matches': 'Matchar {count} av {total} filter',
    'match_card_tap_details': 'Tryck f\u00f6r detaljer',

    // Quick Actions
    'action_call': 'Ring',
    'action_booking': 'Boka',
    'action_map': 'Karta',
    'choose_map_app': 'V\u00e4lj kartapp',
    'map_select_app': 'V\u00e4lj navigering',
    'map_app_google': 'Google Maps',
    'map_app_apple': 'Apple Maps',

    // Quick Actions - Error Messages
    'error_cannot_make_call': 'Kan inte \u00f6ppna telefonappen',
    'error_cannot_open_website': 'Kan inte \u00f6ppna webbplatsen',
    'error_cannot_open_booking': 'Kan inte \u00f6ppna bokningssidan',
    'error_no_location_data': 'Plats inte tillg\u00e4nglig f\u00f6r detta f\u00f6retag',
    'error_no_map_app': 'Ingen kartapp hittades p\u00e5 enheten',
    'error_cannot_open_map': 'Kan inte \u00f6ppna kartan',

    // Gallery
    'tab_gallery': 'Galleri',
    'gallery_view_all': 'Se alla {count} bilder',
    'gallery_food': 'Mat',
    'tab_menu': 'Meny',
    'gallery_interior': 'Interi\u00f6r',
    'gallery_outdoor': 'Utomhus',
    'gallery_no_images': 'Inga bilder tillg\u00e4ngliga',

    // Menu
    'menu_category_all': 'Alla',
    'menu_filters_active': '{count} filter aktiva',
    'menu_filters_none': 'Inga filter aktiva',
    'menu_filters_edit': 'Redigera',
    'menu_show_all': 'Visa alla {count} r\u00e4tter',
    'expandable_show_less': 'Visa mindre',
    'menu_view_full_page': 'Visa hela menyn',
    'menu_load_error': 'Kunde inte ladda menyn. F\u00f6rs\u00f6k igen.',
    'menu_last_updated_prefix': 'Senast uppdaterad',
    'menu_hide_filters': 'D\u00f6lj filter',
    'menu_show_filters': 'Visa filter',
    'menu_filter_summary': 'Visar {count} r\u00e4tter',

    // Opening Hours & Contact
    'opening_hours_and_contact': '\u00d6ppettider och kontakt',
    'opening_hours_label': '\u00d6PPETTIDER',
    'contact_label': 'KONTAKT',
    'today_prefix': 'Idag: ',
    'closed': 'St\u00e4ngt',
    'phone': 'Telefon',
    'phone_number_label': 'Telefonnummer',
    'email_label': 'E-post',
    'facebook_label': 'Facebook',
    'tiktok_label': 'TikTok',
    'send_email_action': 'Skicka e-post',
    'visit_website_action': 'Bes\u00f6k webbplatsen',
    'make_reservation_action': 'G\u00f6r en reservation',
    'view_instagram_action': 'Se p\u00e5 Instagram',
    'view_facebook_action': 'Se p\u00e5 Facebook',
    'view_tiktok_action': 'Se p\u00e5 TikTok',
    'error_cannot_open_email': 'Kan inte \u00f6ppna e-postappen',
    'website': 'Webbplats',
    'booking': 'Bokning',
    'instagram': 'Instagram',
    'copied_to_clipboard': 'Kopierat till urklipp',

    // Section Headings
    'facilities_heading': 'Faciliteter',

    // Page-level
    'error_loading_business': 'Kunde inte ladda f\u00f6retagsprofil',
    'about_payment_options_label': 'Betalningsalternativ',
    'about_description_label': 'Om',
    'about_report_incorrect_info': 'Rapportera felaktig information',
    'retry': 'F\u00f6rs\u00f6k igen',
    'share_business_text': 'Kolla in {name} p\u00e5 JourneyMate!',
    'business_type_default': 'Restaurang',

    // Facilities Info
    'no_description_available': 'Ingen beskrivning tillg\u00e4nglig',
  },
};
