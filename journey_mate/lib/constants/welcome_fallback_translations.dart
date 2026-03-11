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
///
/// **Source of truth:** Supabase `ui_translations` table (synced 2026-03-11).
/// The `welcome_tagline` is intentionally kept in English for all languages.
const Map<String, Map<String, String>> kWelcomeFallbackTranslations = {
  // Language code → (translation key → text)
  // ── Active languages ──
  'en': {
    'onboarding_title_welcome_prefix': 'Welcome to',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': 'Discover restaurants, cafés, and bars filtered by your lifestyle, preferences, and dietary needs.',
    'welcome_continue': 'Continue',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'da': {
    'onboarding_title_welcome_prefix': 'Velkommen til',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': 'Opdag restauranter, caféer og barer filtreret efter din livsstil, præferencer og kostbehov.',
    'welcome_continue': 'Fortsæt',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'de': {
    'onboarding_title_welcome_prefix': 'Willkommen bei',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': 'Entdecken Sie Restaurants, Cafés und Bars, gefiltert nach Ihrem Lebensstil, Ihren Vorlieben und Ernährungsbedürfnissen.',
    'welcome_continue': 'Weitermachen',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'fr': {
    'onboarding_title_welcome_prefix': 'Bienvenue chez',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': 'Découvrez des restaurants, des cafés et des bars filtrés en fonction de votre style de vie, de vos préférences et de vos besoins alimentaires.',
    'welcome_continue': 'Continuer',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'it': {
    'onboarding_title_welcome_prefix': 'Benvenuti a',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': 'Scopri ristoranti, caffè e bar filtrati in base al tuo stile di vita, alle tue preferenze e alle tue esigenze alimentari.',
    'welcome_continue': 'Prosegui',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'no': {
    'onboarding_title_welcome_prefix': 'Velkommen til',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': 'Oppdag restauranter, kafeer og barer filtrert etter din livsstil, preferanser og kostholdsbehov.',
    'welcome_continue': 'Fortsett',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'sv': {
    'onboarding_title_welcome_prefix': 'Välkommen till',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': 'Upptäck restauranger, kaféer och barer filtrerade efter din livsstil, dina preferenser och dina kostbehov.',
    'welcome_continue': 'Fortsätt',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  // ── Inactive languages (ready for activation) ──
  'es': {
    'onboarding_title_welcome_prefix': 'Bienvenido a',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': 'Descubre restaurantes, cafeterías y bares filtrados por tu estilo de vida, preferencias y necesidades alimentarias.',
    'welcome_continue': 'Continuar',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'fi': {
    'onboarding_title_welcome_prefix': 'Tervetuloa',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': 'Löydä ravintolat, kahvilat ja baarit suodatettuna elämäntapasi, mieltymystesi ja ruokavaliotarpeidesi mukaan.',
    'welcome_continue': 'Jatka',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'ja': {
    'onboarding_title_welcome_prefix': 'ようこそ',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': 'ライフスタイル、好み、食事制限に合わせてレストラン、カフェ、バーを検索できます。',
    'welcome_continue': '続ける',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'ko': {
    'onboarding_title_welcome_prefix': '환영합니다',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': '라이프스타일, 취향, 식이 요구에 맞춰 레스토랑, 카페, 바를 찾아보세요.',
    'welcome_continue': '계속',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'nl': {
    'onboarding_title_welcome_prefix': 'Welkom bij',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': 'Ontdek restaurants, cafés en bars gefilterd op jouw levensstijl, voorkeuren en dieetwensen.',
    'welcome_continue': 'Doorgaan',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'pl': {
    'onboarding_title_welcome_prefix': 'Witamy w',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': 'Odkrywaj restauracje, kawiarnie i bary dopasowane do Twojego stylu życia, preferencji i potrzeb dietetycznych.',
    'welcome_continue': 'Kontynuuj',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'uk': {
    'onboarding_title_welcome_prefix': 'Ласкаво просимо до',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': 'Знаходьте ресторани, кафе та бари, підібрані за вашим стилем життя, вподобаннями та дієтичними потребами.',
    'welcome_continue': 'Продовжити',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
  'zh': {
    'onboarding_title_welcome_prefix': '欢迎使用',
    'welcome_tagline': 'Go out, your way.',
    'welcome_subtitle': '根据您的生活方式、偏好和饮食需求，发现适合您的餐厅、咖啡馆和酒吧。',
    'welcome_continue': '继续',
    'welcome_continue_danish': 'Fortsæt på dansk',
  },
};
