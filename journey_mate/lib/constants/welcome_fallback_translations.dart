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
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': 'Discover restaurants, cafés, and bars curated just for you.',
    'welcome_continue': 'Continue',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'da': {
    'onboarding_title_welcome_prefix': 'Velkommen til',
    'welcome_tagline': 'Gå ud, på din måde.',
    'welcome_subtitle': 'Oplev restauranter, caféer og barer kurateret til dig.',
    'welcome_continue': 'Fortsæt',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'de': {
    'onboarding_title_welcome_prefix': 'Willkommen bei',
    'welcome_tagline': 'Geh aus, auf deine Weise.',
    'welcome_subtitle': 'Entdecke Restaurants, Cafés und Bars, die für dich kuratiert wurden.',
    'welcome_continue': 'Weiter',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'fr': {
    'onboarding_title_welcome_prefix': 'Bienvenue chez',
    'welcome_tagline': 'Sortez, à votre façon.',
    'welcome_subtitle': 'Découvrez des restaurants, cafés et bars sélectionnés pour vous.',
    'welcome_continue': 'Continuer',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'it': {
    'onboarding_title_welcome_prefix': 'Benvenuto a',
    'welcome_tagline': 'Esci, a modo tuo.',
    'welcome_subtitle': 'Scopri ristoranti, caffè e bar selezionati per te.',
    'welcome_continue': 'Continua',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'no': {
    'onboarding_title_welcome_prefix': 'Velkommen til',
    'welcome_tagline': 'Gå ut, på din måte.',
    'welcome_subtitle': 'Oppdag restauranter, kafeer og barer kuratert for deg.',
    'welcome_continue': 'Fortsett',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'sv': {
    'onboarding_title_welcome_prefix': 'Välkommen till',
    'welcome_tagline': 'Gå ut, på ditt sätt.',
    'welcome_subtitle': 'Upptäck restauranger, kaféer och barer kurerade för dig.',
    'welcome_continue': 'Fortsätt',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
};
