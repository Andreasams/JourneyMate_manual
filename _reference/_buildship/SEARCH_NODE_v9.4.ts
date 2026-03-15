/**
 * =============================================================================
 * JOURNEYMATE — TYPESENSE SEARCH NODE (v9.4)
 * =============================================================================
 *
 * WHAT IT DOES
 * Searches the `businesses` Typesense collection for restaurants matching a
 * user's dietary filters, location, text query, and preferences. Returns a
 * scored, paginated list where full dietary matches rank above partial matches.
 *
 * INPUTS (SearchParams)
 *   filters            number[]|string  — Dietary/feature filter IDs to score.
 *   city_id            string|null      — Restrict to a city.
 *   search_input       string|null      — Free-text query; "*" = match all.
 *   userLocation       string|null      — Flutter LatLng string for geo-sort.
 *   language_code      string           — ISO lang code (default "da"). 15 supported.
 *   host / apiKey                       — Typesense connection.
 *   supabaseUrl / supabaseKey           — Supabase connection (station lookups).
 *   sortBy             string           — nearest|station|price_low|price_high.
 *   selectedStation    number|null      — Train station ID for station-sort.
 *   onlyOpen           boolean|string   — Only return currently-open restaurants (CPH tz).
 *   page / pageSize    number           — Pagination (1-indexed).
 *   neighbourhood_id   number|number[]  — Filter by neighbourhood(s).
 *   shopping_area_id   number|null      — Filter by shopping area.
 *   geoBounds          string|null      — JSON viewport bounds for map search.
 *                        Format: {"ne_lat":55.72,"ne_lng":12.62,"sw_lat":55.65,"sw_lng":12.50}
 *                        Sent only when user is in map view AND has panned/zoomed.
 *                        Parsed into a Typesense geo polygon filter on `location` field.
 *
 * OUTPUTS (NodeOutput)
 *   documents[]        — Restaurant docs, each annotated with:
 *                        matchCount, matchedFilters, missedFilters, section,
 *                        distanceFromUser, distanceFromStation
 *   scoringFilterIds   — Cleaned filter IDs used for scoring (echo for client).
 *   activeids          — Filter IDs present across full-match restaurants only (from
 *                        a dedicated facet query). Used by the app for filter chips —
 *                        scoped to full matches to prevent selecting a filter that
 *                        only exists on partial/other restaurants.
 *   resultCount        — Total Typesense matches (pre open-now filtering).
 *   fullMatchCount     — Global count of restaurants matching ALL scoring filters.
 *   onlyOpenCount      — Count of open restaurants found across all over-fetch rounds.
 *                        Only populated when onlyOpen=true; 0 otherwise.
 *                        NOTE: This is a lower-bound count, not an absolute global
 *                        total. It reflects only the restaurants seen within the
 *                        over-fetch window (max 5 rounds × chunk size, up to 300
 *                        documents). If open restaurants are sparse and spread beyond
 *                        the fetch window, the true total may be higher.
 *   pagination         — { currentPage, totalPages, totalResults, hasMore }
 *
 * DISTANCE FIELDS (v9.3)
 * ──────────────────────
 *   Each document includes two precomputed distance fields (integer meters):
 *
 *   distanceFromUser    — Haversine distance from the user's GPS location to the
 *                         restaurant. null if user location is unavailable.
 *
 *   distanceFromStation — Haversine distance from the selected train station to the
 *                         restaurant. null unless sortBy=station with a valid station.
 *
 *   Distances are rounded to whole meters. The Flutter client is responsible for
 *   unit conversion (metric/imperial) and display formatting — the node does not
 *   know about display preferences.
 *
 *   This moves the per-card haversine computation from Flutter (where it ran on
 *   every widget rebuild) to the node (computed once per search). It also enables
 *   showing station distance as the primary distance label when sorting by station,
 *   with user distance as an optional secondary label.
 *
 * SCORING SYSTEM  (v9.1 — section-safe)
 * ─────────────────────────────────────
 *   Uses Typesense _eval() to rank results with GUARANTEED section ordering.
 *
 *   Each matched filter contributes:
 *     SECTION_MULTIPLIER (100,000)  +  priority points (200–5,000)
 *
 *   Because every matched filter adds at least 100,000, the score gap between
 *   N matched filters and N−1 matched filters is always ≥ 95,000 — far larger
 *   than the maximum priority bonus (5,000). This guarantees:
 *
 *     fullMatch score  ≫  partialMatch score  ≫  others score
 *
 *   On top of that, a FULL_MATCH_BONUS (10,000,000) is added when ALL scoring
 *   filters match, providing an extra safety margin.
 *
 *   Within a section, restaurants are sub-sorted by which priority filters they
 *   matched (P1=5000 > P2=4000 > ... > non-dietary=200), then by the chosen
 *   secondary sort (distance, price, etc.).
 *
 *   Mathematical guarantee (worst case: 30 filters, all P1):
 *     29 matches (partial min) = 29 × 105,000 = 3,045,000
 *     28 matches (others max)  = 28 × 105,000 = 2,940,000
 *     Gap = 105,000 — always positive ✓
 *
 *   Priority groups (higher = more safety-critical):
 *     P1 (5000): parentId 94  — ids [466, 173, 174]
 *     P2 (4000): parentId 93  — ids [177]
 *     P3 (3000): parentId 91  — ids [553–577] (15 items)
 *     P4 (2000): parentId 95  — ids [175, 176]
 *     P5 (1500): parentId 96  — ids [178]
 *     P6 (1000): parentIds 90, 92, 97 — ids [179, 180, 181, 182, 183]
 *
 * ID RANGES
 *   1–9999         Standard filters (dietary, features)
 *   10000–19999    Train stations (offset by 10000)
 *   20000-22000    Shopping areas
 *   592000–602999  Composite dietary menu filters → dietary_menu_filters field
 *
 * GEO BOUNDS FILTERING (v9.2)
 * ───────────────────────────
 *   When the user pans/zooms the map, the Flutter app sends a `geoBounds` JSON
 *   string with the viewport's NE and SW corners. This is parsed into a
 *   Typesense geo polygon filter on the `location` geopoint field, restricting
 *   results to restaurants within the visible map area.
 *
 *   The geo filter is a hard constraint (ANDed with all other filters). It does
 *   NOT affect sort order — sortBy=nearest still uses userLocation (GPS), not
 *   the map center. When geoBounds is absent or invalid, no geo filtering is
 *   applied (backward compatible).
 *
 * OPEN-NOW FILTERING
 *   Typesense can't natively filter on open_windows time arrays, so the node
 *   over-fetches (3× pageSize, up to 5 rounds) and filters locally using
 *   Copenhagen timezone. totalPages = -1; Flutter uses hasMore.
 *
 * SECTION TAGGING
 *   Each document gets a `section` field: "fullMatch", "partialMatch", or "others".
 *   - fullMatch:    matches ALL scoring filters
 *   - partialMatch: missing exactly 1 scoring filter AND matches at least 1
 *   - others:       missing 2+ filters, or matched none
 *   Documents arrive pre-sorted by _eval score (full → partial → others).
 *   The Flutter app renders cards top-to-bottom and inserts a section header
 *   whenever the section value changes. No client-side sorting or grouping needed.
 *
 * FULL MATCH COUNT + ACTIVEIDS QUERY
 *   Runs a single per_page=0 Typesense query with all scoring filters as hard
 *   filter_by constraints and facet_by enabled. Returns both the exact global
 *   full-match count and activeids scoped to full-match restaurants only.
 *
 * =============================================================================
 * CHANGELOG
 *   v9.4 — Added onlyOpenCount to NodeOutput. When onlyOpen=true, tracks the
 *          cumulative count of open restaurants found across all over-fetch
 *          rounds, independently of pagination skip/collect logic. This gives
 *          the Flutter client a count of open restaurants without requiring a
 *          separate query. onlyOpenCount is a lower-bound (capped by the
 *          over-fetch window of max 300 documents); 0 when onlyOpen=false.
 *   v9.3 — Added precomputed distance fields (distanceFromUser, distanceFromStation)
 *          to each document. Haversine calculation moved from Flutter client to node,
 *          eliminating per-card recomputation on widget rebuilds. Enables showing
 *          station-relative distance when sorting by train station, with user distance
 *          available as a secondary label. Both fields are integer meters; null when
 *          the relevant reference point is unavailable. Backward compatible: Flutter
 *          formatting/unit logic stays client-side.
 *   v9.2 — Added geoBounds viewport filtering. New query parameter parsed into
 *          Typesense geo polygon filter on `location` field. Backward compatible:
 *          absent/invalid geoBounds is silently ignored.
 *   v9.1 — Fixed section interleaving bug. Per-filter _eval scores now include
 *          a 100,000-point base (SECTION_MULTIPLIER) so match count always
 *          dominates priority, guaranteeing strict full→partial→others ordering.
 * =============================================================================
 */

import Typesense from 'typesense';
import { createClient } from '@supabase/supabase-js';

// =============================================================================
// CONSTANTS
// =============================================================================

const FILTER_PRIORITY_GROUPS = [
  { priority: 1, parentId: 94, ids: [466, 173, 174] },
  { priority: 2, parentId: 93, ids: [177] },
  { priority: 3, parentId: 91, ids: [553, 554, 555, 556, 557, 558, 559, 570, 571, 572, 573, 574, 575, 576, 577] },
  { priority: 4, parentId: 95, ids: [175, 176] },
  { priority: 5, parentId: 96, ids: [178] },
  { priority: 6, parentId: 90, ids: [180, 181] },
  { priority: 6, parentId: 92, ids: [182, 183] },
  { priority: 6, parentId: 97, ids: [179] },
] as const;

const SCORE_BY_PRIORITY: Record<number, number> = {
  1: 5000, 2: 4000, 3: 3000, 4: 2000, 5: 1500, 6: 1000,
};

/**
 * SECTION_MULTIPLIER — the base score every matched filter contributes.
 *
 * This is the key to guaranteed section ordering. Because each matched filter
 * adds 100,000 and the maximum priority bonus is only 5,000, a restaurant with
 * N matched filters will ALWAYS outscore one with N−1, regardless of which
 * specific priority filters they have.
 *
 * Minimum gap between adjacent match counts:
 *   100,000 − 5,000 = 95,000 (always positive)
 */
const SECTION_MULTIPLIER = 100_000;

/**
 * FULL_MATCH_BONUS — extra score when ALL scoring filters are present.
 *
 * Set far above the max possible per-filter sum to guarantee full matches
 * are always ranked first, even with many filters.
 *   Max per-filter sum (30 filters × 105,000) = 3,150,000
 *   FULL_MATCH_BONUS = 10,000,000 → always dominant
 */
const FULL_MATCH_BONUS = 10_000_000;

/** Score for non-dietary (feature) filters — tiebreaker within section only. */
const NON_DIETARY_SCORE = 200;

const isTrainStation  = (id: number) => id >= 10000 && id < 20000;
const isShoppingArea  = (id: number) => id >= 20000 && id <= 22000;
const isComposite     = (id: number) => id >= 592000 && id <= 602999;

/**
 * Parent-child filter relationships where selecting a child implies the parent.
 *
 * When both parent and child are in scoringFilters, the parent is redundant —
 * the child alone represents the combined selection. This mirrors the
 * deduplication already done in filter_count_helper.dart and
 * selected_filters_btns.dart on the Flutter side.
 *
 * Used by deduplicateParentChildCombos() to collapse these into logical filters
 * for accurate matchCount / missedFilters / scoringFilterIds.length.
 */
const PARENT_CHILD_RELATIONSHIPS: Record<number, number[]> = {
  56: [585, 586],        // Bakery → [With seating, With café]
  58: [158, 159],        // Café → [With in-house bakery, In bookstore]
  55: [588],             // Food truck → [Other]
  100: [196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207], // Sharing menu → courses
  101: [184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195], // Multi-course → courses
};

/**
 * Deduplicate parent+child combos in scoring filters.
 *
 * When both a parent (e.g. 56=Bakery) and a child (e.g. 585=With café) are
 * selected, they represent ONE logical filter. This function:
 * - Removes redundant parents from the filter list
 * - Tracks which children are active combos (need both parent+child in doc)
 *
 * @returns logicalFilters - scoring filter IDs with redundant parents removed
 * @returns activeCombos   - Map<childId, parentId> for children that form combos
 */
function deduplicateParentChildCombos(scoringFilters: number[]): {
  logicalFilters: number[];
  activeCombos: Map<number, number>;
} {
  const filterSet = new Set(scoringFilters);
  const parentsToRemove = new Set<number>();
  const activeCombos = new Map<number, number>();

  for (const [parentStr, children] of Object.entries(PARENT_CHILD_RELATIONSHIPS)) {
    const parentId = Number(parentStr);
    if (!filterSet.has(parentId)) continue;

    for (const childId of children) {
      if (filterSet.has(childId)) {
        parentsToRemove.add(parentId);
        activeCombos.set(childId, parentId);
      }
    }
  }

  const logicalFilters = scoringFilters.filter(id => !parentsToRemove.has(id));
  return { logicalFilters, activeCombos };
}

// =============================================================================
// TYPES
// =============================================================================

interface SearchParams {
  filters?: number[] | string;
  city_id?: string | null;
  search_input?: string | null;
  userLocation?: string | null;
  language_code: string;
  host: string;
  apiKey: string;
  supabaseUrl: string;
  supabaseKey: string;
  sortBy?: 'nearest' | 'station' | 'price_low' | 'price_high';
  sortOrder?: 'asc' | 'desc';
  selectedStation?: number | null;
  onlyOpen?: boolean | string;
  page?: number;
  pageSize?: number;
  neighbourhoodId?: number | number[] | null;
  neighbourhood_id?: number | number[] | null;
  shoppingAreaId?: number | null;
  shopping_area_id?: number | null;
  geoBounds?: string | null;
}

interface PaginationResult {
  currentPage: number;
  totalPages: number;
  totalResults: number;
  hasMore: boolean;
}

interface NodeOutput {
  documents: any[];
  scoringFilterIds: number[];
  activeids: number[];
  resultCount: number;
  fullMatchCount: number;
  /**
   * Count of open restaurants found across all over-fetch rounds.
   * Only populated when onlyOpen=true; always 0 otherwise.
   *
   * Lower-bound: reflects only what was seen within the over-fetch window
   * (max 5 rounds × chunk size, up to 300 documents). If open restaurants
   * are sparse and spread beyond the fetch window, the true global total
   * may be higher than this value.
   */
  onlyOpenCount: number;
  pagination: PaginationResult;
}

// =============================================================================
// HELPERS
// =============================================================================

function fieldRef(id: number): string {
  return isComposite(id) ? `dietary_menu_filters:${id}` : `filters:${id}`;
}

/** Typesense filter_by reference for a single filter ID (hard constraint). */
function filterConstraintRef(id: number): string {
  const field = isComposite(id) ? 'dietary_menu_filters' : 'filters';
  return `${field}:=${id}`;
}

/**
 * Compute the _eval score for a single matched filter.
 *
 * Structure:  SECTION_MULTIPLIER + priorityScore
 *
 * The SECTION_MULTIPLIER (100,000) ensures that match COUNT is the dominant
 * factor in ordering. The priority score (200–5,000) acts as a tiebreaker
 * within the same match-count tier, ranking safety-critical dietary filters
 * higher than feature filters.
 */
function perFilterScore(id: number): number {
  const group = FILTER_PRIORITY_GROUPS.find(g => (g.ids as readonly number[]).includes(id));
  const priorityScore = group ? (SCORE_BY_PRIORITY[group.priority] ?? 1000) : NON_DIETARY_SCORE;
  return SECTION_MULTIPLIER + priorityScore;
}

function buildEvalExpression(scoringFilters: number[]): string {
  if (scoringFilters.length === 0) return '';

  // Condition 1: Full match bonus — fires only when ALL scoring filters present
  const allPresent = scoringFilters.map(f => fieldRef(f)).join(' && ');
  const conditions: string[] = [`(${allPresent}):${FULL_MATCH_BONUS}`];

  // Conditions 2..N+1: Per-filter scores (SECTION_MULTIPLIER + priority)
  // Sorted by score descending for readability; Typesense evaluates all anyway
  const scored = scoringFilters
    .map(f => ({ f, score: perFilterScore(f) }))
    .sort((a, b) => b.score - a.score);

  for (const { f, score } of scored) {
    conditions.push(`(${fieldRef(f)}):${score}`);
  }

  return `_eval([${conditions.join(', ')}]):desc`;
}

/**
 * Normalize neighbourhood input to a clean number array.
 * Handles: number, number[], null, undefined, 0, [0], "47", "[47]"
 */
function normalizeNeighbourhoodInput(
  raw: number | number[] | string | null | undefined
): number[] {
  if (raw === null || raw === undefined) return [];

  if (Array.isArray(raw)) {
    return raw
      .map(v => typeof v === 'string' ? parseInt(v, 10) : v)
      .filter((v): v is number => typeof v === 'number' && !isNaN(v) && v !== 0);
  }

  if (typeof raw === 'string') {
    const trimmed = raw.trim();
    if (trimmed.startsWith('[')) {
      try {
        const parsed = JSON.parse(trimmed);
        if (Array.isArray(parsed)) return normalizeNeighbourhoodInput(parsed);
      } catch { /* fall through */ }
    }
    const asNum = parseInt(trimmed, 10);
    if (!isNaN(asNum) && asNum !== 0) return [asNum];
    return [];
  }

  if (typeof raw === 'number' && !isNaN(raw) && raw !== 0) return [raw];

  return [];
}

/**
 * Parse geoBounds JSON string into a Typesense geo polygon filter.
 *
 * Input:  '{"ne_lat":55.72,"ne_lng":12.62,"sw_lat":55.65,"sw_lng":12.50}'
 * Output: 'location:(55.72,12.50, 55.72,12.62, 55.65,12.62, 55.65,12.50)'
 *
 * The polygon corners represent the viewport rectangle:
 *   NW (top-left):     ne_lat, sw_lng
 *   NE (top-right):    ne_lat, ne_lng
 *   SE (bottom-right): sw_lat, ne_lng
 *   SW (bottom-left):  sw_lat, sw_lng
 *
 * Returns empty string if geoBounds is absent, null, or invalid.
 */
function parseGeoBoundsFilter(geoBounds: string | null | undefined): string {
  if (!geoBounds) return '';

  try {
    const bounds = JSON.parse(geoBounds);
    const { ne_lat, ne_lng, sw_lat, sw_lng } = bounds;

    // Validate all 4 values are finite numbers
    if ([ne_lat, ne_lng, sw_lat, sw_lng].every(v => typeof v === 'number' && !isNaN(v) && isFinite(v))) {
      // Typesense geo polygon: 4 corners of viewport rectangle (NW, NE, SE, SW)
      return `location:(${ne_lat},${sw_lng}, ${ne_lat},${ne_lng}, ${sw_lat},${ne_lng}, ${sw_lat},${sw_lng})`;
    }
  } catch (e) {
    // Invalid JSON — skip geo filtering silently
  }

  return '';
}

/**
 * Haversine distance between two geographic points.
 *
 * @returns Distance in meters (whole integer, rounded).
 *
 * Uses the same formula as the Flutter returnDistance() in
 * distance_calculator.dart, but returns raw meters instead of formatted km/mi.
 * Unit conversion and display formatting stay in Flutter.
 */
function haversineMeters(
  lat1: number, lng1: number,
  lat2: number, lng2: number,
): number {
  const toRad = (deg: number) => deg * (Math.PI / 180);
  const R = 6_371_000; // Earth's mean radius in meters
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return Math.round(R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)));
}

/**
 * Attach precomputed distance fields to each document.
 *
 * distanceFromUser    — meters from user's GPS location (null if unavailable)
 * distanceFromStation — meters from selected train station (null if not station sort)
 *
 * Called after annotateMatchFields, before enforceSectionOrder.
 * Pure math on already-fetched data — negligible performance cost.
 */
function attachDistances(
  documents: any[],
  userLat: number | null,
  userLng: number | null,
  stationLat: number | null,
  stationLng: number | null,
): any[] {
  const hasUser = userLat !== null && userLng !== null;
  const hasStation = stationLat !== null && stationLng !== null;

  // Fast path: no reference points available
  if (!hasUser && !hasStation) {
    return documents.map(doc => ({
      ...doc,
      distanceFromUser: null,
      distanceFromStation: null,
    }));
  }

  return documents.map(doc => {
    const lat = doc.latitude;
    const lng = doc.longitude;
    const hasDocCoords = typeof lat === 'number' && typeof lng === 'number';

    const distanceFromUser: number | null =
      hasDocCoords && hasUser
        ? haversineMeters(userLat!, userLng!, lat, lng)
        : null;

    const distanceFromStation: number | null =
      hasDocCoords && hasStation
        ? haversineMeters(stationLat!, stationLng!, lat, lng)
        : null;

    return { ...doc, distanceFromUser, distanceFromStation };
  });
}

// =============================================================================
// MAIN EXPORT
// =============================================================================
export default async function optimizedTypesenseSearch(params: SearchParams): Promise<NodeOutput> {

  const {
    filters,
    city_id,
    search_input,
    userLocation,
    language_code,
    host,
    apiKey,
    supabaseUrl,
    supabaseKey,
    sortBy = 'nearest',
    selectedStation = null,
    onlyOpen = false,
    page = 1,
    pageSize = 20,
    geoBounds = null,
  } = params;

  // Resolve snake_case vs camelCase — snake_case (BuildShip) takes priority
  const rawNeighbourhood = params.neighbourhood_id ?? params.neighbourhoodId ?? null;
  const resolvedNeighbourhoodIds = normalizeNeighbourhoodInput(rawNeighbourhood);

  const rawShoppingArea = params.shopping_area_id ?? params.shoppingAreaId ?? null;
  const resolvedShoppingAreaId: number | null =
    (typeof rawShoppingArea === 'number' && rawShoppingArea !== 0) ? rawShoppingArea :
    (typeof rawShoppingArea === 'string' && parseInt(rawShoppingArea, 10) !== 0) ? parseInt(rawShoppingArea, 10) :
    null;

  const emptyPagination: PaginationResult = {
    currentPage: 1, totalPages: 0, totalResults: 0, hasMore: false,
  };

  let scoringFilters: number[] = [];

  const supabase = createClient(supabaseUrl, supabaseKey);

  // ===========================================================================
  // SANITIZE INPUTS
  // ===========================================================================

  const sanitizedLanguage = (language_code && typeof language_code === 'string')
    ? language_code : 'da';

  const resolvedOnlyOpen: boolean = onlyOpen === true || onlyOpen === 'true';

  let sanitizedFilters: number[] = [];
  if (Array.isArray(filters)) {
    sanitizedFilters = filters.filter((f): f is number => typeof f === 'number' && !isNaN(f));
  } else if (typeof filters === 'string' && filters.trim() !== '') {
    if (filters.includes(',')) {
      sanitizedFilters = filters.split(',')
        .map(s => parseInt(s.trim(), 10))
        .filter(n => !isNaN(n));
    } else {
      const asNumber = parseInt(filters.trim(), 10);
      if (!isNaN(asNumber)) {
        sanitizedFilters = [asNumber];
      } else {
        try {
          const parsed = JSON.parse(filters);
          if (Array.isArray(parsed)) {
            sanitizedFilters = parsed.filter((f): f is number => typeof f === 'number' && !isNaN(f));
          }
        } catch { /* silent */ }
      }
    }
  }

  const strippedIds = sanitizedFilters.filter(f => isTrainStation(f) || isShoppingArea(f));
  if (strippedIds.length > 0) {
    console.warn('Stripped non-scoring IDs from filters array:', strippedIds);
  }
  const cleanFilters = sanitizedFilters.filter(f => !isTrainStation(f) && !isShoppingArea(f));
  scoringFilters = cleanFilters;

  const sanitizedUserLocation = (
    userLocation &&
    typeof userLocation === 'string' &&
    userLocation !== '' &&
    userLocation !== 'null' &&
    userLocation !== 'undefined' &&
    userLocation !== 'LatLng(lat: 0, lng: 0)' &&
    userLocation !== 'LatLng(lat: 0.0, lng: 0.0)'
  ) ? userLocation : null;

  const sanitizedSearchInput = (
    search_input && typeof search_input === 'string' &&
    search_input !== '' && search_input !== 'null' && search_input !== 'undefined'
  ) ? search_input : '*';

  const sanitizedCityId = (
    city_id && typeof city_id === 'string' &&
    city_id !== 'null' && city_id !== 'undefined'
  ) ? city_id : null;

  // Parse geoBounds into Typesense geo polygon filter (empty string if absent/invalid)
  const geoFilter = parseGeoBoundsFilter(geoBounds);

  // ===========================================================================
  // PARSE USER LOCATION
  // ===========================================================================
  let userLat: number | null = null;
  let userLng: number | null = null;
  if (sanitizedUserLocation) {
    const match = sanitizedUserLocation.match(/LatLng\(lat: ([-\d.]+), lng: ([-\d.]+)\)/);
    if (match) {
      userLat = parseFloat(match[1]);
      userLng = parseFloat(match[2]);
    }
  }

  // ===========================================================================
  // STATION COORDINATES LOOKUP
  // ===========================================================================
  let stationLat: number | null = null;
  let stationLng: number | null = null;

  if (sortBy === 'station' && selectedStation !== null) {
    const parsedStationId = typeof selectedStation === 'string'
      ? parseInt(selectedStation as any, 10) : selectedStation;
    const isValidId = typeof parsedStationId === 'number' &&
      !isNaN(parsedStationId) && parsedStationId > 0 && Number.isInteger(parsedStationId);
    if (isValidId) {
      try {
        const actualId = parsedStationId >= 10000 ? parsedStationId - 10000 : parsedStationId;
        const { data, error } = await supabase
          .from('FilterTrainStation')
          .select('latitude, longitude')
          .eq('train_station_id', actualId)
          .single();
        if (!error && data) {
          stationLat = data.latitude;
          stationLng = data.longitude;
        } else {
          console.error('Station lookup failed:', error?.message, '| ID:', actualId);
        }
      } catch (e) {
        console.error('Station lookup exception:', e);
      }
    }
  }

  // ===========================================================================
  // BUILD SORT STRING
  // ===========================================================================
  const evalExpr = buildEvalExpression(scoringFilters);

  let secondarySort = 'business_name:asc';
  switch (sortBy) {
    case 'nearest':
      if (userLat !== null && userLng !== null) secondarySort = `location(${userLat},${userLng}):asc`;
      break;
    case 'station':
      if (stationLat !== null && stationLng !== null) secondarySort = `location(${stationLat},${stationLng}):asc`;
      else if (userLat !== null && userLng !== null) secondarySort = `location(${userLat},${userLng}):asc`;
      break;
    case 'price_low':  secondarySort = 'price_range_min:asc'; break;
    case 'price_high': secondarySort = 'price_range_max:desc'; break;
  }

  const hasSearchQuery = sanitizedSearchInput !== '*';
  let sortByString: string;
  if (evalExpr && hasSearchQuery) {
    sortByString = `${evalExpr},_text_match:desc,${secondarySort}`;
  } else if (evalExpr) {
    sortByString = `${evalExpr},${secondarySort}`;
  } else if (hasSearchQuery) {
    sortByString = `_text_match:desc,${secondarySort}`;
  } else {
    sortByString = secondarySort;
  }

  // ===========================================================================
  // BUILD INCLUDE_FIELDS
  // ===========================================================================
  const allLanguages = ['da', 'de', 'en', 'es', 'fi', 'fr', 'it', 'ja', 'ko', 'nl', 'no', 'pl', 'sv', 'uk', 'zh'];
  const langFieldsToInclude: string[] = [];
  allLanguages.forEach(lang => {
    if (lang === 'en' || lang === 'da' || lang === sanitizedLanguage) langFieldsToInclude.push(`tags_${lang}`);
    if (lang === sanitizedLanguage) langFieldsToInclude.push(`business_type_${lang}`);
  });

  const includeFields = [
    'business_id', 'business_name', 'is_active',
    'city_id', 'city_name', 'neighbourhood_name',
    'street', 'postal_code', 'postal_city',
    'latitude', 'longitude', 'location',
    'profile_picture_url',
    'filters', 'dietary_menu_filters',
    'price_range_min', 'price_range_max', 'price_range',
    'business_hours',
    ...(resolvedOnlyOpen ? ['open_windows'] : []),
    'created_at', 'last_reviewed_at',
    'brand_id', 'company_id', 'typesense_id', 'business_type_id', 'gallery_images',
    'neighbourhood_id', 'shopping_area_id',
    ...langFieldsToInclude,
  ].join(',');

  // ===========================================================================
  // TYPESENSE SEARCH
  // ===========================================================================
  try {
    const client = new Typesense.Client({
      nodes: [{ host, port: 443, protocol: 'https' }],
      apiKey,
    });

    // =========================================================================
    // BUILD filter_by
    // =========================================================================
    let filterByString = sanitizedCityId
      ? `city_id:=${sanitizedCityId} && is_active:=true`
      : 'is_active:=true';

    if (resolvedNeighbourhoodIds.length === 1) {
      filterByString += ` && neighbourhood_id:${resolvedNeighbourhoodIds[0]}`;
    } else if (resolvedNeighbourhoodIds.length > 1) {
      filterByString += ` && neighbourhood_id:[${resolvedNeighbourhoodIds.join(',')}]`;
    }

    if (resolvedShoppingAreaId !== null) {
      filterByString += ` && shopping_area_id:=${resolvedShoppingAreaId}`;
    }

    // Geo bounds filter — restricts results to visible map viewport
    if (geoFilter) {
      filterByString += ` && ${geoFilter}`;
    }

    const tagsField = `tags_${sanitizedLanguage}`;
    const businessTypeField = `business_type_${sanitizedLanguage}`;

    const baseSearchParameters: any = {
      q: sanitizedSearchInput,
      query_by: `business_name,${tagsField},street,neighbourhood_name`,
      query_by_weights: '4,3,2,1',
      filter_by: filterByString,
      sort_by: sortByString,
      facet_by: 'filters,dietary_menu_filters',
      max_facet_values: 1000,
      num_typos: 2,
      include_fields: includeFields,
      use_cache: true,
      cache_ttl: 60,
      search_cutoff_ms: 200,
    };

    // =========================================================================
    // onlyOpen over-fetch config
    // =========================================================================
    const OVERFETCH_MULTIPLIER = 3;
    const MAX_OVERFETCH_ROUNDS = 5;

    let documents: any[];
    let activeids: number[];
    let totalResultsFromTypesense: number;
    let fullMatchCount: number;

    if (!resolvedOnlyOpen) {
      // ----- STANDARD PATH -----
      const searchParameters = {
        ...baseSearchParameters,
        page,
        per_page: pageSize,
      };

      const searchResults = await client.collections('businesses').documents().search(searchParameters);

      if (!searchResults.hits || !Array.isArray(searchResults.hits)) {
        return {
          documents: [], scoringFilterIds: deduplicateParentChildCombos(scoringFilters).logicalFilters, activeids: [],
          resultCount: 0, fullMatchCount: 0, onlyOpenCount: 0, pagination: emptyPagination,
        };
      }

      const mainQueryActiveids = extractActiveIds(searchResults);
      totalResultsFromTypesense = searchResults.found ?? 0;
      documents = normalizeDocuments(searchResults.hits, businessTypeField, tagsField, sanitizedLanguage, allLanguages);
      documents = annotateMatchFields(documents, scoringFilters);
      documents = attachDistances(documents, userLat, userLng, stationLat, stationLng);

      // activeids scoped to full matches only; falls back to main query facets if no scoring filters
      const fullMatchData = await getFullMatchData(
        client, scoringFilters, filterByString, sanitizedSearchInput,
        tagsField, totalResultsFromTypesense, documents, mainQueryActiveids
      );
      fullMatchCount = fullMatchData.fullMatchCount;
      activeids = fullMatchData.activeids;

      // --- DEFENSIVE: verify section ordering ---
      // If Typesense _eval produced unexpected ordering (should not happen with
      // v9.1 scoring, but guards against edge cases like search_cutoff_ms
      // truncation), enforce strict full → partial → others ordering as a
      // final safety net. Preserves within-section order from Typesense.
      documents = enforceSectionOrder(documents);

      const totalPages = Math.ceil(totalResultsFromTypesense / pageSize);
      return {
        documents,
        scoringFilterIds: deduplicateParentChildCombos(scoringFilters).logicalFilters,
        activeids,
        resultCount: totalResultsFromTypesense,
        fullMatchCount,
        onlyOpenCount: 0,
        pagination: {
          currentPage: page,
          totalPages,
          totalResults: totalResultsFromTypesense,
          hasMore: page < totalPages,
        },
      };

    } else {
      // ----- ONLY-OPEN PATH -----
      const skipTarget = (page - 1) * pageSize;
      const collectTarget = pageSize;

      const openResults: any[] = [];
      let skipped = 0;
      let tsPage = 1;
      let tsFound = 0;
      let facetActiveids: number[] = [];
      let onlyOpenCount = 0; // cumulative open count across all rounds (lower-bound)

      const nowCph = new Date(
        new Date().toLocaleString('en-US', { timeZone: 'Europe/Copenhagen' })
      );
      const jsDay = nowCph.getDay();
      const currentDay = jsDay === 0 ? 6 : jsDay - 1;
      const currentMinutes = nowCph.getHours() * 60 + nowCph.getMinutes();

      for (let round = 0; round < MAX_OVERFETCH_ROUNDS; round++) {
        const chunkSize = Math.min(pageSize * OVERFETCH_MULTIPLIER, 250);
        const searchParameters = {
          ...baseSearchParameters,
          page: tsPage,
          per_page: chunkSize,
        };

        const searchResults = await client.collections('businesses').documents().search(searchParameters);

        if (!searchResults.hits || searchResults.hits.length === 0) break;

        if (round === 0) {
          facetActiveids = extractActiveIds(searchResults);
          tsFound = searchResults.found ?? 0;
        }

        let chunk = normalizeDocuments(searchResults.hits, businessTypeField, tagsField, sanitizedLanguage, allLanguages);
        chunk = annotateMatchFields(chunk, scoringFilters);
        chunk = attachDistances(chunk, userLat, userLng, stationLat, stationLng);

        const openChunk = chunk.filter((doc: any) => {
          if (!doc?.open_windows || !Array.isArray(doc.open_windows)) return false;
          return doc.open_windows.some((w: { day: number; open: number; close: number }) =>
            w.day === currentDay &&
            currentMinutes >= w.open &&
            currentMinutes < w.close
          );
        });

        // Accumulate total open count across all rounds, independent of pagination
        onlyOpenCount += openChunk.length;

        for (const doc of openChunk) {
          if (skipped < skipTarget) {
            skipped++;
            continue;
          }
          openResults.push(doc);
          if (openResults.length >= collectTarget) break;
        }

        if (openResults.length >= collectTarget) break;

        const totalTsPages = Math.ceil(tsFound / chunkSize);
        if (tsPage >= totalTsPages) break;
        tsPage++;
      }

      // --- DEFENSIVE: enforce section ordering for open-now results ---
      documents = enforceSectionOrder(openResults);
      totalResultsFromTypesense = tsFound;

      // activeids scoped to full matches only; falls back to main query facets if no scoring filters
      const fullMatchData = await getFullMatchData(
        client, scoringFilters, filterByString, sanitizedSearchInput,
        tagsField, totalResultsFromTypesense, documents, facetActiveids
      );
      fullMatchCount = fullMatchData.fullMatchCount;
      activeids = fullMatchData.activeids;

      const hasMore = documents.length >= collectTarget && tsPage <= Math.ceil(tsFound / Math.min(pageSize *
        OVERFETCH_MULTIPLIER, 250));

      return {
        documents,
        scoringFilterIds: deduplicateParentChildCombos(scoringFilters).logicalFilters,
        activeids,
        resultCount: totalResultsFromTypesense,
        fullMatchCount,
        onlyOpenCount,
        pagination: {
          currentPage: page,
          totalPages: -1,
          totalResults: totalResultsFromTypesense,
          hasMore,
        },
      };
    }

  } catch (error) {
    console.error('Typesense search error:', error);
    return {
      documents: [], scoringFilterIds: deduplicateParentChildCombos(scoringFilters).logicalFilters, activeids: [],
      resultCount: 0, fullMatchCount: 0, onlyOpenCount: 0, pagination: emptyPagination,
    };
  }
}

// =============================================================================
// Global full match count + full-match-scoped activeids
//
// Runs a single per_page=0 Typesense query with all scoring filters as hard
// constraints and facet_by enabled. Returns:
//   - fullMatchCount: exact global count of restaurants matching ALL filters
//   - activeids: filter IDs present only among full-match restaurants
//
// Scoping activeids to full matches prevents the app from showing filter chips
// that only exist on partial/other restaurants (which would create zero-result
// queries if selected).
// =============================================================================
async function getFullMatchData(
  client: any,
  scoringFilters: number[],
  baseFilterBy: string,
  searchInput: string,
  tagsField: string,
  totalResults: number,
  currentPageDocs: any[],
  fallbackActiveids: number[],
): Promise<{ fullMatchCount: number; activeids: number[] }> {

  // No scoring filters = every result is a "full match", use main query facets
  if (scoringFilters.length === 0) {
    return { fullMatchCount: totalResults, activeids: fallbackActiveids };
  }

  const filterConstraints = scoringFilters.map(f => filterConstraintRef(f));
  const fullMatchFilterBy = `${baseFilterBy} && ${filterConstraints.join(' && ')}`;

  try {
    const countResult = await client.collections('businesses').documents().search({
      q: searchInput,
      query_by: `business_name,${tagsField}`,
      filter_by: fullMatchFilterBy,
      facet_by: 'filters,dietary_menu_filters',
      max_facet_values: 1000,
      per_page: 0,
      include_fields: '',
    });

    const fullMatchCount = countResult.found ?? 0;
    const activeids = extractActiveIds(countResult);

    return { fullMatchCount, activeids };
  } catch (error) {
    console.error('fullMatchData query failed, falling back to page-level data:', error);
    // Fallback: count on current page, use main query facets
    // Use logicalFilters.length (not raw scoringFilters.length) since
    // annotateMatchFields computes matchCount against deduplicated filters.
    const { logicalFilters } = deduplicateParentChildCombos(scoringFilters);
    const fullMatchCount = currentPageDocs.filter(
      (doc: any) => doc.matchCount === logicalFilters.length
    ).length;
    return { fullMatchCount, activeids: fallbackActiveids };
  }
}

// =============================================================================
// EXTRACTED HELPERS
// =============================================================================

function extractActiveIds(searchResults: any): number[] {
  const activeidSet = new Set<number>();
  if (searchResults.facet_counts && Array.isArray(searchResults.facet_counts)) {
    for (const facet of searchResults.facet_counts) {
      if (facet?.counts && Array.isArray(facet.counts)) {
        for (const entry of facet.counts as { value: string; count: number }[]) {
          const id = parseInt(entry.value, 10);
          if (!isNaN(id)) activeidSet.add(id);
        }
      }
    }
  }
  return Array.from(activeidSet);
}

function normalizeDocuments(
  hits: any[],
  businessTypeField: string,
  tagsField: string,
  sanitizedLanguage: string,
  allLanguages: string[],
): any[] {
  const languagesToKeep = new Set(['en', 'da', sanitizedLanguage]);

  return hits.map((hit: any) => {
    const doc = hit.document;
    if (!doc) return doc;

    doc.business_type = doc[businessTypeField] || '';
    doc.tags = doc[tagsField] || [];

    allLanguages.forEach(lang => {
      delete doc[`business_type_${lang}`];
      if (!languagesToKeep.has(lang)) delete doc[`tags_${lang}`];
    });

    if (sanitizedLanguage !== 'en' && sanitizedLanguage !== 'da') {
      delete doc[`tags_${sanitizedLanguage}`];
    }

    return doc;
  });
}

function annotateMatchFields(documents: any[], scoringFilters: number[]): any[] {
  const { logicalFilters, activeCombos } = deduplicateParentChildCombos(scoringFilters);

  return documents.map((doc: any) => {
    const docFilters: number[] = Array.isArray(doc.filters) ? doc.filters : [];
    const docComposites: number[] = Array.isArray(doc.dietary_menu_filters)
      ? doc.dietary_menu_filters : [];

    const matchedFilters: number[] = [];
    const missedFilters: number[] = [];

    for (const f of logicalFilters) {
      if (activeCombos.has(f)) {
        // Combo child: matched only if BOTH parent AND child are in doc.filters
        const parentId = activeCombos.get(f)!;
        if (docFilters.includes(parentId) && docFilters.includes(f)) {
          matchedFilters.push(f);
        } else {
          missedFilters.push(f);
        }
      } else if (isComposite(f)) {
        (docComposites.includes(f) ? matchedFilters : missedFilters).push(f);
      } else {
        (docFilters.includes(f) ? matchedFilters : missedFilters).push(f);
      }
    }

    // Section tag for Flutter: determines which UI section this card belongs to.
    // fullMatch    = all logical filters present
    // partialMatch = exactly 1 filter missing AND at least 1 matched
    // others       = 2+ filters missing, or 0 matched
    const section: string =
      matchedFilters.length === logicalFilters.length ? 'fullMatch' :
      missedFilters.length === 1 && matchedFilters.length > 0 ? 'partialMatch' :
      'others';

    return { ...doc, matchCount: matchedFilters.length, matchedFilters, missedFilters, section };
  });
}

/**
 * DEFENSIVE SAFETY NET — enforce strict section ordering.
 *
 * With v9.1 scoring (SECTION_MULTIPLIER), Typesense should already return
 * documents in correct section order. This function acts as a final guarantee
 * against edge cases that could break ordering:
 *   - search_cutoff_ms truncating the ranking computation
 *   - Typesense _eval tie-breaking on secondary sort crossing section boundaries
 *   - Future Typesense version behavior changes
 *
 * Uses a stable sort so within-section ordering (from Typesense's _eval +
 * secondary sort) is fully preserved.
 */
function enforceSectionOrder(documents: any[]): any[] {
  const SECTION_RANK: Record<string, number> = {
    fullMatch: 0,
    partialMatch: 1,
    others: 2,
  };

  // Check if already correctly ordered (fast path — usually true with v9.1)
  let needsSort = false;
  for (let i = 1; i < documents.length; i++) {
    const prevRank = SECTION_RANK[documents[i - 1].section] ?? 2;
    const currRank = SECTION_RANK[documents[i].section] ?? 2;
    if (currRank < prevRank) {
      needsSort = true;
      break;
    }
  }

  if (!needsSort) return documents;

  // Stable sort: preserve within-section order from Typesense
  console.warn('enforceSectionOrder: corrected out-of-order sections');
  return [...documents].sort((a, b) => {
    const rankA = SECTION_RANK[a.section] ?? 2;
    const rankB = SECTION_RANK[b.section] ?? 2;
    return rankA - rankB;
  });
}
