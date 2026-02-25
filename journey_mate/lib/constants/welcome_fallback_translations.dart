/// Welcome page fallback translations
///
/// Used ONLY on first launch before real translations load from API.
/// These 5 keys enable instant welcome page display (<100ms).
///
/// **Lifecycle:**
/// 1. First launch: App uses these fallbacks (0ms load time)
/// 2. API fetch completes: Real translations replace fallbacks
/// 3. All subsequent launches: Real translations from cache (7-day TTL)
///
/// **DO NOT EXPAND THIS FILE** — It's intentionally minimal for instant startup.
/// Only add keys if they're critical for first-launch welcome page.
const Map<String, Map<String, String>> kWelcomeFallbackTranslations = {
  // Language code → (translation key → text)
  'en': {
    'onboarding_title_welcome_prefix': 'Welcome to',
    'z6e1v2g7': 'Go out, your way.',
    '0eehrkgn': 'Discover restaurants, cafés, and bars curated just for you.',
    'd2mrwxr4': 'Continue',
    'cuy6esxb': 'Fortsæt på dansk',
  },
  'da': {
    'onboarding_title_welcome_prefix': 'Velkommen til',
    'z6e1v2g7': 'Gå ud, på din måde.',
    '0eehrkgn': 'Oplev restauranter, caféer og barer kurateret til dig.',
    'd2mrwxr4': 'Fortsæt',
    'cuy6esxb': 'Fortsæt på dansk',
  },
  'de': {
    'onboarding_title_welcome_prefix': 'Willkommen bei',
    'z6e1v2g7': 'Geh aus, auf deine Weise.',
    '0eehrkgn': 'Entdecke Restaurants, Cafés und Bars, die für dich kuratiert wurden.',
    'd2mrwxr4': 'Weiter',
    'cuy6esxb': 'Fortsæt på dansk',
  },
  'fr': {
    'onboarding_title_welcome_prefix': 'Bienvenue chez',
    'z6e1v2g7': 'Sortez, à votre façon.',
    '0eehrkgn': 'Découvrez des restaurants, cafés et bars sélectionnés pour vous.',
    'd2mrwxr4': 'Continuer',
    'cuy6esxb': 'Fortsæt på dansk',
  },
  'it': {
    'onboarding_title_welcome_prefix': 'Benvenuto a',
    'z6e1v2g7': 'Esci, a modo tuo.',
    '0eehrkgn': 'Scopri ristoranti, caffè e bar selezionati per te.',
    'd2mrwxr4': 'Continua',
    'cuy6esxb': 'Fortsæt på dansk',
  },
  'no': {
    'onboarding_title_welcome_prefix': 'Velkommen til',
    'z6e1v2g7': 'Gå ut, på din måte.',
    '0eehrkgn': 'Oppdag restauranter, kafeer og barer kuratert for deg.',
    'd2mrwxr4': 'Fortsett',
    'cuy6esxb': 'Fortsæt på dansk',
  },
  'sv': {
    'onboarding_title_welcome_prefix': 'Välkommen till',
    'z6e1v2g7': 'Gå ut, på ditt sätt.',
    '0eehrkgn': 'Upptäck restauranger, kaféer och barer kurerade för dig.',
    'd2mrwxr4': 'Fortsätt',
    'cuy6esxb': 'Fortsæt på dansk',
  },
};
