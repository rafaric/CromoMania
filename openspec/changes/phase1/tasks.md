# SDD Tasks — Sticker Collector App Phase 1

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~2,200 - 2,500 lines |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | 6 sequential work units |
| Delivery strategy | ask-on-risk |
| Chain strategy | feature-branch-chain |

**Rationale for High Risk:**
- 4 feature modules (album, collection, stats, pdf_export)
- Database layer with Drift code generation
- 100+ seed stickers across 10 sections
- Integration with navigation and theming
- Full Clean Architecture with 30+ new files

**Recommended Chain Sequence:**
1. **PR 1 → Foundation:** Project setup, dependencies, database layer
2. **PR 2 → Album Feature:** Domain entities, repository, cubit, pages
3. **PR 3 → Collection Feature:** State machine, persistence, sticker tile
4. **PR 4 → Stats Feature:** Calculator, dashboard, widgets
5. **PR 5 → PDF Export Feature:** Generator, service, cubit, pages
6. **PR 6 → Integration:** Navigation, app shell, final polish, APK verification

---

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: feature-branch-chain
400-line budget risk: High

---

## Task Groups

### [Group 1: Foundation] — Project Setup, Dependencies, and Database Layer

**Purpose:** Establish the Flutter project with Clean Architecture structure, configure dependencies, and implement the Drift database layer with lazy initialization.

#### T1.1: Create Flutter Project Structure
- **File:** `pubspec.yaml`
- **Action:** Create Flutter project with `flutter create sticker_collector_app`, then restructure to feature-first Clean Architecture:
  - Create `lib/core/` directory with constants, theme, utils
  - Create `lib/database/` directory with tables and daos
  - Create `lib/features/` directory with album, collection, stats, pdf_export subdirectories
- **Verification:** Run `flutter pub get` successfully, verify folder structure matches design.md
- **Depends on:** None

#### T1.2: Configure Dependencies
- **File:** `pubspec.yaml`
- **Action:** Add dependencies:
  ```yaml
  dependencies:
    flutter_bloc: ^8.1.0
    drift: ^2.15.0
    sqlite3_flutter_libs: ^0.5.0
    path_provider: ^2.1.0
    path: ^1.8.0
    pdf: ^3.10.0
    share_plus: ^7.2.0
    equatable: ^2.0.5
  
  dev_dependencies:
    drift_dev: ^2.15.0
    build_runner: ^2.4.0
  ```
- **Verification:** Run `flutter pub get` without errors
- **Depends on:** T1.1

#### T1.3: Create Core Constants
- **File:** `lib/core/constants/app_constants.dart`
- **Action:** Create constants class with:
  - `defaultUserId = 'default_user'`
  - `appName = 'Sticker Collector'`
  - `databaseName = 'sticker_collector.db'`
- **Verification:** File exists and exports constants, `dart analyze` passes
- **Depends on:** T1.1

#### T1.4: Create App Theme
- **File:** `lib/core/theme/app_theme.dart`
- **Action:** Create Material theme with:
  - Primary color: Blue (FIFA style)
  - Secondary color: Green (owned state)
  - Warning color: Amber (repeated state)
  - Gray: Missing state
  - Text styles for headers, body, captions
  - Card decorations for album/section tiles
- **Verification:** Theme compiles, colors match spec requirements
- **Depends on:** T1.1

#### T1.5: Create Drift Database Class
- **File:** `lib/database/app_database.dart`
- **Action:** Create `AppDatabase` class with:
  - LazyDatabase initialization
  - All 4 table classes (albums, sections, stickers, collection_statuses)
  - DAOs for each table
  - MigrationStrategy with onCreate
  - Singleton instance getter
- **Verification:** Code compiles, generates `app_database.g.dart` after build_runner
- **Depends on:** T1.2

#### T1.6: Create Album Seed Data
- **File:** `lib/features/album/data/datasources/local/seed_data.dart`
- **Action:** Create SeedData class with static data:
  - 1 album (Panini WC 2026)
  - 10 sections (Cover, Stars, Group A-H)
  - ~100 stickers (10 per section, per design.md section 7.1)
- **Verification:** All sticker data matches design.md section 7.1 structure
- **Depends on:** T1.5

---

### [Group 2: Album Feature] — Album Browsing with WC 2026 Data

**Purpose:** Implement album browsing feature with domain entities, repository, cubit, and UI pages.

#### T2.1: Create Album Domain Entities
- **File:** `lib/features/album/domain/entities/`
- **Action:** Create entity classes:
  - `album.dart` with id, name, publisher, description, totalStickers, createdAt
  - `section.dart` with id, albumId, name, orderIndex
  - `sticker.dart` with id, sectionId, stickerNumber, name, isSpecial
- **Verification:** Entities are simple data classes with Equatable, pass dart analyze
- **Depends on:** T1.1

#### T2.2: Create Album Repository Interface
- **File:** `lib/features/album/domain/repositories/album_repository.dart`
- **Action:** Define abstract interface with methods:
  - `getAlbums()`, `getAlbumById(int)`, `getSectionsForAlbum(int)`
  - `getStickersForSection(int)`, `getStickersForAlbum(int)`
  - `isAlbumsTableEmpty()`
- **Verification:** Interface compiles, no implementation
- **Depends on:** T2.1

#### T2.3: Create Album Data Models
- **File:** `lib/features/album/data/models/`
- **Action:** Create data models with:
  - `AlbumModel`, `SectionModel`, `StickerModel`
  - JSON serialization methods
  - Conversion to/from entities
- **Verification:** Models have toJson/fromJson, compile successfully
- **Depends on:** T2.1

#### T2.4: Create Album Local DataSource with Seeding
- **File:** `lib/features/album/data/datasources/local/album_local_datasource.dart`
- **Action:** Implement AlbumLocalDataSource with:
  - Seed check (isAlbumsTableEmpty)
  - Seed transaction (insert album → sections → stickers → collection statuses)
  - CRUD operations for all entities
- **Verification:** Seed data loads on first run, subsequent runs skip seeding
- **Depends on:** T1.5, T1.6

#### T2.5: Create Album Repository Implementation
- **File:** `lib/features/album/data/repositories/album_repository_impl.dart`
- **Action:** Implement AlbumRepository interface using AlbumLocalDataSource
- **Verification:** Repository compiles, implements all interface methods
- **Depends on:** T2.2, T2.4

#### T2.6: Create Album Cubit and State
- **File:** `lib/features/album/presentation/cubit/album_cubit.dart`
- **Action:** Implement AlbumCubit with:
  - `loadAlbums()` - loads albums, triggers seeding if needed
  - `loadSectionsForAlbum(int)` - loads sections
  - `loadStickersForSection(int)` - loads stickers
  - Immutable AlbumState with copyWith
- **Verification:** Cubit handles loading, loaded, error states correctly
- **Depends on:** T2.5

#### T2.7: Create Album List Page
- **File:** `lib/features/album/presentation/pages/album_list_page.dart`
- **Action:** Build AlbumListPage with:
  - AppBar with "Sticker Collector" title
  - ListView of album cards
  - Navigation to AlbumDetailPage on tap
- **Verification:** Page displays album list, navigation works
- **Depends on:** T2.6

#### T2.8: Create Album Detail Page
- **File:** `lib/features/album/presentation/pages/album_detail_page.dart`
- **Action:** Build AlbumDetailPage with:
  - AppBar with album name
  - Album header (total stickers count)
  - ListView of section tiles in orderIndex order
  - Navigation to SectionStickersPage on tap
- **Verification:** Page displays sections in correct order, navigates to stickers
- **Depends on:** T2.7

#### T2.9: Create Section Stickers Page
- **File:** `lib/features/album/presentation/pages/section_stickers_page.dart`
- **Action:** Build SectionStickersPage with:
  - AppBar with section name
  - GridView.builder with 4 columns
  - StickerTile widget per sticker (placeholder for now)
  - RepaintBoundary per tile for performance
- **Verification:** Grid scrolls at 60fps with 20+ stickers
- **Depends on:** T2.8

#### T2.10: Create Supporting Widgets
- **File:** `lib/features/album/presentation/widgets/`
- **Action:** Create widgets:
  - `album_card.dart` - Card for album list with name, description, sticker count
  - `section_tile.dart` - ListTile for section with name, sticker count, icon
- **Verification:** Widgets render correctly, match design theme
- **Depends on:** T1.4, T2.7

---

### [Group 3: Collection Feature] — State Machine and Persistence

**Purpose:** Implement sticker collection state machine with tap/long-press interactions and Drift persistence.

#### T3.1: Create Collection Status Entity
- **File:** `lib/features/collection/domain/entities/collection_status.dart`
- **Action:** Create CollectionStatus entity with:
  - stickerId, userId, count (0=missing, 1=owned, 2+=repeated)
  - Computed getters: isMissing, isOwned, isRepeated
- **Verification:** Entity compiles, computed properties work correctly
- **Depends on:** T1.1

#### T3.2: Create Collection Repository Interface
- **File:** `lib/features/collection/domain/repositories/collection_repository.dart`
- **Action:** Define abstract interface with methods:
  - `getStatusesForUser(String)`
  - `getStatusForSticker(int, String)`
  - `saveStatus(CollectionStatus)`
  - `saveStatuses(List<CollectionStatus>)`
  - `getStatusMap(String)`
  - `initializeDefaultStatuses(String, List<int>)`
- **Verification:** Interface compiles
- **Depends on:** T3.1

#### T3.3: Create Collection Data Model
- **File:** `lib/features/collection/data/models/collection_status_model.dart`
- **Action:** Create model with:
  - Database table annotation (@DriftTable)
  - JSON serialization
  - Conversion to/from entity
- **Verification:** Model compiles, Drift annotations correct
- **Depends on:** T3.1, T1.5

#### T3.4: Create Collection Local DataSource
- **File:** `lib/features/collection/data/datasources/local/collection_local_datasource.dart`
- **Action:** Implement CollectionLocalDataSource with:
  - CRUD operations for collection_status table
  - getStatusMap query
  - initializeDefaultStatuses for new users
- **Verification:** DataSource compiles, all queries implementable
- **Depends on:** T1.5, T3.3

#### T3.5: Create Collection Repository Implementation
- **File:** `lib/features/collection/data/repositories/collection_repository_impl.dart`
- **Action:** Implement CollectionRepository using CollectionLocalDataSource
- **Verification:** Repository compiles, implements all interface methods
- **Depends on:** T3.2, T3.4

#### T3.6: Create Collection Cubit with State Machine
- **File:** `lib/features/collection/presentation/cubit/collection_cubit.dart`
- **Action:** Implement CollectionCubit with:
  - State machine logic (tap=+1, longPress=-1, clamped 0-999)
  - Immutable CollectionState with statusMap
  - Computed properties: ownedCount, missingCount, repeatedCount, completionPercent
  - Async load from repository
- **Verification:** State transitions work per spec requirements
- **Depends on:** T3.5

#### T3.7: Create StickerTile Widget
- **File:** `lib/features/collection/presentation/widgets/sticker_tile.dart`
- **Action:** Create StickerTile with:
  - GestureDetector for tap/long-press
  - Visual states: gray (missing), green (owned), amber (repeated)
  - Status icon (check for owned, copy for repeated)
  - Count badge for repeated stickers
  - AnimatedContainer for state transitions
  - RepaintBoundary wrapper
- **Verification:** Widget displays correct visual state, responds to gestures
- **Depends on:** T3.6, T1.4

#### T3.8: Integrate StickerTile into Section Stickers Page
- **File:** `lib/features/album/presentation/pages/section_stickers_page.dart`
- **Action:** Update SectionStickersPage to:
  - Wrap with BlocProvider<CollectionCubit>
  - Pass collection state to StickerTile
  - Connect tap/long-press to cubit methods
- **Verification:** Sticker tiles update collection state on interaction
- **Depends on:** T3.7, T2.9

---

### [Group 4: Stats Feature] — Dashboard and Calculations

**Purpose:** Implement stats dashboard with real-time calculations and visual progress indicators.

#### T4.1: Create Stats Calculator Domain Class
- **File:** `lib/features/stats/domain/stats_calculator.dart`
- **Action:** Create StatsCalculator with:
  - `calculateStats(CollectionState)` method
  - Calculate: completionPercent, ownedCount, missingCount, repeatedCount
  - Section-level stats computation
- **Verification:** Calculator produces correct values per spec examples
- **Depends on:** T3.6

#### T4.2: Create Stats State
- **File:** `lib/features/stats/presentation/cubit/stats_state.dart`
- **Action:** Create StatsState with:
  - completionPercent, ownedCount, missingCount, repeatedCount, totalStickers
  - sectionStats map
  - isLoading flag
  - Immutable copyWith
- **Verification:** State compiles, copyWith works correctly
- **Depends on:** T4.1

#### T4.3: Create Stats Cubit
- **File:** `lib/features/stats/presentation/cubit/stats_cubit.dart`
- **Action:** Implement StatsCubit with:
  - `recalculateStats(CollectionState)` method
  - Emit updated StatsState on collection changes
- **Verification:** Cubit recalculates stats when collection state changes
- **Depends on:** T4.1, T4.2

#### T4.4: Create ProgressRing Widget
- **File:** `lib/features/stats/presentation/widgets/progress_ring.dart`
- **Action:** Create ProgressRing with:
  - CircularProgressIndicator with animated TweenAnimationBuilder
  - Color changes: green (90%+), blue (50-89%), orange (<50%)
  - Center percentage text
  - Configurable size
- **Verification:** Ring animates on load, colors match thresholds
- **Depends on:** T1.4

#### T4.5: Create StatCard Widget
- **File:** `lib/features/stats/presentation/widgets/stat_card.dart`
- **Action:** Create StatCard with:
  - Icon, value, label layout
  - Configurable color per stat type
  - Card decoration
- **Verification:** Cards display correctly in dashboard grid
- **Depends on:** T1.4

#### T4.6: Create Stats Dashboard Page
- **File:** `lib/features/stats/presentation/pages/stats_dashboard_page.dart`
- **Action:** Build StatsDashboardPage with:
  - AppBar with "My Collection Stats" title
  - ProgressRing at top
  - Grid of 4 StatCards (owned, missing, repeated, completion)
  - Pull-to-refresh for recalculation
- **Verification:** Dashboard displays correct stats, updates on collection changes
- **Depends on:** T4.3, T4.4, T4.5

---

### [Group 5: PDF Export Feature] — Generator, Cubit, and Share UI

**Purpose:** Implement PDF export with multiple filter options and native sharing.

#### T5.1: Create PDF Generator
- **File:** `lib/features/pdf_export/data/pdf_generator.dart`
- **Action:** Create PdfGenerator with:
  - `generateCollectionPdf()` method
  - A4 page format with 32pt margins
  - Header with album name and date
  - Table with #, Name, Status columns
  - ASCII status symbols: [ ] (missing), [✓] (owned), [+n] (repeated)
  - Multi-page support with pw.MultiPage
  - Legend at bottom
  - Footer with page numbers
- **Verification:** Generates valid PDF file, opens correctly in viewer
- **Depends on:** T1.2

#### T5.2: Create PDF Export Service
- **File:** `lib/features/pdf_export/domain/pdf_export_service.dart`
- **Action:** Create PdfExportService with:
  - Filter options: full, missingOnly, section
  - Share functionality using share_plus
  - Filename generation with timestamp
- **Verification:** Service shares PDF via native share sheet
- **Depends on:** T5.1

#### T5.3: Create PDF Export State
- **File:** `lib/features/pdf_export/presentation/cubit/pdf_export_state.dart`
- **Action:** Create PdfExportState with:
  - status enum: initial, generating, ready, sharing, error
  - pdfBytes nullable
  - filter enum
  - errorMessage nullable
  - Immutable copyWith
- **Verification:** State compiles
- **Depends on:** T5.1

#### T5.4: Create PDF Export Cubit
- **File:** `lib/features/pdf_export/presentation/cubit/pdf_export_cubit.dart`
- **Action:** Implement PdfExportCubit with:
  - `generatePdf()` method with filter options
  - `sharePdf()` method
  - Error handling
- **Verification:** Cubit generates and shares PDFs correctly
- **Depends on:** T5.2, T5.3

#### T5.5: Create PDF Export Page
- **File:** `lib/features/pdf_export/presentation/pages/pdf_export_page.dart`
- **Action:** Build PdfExportPage with:
  - AppBar with "Export Collection" title
  - Three export buttons: Full Collection, Missing Only, Current Section
  - Loading indicator during generation
  - Share button when PDF ready
  - Error display state
- **Verification:** Page displays options, generates PDFs, opens share sheet
- **Depends on:** T5.4

---

### [Group 6: Integration] — Navigation, App Shell, and Final Polish

**Purpose:** Wire all features together with navigation, implement bottom nav, and verify APK build.

#### T6.1: Wire Cubits and Repositories in Main
- **File:** `lib/main.dart`
- **Action:** Update main.dart with:
  - Database singleton initialization
  - RepositoryProvider for AlbumRepository and CollectionRepository
  - BlocProvider for AlbumCubit, CollectionCubit, StatsCubit, PdfExportCubit
  - BlocListener for StatsCubit to recalculate on collection changes
- **Verification:** All providers accessible, app initializes correctly
- **Depends on:** T2.6, T3.6, T4.3, T5.4

#### T6.2: Implement Bottom Navigation
- **File:** `lib/core/navigation/app_navigation.dart`
- **Action:** Create navigation structure with:
  - IndexedStack for 3 tabs: Albums, Stats, Export
  - BottomNavigationBar with icons
  - Persistent state across tab switches
- **Verification:** Navigation works, state persists when switching tabs
- **Depends on:** T2.7, T4.6, T5.5

#### T6.3: Configure Android Build
- **File:** `android/app/build.gradle`
- **Action:** Verify/update Android configuration:
  - minSdkVersion for Drift compatibility (21+)
  - targetSdkVersion
  - compileSdkVersion
- **Verification:** `flutter build apk --debug` succeeds
- **Depends on:** T1.2

#### T6.4: Add App Constants and Theme Exports
- **File:** `lib/core/core.dart`
- **Action:** Create barrel export file for core module
- **Verification:** Imports work from `package:sticker_collector/core/core.dart`
- **Depends on:** T1.3, T1.4

#### T6.5: Build and Verify Debug APK
- **File:** `build/app/outputs/flutter-apk/app-debug.apk`
- **Action:** Run complete build pipeline:
  - `flutter pub get`
  - `dart run build_runner build --delete-conflicting-outputs`
  - `flutter build apk --debug`
  - Install on device/emulator
- **Verification:** APK installs and launches, WC 2026 album displays
- **Depends on:** T6.1, T6.2, T6.3

#### T6.6: Manual Acceptance Testing
- **File:** None (verification only)
- **Action:** Test all acceptance criteria from proposal.md:
  - F1-F12: Functional acceptance tests
  - N1-N6: Non-functional acceptance tests
  - A1-A5: Architecture quality checks
- **Verification:** All criteria pass or documented exceptions
- **Depends on:** T6.5

---

## Dependency Graph

```
Foundation (Group 1)
├── T1.1 → T1.2 → T1.3 → T1.4 → T1.5 → T1.6

Album Feature (Group 2)
├── T2.1 → T2.2 → T2.3 → T2.4 → T2.5 → T2.6 → T2.7 → T2.8 → T2.9 → T2.10
└── Depends on: T1.1, T1.4, T1.5, T1.6

Collection Feature (Group 3)
├── T3.1 → T3.2 → T3.3 → T3.4 → T3.5 → T3.6 → T3.7 → T3.8
└── Depends on: T1.1, T1.4, T1.5, T2.9

Stats Feature (Group 4)
├── T4.1 → T4.2 → T4.3 → T4.4 → T4.5 → T4.6
└── Depends on: T1.4, T3.6

PDF Export Feature (Group 5)
├── T5.1 → T5.2 → T5.3 → T5.4 → T5.5
└── Depends on: T1.2, T3.6

Integration (Group 6)
├── T6.1 → T6.2 → T6.3 → T6.4 → T6.5 → T6.6
└── Depends on: All previous groups
```

---

## Verification Commands

### Per Work Unit
```bash
# After Foundation (Group 1)
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart analyze

# After Album Feature (Group 2)
flutter test test/features/album/
dart analyze

# After Collection Feature (Group 3)
flutter test test/features/collection/
dart analyze

# After Stats Feature (Group 4)
flutter test test/features/stats/
dart analyze

# After PDF Export (Group 5)
flutter test test/features/pdf_export/
dart analyze

# After Integration (Group 6)
flutter build apk --debug
```

### Final Verification
```bash
# Full build and test
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter build apk --debug

# APK size check (should be < 50MB for debug)
ls -lh build/app/outputs/flutter-apk/app-debug.apk
```

---

*Tasks authored 2026-05-22 for Sticker Collector App Phase 1 MVP*
*Status: Ready for supervisor review and implementation start*
