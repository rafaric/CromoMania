# SDD Design — Sticker Collector App Phase 1

**Document Version:** 1.0  
**Date:** 2026-05-22  
**Status:** Ready for Implementation  
**Change ID:** phase1

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Folder Structure](#2-folder-structure)
3. [Database Design](#3-database-design)
4. [Repository Pattern](#4-repository-pattern)
5. [State Management](#5-state-management)
6. [Widget Architecture](#6-widget-architecture)
7. [Data Seeding](#7-data-seeding)
8. [PDF Generation Flow](#8-pdf-generation-flow)
9. [Design Decisions](#9-design-decisions)

---

## 1. Architecture Overview

### 1.1 Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Pages     │  │   Widgets   │  │   Cubits    │             │
│  │  (screens)  │  │ (reusable)  │  │  (state)   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
├─────────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  Entities   │  │ Repositories│  │  Use Cases  │             │
│  │ (business)  │  │ (interfaces)│  │ (optional)  │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
├─────────────────────────────────────────────────────────────────┤
│                       DATA LAYER                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Models   │  │DataSources  │  │ Repository  │             │
│  │  (DTOs)    │  │  (local)    │  │  (impls)    │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
├─────────────────────────────────────────────────────────────────┤
│                    INFRASTRUCTURE LAYER                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  Database   │  │   Drift     │  │   PDF Gen   │             │
│  │   (Drift)   │  │   (SQLite)  │  │  (pure Dart)│             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Data Flow Diagram

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           USER INTERACTION                               │
│  Tap Sticker → Long-Press Sticker → Export PDF → View Stats            │
└───────────────────────────────┬──────────────────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         WIDGET LAYER                                     │
│  StickerTile → StatsDashboard → PdfExportPage                          │
│       │                │                  │                             │
│       ▼                ▼                  ▼                             │
│  ┌──────────┐    ┌───────────┐      ┌───────────┐                        │
│  │ OnTap()  │    │ StatsCubit│      │PdfExport  │                        │
│  │OnLongPress│    │   reads   │      │  Cubit    │                        │
│  └────┬─────┘    └─────┬─────┘      └─────┬─────┘                        │
└───────┼────────────────┼─────────────────┼───────────────────────────────┘
        │                │                 │
        ▼                ▼                 ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         CUBIT LAYER                                     │
│  ┌──────────────────────┐  ┌──────────────────────┐                   │
│  │   CollectionCubit    │  │      StatsCubit       │                   │
│  │  ┌────────────────┐  │  │  ┌────────────────┐  │                   │
│  │  │ CollectionState│  │  │  │   StatsState   │  │                   │
│  │  │ - statuses[]   │  │  │  │ - completion%  │  │                   │
│  │  │ - isLoading    │  │  │  │ - owned/missing│  │                   │
│  │  └────────────────┘  │  │  └────────────────┘  │                   │
│  └──────────┬───────────┘  └──────────┬───────────┘                   │
│             │                         │                                │
│             ▼                         ▼                                │
│  ┌──────────────────────────────────────────────────────────────┐     │
│  │                    Repository Layer                           │     │
│  │  ┌───────────────────────┐  ┌───────────────────────────┐   │     │
│  │  │ CollectionRepository  │  │      AlbumRepository       │   │     │
│  │  │  (interface)          │  │      (interface)           │   │     │
│  │  └───────────┬───────────┘  └───────────────┬───────────┘   │     │
│  └──────────────┼──────────────────────────────┼──────────────┘     │
└─────────────────┼──────────────────────────────┼────────────────────────┘
                  │                              │
                  ▼                              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                      DATA SOURCE LAYER                                   │
│  ┌────────────────────────────────┐  ┌──────────────────────────────┐   │
│  │   CollectionLocalDataSource    │  │    AlbumLocalDataSource      │   │
│  │   (Drift DAO operations)       │  │    (Drift DAO + Seeding)      │   │
│  └────────────┬───────────────────┘  └───────────────┬──────────────┘   │
└───────────────┼────────────────────────────────────┼──────────────────┘
                │                                      │
                ▼                                      ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                      DRIFT DATABASE                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐       │
│  │  albums  │  │ sections │  │ stickers │  │collection_status │       │
│  │   table  │  │  table   │  │  table   │  │      table       │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘       │
│                                                                    │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                  LazyDatabase Connection                     │ │
│  │         (opens on first query, not on app start)            │ │
│  └──────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
```

### 1.3 ASCII Architecture Diagram

```
                    ┌─────────────────────────────────────────────────────┐
                    │                    FEATURES                          │
                    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
                    │  │   Album     │ │ Collection  │ │   Stats     │      │
                    │  │  Feature    │ │  Feature    │ │  Feature    │      │
                    │  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘      │
                    └─────────┼───────────────┼───────────────┼─────────────┘
                              │               │               │
                    ┌─────────┴───────────────┴───────────────┴─────────────┐
                    │                    CORE                              │
                    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
                    │  │   Theme    │ │ Constants  │ │   Utils     │      │
                    │  └─────────────┘ └─────────────┘ └─────────────┘      │
                    └──────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                           APP LAYER                                      │
│                                                                                │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                         main.dart                                │    │
│  │  ┌─────────────────────────────────────────────────────────────┐ │    │
│  │  │  StickerCollectorApp()  ← BlocProvider/RepositoryProvider   │ │    │
│  │  │       │                                                      │ │    │
│  │  │       ▼                                                      │ │    │
│  │  │  AppRouter()                                                 │ │    │
│  │  │       │                                                      │ │    │
│  │  │       ├── / → AlbumListPage                                  │ │    │
│  │  │       ├── /album/:id → AlbumDetailPage                      │ │    │
│  │  │       ├── /album/:id/section/:sid → SectionStickersPage     │ │    │
│  │  │       ├── /stats → StatsDashboardPage                        │ │    │
│  │  │       └── /export → PdfExportPage                            │ │    │
│  │  └─────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Folder Structure

```
lib/
├── main.dart                                    # App entry, DB init, providers
│
├── core/                                        # Shared utilities across app
│   ├── constants/
│   │   └── app_constants.dart                   # App strings, hardcoded user ID
│   ├── theme/
│   │   └── app_theme.dart                       # Colors, text styles, dimensions
│   └── utils/
│       ├── date_utils.dart                      # Date formatting helpers
│       └── status_utils.dart                    # Status enum utilities
│
├── database/                                    # Drift database layer
│   ├── app_database.dart                        # Main database class
│   ├── app_database.g.dart                      # Generated (do not edit)
│   ├── tables/
│   │   ├── albums_table.dart                   # Album template table
│   │   ├── sections_table.dart                 # Section grouping table
│   │   ├── stickers_table.dart                  # Sticker template table
│   │   └── collection_status_table.dart         # User collection state table
│   └── daos/
│       ├── album_dao.dart                       # Album/Section/Sticker operations
│       └── collection_dao.dart                  # Collection status CRUD
│
└── features/                                    # Feature-first organization
    ├── album/                                   # Album browsing feature
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── local/
    │   │   │       ├── album_local_datasource.dart
    │   │   │       └── seed_data.dart           # WC 2026 template JSON
    │   │   ├── models/
    │   │   │   ├── album_model.dart
    │   │   │   ├── section_model.dart
    │   │   │   └── sticker_model.dart
    │   │   └── repositories/
    │   │       └── album_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── album.dart
    │   │   │   ├── section.dart
    │   │   │   └── sticker.dart
    │   │   └── repositories/
    │   │       └── album_repository.dart        # Abstract interface
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── album_cubit.dart
    │       │   ├── album_state.dart
    │       │   └── section_stickers_cubit.dart
    │       ├── pages/
    │       │   ├── album_list_page.dart
    │       │   ├── album_detail_page.dart
    │       │   └── section_stickers_page.dart
    │       └── widgets/
    │           ├── album_card.dart
    │           └── section_tile.dart
    │
    ├── collection/                              # Collection state feature
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── local/
    │   │   │       └── collection_local_datasource.dart
    │   │   ├── models/
    │   │   │   └── collection_status_model.dart
    │   │   └── repositories/
    │   │       └── collection_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── collection_status.dart
    │   │   └── repositories/
    │   │       └── collection_repository.dart    # Abstract interface
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── collection_cubit.dart
    │       │   └── collection_state.dart
    │       └── widgets/
    │           └── sticker_tile.dart             # Core sticker interactive tile
    │
    ├── stats/                                   # Stats dashboard feature
    │   ├── domain/
    │   │   └── stats_calculator.dart             # Stats computation logic
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── stats_cubit.dart
    │       │   └── stats_state.dart
    │       ├── pages/
    │       │   └── stats_dashboard_page.dart
    │       └── widgets/
    │           ├── progress_ring.dart
    │           └── stat_card.dart
    │
    └── pdf_export/                              # PDF export feature
        ├── data/
        │   └── pdf_generator.dart                # PDF document generation
        ├── domain/
        │   └── pdf_export_service.dart           # Business logic for export
        └── presentation/
            ├── cubit/
            │   ├── pdf_export_cubit.dart
            │   └── pdf_export_state.dart
            └── pages/
                └── pdf_export_page.dart

assets/
└── (placeholder for future sticker images)

android/
└── app/
    └── build.gradle                              # Android build config

test/
└── (unit and widget tests)

openspec/
└── changes/phase1/
    ├── specs/                                   # Already completed specs
    ├── proposal.md                              # Already approved proposal
    └── design.md                                # This document
```

---

## 3. Database Design

### 3.1 Drift Database Schema

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              ER DIAGRAM                                  │
│                                                                         │
│  ┌──────────┐     ┌────────────┐     ┌─────────────┐                    │
│  │  Album   │────<│  Section   │────<│   Sticker  │                    │
│  └──────────┘     └────────────┘     └─────────────┘                    │
│       │                                     │                            │
│       │                                     │                            │
│       │        ┌────────────────────┐      │                            │
│       │        │ CollectionStatus   │<─────┘                            │
│       │        │  (per user/sticker) │                                   │
│       │        └────────────────────┘                                   │
│       │                 │                                               │
│       └─────────────────┼───────────────────────────────────────────────│
│                         │                                               │
│                    ┌────┴────┐                                         │
│                    │  User   │ (hardcoded "default_user" Phase 1)       │
│                    └─────────┘                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Table Definitions

#### 3.2.1 Albums Table

```dart
// database/tables/albums_table.dart
class Albums extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get publisher => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get totalStickers => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PK, AUTO_INCREMENT | Unique album identifier |
| name | TEXT | NOT NULL | "Panini FIFA World Cup 2026" |
| publisher | TEXT | NULLABLE | "Panini" |
| description | TEXT | NULLABLE | Album description |
| totalStickers | INTEGER | NOT NULL | Total sticker count (670) |
| createdAt | DATETIME | DEFAULT NOW | Creation timestamp |

**Indexes:** `idx_albums_name` on `name`

---

#### 3.2.2 Sections Table

```dart
// database/tables/sections_table.dart
class Sections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get albumId => integer().references(Albums, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  IntColumn get orderIndex => integer()();
}
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PK, AUTO_INCREMENT | Unique section identifier |
| albumId | INTEGER | FK → albums(id) | Parent album reference |
| name | TEXT | NOT NULL | "Group A", "Stars", etc. |
| orderIndex | INTEGER | NOT NULL | Display order (0, 1, 2...) |

**Indexes:** `idx_sections_album_order` on `(albumId, orderIndex)`

---

#### 3.2.3 Stickers Table

```dart
// database/tables/stickers_table.dart
class Stickers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sectionId => integer().references(Sections, #id)();
  TextColumn get stickerNumber => text().withLength(min: 1, max: 20)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  BoolColumn get isSpecial => boolean().withDefault(const Constant(false))();
}
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PK, AUTO_INCREMENT | Unique sticker identifier |
| sectionId | INTEGER | FK → sections(id) | Parent section reference |
| stickerNumber | TEXT | NOT NULL | "A1", "S5", "MS-7" |
| name | TEXT | NOT NULL | Player/team name |
| isSpecial | BOOLEAN | DEFAULT FALSE | Holographic/glitter flag |

**Indexes:** `idx_stickers_section` on `sectionId`

---

#### 3.2.4 Collection Status Table

```dart
// database/tables/collection_status_table.dart
class CollectionStatuses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get stickerId => integer().references(Stickers, #id)();
  TextColumn get userId => text().withDefault(const Constant('default_user'))();
  IntColumn get count => integer().withDefault(const Constant(0))();
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {stickerId, userId},  // Composite unique constraint
  ];
}
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PK, AUTO_INCREMENT | Unique status identifier |
| stickerId | INTEGER | FK → stickers(id), UNIQUE with userId | Sticker reference |
| userId | TEXT | DEFAULT 'default_user' | User identifier (Phase 1: hardcoded) |
| count | INTEGER | DEFAULT 0 | Owned count (0=missing, 1=owned, 2+=repeated) |

**Indexes:** `idx_collection_user_sticker` on `(userId, stickerId)`

### 3.3 Database Initialization

```dart
// database/app_database.dart
class AppDatabase {
  static AppDatabase? _instance;
  static AppDatabase get instance => _instance!;
  
  LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(join(dbFolder.path, 'sticker_collector.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
  
  // Constructor called once at app start
  AppDatabase() {
    _db = LazyDatabase(_openConnection);
  }
}
```

### 3.4 Database Migration Strategy

```dart
MigrationStrategy(
  onCreate: (Migrator m) async {
    await m.createAllTables();
  },
  onUpgrade: (Migrator m, int from, int to) async {
    // Future migrations go here
    // Example:
    // if (from < 2) {
    //   await m.addColumn('albums', 'updated_at');
    // }
  },
)
```

---

## 4. Repository Pattern

### 4.1 Repository Interfaces (Domain Layer)

```dart
// features/album/domain/repositories/album_repository.dart
abstract class AlbumRepository {
  /// Get all albums
  Future<List<Album>> getAlbums();
  
  /// Get album by ID with all sections
  Future<Album?> getAlbumById(int id);
  
  /// Get all sections for an album
  Future<List<Section>> getSectionsForAlbum(int albumId);
  
  /// Get all stickers for a section
  Future<List<Sticker>> getStickersForSection(int sectionId);
  
  /// Get all stickers for an album
  Future<List<Sticker>> getStickersForAlbum(int albumId);
  
  /// Check if albums table is empty (for seeding decision)
  Future<bool> isAlbumsTableEmpty();
}
```

```dart
// features/collection/domain/repositories/collection_repository.dart
abstract class CollectionRepository {
  /// Get all collection statuses for a user
  Future<List<CollectionStatus>> getStatusesForUser(String userId);
  
  /// Get collection status for a specific sticker
  Future<CollectionStatus?> getStatusForSticker(int stickerId, String userId);
  
  /// Save or update collection status
  Future<void> saveStatus(CollectionStatus status);
  
  /// Batch save collection statuses
  Future<void> saveStatuses(List<CollectionStatus> statuses);
  
  /// Get statuses map for quick lookup (stickerId → status)
  Future<Map<int, CollectionStatus>> getStatusMap(String userId);
  
  /// Initialize default status for all stickers (for new user)
  Future<void> initializeDefaultStatuses(String userId, List<int> stickerIds);
}
```

### 4.2 Repository Implementations (Data Layer)

```dart
// features/album/data/repositories/album_repository_impl.dart
class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumDao _albumDao;
  
  AlbumRepositoryImpl(this._albumDao);
  
  @override
  Future<List<Album>> getAlbums() async {
    final rows = await _albumDao.selectAllAlbums();
    return rows.map(_mapRowToAlbum).toList();
  }
  
  // ... other implementations using DAO
}
```

```dart
// features/collection/data/repositories/collection_repository_impl.dart
class CollectionRepositoryImpl implements CollectionRepository {
  final CollectionDao _collectionDao;
  
  CollectionRepositoryImpl(this._collectionDao);
  
  @override
  Future<Map<int, CollectionStatus>> getStatusMap(String userId) async {
    final rows = await _collectionDao.selectStatusesForUser(userId);
    return {for (var r in rows) r.stickerId: _mapRowToStatus(r)};
  }
  
  // ... other implementations using DAO
}
```

---

## 5. State Management

### 5.1 Collection Cubit (Core State Machine)

```dart
// features/collection/presentation/cubit/collection_state.dart
enum CollectionStatus { initial, loading, loaded, error }

class CollectionState {
  final CollectionStatus status;
  final Map<int, CollectionStatusModel> statusMap;  // stickerId → status
  final int totalStickers;
  final String? errorMessage;
  
  const CollectionState({
    this.status = CollectionStatus.initial,
    this.statusMap = const {},
    this.totalStickers = 0,
    this.errorMessage,
  });
  
  // Immutable copyWith pattern
  CollectionState copyWith({
    CollectionStatus? status,
    Map<int, CollectionStatusModel>? statusMap,
    int? totalStickers,
    String? errorMessage,
  }) {
    return CollectionState(
      status: status ?? this.status,
      statusMap: statusMap ?? this.statusMap,
      totalStickers: totalStickers ?? this.totalStickers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  // Computed properties
  int get ownedCount => statusMap.values.where((s) => s.count > 0).length;
  int get missingCount => totalStickers - ownedCount;
  int get repeatedCount => statusMap.values
      .where((s) => s.count > 1)
      .fold(0, (sum, s) => sum + (s.count - 1));
  double get completionPercent => 
      totalStickers > 0 ? (ownedCount / totalStickers * 100) : 0;
}
```

```dart
// features/collection/presentation/cubit/collection_cubit.dart
class CollectionCubit extends Cubit<CollectionState> {
  final CollectionRepository _repository;
  final String userId = 'default_user';  // Phase 1 hardcoded
  
  CollectionCubit(this._repository) : super(const CollectionState());
  
  /// Load all collection statuses from database
  Future<void> loadCollection() async {
    emit(state.copyWith(status: CollectionStatus.loading));
    
    try {
      final statusMap = await _repository.getStatusMap(userId);
      final totalStickers = statusMap.length;
      
      emit(state.copyWith(
        status: CollectionStatus.loaded,
        statusMap: statusMap,
        totalStickers: totalStickers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CollectionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  
  /// Increment sticker count (tap action)
  void incrementSticker(int stickerId) {
    _updateStickerCount(stickerId, delta: 1);
  }
  
  /// Decrement sticker count (long-press action)
  void decrementSticker(int stickerId) {
    _updateStickerCount(stickerId, delta: -1);
  }
  
  void _updateStickerCount(int stickerId, {required int delta}) {
    final currentStatus = state.statusMap[stickerId];
    final currentCount = currentStatus?.count ?? 0;
    final newCount = (currentCount + delta).clamp(0, 999);
    
    final newStatus = CollectionStatusModel(
      stickerId: stickerId,
      userId: userId,
      count: newCount,
    );
    
    // Immutable map update
    final newMap = Map<int, CollectionStatusModel>.from(state.statusMap);
    newMap[stickerId] = newStatus;
    
    emit(state.copyWith(statusMap: newMap));
    
    // Persist asynchronously (fire-and-forget for responsiveness)
    _repository.saveStatus(newStatus);
  }
}
```

### 5.2 Album Cubit

```dart
// features/album/presentation/cubit/album_state.dart
enum AlbumStatus { initial, loading, loaded, error }

class AlbumState {
  final AlbumStatus status;
  final List<AlbumModel> albums;
  final AlbumModel? selectedAlbum;
  final List<SectionModel> sections;
  final List<StickerModel> currentSectionStickers;
  final String? errorMessage;
  
  const AlbumState({
    this.status = AlbumStatus.initial,
    this.albums = const [],
    this.selectedAlbum,
    this.sections = const [],
    this.currentSectionStickers = const [],
    this.errorMessage,
  });
  
  AlbumState copyWith({
    AlbumStatus? status,
    List<AlbumModel>? albums,
    AlbumModel? selectedAlbum,
    List<SectionModel>? sections,
    List<StickerModel>? currentSectionStickers,
    String? errorMessage,
  }) {
    return AlbumState(
      status: status ?? this.status,
      albums: albums ?? this.albums,
      selectedAlbum: selectedAlbum ?? this.selectedAlbum,
      sections: sections ?? this.sections,
      currentSectionStickers: currentSectionStickers ?? this.currentSectionStickers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
```

```dart
// features/album/presentation/cubit/album_cubit.dart
class AlbumCubit extends Cubit<AlbumState> {
  final AlbumRepository _repository;
  
  AlbumCubit(this._repository) : super(const AlbumState());
  
  Future<void> loadAlbums() async {
    emit(state.copyWith(status: AlbumStatus.loading));
    
    try {
      // Check if seeding needed
      if (await _repository.isAlbumsTableEmpty()) {
        await _seedData();  // Seed WC 2026 data
      }
      
      final albums = await _repository.getAlbums();
      emit(state.copyWith(
        status: AlbumStatus.loaded,
        albums: albums,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AlbumStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  
  Future<void> loadSectionsForAlbum(int albumId) async {
    final sections = await _repository.getSectionsForAlbum(albumId);
    emit(state.copyWith(sections: sections));
  }
  
  Future<void> loadStickersForSection(int sectionId) async {
    final stickers = await _repository.getStickersForSection(sectionId);
    emit(state.copyWith(currentSectionStickers: stickers));
  }
  
  Future<void> _seedData() async {
    // Implemented in AlbumLocalDataSource
  }
}
```

### 5.3 Stats Cubit

```dart
// features/stats/presentation/cubit/stats_state.dart
class StatsState {
  final double completionPercent;
  final int ownedCount;
  final int missingCount;
  final int repeatedCount;
  final int totalStickers;
  final Map<String, SectionStats> sectionStats;
  final bool isLoading;
  
  const StatsState({
    this.completionPercent = 0,
    this.ownedCount = 0,
    this.missingCount = 0,
    this.repeatedCount = 0,
    this.totalStickers = 0,
    this.sectionStats = const {},
    this.isLoading = false,
  });
  
  StatsState copyWith({
    double? completionPercent,
    int? ownedCount,
    int? missingCount,
    int? repeatedCount,
    int? totalStickers,
    Map<String, SectionStats>? sectionStats,
    bool? isLoading,
  }) {
    return StatsState(
      completionPercent: completionPercent ?? this.completionPercent,
      ownedCount: ownedCount ?? this.ownedCount,
      missingCount: missingCount ?? this.missingCount,
      repeatedCount: repeatedCount ?? this.repeatedCount,
      totalStickers: totalStickers ?? this.totalStickers,
      sectionStats: sectionStats ?? this.sectionStats,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SectionStats {
  final String sectionId;
  final String sectionName;
  final int total;
  final int owned;
  final double percent;
  
  const SectionStats({
    required this.sectionId,
    required this.sectionName,
    required this.total,
    required this.owned,
    required this.percent,
  });
}
```

```dart
// features/stats/presentation/cubit/stats_cubit.dart
class StatsCubit extends Cubit<StatsState> {
  final StatsCalculator _calculator;
  
  StatsCubit(this._calculator) : super(const StatsState());
  
  /// Recalculate stats from collection state
  void recalculateStats(CollectionState collectionState) {
    final stats = _calculator.calculateStats(collectionState);
    emit(stats);
  }
}
```

### 5.4 PDF Export Cubit

```dart
// features/pdf_export/presentation/cubit/pdf_export_state.dart
enum PdfExportStatus { initial, generating, ready, sharing, error }

class PdfExportState {
  final PdfExportStatus status;
  final Uint8List? pdfBytes;
  final ExportFilter filter;
  final String? errorMessage;
  
  const PdfExportState({
    this.status = PdfExportStatus.initial,
    this.pdfBytes,
    this.filter = ExportFilter.full,
    this.errorMessage,
  });
  
  PdfExportState copyWith({
    PdfExportStatus? status,
    Uint8List? pdfBytes,
    ExportFilter? filter,
    String? errorMessage,
  }) {
    return PdfExportState(
      status: status ?? this.status,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum ExportFilter {
  full,
  missingOnly,
  section,  // Requires sectionId in export call
}
```

```dart
// features/pdf_export/presentation/cubit/pdf_export_cubit.dart
class PdfExportCubit extends Cubit<PdfExportState> {
  final PdfExportService _service;
  
  PdfExportCubit(this._service) : super(const PdfExportState());
  
  Future<void> generatePdf({
    required List<StickerModel> stickers,
    required Map<int, CollectionStatusModel> statusMap,
    ExportFilter filter = ExportFilter.full,
    int? sectionId,
  }) async {
    emit(state.copyWith(
      status: PdfExportStatus.generating,
      filter: filter,
    ));
    
    try {
      final pdfBytes = await _service.generateCollectionPdf(
        stickers: stickers,
        statusMap: statusMap,
        filter: filter,
        sectionId: sectionId,
      );
      
      emit(state.copyWith(
        status: PdfExportStatus.ready,
        pdfBytes: pdfBytes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PdfExportStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  
  Future<void> sharePdf() async {
    if (state.pdfBytes == null) return;
    
    emit(state.copyWith(status: PdfExportStatus.sharing));
    
    try {
      await _service.sharePdf(
        state.pdfBytes!,
        filterName: state.filter.name,
      );
      
      emit(state.copyWith(status: PdfExportStatus.ready));
    } catch (e) {
      emit(state.copyWith(
        status: PdfExportStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
```

---

## 6. Widget Architecture

### 6.1 Key Widgets and Composition

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         WIDGET COMPOSITION TREE                        │
└─────────────────────────────────────────────────────────────────────────┘

App
 └── MaterialApp
      └── BlocProvider<CollectionCubit>
           └── BlocProvider<AlbumCubit>
                └── BlocProvider<StatsCubit>
                     └── BlocProvider<PdfExportCubit>
                          └── AppRouter
                               │
                               ├── /albums → AlbumListPage
                               │    └── AlbumListView
                               │         └── ListView.builder
                               │              └── AlbumCard (per album)
                               │
                               ├── /albums/:id → AlbumDetailPage
                               │    └── SectionListView
                               │         └── ListView.builder
                               │              └── SectionTile (per section)
                               │
                               ├── /albums/:id/section/:sid → SectionStickersPage
                               │    └── StickerGridView
                               │         └── GridView.builder
                               │              └── RepaintBoundary (per sticker)
                               │                   └── StickerTile
                               │                        ├── StickerNumber
                               │                        ├── StickerName
                               │                        └── StatusIndicator
                               │
                               ├── /stats → StatsDashboardPage
                               │    └── StatsDashboard
                               │         ├── ProgressRing
                               │         ├── StatCard (owned)
                               │         ├── StatCard (missing)
                               │         ├── StatCard (repeated)
                               │         └── SectionStatsList
                               │
                               └── /export → PdfExportPage
                                    └── ExportOptionsView
                                         ├── ExportButton (full)
                                         ├── ExportButton (missing only)
                                         └── ExportButton (current section)
```

### 6.2 StickerTile Widget (Core Interactive Component)

```dart
// features/collection/presentation/widgets/sticker_tile.dart
class StickerTile extends StatelessWidget {
  final StickerModel sticker;
  final CollectionStatusModel status;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  
  const StickerTile({
    super.key,
    required this.sticker,
    required this.status,
    required this.onTap,
    required this.onLongPress,
  });
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(  // Critical for performance
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(  // Subtle animation on state change
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor, width: 2),
          ),
          child: Stack(
            children: [
              // Sticker number (always visible)
              Center(
                child: Text(
                  sticker.stickerNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Status indicator (top-right)
              if (status.count > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: _buildStatusIcon(),
                ),
              
              // Count badge (bottom-right)
              if (status.count > 1)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: _buildCountBadge(),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color get _backgroundColor {
    if (status.count == 0) return Colors.grey.shade200;    // Missing
    if (status.count == 1) return Colors.green.shade100;    // Owned
    return Colors.amber.shade100;                            // Repeated
  }
  
  Color get _borderColor {
    if (status.count == 0) return Colors.grey;             // Missing
    if (status.count == 1) return Colors.green;            // Owned
    return Colors.amber;                                    // Repeated
  }
  
  Widget _buildStatusIcon() {
    if (status.count == 1) {
      return const Icon(Icons.check, color: Colors.green, size: 16);
    }
    return const Icon(Icons.copy, color: Colors.amber, size: 16);
  }
  
  Widget _buildCountBadge() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${status.count}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

### 6.3 Stats Dashboard Widgets

```dart
// features/stats/presentation/widgets/progress_ring.dart
class ProgressRing extends StatelessWidget {
  final double percent;
  final double size;
  
  const ProgressRing({
    super.key,
    required this.percent,
    this.size = 150,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CircularProgressIndicator(
            value: 1,
            strokeWidth: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(Colors.grey.shade200),
          ),
          // Progress ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent / 100),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 12,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(
                  _ringColor(percent),
                ),
              );
            },
          ),
          // Percentage text
          Text(
            '${percent.round()}%',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _ringColor(double percent) {
    if (percent >= 90) return Colors.green;
    if (percent >= 50) return Colors.blue;
    return Colors.orange;
  }
}
```

```dart
// features/stats/presentation/widgets/stat_card.dart
class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 7. Data Seeding

### 7.1 Seed Data Structure

```dart
// features/album/data/datasources/local/seed_data.dart
class SeedData {
  static const album = {
    'id': 'panini_wc2026',
    'name': 'Panini FIFA World Cup 2026',
    'publisher': 'Panini',
    'description': 'Official FIFA World Cup USA-Canada-Mexico 2026 Sticker Album',
    'totalStickers': 670,
  };
  
  static const sections = [
    {'name': 'Cover & Official', 'orderIndex': 0},
    {'name': 'Stars', 'orderIndex': 1},
    {'name': 'Group A', 'orderIndex': 2},
    {'name': 'Group B', 'orderIndex': 3},
    {'name': 'Group C', 'orderIndex': 4},
    {'name': 'Group D', 'orderIndex': 5},
    {'name': 'Group E', 'orderIndex': 6},
    {'name': 'Group F', 'orderIndex': 7},
    {'name': 'Group G', 'orderIndex': 8},
    {'name': 'Group H', 'orderIndex': 9},
  ];
  
  static const stickers = {
    // Cover & Official (Section 0)
    0: [
      {'number': 'C1', 'name': 'Official Match Ball', 'isSpecial': false},
      {'number': 'C2', 'name': 'Official Logo', 'isSpecial': true},
      {'number': 'C3', 'name': 'USA 2026', 'isSpecial': false},
      {'number': 'C4', 'name': 'Canada 2026', 'isSpecial': false},
      {'number': 'C5', 'name': 'Mexico 2026', 'isSpecial': false},
    ],
    // Stars (Section 1)
    1: [
      {'number': 'S1', 'name': 'Messi', 'isSpecial': true},
      {'number': 'S2', 'name': 'Ronaldo', 'isSpecial': true},
      {'number': 'S3', 'name': 'Mbappé', 'isSpecial': true},
      {'number': 'S4', 'name': 'Haaland', 'isSpecial': false},
      {'number': 'S5', 'name': 'Bellingham', 'isSpecial': false},
      {'number': 'S6', 'name': 'Vinícius Jr', 'isSpecial': true},
      {'number': 'S7', 'name': 'Rodri', 'isSpecial': false},
      {'number': 'S8', 'name': 'Bellingham', 'isSpecial': false},
      {'number': 'S9', 'name': 'Sané', 'isSpecial': false},
      {'number': 'S10', 'name': 'Kane', 'isSpecial': true},
    ],
    // Group A (Section 2)
    2: [
      {'number': 'A1', 'name': 'Argentina', 'isSpecial': false},
      {'number': 'A2', 'name': 'Argentina Logo', 'isSpecial': false},
      {'number': 'A3', 'name': 'Argentina Home', 'isSpecial': false},
      {'number': 'A4', 'name': 'Argentina Away', 'isSpecial': false},
      {'number': 'A5', 'name': 'Argentina Star', 'isSpecial': true},
      {'number': 'A6', 'name': 'Mexico', 'isSpecial': false},
      {'number': 'A7', 'name': 'Mexico Logo', 'isSpecial': false},
      {'number': 'A8', 'name': 'Mexico Home', 'isSpecial': false},
      {'number': 'A9', 'name': 'Mexico Away', 'isSpecial': false},
      {'number': 'A10', 'name': 'Mexico Star', 'isSpecial': true},
    ],
    // Group B (Section 3)
    3: [
      {'number': 'B1', 'name': 'Brazil', 'isSpecial': false},
      {'number': 'B2', 'name': 'Brazil Logo', 'isSpecial': false},
      {'number': 'B3', 'name': 'Brazil Home', 'isSpecial': false},
      {'number': 'B4', 'name': 'Brazil Away', 'isSpecial': false},
      {'number': 'B5', 'name': 'Brazil Star', 'isSpecial': true},
      {'number': 'B6', 'name': 'Italy', 'isSpecial': false},
      {'number': 'B7', 'name': 'Italy Logo', 'isSpecial': false},
      {'number': 'B8', 'name': 'Italy Home', 'isSpecial': false},
      {'number': 'B9', 'name': 'Italy Away', 'isSpecial': false},
      {'number': 'B10', 'name': 'Italy Star', 'isSpecial': true},
    ],
    // Group C (Section 4)
    4: [
      {'number': 'C1', 'name': 'USA', 'isSpecial': false},
      {'number': 'C2', 'name': 'USA Logo', 'isSpecial': false},
      {'number': 'C3', 'name': 'USA Home', 'isSpecial': false},
      {'number': 'C4', 'name': 'USA Away', 'isSpecial': false},
      {'number': 'C5', 'name': 'USA Star', 'isSpecial': true},
      {'number': 'C6', 'name': 'Canada', 'isSpecial': false},
      {'number': 'C7', 'name': 'Canada Logo', 'isSpecial': false},
      {'number': 'C8', 'name': 'Canada Home', 'isSpecial': false},
      {'number': 'C9', 'name': 'Canada Away', 'isSpecial': false},
      {'number': 'C10', 'name': 'Canada Star', 'isSpecial': true},
    ],
    // Group D (Section 5)
    5: [
      {'number': 'D1', 'name': 'France', 'isSpecial': false},
      {'number': 'D2', 'name': 'France Logo', 'isSpecial': false},
      {'number': 'D3', 'name': 'France Home', 'isSpecial': false},
      {'number': 'D4', 'name': 'France Away', 'isSpecial': false},
      {'number': 'D5', 'name': 'France Star', 'isSpecial': true},
      {'number': 'D6', 'name': 'Germany', 'isSpecial': false},
      {'number': 'D7', 'name': 'Germany Logo', 'isSpecial': false},
      {'number': 'D8', 'name': 'Germany Home', 'isSpecial': false},
      {'number': 'D9', 'name': 'Germany Away', 'isSpecial': false},
      {'number': 'D10', 'name': 'Germany Star', 'isSpecial': true},
    ],
    // Group E (Section 6)
    6: [
      {'number': 'E1', 'name': 'Spain', 'isSpecial': false},
      {'number': 'E2', 'name': 'Spain Logo', 'isSpecial': false},
      {'number': 'E3', 'name': 'Spain Home', 'isSpecial': false},
      {'number': 'E4', 'name': 'Spain Away', 'isSpecial': false},
      {'number': 'E5', 'name': 'Spain Star', 'isSpecial': true},
      {'number': 'E6', 'name': 'England', 'isSpecial': false},
      {'number': 'E7', 'name': 'England Logo', 'isSpecial': false},
      {'number': 'E8', 'name': 'England Home', 'isSpecial': false},
      {'number': 'E9', 'name': 'England Away', 'isSpecial': false},
      {'number': 'E10', 'name': 'England Star', 'isSpecial': true},
    ],
    // Group F (Section 7)
    7: [
      {'number': 'F1', 'name': 'Portugal', 'isSpecial': false},
      {'number': 'F2', 'name': 'Portugal Logo', 'isSpecial': false},
      {'number': 'F3', 'name': 'Portugal Home', 'isSpecial': false},
      {'number': 'F4', 'name': 'Portugal Away', 'isSpecial': false},
      {'number': 'F5', 'name': 'Portugal Star', 'isSpecial': true},
      {'number': 'F6', 'name': 'Netherlands', 'isSpecial': false},
      {'number': 'F7', 'name': 'Netherlands Logo', 'isSpecial': false},
      {'number': 'F8', 'name': 'Netherlands Home', 'isSpecial': false},
      {'number': 'F9', 'name': 'Netherlands Away', 'isSpecial': false},
      {'number': 'F10', 'name': 'Netherlands Star', 'isSpecial': true},
    ],
    // Group G (Section 8)
    8: [
      {'number': 'G1', 'name': 'Belgium', 'isSpecial': false},
      {'number': 'G2', 'name': 'Belgium Logo', 'isSpecial': false},
      {'number': 'G3', 'name': 'Belgium Home', 'isSpecial': false},
      {'number': 'G4', 'name': 'Belgium Away', 'isSpecial': false},
      {'number': 'G5', 'name': 'Belgium Star', 'isSpecial': true},
      {'number': 'G6', 'name': 'Croatia', 'isSpecial': false},
      {'number': 'G7', 'name': 'Croatia Logo', 'isSpecial': false},
      {'number': 'G8', 'name': 'Croatia Home', 'isSpecial': false},
      {'number': 'G9', 'name': 'Croatia Away', 'isSpecial': false},
      {'number': 'G10', 'name': 'Croatia Star', 'isSpecial': true},
    ],
    // Group H (Section 9)
    9: [
      {'number': 'H1', 'name': 'Uruguay', 'isSpecial': false},
      {'number': 'H2', 'name': 'Uruguay Logo', 'isSpecial': false},
      {'number': 'H3', 'name': 'Uruguay Home', 'isSpecial': false},
      {'number': 'H4', 'name': 'Uruguay Away', 'isSpecial': false},
      {'number': 'H5', 'name': 'Uruguay Star', 'isSpecial': true},
      {'number': 'H6', 'name': 'Colombia', 'isSpecial': false},
      {'number': 'H7', 'name': 'Colombia Logo', 'isSpecial': false},
      {'number': 'H8', 'name': 'Colombia Home', 'isSpecial': false},
      {'number': 'H9', 'name': 'Colombia Away', 'isSpecial': false},
      {'number': 'H10', 'name': 'Colombia Star', 'isSpecial': true},
    ],
  };
}
```

### 7.2 Seeding Flow

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         DATA SEEDING FLOW                               │
│                                                                          │
│  App Start                                                              │
│      │                                                                  │
│      ▼                                                                  │
│  ┌────────────────────────────────────────┐                            │
│  │  AlbumLocalDataSource.isAlbumsEmpty()  │                            │
│  └─────────────────┬──────────────────────┘                            │
│                    │                                                     │
│          ┌────────┴────────┐                                             │
│          │                 │                                             │
│          ▼                 ▼                                             │
│    [Empty = YES]      [Not Empty = NO]                                  │
│          │                 │                                             │
│          ▼                 ▼                                             │
│  ┌───────────────┐    ┌───────────────┐                                 │
│  │ Run Seeding  │    │ Load Existing │                                 │
│  │ Transaction  │    │     Data     │                                 │
│  └───────┬───────┘    └───────────────┘                                 │
│          │                                                                 │
│          ▼                                                                 │
│  ┌────────────────────────────────────────────────────────┐            │
│  │              Within Single Transaction:                │            │
│  │  1. Insert album (Panini WC 2026)                      │            │
│  │  2. Insert 10 sections (Cover, Stars, Groups A-H)       │            │
│  │  3. Insert ~100 stickers (10 per section for MVP)        │            │
│  │  4. Initialize collection_status for "default_user"    │            │
│  │     with count=0 for all stickers                     │            │
│  └────────────────────────────────────────────────────────┘            │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

### 7.3 Seed Implementation

```dart
// features/album/data/datasources/local/album_local_datasource.dart
class AlbumLocalDataSource {
  final AppDatabase _db;
  
  Future<void> seedIfNeeded() async {
    final isEmpty = await _db.albumDao.countAlbums() == 0;
    if (!isEmpty) return;
    
    await _db.transaction(() async {
      // 1. Insert album
      final albumId = await _db.albumDao.insertAlbum(AlbumModel(
        name: SeedData.album['name']!,
        publisher: SeedData.album['publisher'],
        description: SeedData.album['description'],
        totalStickers: SeedData.album['totalStickers']!,
      ));
      
      // 2. Insert sections and stickers
      for (final sectionData in SeedData.sections) {
        final sectionId = await _db.albumDao.insertSection(SectionModel(
          albumId: albumId,
          name: sectionData['name']!,
          orderIndex: sectionData['orderIndex']!,
        ));
        
        // Insert stickers for this section
        final sectionIndex = sectionData['orderIndex'] as int;
        final stickerList = SeedData.stickers[sectionIndex] ?? [];
        
        for (final stickerData in stickerList) {
          await _db.albumDao.insertSticker(StickerModel(
            sectionId: sectionId,
            stickerNumber: stickerData['number']!,
            name: stickerData['name']!,
            isSpecial: stickerData['isSpecial'] ?? false,
          ));
        }
      }
      
      // 3. Initialize collection statuses
      final allStickers = await _db.albumDao.selectAllStickers();
      for (final sticker in allStickers) {
        await _db.collectionDao.insertStatus(CollectionStatusModel(
          stickerId: sticker.id,
          userId: 'default_user',
          count: 0,
        ));
      }
    });
  }
}
```

---

## 8. PDF Generation Flow

### 8.1 PDF Generation Data Flow

```
┌──────────────────────────────────────────────────────────────────────────┐
│                      PDF GENERATION FLOW                                │
│                                                                          │
│  User Action: Tap "Export Full Collection" button                      │
│      │                                                                  │
│      ▼                                                                  │
│  PdfExportCubit.generatePdf()                                          │
│      │                                                                  │
│      ▼                                                                  │
│  ┌─────────────────────────────────────────────┐                       │
│  │  PdfExportService.generateCollectionPdf()   │                       │
│  │  ┌───────────────────────────────────────┐  │                       │
│  │  │  1. Apply filter to stickers           │  │                       │
│  │  │     filter = full → all stickers       │  │                       │
│  │  │     filter = missingOnly → count == 0  │  │                       │
│  │  │     filter = section → section sticker │  │                       │
│  │  └───────────────────────────────────────┘  │                       │
│  │  ┌───────────────────────────────────────┐  │                       │
│  │  │  2. Build PDF document with pdf pkg   │  │                       │
│  │  │     - Header: Album name, date        │  │                       │
│  │  │     - Table: #, Name, Status columns   │  │                       │
│  │  │     - Status symbols: [✓] [ ] [+n]    │  │                       │
│  │  │     - Legend at bottom                │  │                       │
│  │  └───────────────────────────────────────┘  │                       │
│  │  ┌───────────────────────────────────────┐  │                       │
│  │  │  3. Return Uint8List (PDF bytes)       │  │                       │
│  │  └───────────────────────────────────────┘  │                       │
│  └─────────────────────────────────────────────┘                       │
│      │                                                                  │
│      ▼                                                                  │
│  PdfExportCubit emits state with pdfBytes                              │
│      │                                                                  │
│      ▼                                                                  │
│  UI shows "Share" button enabled                                        │
│      │                                                                  │
│      ▼                                                                  │
│  User taps "Share" button                                              │
│      │                                                                  │
│      ▼                                                                  │
│  PdfExportCubit.sharePdf()                                             │
│      │                                                                  │
│      ▼                                                                  │
│  Share Plus: Native share sheet opens                                  │
│      │                                                                  │
│      ▼                                                                  │
│  User selects sharing target (WhatsApp, Email, etc.)                   │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

### 8.2 PDF Generator Implementation

```dart
// features/pdf_export/data/pdf_generator.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  Future<Uint8List> generateCollectionPdf({
    required List<StickerModel> stickers,
    required Map<int, CollectionStatusModel> statusMap,
    required ExportFilter filter,
    int? sectionId,
    String? albumName,
  }) async {
    final pdf = pw.Document();
    
    // Apply filter
    final filteredStickers = _filterStickers(stickers, statusMap, filter, sectionId);
    
    // Group by section for organized output
    final groupedStickers = _groupBySection(filteredStickers);
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(albumName ?? 'My Collection'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Summary section
          _buildSummary(filteredStickers, statusMap),
          pw.SizedBox(height: 20),
          
          // Stickers by section
          ...groupedStickers.entries.expand((entry) => [
            pw.Header(
              level: 1,
              child: pw.Text(entry.key),
              textStyle: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            _buildStickerTable(entry.value, statusMap),
            pw.SizedBox(height: 16),
          ]),
          
          // Legend
          pw.SizedBox(height: 24),
          _buildLegend(),
        ],
      ),
    );
    
    return pdf.save();
  }
  
  List<StickerModel> _filterStickers(
    List<StickerModel> stickers,
    Map<int, CollectionStatusModel> statusMap,
    ExportFilter filter,
    int? sectionId,
  ) {
    switch (filter) {
      case ExportFilter.full:
        return stickers;
      case ExportFilter.missingOnly:
        return stickers.where((s) {
          final status = statusMap[s.id];
          return status == null || status.count == 0;
        }).toList();
      case ExportFilter.section:
        return stickers.where((s) => s.sectionId == sectionId).toList();
    }
  }
  
  Map<String, List<StickerModel>> _groupBySection(List<StickerModel> stickers) {
    // Group stickers by section name
    // Returns Map<sectionName, List<StickerModel>>
    final grouped = <String, List<StickerModel>>{};
    for (final sticker in stickers) {
      // Use sectionId to lookup section name (passed from Cubit)
      final sectionName = _sectionNames[sticker.sectionId] ?? 'Unknown';
      grouped.putIfAbsent(sectionName, () => []).add(sticker);
    }
    return grouped;
  }
  
  pw.Widget _buildHeader(String albumName) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            albumName,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated: ${DateTime.now().toIso8601String().split('T').first}',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }
  
  pw.Widget _buildStickerTable(
    List<StickerModel> stickers,
    Map<int, CollectionStatusModel> statusMap,
  ) {
    return pw.Table.fromTextArray(
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
      cellStyle: const pw.TextStyle(fontSize: 10),
      data: stickers.map((s) {
        final status = statusMap[s.id];
        return [
          s.stickerNumber,
          s.name,
          _statusSymbol(status?.count ?? 0),
        ];
      }).toList(),
    );
  }
  
  String _statusSymbol(int count) {
    if (count == 0) return '[ ]';           // Missing
    if (count == 1) return '[✓]';         // Owned
    return '[+$count]';                    // Repeated
  }
  
  pw.Widget _buildSummary(
    List<StickerModel> stickers,
    Map<int, CollectionStatusModel> statusMap,
  ) {
    final owned = stickers.where((s) {
      final status = statusMap[s.id];
      return status != null && status.count > 0;
    }).length;
    final missing = stickers.length - owned;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Text('Total: ${stickers.length}'),
          pw.Text('Owned: $owned'),
          pw.Text('Missing: $missing'),
        ],
      ),
    );
  }
  
  pw.Widget _buildLegend() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Legend:', style: pw.TextStyle.bold),
          pw.SizedBox(height: 4),
          pw.Text('[ ] = Missing (not in collection)'),
          pw.Text('[✓] = Owned (have this sticker)'),
          pw.Text('[+n] = Repeated (have n copies)'),
        ],
      ),
    );
  }
  
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 16),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }
}
```

### 8.3 Share Implementation

```dart
// features/pdf_export/domain/pdf_export_service.dart
import 'package:share_plus/share_plus.dart';

class PdfExportService {
  final PdfGenerator _generator;
  
  PdfExportService(this._generator);
  
  Future<Uint8List> generateCollectionPdf({
    required List<StickerModel> stickers,
    required Map<int, CollectionStatusModel> statusMap,
    ExportFilter filter = ExportFilter.full,
    int? sectionId,
  }) async {
    return await _generator.generateCollectionPdf(
      stickers: stickers,
      statusMap: statusMap,
      filter: filter,
      sectionId: sectionId,
    );
  }
  
  Future<void> sharePdf(Uint8List pdfBytes, {required String filterName}) async {
    final filename = _generateFilename(filterName);
    
    final file = XFile.fromData(
      pdfBytes,
      mimeType: 'application/pdf',
      name: filename,
    );
    
    await Share.shareXFiles(
      [file],
      text: 'My WC 2026 sticker list',
    );
  }
  
  String _generateFilename(String filterName) {
    final timestamp = DateTime.now().toIso8601String().split('T').first;
    return 'wc2026_${filterName}_$timestamp.pdf';
  }
}
```

---

## 9. Design Decisions

### 9.1 User Identity: Single Hardcoded User

**Decision:** Use a single hardcoded "default_user" identifier for all collection operations.

**Rationale:**
- Phase 1 scope is single-device, single-user
- Multi-user identity deferred to cloud sync phase (Phase 2+)
- Simplifies repository interfaces (no userId parameter needed in Phase 1)
- Allows easy migration to multi-user later (just change where userId is stored)

**Implementation:**
```dart
// core/constants/app_constants.dart
class AppConstants {
  static const String defaultUserId = 'default_user';
  static const String appName = 'Sticker Collector';
  static const String databaseName = 'sticker_collector.db';
}
```

**Migration Path:** When Firebase Auth is added:
1. Store authenticated user's UID
2. Update repository queries to use dynamic userId
3. Keep defaultUserId for backward compatibility during migration

---

### 9.2 Collection Status: Count-Based (Not Enum-Based)

**Decision:** Store collection status as a count integer, not as an enum (missing/owned/repeated).

**Rationale:**
- More flexible: supports count > 2 for repeated stickers
- Simpler state machine: only need to track count, derive status from count
- Natural for "how many of this sticker do I have?" query
- Enables future features (trading surplus calculations, etc.)

**Implementation:**
```dart
// collection_status table stores count directly
IntColumn get count => integer().withDefault(const Constant(0))();

// Status derived at runtime:
bool get isMissing => count == 0;
bool get isOwned => count == 1;
bool get isRepeated => count > 1;
```

**Comparison to Enum Approach:**
| Aspect | Count-Based | Enum-Based |
|--------|-------------|------------|
| Storage | Single INT | Single INT (or small enum) |
| Flexibility | High (any count) | Limited (0, 1, 2+) |
| "How many?" | Direct query | Need additional count field |
| UI Badge | Easy (show count) | Need count separately |
| State Machine | Simple (delta count) | Need enum transitions |

---

### 9.3 Database: Drift with LazyDatabase

**Decision:** Use Drift ORM with LazyDatabase for all local persistence.

**Rationale:**
- **Type-safe SQL:** Compile-time checking of queries and table definitions
- **Lazy initialization:** Database opens on first query, not app startup (critical for cold start performance)
- **Reactive streams:** Built-in support for watch queries (future enhancement)
- **Migration support:** MigrationStrategy for schema evolution
- **Pure Dart:** No native code dependencies that could break

**Implementation Pattern:**
```dart
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(join(dbFolder.path, 'sticker_collector.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

**Why Not sqflite directly:**
- Drift provides type-safe abstractions without sacrificing performance
- Code generation reduces boilerplate significantly
- Future: Easy to add reactive queries with watch()

---

### 9.4 State Management: Cubit with Immutable States

**Decision:** Use Cubit (not full BLoC) with immutable state classes using copyWith pattern.

**Rationale:**
- **Less boilerplate:** No need to define Events for simple state transitions
- **Sufficient complexity:** App state changes are straightforward (tap/long-press increment/decrement)
- **Easier testing:** States are simple data classes, easily mocked
- **Readability:** State changes are self-documenting in code

**State Class Pattern:**
```dart
class CollectionState {
  final CollectionStatus status;
  final Map<int, CollectionStatusModel> statusMap;
  
  CollectionState copyWith({
    CollectionStatus? status,
    Map<int, CollectionStatusModel>? statusMap,
  }) {
    return CollectionState(
      status: status ?? this.status,
      statusMap: statusMap ?? this.statusMap,
    );
  }
}
```

**Why Not Provider:**
- Cubit provides better separation of concerns
- State is fully encapsulated (not exposed as ChangeNotifier)
- Built-in support for async operations in emit()
- Better testability with explicit state classes

---

### 9.5 Grid Performance: GridView.builder + RepaintBoundary

**Decision:** Use GridView.builder with RepaintBoundary per tile for 800+ sticker grids.

**Rationale:**
- **GridView.builder:** Only builds visible items (lazy loading), critical for 800+ stickers
- **RepaintBoundary:** Isolates repaints to individual tiles (when one sticker changes, only that tile repaints)
- **Fixed cross-axis count:** Predictable layout calculations
- **Const delegates:** No runtime delegate creation

**Implementation:**
```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,
    childAspectRatio: 0.85,
  ),
  itemCount: stickers.length,
  itemBuilder: (context, index) {
    final sticker = stickers[index];
    return RepaintBoundary(
      key: ValueKey(sticker.id),
      child: StickerTile(
        sticker: sticker,
        status: state.statusMap[sticker.id],
        onTap: () => collectionCubit.incrementSticker(sticker.id),
        onLongPress: () => collectionCubit.decrementSticker(sticker.id),
      ),
    );
  },
)
```

**Performance Benchmarks (target):**
- Cold start to interactive: < 3 seconds
- Grid scroll: 60fps (no jank)
- Single sticker update: < 16ms (one frame)
- Memory: < 150MB with 670 stickers loaded

---

### 9.6 PDF Symbols: ASCII Instead of Emoji

**Decision:** Use ASCII symbols ([✓], [ ], [+n]) instead of emoji for PDF status indicators.

**Rationale:**
- **Cross-platform compatibility:** Emoji rendering varies significantly across PDF viewers
- **Android PDF readers:** Many strip or display emoji incorrectly
- **Print reliability:** ASCII characters render consistently on all printers
- **Fallback ready:** Easy to add emoji option later if needed

**Implementation:**
```dart
String _statusSymbol(int count) {
  if (count == 0) return '[ ]';      // Empty box (missing)
  if (count == 1) return '[✓]';     // Checkmark (owned)
  return '[+$count]';               // Count indicator (repeated)
}
```

**Alternative (future enhancement):**
```dart
// If emoji support is needed:
String _statusSymbolWithEmoji(int count) {
  if (count == 0) return '○';      // Circle (missing)
  if (count == 1) return '✓';     // Checkmark (owned)
  return '🔄 x$count';             // Repeat with count
}
```

---

### 9.7 Feature-First vs Layer-First Architecture

**Decision:** Use feature-first folder organization within features/, not layer-first at lib/ root.

**Rationale:**
- **Solo developer:** Easy to find files by feature ("Where is stats code?" → features/stats/)
- **Scalable:** Can add features without cluttering layer folders
- **Team-ready:** Clear feature boundaries for future team growth
- **Self-contained:** Each feature has its own data/domain/presentation

**Comparison:**
```
FEATURE-FIRST (chosen)          LAYER-FIRST
lib/                            lib/
├── features/                   ├── data/
│   ├── album/                 │   ├── models/
│   │   ├── data/              │   └── repositories/
│   │   ├── domain/            ├── domain/
│   │   └── presentation/     │   ├── entities/
│   ├── stats/                │   └── repositories/
│   └── ...                    └── presentation/
└── core/                          ├── cubits/
                                    └── pages/
```

**Why Feature-First for MVP:**
- Fewer deeply nested directories
- Easier to understand app structure at a glance
- Each feature is a "module" that could be extracted later
- Natural way to think about app features

---

## 10. Implementation Checklist

### 10.1 Database Layer
- [ ] Create Drift database class with LazyDatabase
- [ ] Define 4 tables (albums, sections, stickers, collection_status)
- [ ] Create DAOs for each table
- [ ] Implement migration strategy (even if empty initially)
- [ ] Write unit tests for DAO operations

### 10.2 Album Feature
- [ ] Define domain entities (Album, Section, Sticker)
- [ ] Implement AlbumRepository interface
- [ ] Create AlbumLocalDataSource with seed data
- [ ] Implement AlbumRepositoryImpl
- [ ] Create AlbumCubit with seeding logic
- [ ] Build AlbumListPage and AlbumDetailPage
- [ ] Build SectionStickersPage with GridView

### 10.3 Collection Feature
- [ ] Define CollectionStatus entity
- [ ] Implement CollectionRepository interface
- [ ] Create CollectionLocalDataSource
- [ ] Implement CollectionRepositoryImpl
- [ ] Create CollectionCubit with state machine
- [ ] Build StickerTile widget with tap/long-press

### 10.4 Stats Feature
- [ ] Create StatsCalculator domain class
- [ ] Implement StatsCubit
- [ ] Build StatsDashboardPage
- [ ] Build ProgressRing and StatCard widgets
- [ ] Add pull-to-refresh functionality

### 10.5 PDF Export Feature
- [ ] Implement PdfGenerator with pdf package
- [ ] Create PdfExportService
- [ ] Implement PdfExportCubit
- [ ] Build PdfExportPage with export options
- [ ] Add share functionality with share_plus
- [ ] Test PDF output on physical Android device

### 10.6 Integration
- [ ] Wire all Cubits and Repositories in main.dart
- [ ] Implement navigation with go_router or Navigator
- [ ] Add bottom navigation bar (Albums, Stats, Export)
- [ ] Verify offline functionality (airplane mode test)
- [ ] Build and verify debug APK

---

*SDD Design completed 2026-05-22 for Sticker Collector App Phase 1 MVP*
*Status: Ready for SDD Tasks and Implementation*