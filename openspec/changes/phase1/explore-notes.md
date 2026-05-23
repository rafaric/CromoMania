# SDD Explore — Phase 1 Exploration Notes

## 1. Architecture Approach

**Recommendation: Hybrid Feature-First + Layer-First Clean Architecture**

For a solo developer building an MVP with Flutter BLoC/Cubit:

```
lib/
├── core/                    # Shared utilities, themes, constants
│   ├── theme/
│   ├── utils/
│   └── constants/
├── features/                # Feature-first organization
│   ├── album/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── cubit/
│   │       ├── pages/
│   │       └── widgets/
│   ├── collection/
│   └── stats/
└── main.dart
```

**Rationale:**
- Feature-first allows easy navigation for solo dev
- Layer separation within each feature keeps concerns distinct
- BLoC/Cubit lives in presentation layer (per Flutter_bloc conventions)
- Shared code in `core/` prevents duplication

**Trade-off vs Layer-First:**
- Layer-first (data/domain/presentation at root) is better for large teams
- Feature-first chosen because Phase 1 has limited features (album, collection, stats, pdf_export)
- Easy to refactor later if team grows

---

## 2. Database Schema Approach (Drift)

### Entity Relationship

```
┌──────────┐     ┌────────────┐     ┌─────────────┐
│  Album   │────<│   Section  │────<│   Sticker   │
└──────────┘     └────────────┘     └─────────────┘
                                           │
                                           │ (1:1 per user)
                                           ▼
                                    ┌─────────────┐
                                    │  Collection │
                                    │   Status    │
                                    └─────────────┘
```

### Tables Design

**albums** (template definitions)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | Auto-increment |
| name | TEXT | "Panini WC 2026" |
| description | TEXT | Optional |
| total_stickers | INTEGER | 800 |
| created_at | DATETIME | |

**sections** (groups within album)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| album_id | INTEGER FK | References albums |
| name | TEXT | "Group A", "Stars" |
| order_index | INTEGER | Display order |

**stickers** (template stickers)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| section_id | INTEGER FK | |
| number | TEXT | "1", "23", "MS-7" |
| name | TEXT | Player/team name |
| is_special | BOOLEAN | For holographic/glitter |

**collection_status** (user's collection state)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| sticker_id | INTEGER FK | Composite unique with user_id |
| status | INTEGER | 0=missing, 1=owned, 2=repeated |
| count | INTEGER | For repeated (default 1) |
| user_id | TEXT | Hardcoded "default_user" for Phase 1 |

### Drift Implementation Pattern

```dart
// Lazy database opening - important for offline-first
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    dbFolders = await getApplicationDocumentsDirectory();
    final file = File(join(dbFolders.path, 'sticker_collector.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// Use @DriftIgnore annotation for Flutter-specific code
// Keep database classes pure Dart for testability
```

### Migration Strategy
- Start with simple schema (no migrations needed initially)
- Use `migration` callback in `MigrationStrategy` for future changes
- Keep schema minimal for Phase 1

---

## 3. Performance for 800+ Sticker Grids

### Critical Techniques

**1. GridView.builder (NOT GridView)**
```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,
    childAspectRatio: 1,
  ),
  itemCount: stickers.length,
  itemBuilder: (context, index) => StickerItem(stickers[index]),
)
```

**2. RepaintBoundary per item**
```dart
RepaintBoundary(
  child: StickerCard(
    key: ValueKey(sticker.id),
    sticker: sticker,
    status: collectionStatus[index],
  ),
)
```

**3. Const constructors everywhere**
```dart
class StickerCard extends StatelessWidget {
  const StickerCard({super.key, required this.sticker, ...}); // const!
}
```

**4. State management isolation**
- Each sticker tile should NOT trigger full grid rebuild
- Use `Cubit` with immutable state copy-on-write
- Collection changes update only affected items via `List.copyWith`

**5. Lazy loading with pagination**
- Load stickers in pages of ~100
- Use `ListView.builder` with pagination for sections
- Pre-calculate stats to avoid runtime computation

**6. Avoid heavy animations**
- Disable implicit animations for grid items
- Use `AnimatedContainer` only for status indicator changes

### Memory Optimization
- Sticker images: Store locally, load on-demand (not in DB)
- Thumbnail cache with `CachedNetworkImage` pattern for local files
- Limit in-memory collection to current album's stickers

---

## 4. PDF Export with Emoji/Flag Integration

### Using the `pdf` package

```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generateCollectionPDF(List<Sticker> stickers) async {
  final pdf = pw.Document();
  
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Header(level: 0, child: pw.Text('My Collection')),
        pw.Table.fromTextArray(
          headers: ['#', 'Name', 'Status'],
          data: stickers.map((s) => [
            s.number,
            s.name,
            _statusEmoji(s.status), // ✓, 🔄, ○
          ]).toList(),
        ),
      ],
    ),
  );
  
  return pdf.save();
}
```

### Emoji/Flag Rendering Notes

**Challenges:**
- Not all PDF viewers render emoji correctly
- Some Android PDF readers strip emoji
- Cross-platform compatibility varies

**Recommendations:**
- Primary approach: Use Unicode checkmarks/boxes for status indicators
  - ✓ (U+2713) for owned
  - 🔄 (U+1F504) for repeated  
  - ○ (U+25CB) for missing
- Fallback: Use colored squares (green/yellow/gray) if emoji fails
- Test PDF on target Android device before shipping

**For Flag Emojis (country stickers):**
- Most modern Android PDF viewers handle flag emoji (country code → flag)
- Works on Android 7.0+ for most apps
- Alternative: Store flag as text "🇦🇷" and trust system rendering

### Share Implementation
```dart
final pdfBytes = await generateCollectionPDF(stickers);
await Share.shareXFiles(
  [XFile.fromData(pdfBytes, mimeType: 'application/pdf', name: 'my_collection.pdf')],
);
```

---

## 5. Key Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State Management | Cubit (not BLoC) | Less boilerplate, easier for solo dev, sufficient for this app complexity |
| Database | Drift with LazyDatabase | Type-safe SQL, reactive streams, offline-first by design |
| Folder Structure | Feature-first | Easier navigation for solo dev, scales with app growth |
| PDF Generation | pure Dart `pdf` package | No native dependencies, works offline, share_plus compatible |
| Image Strategy | Local placeholder + future asset loading | Phase 1 MVP: numbers only. Images deferred to Phase 2 |
| User Identity | Single hardcoded user ("default_user") | Phase 1 is single-device, multi-user deferred to cloud sync phase |

---

## 6. Risks and Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Drift code generation complexity | Medium | Medium | Start with simple 3-table schema, no relationships until comfortable |
| Large grid performance issues | Medium | Low | Build with GridView.builder from day 1, benchmark early |
| PDF emoji rendering inconsistency | Medium | Low | Provide text fallback, test on physical device |
| Solo dev bandwidth | High | High | Strict MVP scope, defer non-essentials |
| Flutter SDK installation issues | Low | Medium | Use official installer, not git clone on Windows |

---

## 7. Questions for Proposal Phase

1. **Album Templates:** Will users create their own albums or only use pre-defined templates? If templates, what's the import format (JSON, CSV)?

2. **Sticker Images:** Phase 1 uses number-only display. When do images get added? Do we need placeholder icon support for MVP?

3. **Collection State Machine:** Tap cycles through missing→owned→repeated→missing? Or distinct interactions (tap vs long-press)? Confirm interaction design.

4. **Stats Dashboard:** What specific stats are most valuable? (e.g., completion %, missing count, duplicates value) Prioritize for MVP.

5. **PDF Export Scope:** Full collection list or filtered (missing stickers only, section-specific)? Define minimum viable export.

---

## 8. Exploration Summary

**Status:** Complete ✅

**Key Findings:**
- Feature-first architecture works well for solo MVP development
- Drift's lazy database opening is essential for offline-first performance
- GridView.builder with RepaintBoundary is the right pattern for 800+ stickers
- PDF export via pure Dart works well, but emoji fallback is needed
- Cubit provides adequate state management without BLoC complexity

**Next Phase:** SDD Proposal — Document proposed solutions for each feature with specific implementations

---

*Exploration completed 2026-05-22 for Sticker Collector App Phase 1*