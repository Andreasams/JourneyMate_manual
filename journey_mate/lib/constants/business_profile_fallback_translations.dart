/// Fallback translations for Business Profile page widgets
/// Used when translation cache is empty or API is unavailable
///
/// Structure: Map of languageCode to Map of translationKey to translationValue
///
/// Categories:
/// - business_profile_page: General page elements
/// - match_card: Filter match card widget
/// - quick_actions: Quick action pills (Call, Website, Booking, Map)
/// - gallery: Inline gallery widget
/// - menu: Inline menu widget
/// - section_headings: Section titles
///
/// Usage in td() function:
/// If key not found in translationsCache, falls back to this map
const Map<String, Map<String, String>> businessProfileFallbackTranslations = {
  // ============================================================================
  // ENGLISH
  // ============================================================================
  'en': {
    // Match Card
    'match_card_matches': 'Matches {count} of {total} filters',
    'match_card_tap_details': 'Tap for details',

    // Quick Actions
    'action_call': 'Call',
    'action_website': 'Website',
    'action_booking': 'Book',
    'action_map': 'Map',

    // Quick Actions - Error Messages
    'error_cannot_make_call': 'Unable to open phone app',
    'error_cannot_open_website': 'Unable to open website',
    'error_cannot_open_booking': 'Unable to open booking page',
    'error_no_map_app': 'No map app found on your device',
    'error_cannot_open_map': 'Unable to open map',

    // Gallery
    'gallery_heading': 'Gallery',
    'gallery_view_all': 'View all {count} photos',
    'gallery_tab_food': 'Food',
    'gallery_tab_menu': 'Menu',
    'gallery_tab_interior': 'Interior',
    'gallery_tab_exterior': 'Outdoor',
    'gallery_no_images': 'No images available',

    // Menu
    'menu_heading': 'Menu',
    'menu_filters_active': '{count} filters active',
    'menu_filters_none': 'No filters active',
    'menu_filters_edit': 'Edit',
    'menu_show_all': 'Show all {count} items',
    'menu_show_less': 'Show less',

    // Section Headings
    'opening_hours_heading': 'Opening Hours',
    'facilities_heading': 'Facilities',
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
    'action_website': 'Hjemmeside',
    'action_booking': 'Book',
    'action_map': 'Kort',

    // Quick Actions - Error Messages
    'error_cannot_make_call': 'Kan ikke åbne telefon-app',
    'error_cannot_open_website': 'Kan ikke åbne hjemmeside',
    'error_cannot_open_booking': 'Kan ikke åbne bookingside',
    'error_no_map_app': 'Ingen kort-app fundet på din enhed',
    'error_cannot_open_map': 'Kan ikke åbne kort',

    // Gallery
    'gallery_heading': 'Galleri',
    'gallery_view_all': 'Se alle {count} billeder',
    'gallery_tab_food': 'Mad',
    'gallery_tab_menu': 'Menu',
    'gallery_tab_interior': 'Inde',
    'gallery_tab_exterior': 'Ude',
    'gallery_no_images': 'Ingen billeder tilgængelige',

    // Menu
    'menu_heading': 'Menu',
    'menu_filters_active': '{count} filtre aktive',
    'menu_filters_none': 'Ingen filtre aktive',
    'menu_filters_edit': 'Rediger',
    'menu_show_all': 'Vis alle {count} retter',
    'menu_show_less': 'Vis mindre',

    // Section Headings
    'opening_hours_heading': 'Åbningstider',
    'facilities_heading': 'Faciliteter',
  },

  // ============================================================================
  // GERMAN
  // ============================================================================
  'de': {
    // Match Card
    'match_card_matches': 'Entspricht {count} von {total} Filtern',
    'match_card_tap_details': 'Tippen für Details',

    // Quick Actions
    'action_call': 'Anrufen',
    'action_website': 'Webseite',
    'action_booking': 'Buchen',
    'action_map': 'Karte',

    // Quick Actions - Error Messages
    'error_cannot_make_call': 'Telefon-App kann nicht geöffnet werden',
    'error_cannot_open_website': 'Webseite kann nicht geöffnet werden',
    'error_cannot_open_booking': 'Buchungsseite kann nicht geöffnet werden',
    'error_no_map_app': 'Keine Karten-App auf Ihrem Gerät gefunden',
    'error_cannot_open_map': 'Karte kann nicht geöffnet werden',

    // Gallery
    'gallery_heading': 'Galerie',
    'gallery_view_all': 'Alle {count} Fotos anzeigen',
    'gallery_tab_food': 'Essen',
    'gallery_tab_menu': 'Menü',
    'gallery_tab_interior': 'Innenraum',
    'gallery_tab_exterior': 'Außenbereich',
    'gallery_no_images': 'Keine Bilder verfügbar',

    // Menu
    'menu_heading': 'Speisekarte',
    'menu_filters_active': '{count} Filter aktiv',
    'menu_filters_none': 'Keine Filter aktiv',
    'menu_filters_edit': 'Bearbeiten',
    'menu_show_all': 'Alle {count} Gerichte anzeigen',
    'menu_show_less': 'Weniger anzeigen',

    // Section Headings
    'opening_hours_heading': 'Öffnungszeiten',
    'facilities_heading': 'Ausstattung',
  },

  // ============================================================================
  // SPANISH
  // ============================================================================
  'es': {
    // Match Card
    'match_card_matches': 'Coincide con {count} de {total} filtros',
    'match_card_tap_details': 'Toca para ver detalles',

    // Quick Actions
    'action_call': 'Llamar',
    'action_website': 'Sitio web',
    'action_booking': 'Reservar',
    'action_map': 'Mapa',

    // Quick Actions - Error Messages
    'error_cannot_make_call': 'No se puede abrir la aplicación de teléfono',
    'error_cannot_open_website': 'No se puede abrir el sitio web',
    'error_cannot_open_booking': 'No se puede abrir la página de reservas',
    'error_no_map_app': 'No se encontró ninguna aplicación de mapas',
    'error_cannot_open_map': 'No se puede abrir el mapa',

    // Gallery
    'gallery_heading': 'Galería',
    'gallery_view_all': 'Ver todas las {count} fotos',
    'gallery_tab_food': 'Comida',
    'gallery_tab_menu': 'Menú',
    'gallery_tab_interior': 'Interior',
    'gallery_tab_exterior': 'Exterior',
    'gallery_no_images': 'No hay imágenes disponibles',

    // Menu
    'menu_heading': 'Menú',
    'menu_filters_active': '{count} filtros activos',
    'menu_filters_none': 'No hay filtros activos',
    'menu_filters_edit': 'Editar',
    'menu_show_all': 'Mostrar todos los {count} platos',
    'menu_show_less': 'Mostrar menos',

    // Section Headings
    'opening_hours_heading': 'Horario',
    'facilities_heading': 'Instalaciones',
  },

  // ============================================================================
  // FRENCH
  // ============================================================================
  'fr': {
    // Match Card
    'match_card_matches': 'Correspond à {count} sur {total} filtres',
    'match_card_tap_details': 'Appuyez pour les détails',

    // Quick Actions
    'action_call': 'Appeler',
    'action_website': 'Site web',
    'action_booking': 'Réserver',
    'action_map': 'Carte',

    // Quick Actions - Error Messages
    'error_cannot_make_call': 'Impossible d\'ouvrir l\'application téléphone',
    'error_cannot_open_website': 'Impossible d\'ouvrir le site web',
    'error_cannot_open_booking': 'Impossible d\'ouvrir la page de réservation',
    'error_no_map_app': 'Aucune application de carte trouvée',
    'error_cannot_open_map': 'Impossible d\'ouvrir la carte',

    // Gallery
    'gallery_heading': 'Galerie',
    'gallery_view_all': 'Voir les {count} photos',
    'gallery_tab_food': 'Nourriture',
    'gallery_tab_menu': 'Menu',
    'gallery_tab_interior': 'Intérieur',
    'gallery_tab_exterior': 'Extérieur',
    'gallery_no_images': 'Aucune image disponible',

    // Menu
    'menu_heading': 'Menu',
    'menu_filters_active': '{count} filtres actifs',
    'menu_filters_none': 'Aucun filtre actif',
    'menu_filters_edit': 'Modifier',
    'menu_show_all': 'Afficher tous les {count} plats',
    'menu_show_less': 'Afficher moins',

    // Section Headings
    'opening_hours_heading': 'Horaires',
    'facilities_heading': 'Équipements',
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
    'action_website': 'Sito web',
    'action_booking': 'Prenota',
    'action_map': 'Mappa',

    // Quick Actions - Error Messages
    'error_cannot_make_call': 'Impossibile aprire l\'app telefono',
    'error_cannot_open_website': 'Impossibile aprire il sito web',
    'error_cannot_open_booking': 'Impossibile aprire la pagina di prenotazione',
    'error_no_map_app': 'Nessuna app mappe trovata sul dispositivo',
    'error_cannot_open_map': 'Impossibile aprire la mappa',

    // Gallery
    'gallery_heading': 'Galleria',
    'gallery_view_all': 'Vedi tutte le {count} foto',
    'gallery_tab_food': 'Cibo',
    'gallery_tab_menu': 'Menu',
    'gallery_tab_interior': 'Interno',
    'gallery_tab_exterior': 'Esterno',
    'gallery_no_images': 'Nessuna immagine disponibile',

    // Menu
    'menu_heading': 'Menu',
    'menu_filters_active': '{count} filtri attivi',
    'menu_filters_none': 'Nessun filtro attivo',
    'menu_filters_edit': 'Modifica',
    'menu_show_all': 'Mostra tutti i {count} piatti',
    'menu_show_less': 'Mostra meno',

    // Section Headings
    'opening_hours_heading': 'Orari',
    'facilities_heading': 'Servizi',
  },

  // ============================================================================
  // SWEDISH
  // ============================================================================
  'sv': {
    // Match Card
    'match_card_matches': 'Matchar {count} av {total} filter',
    'match_card_tap_details': 'Tryck för detaljer',

    // Quick Actions
    'action_call': 'Ring',
    'action_website': 'Webbplats',
    'action_booking': 'Boka',
    'action_map': 'Karta',

    // Quick Actions - Error Messages
    'error_cannot_make_call': 'Kan inte öppna telefonappen',
    'error_cannot_open_website': 'Kan inte öppna webbplatsen',
    'error_cannot_open_booking': 'Kan inte öppna bokningssidan',
    'error_no_map_app': 'Ingen kartapp hittades på enheten',
    'error_cannot_open_map': 'Kan inte öppna kartan',

    // Gallery
    'gallery_heading': 'Galleri',
    'gallery_view_all': 'Se alla {count} bilder',
    'gallery_tab_food': 'Mat',
    'gallery_tab_menu': 'Meny',
    'gallery_tab_interior': 'Interiör',
    'gallery_tab_exterior': 'Utomhus',
    'gallery_no_images': 'Inga bilder tillgängliga',

    // Menu
    'menu_heading': 'Meny',
    'menu_filters_active': '{count} filter aktiva',
    'menu_filters_none': 'Inga filter aktiva',
    'menu_filters_edit': 'Redigera',
    'menu_show_all': 'Visa alla {count} rätter',
    'menu_show_less': 'Visa mindre',

    // Section Headings
    'opening_hours_heading': 'Öppettider',
    'facilities_heading': 'Faciliteter',
  },
};
