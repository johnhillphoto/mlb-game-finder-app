# Phase 1 — iOS App Research & Planning

> **Status:** Phase 1 (Research — no code changes)
> **Reference app:** [yankee-game-finder](https://github.com/johnhillphoto/yankee-game-finder)
> **MLB API base:** `https://statsapi.mlb.com/api/v1`

---

## 1. Feature Parity Matrix (Web → iOS)

### 1.1 Global / Persistent Features

| # | Web Feature | iOS Equivalent | Notes |
|---|---|---|---|
| G1 | **Team Selector** — `<select>` dropdown in sticky header, 30 teams grouped by division | **Picker / Navigation sheet** — Full-screen team picker presented modally or via `.navigationDestination`, grouped by division with searchable list | Picker is the standard SwiftUI control; a sectioned `List` grouped by `Division` offers better UX on mobile than a flat dropdown |
| G2 | **Team-Themed UI** — 4 CSS custom properties (`--team-primary`, `--team-primary-light`, `--team-primary-dark`, `--team-secondary`) set at SSR time | **`TeamTheme` environment value** — A `TeamTheme` struct injected via SwiftUI `.environment()` containing `Color` values; all views read from the environment | Maps CSS variable theming to SwiftUI's environment-based design token pattern |
| G3 | **Persistent Team Preference** — `selected_team_id` cookie (1-year) | **`@AppStorage("selectedTeamId")`** — Backed by `UserDefaults`; read on launch to restore team | Direct replacement for cookie-based persistence |
| G4 | **Sticky Header** — `position: sticky` with brand, nav links, team selector | **`TabView` + `NavigationStack` toolbar** — Native tab bar replaces nav links; team selector and brand live in the navigation bar | See §3 Navigation Architecture |
| G5 | **Mock Data Fallback** — Hard-coded 2026 Yankees schedule when MLB API is unreachable | **Bundled JSON + Preview assets** — Ship a JSON fixture in the app bundle; surface a banner identical to web when mock data is active | Extend to all 30 teams or show cached last-known data (see Open Questions) |

### 1.2 Upcoming Games (`/` → "Upcoming" Tab)

| # | Web Feature | iOS Equivalent | Notes |
|---|---|---|---|
| U1 | **Upcoming Game List** — Chronological list where `abstractGameState !== "Final"` | **`List` / `LazyVStack`** inside a `ScrollView` | Standard SwiftUI list |
| U2 | **"Next Game" Feature Card** — First game has distinct dark card with "⚾ Next Game" label | **Prominent card style** — First cell uses a differentiated card style with a section header | Use `.listRowBackground` or a custom card view for the featured cell |
| U3 | **Live Game Badge** — Pulsing red `● LIVE` when `abstractGameState === "Live"` | **`LiveBadge` view** with `.symbolEffect(.pulse)` or a `TimelineView` animation | Native pulsing animation support in iOS 17+ |
| U4 | **Home / Away Badge** — Styled `HOME` or `AWAY` pill | **`Badge` view** — Capsule with team-primary tint | Reused across both tabs |
| U5 | **Broadcast Info** — English-language broadcast names as pill badges; "TBD" fallback | **Horizontal `ScrollView` of pills** or `FlowLayout` wrapping pills | Filter to `language == "en"`, deduplicate |
| U6 | **Venue** — 📍 icon + stadium name | **`Label("venue", systemImage: "mappin.and.ellipse")`** | Standard SF Symbol |
| U7 | **Infinite Scroll** — IntersectionObserver, initial 6, then pages of 5 | **`onAppear` on last visible item** or `ScrollView` `.onReachEnd` modifier / task-based pagination | Trigger next page load when last item appears |
| U8 | **Game Count Footer** — "Showing X of Y upcoming games" | **Footer `Text` at bottom of list** | Same copy |
| U9 | **Error State** — Red error banner | **`ContentUnavailableView` or inline banner** | Use iOS 17 `ContentUnavailableView` for empty/error states |
| U10 | **Empty State** — "No upcoming games found" | **`ContentUnavailableView`** with SF Symbol illustration | Native empty-state pattern |

### 1.3 Completed Games (`/completed` → "Completed" Tab)

| # | Web Feature | iOS Equivalent | Notes |
|---|---|---|---|
| C1 | **Completed Game List** — `abstractGameState === "Final"`, most recent first | **`List` / `LazyVStack`** reverse-chronological | Same scrolling pattern as Upcoming |
| C2 | **Scores** — Numeric scores beside team names | **Score labels in `GameCardView`** — Conditionally shown when `showScore == true` | GameCardView accepts a `displayMode` enum (`.upcoming` / `.completed`) |
| C3 | **Win / Loss Badge** — Green `W` / red `L` from selected team's perspective | **`ResultBadge` view** — `.green` or `.red` tint | Reusable component |
| C4 | **Home / Away Badge** | Same as U4 | Shared component |
| C5 | **Broadcast Info** | Same as U5 | Shared component |
| C6 | **Venue** | Same as U6 | Shared component |
| C7 | **Infinite Scroll** — Pages of 20 | Same as U7, with `pageSize = 20` | Configurable page size |
| C8 | **Game Count Footer** | Same as U8 | Same copy pattern |
| C9 | **Error / Empty States** | Same as U9/U10 | Shared pattern |

### 1.4 iOS-Only Enhancements (Not in Web)

| # | Feature | Rationale |
|---|---|---|
| E1 | **Pull-to-Refresh** | Expected iOS pattern — `.refreshable` modifier on `List` |
| E2 | **Team Logo Images** | MLB Stats API provides team logo URLs; significantly improves mobile visual identity |
| E3 | **Accessibility Labels** | Web app has minimal a11y; iOS app should ship with full VoiceOver support from day one |
| E4 | **System Dark Mode Support** | Adapt team theme colors for `colorScheme == .dark` |
| E5 | **Widget / Live Activity** (stretch) | Surface next-game or live-score on Home Screen via WidgetKit |

---

## 2. Recommended Swift Module Structure

```
MLBGameFinder/
├── App/
│   ├── MLBGameFinderApp.swift          // @main entry point, scene setup
│   └── AppState.swift                  // Shared app-level state (selected team)
│
├── Models/                             // Platform-neutral domain models
│   ├── Game.swift                      // Game, GameStatus, TeamScore
│   ├── Team.swift                      // Team, MlbTeam, Division
│   ├── Broadcast.swift                 // Broadcast
│   └── Venue.swift                     // Venue
│
├── Networking/                         // MLB Stats API client
│   ├── MLBAPIClient.swift              // Protocol + async/await implementation
│   ├── MLBEndpoint.swift               // URL construction (endpoint enum)
│   ├── ScheduleResponse.swift          // Raw Decodable API response types
│   └── APIError.swift                  // Typed errors
│
├── Repositories/                       // Data access layer (abstraction over network + cache)
│   ├── GameRepository.swift            // Protocol: fetchUpcoming / fetchCompleted
│   ├── LiveGameRepository.swift        // Concrete: calls MLBAPIClient, paginates, caches
│   └── MockGameRepository.swift        // Bundled JSON fallback for previews & offline
│
├── ViewModels/                         // MVVM view models
│   ├── UpcomingGamesViewModel.swift    // Paging state, load triggers, error handling
│   ├── CompletedGamesViewModel.swift   // Same pattern, reverse-chron
│   └── TeamSelectionViewModel.swift    // Division-grouped team list, selection persistence
│
├── Views/
│   ├── Root/
│   │   ├── ContentView.swift           // TabView shell (Upcoming | Completed)
│   │   └── TeamSelectorView.swift      // Modal / sheet team picker
│   ├── Games/
│   │   ├── GameCardView.swift          // Shared card (upcoming & completed modes)
│   │   ├── GameListView.swift          // Generic paginated game list
│   │   ├── UpcomingGamesView.swift     // Tab content — upcoming
│   │   ├── CompletedGamesView.swift    // Tab content — completed
│   │   └── FeaturedGameCard.swift      // "Next Game" hero card
│   ├── Components/
│   │   ├── LiveBadge.swift             // Pulsing LIVE indicator
│   │   ├── LocationBadge.swift         // HOME / AWAY pill
│   │   ├── ResultBadge.swift           // W / L pill
│   │   ├── BroadcastPills.swift        // Horizontal scroll of broadcast names
│   │   └── VenueLabel.swift            // 📍 venue
│   └── Shared/
│       ├── ErrorBanner.swift           // Inline error display
│       ├── MockDataBanner.swift        // "Using sample data" notice
│       └── LoadingFooter.swift         // Spinner at bottom of list
│
├── Theme/
│   ├── TeamTheme.swift                 // TeamTheme struct + environment key
│   ├── Color+Team.swift                // Extension: team color → SwiftUI Color
│   └── TeamColors.swift                // Static 30-team color definitions
│
├── Utilities/
│   ├── DateFormatting.swift            // Shared date/time formatters
│   └── Constants.swift                 // Page sizes, API base URL, default team
│
├── Resources/
│   ├── MLBTeams.json                   // Static team + division data (bundled)
│   └── MockSchedule.json              // Fallback schedule fixture
│
└── Preview Content/
    └── PreviewHelpers.swift            // Sample data for Xcode previews
```

### Design Rationale

| Decision | Reason |
|---|---|
| **Models/ is platform-neutral** | Structs conform to `Codable` + `Sendable`. No UIKit/SwiftUI imports. Could be shared with a macOS or watchOS target later. |
| **Repository pattern** | Insulates ViewModels from knowing whether data comes from network, cache, or mock. Makes testing trivial — inject `MockGameRepository` in unit tests and previews. |
| **Separate Networking/ from Repositories/** | `MLBAPIClient` is a thin HTTP layer; `GameRepository` adds business logic (filtering, pagination, caching). Keeps single-responsibility clear. |
| **ViewModels are `@Observable`** | Uses the Observation framework (iOS 17+). No Combine publishers needed. `@Observable class` replaces `ObservableObject` + `@Published`. |
| **Theme/ as environment** | Mirrors the web's CSS custom-property approach. One `.environment(\.teamTheme, theme)` at the root propagates colors to every descendant — just like CSS variables on `<html>`. |
| **No Combine** | All async work uses structured concurrency (`async/await`, `Task`, `AsyncSequence`). Combine is avoided per project constraint. |

---

## 3. Navigation Architecture

```
MLBGameFinderApp
└── WindowGroup
    └── ContentView
        ├── .environment(\.teamTheme, currentTheme)
        ├── .toolbar { TeamSelectorButton }
        │
        └── TabView
            ├── Tab("Upcoming", systemImage: "calendar")
            │   └── NavigationStack
            │       └── UpcomingGamesView
            │           ├── FeaturedGameCard (first item)
            │           └── GameCardView × N
            │
            └── Tab("Completed", systemImage: "checkmark.circle")
                └── NavigationStack
                    └── CompletedGamesView
                        └── GameCardView × N
```

### Web → iOS Navigation Mapping

| Web Pattern | iOS Pattern | Notes |
|---|---|---|
| Two `<Link>` nav items (`/`, `/completed`) with `usePathname` active styling | **`TabView` with two tabs** | Standard iOS tab bar; each tab owns its own `NavigationStack` |
| Sticky header with brand + team selector | **Navigation bar `toolbar` items** | `.principal` for brand text; `.topBarTrailing` for team selector button |
| Page titles (`<h2>`) + subtitles | **`.navigationTitle`** + `.navigationSubtitle` or inline header view | |
| `<Link>` active state highlighting | **Tab bar selection** (automatic) | |
| No game detail page | **Future:** `NavigationLink` to `GameDetailView` | Planned for Phase 2 stretch |

---

## 4. JS API Client → Swift Networking Layer Mapping

### 4.1 Endpoint Mapping

| Web (JS) | Swift | Description |
|---|---|---|
| `MLB_API_BASE = "https://statsapi.mlb.com/api/v1"` | `MLBEndpoint.baseURL` static property | Single source of truth for API base URL |
| `fetchUpcomingGames(teamId, page, pageSize)` | `MLBAPIClient.fetchSchedule(teamId:dateRange:hydrations:)` → `GameRepository.upcomingGames(teamId:page:pageSize:)` | In Swift the API client fetches raw data; the repository filters/paginates |
| `fetchCompletedGames(teamId, page, pageSize)` | Same `fetchSchedule` call → `GameRepository.completedGames(teamId:page:pageSize:)` | Same endpoint, different date range and filter |
| URL construction via template literals | `MLBEndpoint.schedule(teamId:startDate:endDate:gameTypes:hydrations:)` enum case → `.url` computed property | Type-safe URL builder |
| `fetch(url, { next: { revalidate: 300 } })` | `URLSession.shared.data(from:)` + `URLCache` or custom `NSCache`-based TTL cache (5 min) | No Next.js cache equivalent; implement a simple time-based cache |
| `res.json()` | `JSONDecoder().decode(ScheduleResponse.self, from: data)` | Strongly typed Decodable response |
| Error: `throw new Error(...)` | `throw APIError.httpError(statusCode:)` or `.decodingFailed` | Typed Swift errors |

### 4.2 Query Parameter Mapping

| JS Parameter | Swift Equivalent | Value |
|---|---|---|
| `sportId=1` | `.sportId(1)` | Always MLB |
| `teamId=${teamId}` | `.teamId(teamId)` | Dynamic, from user selection |
| `startDate=${startDateStr}` | `.startDate(Date)` | Today (upcoming) or March 1 (completed) |
| `endDate=${endDateStr}` | `.endDate(Date)` | +6 months (upcoming) or today (completed) |
| `gameType=R,F,D,L,W` | `.gameTypes([.regular, .wildCard, .division, .league, .worldSeries])` | Enum-based for type safety |
| `hydrate=broadcasts(all),linescore,team` | `.hydrations([.broadcasts, .linescore, .team])` | Enum-based |

### 4.3 Response Model Mapping

| JS Type / Field | Swift Type | Notes |
|---|---|---|
| `data.dates[]` | `ScheduleResponse.dates: [ScheduleDate]` | Top-level Decodable |
| `dates[].games[]` | `ScheduleDate.games: [RawGame]` | Nested Decodable |
| `game.gamePk` | `RawGame.gamePk: Int` | Unique game identifier |
| `game.gameDate` | `RawGame.gameDate: Date` (ISO8601 decoded) | Use `JSONDecoder.dateDecodingStrategy = .iso8601` |
| `game.status.abstractGameState` | `GameState` enum: `.preview`, `.live`, `.final` | Decode from raw string |
| `game.status.detailedState` | `String` | Human-readable status |
| `game.teams.home/away.team` | `TeamInfo` struct | `id`, `name`, `abbreviation` |
| `game.teams.home/away.score` | `Int?` | Optional, only present when live/final |
| `game.teams.home/away.isWinner` | `Bool?` | Optional, only present when final |
| `game.venue.name` | `String` | Stadium name |
| `game.broadcasts[]` | `[Broadcast]` | `name`, `type`, `language`, `isNational` |
| Computed: `isHome` | Computed property on `Game` | `teams.home.team.id == selectedTeamId` |
| Computed: `opponent` | Computed property on `Game` | Derived from `isHome` |

### 4.4 Pagination Strategy

The web app fetches the **entire date range** in one MLB API call and paginates in memory on the server. For iOS:

- **Same approach initially:** Fetch full date range, cache in `GameRepository`, paginate from the cached array. This keeps the networking layer simple and mirrors existing behavior.
- **Optimization (later):** If response sizes become problematic, consider splitting into smaller date ranges.
- **Page sizes:** Match web defaults — 6 initial + 5 per page (upcoming), 20 per page (completed).

### 4.5 Caching Strategy

| Layer | Mechanism | TTL |
|---|---|---|
| HTTP | `URLCache` (system default) respects `Cache-Control` headers from MLB API | Varies |
| Application | `GameRepository` holds an in-memory cache keyed by `(teamId, gameFilter)` | 5 minutes (matches web `revalidate: 300`) |
| Offline fallback | Bundled `MockSchedule.json` for Yankees; cached last-fetch for other teams | Indefinite |

---

## 5. Static Data Mapping

### 5.1 Team Data (`mlb-teams.ts` → `MLBTeams.json` + `Team.swift`)

The web app bundles all 30 teams as a static TypeScript array. For iOS:

| Web | iOS |
|---|---|
| `MLB_TEAMS_LIST: MlbTeam[]` | Bundled `MLBTeams.json` decoded into `[MlbTeam]` at app launch |
| `DIVISIONS: Division[]` | Decoded from same JSON, grouped by division |
| `getTeamById(id)` | `TeamStore.team(byId:)` — O(1) dictionary lookup |
| `DEFAULT_TEAM_ID = 147` | `Constants.defaultTeamId = 147` |

### 5.2 Team Colors

| Web (CSS Variables) | iOS (SwiftUI Colors) |
|---|---|
| `--team-primary: #0c2340` | `TeamTheme.primary: Color` |
| `--team-primary-light: #1a3a5c` | `TeamTheme.primaryLight: Color` |
| `--team-primary-dark: #071729` | `TeamTheme.primaryDark: Color` |
| `--team-secondary: #c4a862` | `TeamTheme.secondary: Color` |

Colors are stored as hex strings in JSON and converted to `Color` at load time via a `Color(hex:)` initializer extension.

---

## 6. State Management Mapping

| Web (React) | iOS (SwiftUI) | Scope |
|---|---|---|
| `TeamContext` (React Context) | `@Observable TeamStore` injected via `.environment()` | App-wide |
| `useState` for `games[]`, `page`, `loading`, etc. | `@Observable` ViewModel properties | Per-screen |
| `useEffect` watching `team.id` | ViewModel `.task(id: teamId)` or `onChange(of:)` | Reactive reload |
| `useCallback` for `loadGames` | `@MainActor func loadGames()` on ViewModel | Memoization not needed in Swift |
| `IntersectionObserver` trigger | `.onAppear` on sentinel view / `.task` | Pagination trigger |
| `document.cookie` read/write | `@AppStorage("selectedTeamId")` | Persistence |
| Next.js `cookies()` at SSR | `UserDefaults` read at app launch | Initial state |

---

## 7. Open Questions & Assumptions

### Open Questions

| # | Question | Impact | Recommendation |
|---|---|---|---|
| Q1 | **Minimum iOS version target?** | Determines availability of `@Observable` (iOS 17), `ContentUnavailableView` (iOS 17), `ScrollView` improvements. | **Target iOS 17.0+** — gives access to Observation framework, modern SwiftUI APIs, and covers 90%+ of active devices. |
| Q2 | **Should the iOS app call the MLB API directly, or go through a backend proxy (like the Next.js API routes)?** | Direct calls simplify architecture; proxy adds rate-limiting control and response shaping. | **Direct API calls initially.** The web's Next.js routes exist primarily for SSR caching and mock fallback — both handled differently on iOS. Add a proxy layer only if rate limiting or API key requirements emerge. |
| Q3 | **Live game auto-refresh?** The web app does NOT auto-refresh live game data. Should iOS? | User expectation on mobile is higher for live data. | **Phase 2 stretch:** Add a configurable polling interval (e.g., 30s) when any visible game has `state == .live`. Use `Timer` + `Task` rather than Combine. |
| Q4 | **Offline / cached data policy?** Web has no offline support beyond the Yankees mock data. | Mobile users expect some offline resilience. | **Phase 1 ships with bundled mock data** (Yankees). Phase 2 adds disk-based caching of last successful API response per team. |
| Q5 | **Should we add a game detail screen?** The web has no individual game detail page. | Significant UX opportunity; MLB API provides `/game/{gamePk}/feed/live` for play-by-play and box score. | **Phase 2:** Add `GameDetailView` with linescore, box score, and play-by-play. Phase 1 game cards are not tappable. |
| Q6 | **Team logos?** Web uses only text. MLB API provides `https://www.mlb.com/team/{id}/logos`. | Major visual upgrade for mobile. | **Include in Phase 2.** Store logo URLs in team data; load via `AsyncImage`. |
| Q7 | **Push notifications for game start?** | Not in web app. Common mobile expectation. | **Out of scope** for Phase 1 and 2. Requires backend infrastructure. Note for future roadmap. |
| Q8 | **App Store distribution or internal only?** | Affects code signing, TestFlight setup, review guidelines compliance. | **Assume TestFlight initially**, App Store later. |

### Assumptions

| # | Assumption | Basis |
|---|---|---|
| A1 | The MLB Stats API at `statsapi.mlb.com` remains publicly accessible without an API key. | Current web app uses it without authentication. **Contingency:** If the API becomes gated, the architecture's `GameRepository` protocol allows swapping in a backend proxy with no view-layer changes. A proxy layer (e.g., a lightweight Vapor or CloudFlare Worker service) could be stood up to handle auth and forward requests. |
| A2 | The API response schema (schedule endpoint with hydrations) is stable and matches the fields documented in ARCHITECTURE.md. | Based on analysis of web app's consumption. |
| A3 | All 30 team IDs in `mlb-teams.ts` are current and correct for the 2026 season. | Matches MLB Stats API team IDs. |
| A4 | Season start is approximately March 1 (hardcoded in web app). | **Elevated priority:** The iOS app should derive the season start from the MLB API's `/seasons` endpoint or from the earliest game date returned by the schedule query, rather than hardcoding March 1. This avoids annual maintenance and prevents missing early-season games (e.g., international openers in February). Target for Phase 2 initial implementation. |
| A5 | English-language broadcasts are the primary/only broadcasts to display. | Matches web app behavior. |
| A6 | Game types `R,F,D,L,W` (Regular, Wild Card, Division, League, World Series) are the correct set to query. | Matches web app; Spring Training (`S`) and All-Star (`A`) excluded. |
| A7 | The Xcode project will use Swift 6 with strict concurrency checking enabled. | Best practice for new projects in 2026. |
| A8 | No third-party dependencies required for Phase 2 implementation. URLSession, JSONDecoder, and SwiftUI provide everything needed. | Keeps the dependency graph minimal. |

---

## 8. Next Steps — Phase 2 Scope Overview

Upon approval of this Phase 1 plan, Phase 2 will deliver:

1. **App scaffold** — Xcode project with folder structure matching §2, configured for iOS 17+, Swift 6.
2. **Core navigation shell** — `TabView` with Upcoming and Completed tabs, `NavigationStack` per tab, team selector in toolbar.
3. **Networking layer** — `MLBAPIClient` protocol + implementation, `MLBEndpoint` enum, `ScheduleResponse` Decodable types, `GameRepository` with 5-minute TTL cache.
4. **Example feature end-to-end** — Upcoming Games tab fully functional: API fetch → parse → paginate → display in themed game cards with infinite scroll, error states, empty state, pull-to-refresh, and mock data fallback.

---

*Generated from analysis of [yankee-game-finder](https://github.com/johnhillphoto/yankee-game-finder) (commit `971bb52`) and [MLB Stats API](https://statsapi.mlb.com/api/v1).*
