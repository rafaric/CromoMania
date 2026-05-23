# Proposal — Sticker Collector App Phase 1

## Intent

Build the offline-first MVP core of the Sticker Collector App: a rock-solid, ad-free sticker collection manager with album browsing, sticker tracking (tap/long-press), stats dashboard, and PDF export. Phase 1 establishes the technical foundation using Flutter + Cubit + Drift, seeding real Panini WC 2026 album data to validate the architecture end-to-end.

**Why this matters:** The market leader crashes on sticker tap, has abusive ads, and broken PDF export. Phase 1 proves we can deliver a stable, offline-first alternative that "just works."

---

## Scope

### In Scope

| Feature | Description |
|---------|-------------|
| **Album Browser** | Browse album sections (Teams A-H, Stars, etc.) with pre-loaded WC 2026 data |
| **Sticker Grid** | Scrollable grid (800+ stickers) with tap/long-press state machine |
| **Collection State Machine** | Tap → +1 owned count; Long-press → -1 owned count; 0 → missing |
| **Stats Dashboard** | Completion %, missing count, owned count, repeated count |
| **PDF Export** | Full collection list + filtered (missing only or section-specific) |
| **Local Persistence** | Drift/SQLite database with album templates and user collection state |
| **Android Build** | Debug APK compilable and installable |

### Out of Scope (Phase 2+)

- Cloud sync / Firebase Auth
- OCR batch scanning
- QR bidirectional trade system
- Push notifications
- Home screen widgets
- Multiple user profiles
- Custom album templates (import/export)
- Sticker images (numbers only for Phase 1)
- iOS build

---

## Capabilities

### Capability: Album Browsing with Pre-Loaded WC 2026 Data

**Solution:**
Seed the local Drift database with a hardcoded Panini WC 2026 album template on first launch.

**Album Structure (based on real Panini WC 2026):**

```json
{
  "album": {
    "id": "panini_wc2026",
    "name": "Panini FIFA World Cup 2026",
    "publisher": "Panini",
    "description": "Official FIFA World Cup USA-Canada-Mexico 2026 Sticker Album",
    "total_stickers": 670,
    "created_at": "2026-01-01T00:00:00Z"
  },
  "sections": [
    {
      "id": "section_cover",
      "name": "Cover & Official",
      "order_index": 0,
      "stickers": [
        { "number": "C1", "name": "Official Ball", "is_special": false },
        { "number": "C2", "name": "Official Logo", "is_special": true }
      ]
    },
    {
      "id": "section_stars",
      "name": "Stars",
      "order_index": 1,
      "stickers": [
        { "number": "S1", "name": "Messi", "is_special": true },
        { "number": "S2", "name": "Ronaldo", "is_special": true },
        { "number": "S3", "name": "Mbappé", "is_special": true },
        { "number": "S4", "name": "Haaland", "is_special": false },
        { "number": "S5", "name": "Bellingham", "is_special": false }
      ]
    },
    {
      "id": "section_group_a",
      "name": "Group A",
      "order_index": 2,
      "stickers": [
        { "number": "A1", "name": "Argentina", "is_special": false },
        { "number": "A2", "name": "Argentina - Logo", "is_special": false },
        { "number": "A3", "name": "Argentina - Home", "is_special": false },
        { "number": "A4", "name": "Argentina - Away", "is_special": false },
        { "number": "A5", "name": "Argentina - Star Player", "is_special": true }
      ]
    },
    {
      "id": "section_group_b",
      "name": "Group B",
      "order_index": 3,
      "stickers": [
        { "number": "B1", "name": "Brazil", "is_special": false },
        { "number": "B2", "name": "Brazil - Logo", "is_special": false },
        { "number": "B3", "name": "Brazil - Home", "is_special": false },
        { "number": "B4", "name": "Brazil - Away", "is_special": false },
        { "number": "B5", "name": "Brazil - Star Player", "is_special": true }
      ]
    },
    {
      "id": "section_group_c",
      "name": "Group C",
      "order_index": 4,
      "stickers": [
        { "number": "C1", "name": "Mexico", "is_special": false },
        { "number": "C2", "name": "Mexico - Logo", "is_special": false },
        { "number": "C3", "name": "Mexico - Home", "is_special": false },
        { "number": "C4", "name": "Mexico - Away", "is_special": false },
        { "number": "C5", "name": "Mexico - Star Player", "is_special": true }
      ]
    }
  ]
}
```

**Implementation:**
1. Create `SeedData` class with static JSON-like data structures
2. On first app launch, check if albums table is empty
3. If empty, insert album → sections → stickers in transaction
4. Use `LazyDatabase` for offline-first performance

**Data Seeding Flow:**
```
App Start → Check DB → albums table empty?
    ├─ Yes → Run seed_transaction()
    │       ├─ Insert album("panini_wc2026")
    │       ├─ Insert sections (Group A-H, Stars, Cover, etc.)
    │       ├─ Insert stickers (670 total)
    │       └─ Initialize collection_status for default_user
    └─ No → Load existing data
```

---

### Capability: Sticker Grid with Tap/Long-Press State Machine

**Solution:**
Implement a responsive grid with isolated state updates per sticker.

**State Machine:**

| Current State | Tap Action | Long-Press Action | Result State |
|---------------|------------|-------------------|--------------|
| Missing (count=0) | Tap → +1 | N/A | Owned (count=1) |
| Owned (count=1) | Tap → +1 | Long-press → -1 | Repeated (count=2) |
| Repeated (count>1) | Tap → +1 | Long-press → -1 | Repeated (count=n-1) or Missing |

**UI Feedback:**
- Missing: Empty cell with gray border, number visible
- Owned: Green fill with checkmark, count badge if >1
- Repeated: Yellow fill with duplicate icon, count badge

**Implementation:**

```dart
// StickerCubit manages collection state
class StickerCubit extends Cubit<CollectionState> {
  void toggleSticker(int stickerId) {
    // Immutable state copy-on-write
    final updatedStatuses = List<StickerStatus>.from(state.statuses);
    final index = updatedStatuses.indexWhere((s) => s.stickerId == stickerId);
    
    final current = updatedStatuses[index];
    final newCount = current.count + 1;
    
    updatedStatuses[index] = current.copyWith(
      status: newCount > 1 ? Status.repeated : Status.owned,
      count: newCount,
    );
    
    emit(state.copyWith(statuses: updatedStatuses));
    _repository.saveStickerStatus(updatedStatuses[index]);
  }
  
  void decrementSticker(int stickerId) {
    // Only owned/repeated stickers respond to long-press
    // If count reaches 0, status → missing
  }
}
```

**Grid Widget with RepaintBoundary:**

```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,
    childAspectRatio: 0.85,
  ),
  itemCount: currentSection.stickers.length,
  itemBuilder: (context, index) {
    final sticker = currentSection.stickers[index];
    final status = state.getStatus(sticker.id);
    
    return RepaintBoundary(
      key: ValueKey(sticker.id),
      child: StickerTile(
        sticker: sticker,
        status: status,
        onTap: () => cubit.toggleSticker(sticker.id),
        onLongPress: () => cubit.decrementSticker(sticker.id),
      ),
    );
  },
)
```

**Performance Guarantees:**
- `GridView.builder` with fixed cross-axis count
- `RepaintBoundary` per tile prevents unnecessary repaints
- Const constructors on all StatelessWidgets
- Pre-calculate stats on state change, not on build

---

### Capability: Stats Dashboard (Completion %, Missing Count)

**Solution:**
Real-time stats calculated from collection_status table, displayed in a dedicated dashboard screen.

**Metrics Display:**

```
┌─────────────────────────────────────────┐
│  📊 My Collection Stats                │
├─────────────────────────────────────────┤
│                                         │
│  ████████████░░░░░░░  64%              │
│  Completed:  428 / 670                 │
│                                         │
│  ┌──────────┐  ┌──────────┐            │
│  │  ✅ Owned │  │ 📋 Missing│            │
│  │    428   │  │    242   │            │
│  └──────────┘  └──────────┘            │
│                                         │
│  ┌──────────┐  ┌──────────┐            │
│  │  🔄 Extra │  │  Teams   │            │
│  │    156   │  │   32/32  │            │
│  └──────────┘  └──────────┘            │
│                                         │
└─────────────────────────────────────────┘
```

**Calculations:**

```dart
// StatsCubit derives stats from CollectionCubit state
class StatsCubit extends Cubit<StatsState> {
  StatsState calculateStats(CollectionState collection) {
    final total = collection.album.totalStickers;
    final owned = collection.statuses.where((s) => s.count > 0).length;
    final missing = total - owned;
    final repeated = collection.statuses
        .where((s) => s.count > 1)
        .fold(0, (sum, s) => sum + (s.count - 1));
    
    return StatsState(
      completionPercent: (owned / total * 100).roundToDouble(),
      ownedCount: owned,
      missingCount: missing,
      repeatedCount: repeated,
      teamsCompleted: _countTeamsWithAllStickers(collection),
    );
  }
}
```

**Dashboard Features:**
- Animated progress ring (circular or linear)
- Tap on stat card → navigate to filtered view
- Pull-to-refresh recalculates from DB
- Persist last stats snapshot for instant load

---

### Capability: PDF Export (Full + Filtered)

**Solution:**
Generate printable PDF documents using the `pdf` package, with share functionality via `share_plus`.

**Export Modes:**

| Mode | Description | Use Case |
|------|-------------|----------|
| **Full Collection** | All 670 stickers with status | Complete inventory |
| **Missing Only** | Filter: status = missing | Shopping list for trades |
| **Section Filter** | Single section (e.g., "Group A") | Targeted trading |

**PDF Layout:**

```
┌─────────────────────────────────────────┐
│  My WC 2026 Collection                  │
│  Generated: 2026-05-22                  │
├─────────────────────────────────────────┤
│  #   │ Name           │ Status          │
│  ────┼────────────────┼─────────        │
│  A1  │ Argentina      │ [x]             │
│  A2  │ Argentina Logo │ [x]             │
│  A3  │ Argentina Home │ [ ]             │
│  ... │ ...            │ ...             │
├─────────────────────────────────────────┤
│  Legend: [x] = Owned  [🔄] = Repeated   │
│  Missing: 242 / 670 (36%)               │
└─────────────────────────────────────────┘
```

**Implementation:**

```dart
Future<Uint8List> generateCollectionPDF({
  required List<Sticker> stickers,
  required Map<int, StickerStatus> statusMap,
  ExportFilter filter = ExportFilter.full,
}) async {
  final pdf = pw.Document();
  
  final filteredStickers = _applyFilter(stickers, filter, statusMap);
  
  pdf.addPage(
    pw.MultiPage(
      pageFormat: pw.PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text('My WC 2026 Collection'),
        ),
        pw.Paragraph(
          text: 'Generated: ${DateTime.now().toIso8601String().split('T').first}',
        ),
        pw.SizedBox(height: 16),
        pw.Table.fromTextArray(
          headers: ['#', 'Name', 'Status'],
          headerStyle: pw.TextStyle.bold,
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.center,
          },
          data: filteredStickers.map((s) => [
            s.number,
            s.name,
            _statusSymbol(statusMap[s.id]!.status),
          ]).toList(),
        ),
        pw.SizedBox(height: 24),
        pw.Paragraph(
          text: _generateLegend(filteredStickers, statusMap),
        ),
      ],
    ),
  );
  
  return pdf.save();
}

String _statusSymbol(Status status) {
  switch (status) {
    case Status.owned: return '[✓]';
    case Status.repeated: return '[🔄]';
    case Status.missing: return '[ ]';
  }
}
```

**Sharing Flow:**

```dart
Future<void> sharePDF(ExportFilter filter) async {
  final pdfBytes = await _pdfService.generateCollectionPDF(
    stickers: _currentAlbum.stickers,
    statusMap: _collectionState.statusMap,
    filter: filter,
  );
  
  final file = XFile.fromData(
    pdfBytes,
    mimeType: 'application/pdf',
    name: 'wc2026_${filter.name}.pdf',
  );
  
  await Share.shareXFiles([file], text: 'My WC 2026 sticker list');
}
```

**Status Symbol Fallback:**
If emoji rendering fails on target device:
- Owned: `[✓]` or `[■]` (green)
- Repeated: `[2+]` or `[■]` (yellow)
- Missing: `[ ]` or `[□]` (empty box)

---

## Affected Areas

### New Files (Phase 1 Implementation)

```
lib/
├── main.dart                           # App entry, DB init
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # Hardcoded user ID, app strings
│   ├── theme/
│   │   └── app_theme.dart             # Colors, text styles
│   └── utils/
│       └── date_utils.dart            # Formatting helpers
├── features/
│   ├── album/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── local/
│   │   │   │       ├── album_local_datasource.dart
│   │   │   │       └── seed_data.dart        # WC 2026 template data
│   │   │   ├── models/
│   │   │   │   ├── album_model.dart
│   │   │   │   ├── section_model.dart
│   │   │   │   └── sticker_model.dart
│   │   │   └── repositories/
│   │   │       └── album_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── album.dart
│   │   │   └── repositories/
│   │   │       └── album_repository.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── album_cubit.dart
│   │       │   └── album_state.dart
│   │       ├── pages/
│   │       │   ├── album_list_page.dart
│   │       │   ├── album_detail_page.dart
│   │       │   └── section_stickers_page.dart
│   │       └── widgets/
│   │           ├── section_tile.dart
│   │           └── sticker_tile.dart
│   ├── collection/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── local/
│   │   │   │       └── collection_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── collection_status_model.dart
│   │   │   └── repositories/
│   │   │       └── collection_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── collection_status.dart
│   │   │   └── repositories/
│   │   │       └── collection_repository.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── collection_cubit.dart
│   │       │   └── collection_state.dart
│   │       └── widgets/
│   │           └── sticker_tile.dart     # Shared with album feature
│   ├── stats/
│   │   ├── presentation/
│   │   │   ├── cubit/
│   │   │   │   ├── stats_cubit.dart
│   │   │   │   └── stats_state.dart
│   │   │   ├── pages/
│   │   │   │   └── stats_dashboard_page.dart
│   │   │   └── widgets/
│   │   │       ├── progress_ring.dart
│   │   │       └── stat_card.dart
│   │   └── domain/
│   │       └── stats_calculator.dart
│   └── pdf_export/
│       ├── data/
│       │   └── pdf_generator.dart
│       ├── domain/
│       │   └── pdf_export_service.dart
│       └── presentation/
│           ├── cubit/
│           │   ├── pdf_export_cubit.dart
│           │   └── pdf_export_state.dart
│           └── pages/
│               └── pdf_export_page.dart
└── database/
    ├── app_database.dart               # Drift database definition
    ├── app_database.g.dart             # Generated
    ├── tables/
    │   ├── albums_table.dart
    │   ├── sections_table.dart
    │   ├── stickers_table.dart
    │   └── collection_status_table.dart
    └── daos/
        ├── album_dao.dart
        └── collection_dao.dart
```

### Modified Files

- `pubspec.yaml` — Add dependencies (flutter_bloc, drift, pdf, share_plus)
- `android/app/build.gradle` — Configure minSdkVersion if needed

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Flutter SDK installation issues | Low | Medium | Use official Flutter installer for Windows. Verify `flutter doctor` before proceeding. |
| Drift code generation complexity | Medium | Medium | Start with simple 3-table schema. Use `@DriftIgnore` for Flutter-specific code. Keep database classes pure Dart for testability. |
| Large grid (800+ stickers) performance | Medium | Low | Use `GridView.builder` + `RepaintBoundary` from day 1. Benchmark early with 670 stickers. |
| PDF emoji rendering inconsistency | Medium | Low | Use ASCII fallback symbols ([✓], [ ]). Test on physical Android device before shipping. |
| Solo dev bandwidth constraints | High | High | Strict MVP scope. Defer all non-essential features. Complete Phase 1 before Phase 2. |
| Database migration complexity | Medium | Medium | Plan schema upfront. Use `MigrationStrategy` from start. Avoid premature schema changes. |
| State management overhead | Low | Low | Cubit provides sufficient abstraction without BLoC complexity. No need for complex event handling for this app. |

---

## Rollback

**If Phase 1 fails or needs reversal:**

### Option 1: Git Revert (Recommended)

```bash
# Revert all Phase 1 changes
git revert HEAD

# Or revert specific feature if isolated in commits
git revert <commit-hash-for-feature>
```

### Option 2: Feature Flag (Forward-Compatible)

```dart
// In main.dart, wrap Phase 1 features behind flag
if (AppConfig.enablePhase1Features) {
  runApp(StickerCollectorApp());
} else {
  runApp(PlaceholderApp());
}
```

### Option 3: Database Schema Preservation

- Drift migrations are additive only (Phase 1 adds tables, Phase 2+ adds columns)
- Drop tables only if reverting to clean state
- Maintain `schema_version` in DB for tracking

### Rollback Sequence

1. **Before Code Changes:** Tag current state as `rollback-point/phase0`
2. **During Implementation:** Commit with descriptive messages per feature
3. **If Issues Arise:** Revert to tag, fix, re-implement
4. **After Phase 1 Complete:** Update tag to `phase1-complete`

---

## Success Criteria

### Functional Acceptance

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| F1 | App launches and displays WC 2026 album on first run | Manual test on Android emulator |
| F2 | User can browse album sections (Teams, Stars, Cover) | Navigate through all sections |
| F3 | Tap on missing sticker → status changes to owned | Tap sticker, verify DB update |
| F4 | Long-press on owned sticker → status changes to missing | Long-press, verify count decrements |
| F5 | Multiple taps increment owned count | Tap 3x, verify count=3 |
| F6 | Stats dashboard shows accurate completion % | Compare with manual count |
| F7 | Stats dashboard shows correct missing count | Compare with manual count |
| F8 | PDF export generates valid A4 document | Open PDF on device, verify layout |
| F9 | PDF filtered export (missing only) works | Export missing, verify 0 owned stickers in list |
| F10 | Share button opens native share sheet | Tap share, verify system picker appears |
| F11 | App functions fully offline (no network required) | Enable airplane mode, test all features |
| F12 | Sticker grid scrolls at 60fps with 670 stickers | Visual inspection, no jank |

### Non-Functional Acceptance

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| N1 | Debug APK builds successfully | `flutter build apk --debug` completes |
| N2 | APK installs on Android device/emulator | `adb install` succeeds |
| N3 | App cold start < 3 seconds | Stopwatch measurement |
| N4 | Database operations < 50ms for single sticker | Performance profiling |
| N5 | Memory usage < 150MB with 670 stickers loaded | Android Studio profiler |
| N6 | No crashes on rapid tap/long-press sequences | Stress test: 100 rapid interactions |

### Architecture Quality

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| A1 | Clean Architecture folder structure established | Directory structure matches proposal |
| A2 | All business logic in domain layer | Repository interfaces and entities in domain |
| A3 | Drift database with proper lazy initialization | Database opens on first query, not on app start |
| A4 | Cubit state management with immutable states | All state classes use `copyWith` pattern |
| A5 | Widgets use const constructors where possible | Dart analyzer warnings for mutable widgets |

---

## Data Reference: Panini WC 2026 Album Structure

**Source:** https://www.checklistinsider.com/2026-panini-fifa-world-cup-sticker

Based on typical Panini World Cup album patterns:

### Album Statistics

- **Total Stickers:** ~670
- **Teams:** 48 national teams (expanded from 32)
- **Sections:** Cover, Official, Teams (8 groups), Stars/Legends, World Cup Stories

### Section Breakdown (Sample)

| Section | Stickers | Description |
|---------|----------|-------------|
| Cover & Official | ~10 | Ball, Logo, Host nations |
| Stars | ~25 | Top player stickers (holographic) |
| Group A-H | 8 × 20 = 160 | 5 per team (Logo, Home, Away, Star, Jumbo) |
| Regional Teams | ~160 | Remaining 32 teams |
| Officials | ~30 | Referees, coaches |
| World Cup Stories | ~50 | Venue stickers, memorable moments |
| Holographic Extras | ~50 | Special parallel inserts |

### Sample Sticker Numbers

```
Cover: C1-C5
Stars: S1-S25
Group A: A1-A20 (Argentina, Mexico, etc.)
Group B: B1-B20 (Brazil, Italy, etc.)
...
Group H: H1-H20
Legends: L1-L15
Official: OF1-OF10
```

### Seeding Strategy for Phase 1

For MVP, generate realistic sample data:
- 1 Album (Panini WC 2026)
- 10 Sections (simplified structure)
- ~100 stickers (subset for faster dev testing)
- Full 670 sticker count referenced in album.total_stickers

**Note:** The full sticker list should be extracted from the actual URL and parsed into the JSON structure above. This proposal uses representative samples.

---

*Proposal authored 2026-05-22 for Sticker Collector App Phase 1 MVP*
*Status: Ready for supervisor review*