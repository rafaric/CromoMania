# SDD — CromoManía 2026 Phase 3: QR Trade System

**Change ID:** phase3  
**Author:** SDD Design Executor  
**Date:** 2026-05-23  
**Status:** Draft

---

## 1. Architecture Overview

### 1.1 High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CromoManía 2026 App                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐      │
│  │   Trade Feature │────▶│  Collection Cubit│◀────│  Album Feature  │      │
│  │   (New)         │     │                 │     │                 │      │
│  └────────┬────────┘     └────────┬────────┘     └─────────────────┘      │
│           │                        │                                          │
│           ▼                        ▼                                          │
│  ┌─────────────────┐     ┌─────────────────┐                                │
│  │   QR Generator  │     │   Collection    │                                │
│  │   (qr_flutter)  │     │   Repository    │                                │
│  └────────┬────────┘     └────────┬────────┘                                │
│           │                        │                                          │
│           │                        ▼                                          │
│           │               ┌─────────────────┐                                │
│           │               │   AppDatabase   │                                │
│           │               │   (Drift/SQLite)│                                │
│           │               └────────┬────────┘                                │
│           │                        │                                          │
│           ▼                        ▼                                          │
│  ┌─────────────────┐     ┌─────────────────┐                                │
│  │   QR Scanner    │     │  Firestore Repo │                                │
│  │ (mobile_scanner)│     │    (Sync)       │                                │
│  └────────┬────────┘     └─────────────────┘                                │
│           │                                                                  │
│           ▼                                                                  │
│  ┌─────────────────┐                                                        │
│  │ Trade Calculator│                                                        │
│  │  (Intersection) │                                                        │
│  └────────┬────────┘                                                        │
│           │                                                                  │
│           ▼                                                                  │
│  ┌─────────────────┐                                                        │
│  │  Trade Executor │                                                        │
│  └─────────────────┘                                                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         QR TRADE DATA FLOW                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  [USER A]                          [USER B]                                 │
│  ┌─────────┐                       ┌─────────┐                             │
│  │ My QR   │                       │ Scan QR │                             │
│  │ Display │                       │         │                             │
│  └────┬────┘                       └────┬────┘                             │
│       │ QR Data (JSON)                 │ QR Data (JSON)                    │
│       │ {"v":1, "uid":"A",            │ {"v":1, "uid":"B",               │
│       │  "missing":[1,5],            │  "missing":[2,7],                │
│       │  "repeated":[3,7]}           │  "repeated":[4,8]}                │
│       ▼                              ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐               │
│  │              TRADE CALCULATION (Set Intersection)       │               │
│  │                                                          │               │
│  │  AliceWants = Alice.missing ∩ Bob.repeated               │               │
│  │  BobWants   = Bob.missing   ∩ Alice.repeated             │               │
│  │                                                          │               │
│  │  Example:                                                │               │
│  │  Alice.missing = [1,5]    Bob.repeated = [3,7]          │               │
│  │  AliceWants    = [ ]      BobWants    = [ ]              │               │
│  │                                                          │               │
│  │  Alice.missing = [1,5]    Bob.repeated = [1,5]           │               │
│  │  AliceWants    = [1,5]    BobWants    = [ ]              │               │
│  │  ─────────────────────────────────────────────────────   │               │
│  │  Result: Alice receives [1,5], Bob receives []           │               │
│  │                                                          │               │
│  └─────────────────────────────────────────────────────────┘               │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────┐               │
│  │                   TRADE OFFER                           │               │
│  │  ┌─────────────────────────────────────────────────┐    │               │
│  │  │ Partner: Juan | Expires: 9:45                   │    │               │
│  │  │─────────────────────────────────────────────────│    │               │
│  │  │ You give:     #5 Argentina, #12 Brazil           │    │               │
│  │  │ You receive:  #23 Germany ✓, #8 France ✓        │    │               │
│  │  │─────────────────────────────────────────────────│    │               │
│  │  │          [Cancel]    [Confirm Trade]            │    │               │
│  │  └─────────────────────────────────────────────────┘    │               │
│  └─────────────────────────────────────────────────────────┘               │
│                              │                                              │
│         ┌────────────────────┴────────────────────┐                        │
│         ▼                                         ▼                        │
│  ┌─────────────────┐                   ┌─────────────────┐                  │
│  │ Update Local DB │                   │ Update Local DB │                  │
│  │ - Decrement 2   │                   │ - Decrement 2   │                  │
│  │ - Increment 2   │                   │ - Increment 2   │                  │
│  └────────┬────────┘                   └────────┬────────┘                  │
│           │                                  │                             │
│           ▼                                  ▼                             │
│  ┌─────────────────┐                   ┌─────────────────┐                  │
│  │ Record to       │                   │ Record to       │                  │
│  │ Trade History   │                   │ Trade History   │                  │
│  └────────┬────────┘                   └────────┬────────┘                  │
│           │                                  │                             │
│           └──────────────┬───────────────────┘                             │
│                          ▼                                                  │
│                 ┌─────────────────┐                                        │
│                 │ Firestore Sync  │                                        │
│                 │ (Background)    │                                        │
│                 └─────────────────┘                                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Folder Structure

### 2.1 Complete New File Structure

```
sticker_collector_app/
├── lib/
│   ├── features/
│   │   └── trade/                          # NEW FEATURE
│   │       ├── data/
│   │       │   ├── models/
│   │       │   │   ├── trade_offer_model.dart
│   │       │   │   └── trade_record_model.dart
│   │       │   ├── repositories/
│   │       │   │   └── trade_repository_impl.dart
│   │       │   └── datasources/
│   │       │       └── trade_local_datasource.dart
│   │       │
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   ├── trade_offer.dart
│   │       │   │   ├── trade_record.dart
│   │       │   │   └── scanned_qr_data.dart
│   │       │   ├── repositories/
│   │       │   │   └── trade_repository.dart
│   │       │   └── usecases/
│   │       │       ├── generate_trade_qr_usecase.dart
│   │       │       ├── calculate_trade_offer_usecase.dart
│   │       │       ├── execute_trade_usecase.dart
│   │       │       └── parse_qr_usecase.dart
│   │       │
│   │       └── presentation/
│   │           ├── cubit/
│   │           │   ├── trade_cubit.dart
│   │           │   ├── trade_state.dart
│   │           │   ├── trade_scanner_cubit.dart
│   │           │   └── trade_scanner_state.dart
│   │           ├── pages/
│   │           │   ├── trade_page.dart
│   │           │   ├── trade_qr_display_page.dart
│   │           │   ├── trade_scanner_page.dart
│   │           │   └── trade_confirmation_page.dart
│   │           └── widgets/
│   │               ├── trade_qr_viewer.dart
│   │               ├── trade_offer_card.dart
│   │               ├── trade_history_list.dart
│   │               └── countdown_timer_widget.dart
│   │
│   │       └── trade.dart                  # Barrel export
│   │
│   └── main.dart                           # MODIFIED (add TradeCubit)
│
├── pubspec.yaml                            # MODIFIED (add dependencies)
└── android/
    └── app/
        └── src/main/AndroidManifest.xml    # MODIFIED (CAMERA permission)
```

### 2.2 Existing Files to Modify

| File | Changes |
|------|---------|
| `pubspec.yaml` | Add `qr_flutter`, `mobile_scanner` dependencies |
| `lib/main.dart` | Add TradeCubit provider, Trade tab in navigation |
| `android/app/src/main/AndroidManifest.xml` | Add CAMERA permission |
| `database/app_database.dart` | Add `trade_records` table |

---

## 3. Class Contracts

### 3.1 Domain Entities

#### `ScannedQRData`
```dart
/// Raw data parsed from QR code payload
class ScannedQRData {
  final int version;           // Protocol version (1)
  final String partnerUid;     // Partner's Firebase UID
  final int timestamp;         // QR generation timestamp (ms)
  final int expirySeconds;    // TTL (600 seconds)
  final String albumId;        // Album identifier
  final List<int> missing;    // Partner's missing sticker IDs
  final List<int> repeated;    // Partner's repeated sticker IDs

  /// Check if QR has expired
  bool get isExpired {
    final ageSeconds = (DateTime.now().millisecondsSinceEpoch - timestamp) / 1000;
    return ageSeconds > expirySeconds;
  }

  /// Get time remaining in seconds
  int get remainingSeconds {
    final ageSeconds = (DateTime.now().millisecondsSinceEpoch - timestamp) / 1000;
    return (expirySeconds - ageSeconds).clamp(0, expirySeconds).toInt();
  }
}
```

#### `TradeOffer`
```dart
/// Calculated trade offer for confirmation
class TradeOffer {
  final ScannedQRData partnerData;    // Partner's scanned QR
  final List<StickerToGive> youGive;  // Stickers user gives to partner
  final List<StickerToReceive> youReceive; // Stickers user receives
  final DateTime expiresAt;           // Expiration time

  /// Whether trade has mutual benefit
  bool get hasTrade => youGive.isNotEmpty && youReceive.isNotEmpty;
  
  /// Whether trade has any exchange
  bool get hasExchange => youGive.isNotEmpty || youReceive.isNotEmpty;
  
  /// Count of stickers user receives
  int get youReceiveCount => youReceive.length;
  
  /// Count of stickers user gives
  int get youGiveCount => youGive.length;
}

/// Sticker info for trade
class StickerToGive {
  final int stickerId;
  final int stickerNumber;
  final String stickerName;
  final int availableCount; // How many user has (for validation)
  
  bool get canGive => availableCount > 0;
}

class StickerToReceive {
  final int stickerId;
  final int stickerNumber;
  final String stickerName;
}
```

#### `TradeRecord`
```dart
/// Completed trade record for history
class TradeRecord {
  final int? id;
  final String partnerId;      // Partner's UID
  final String partnerName;   // Partner's display name
  final int stickersGiven;    // Count of stickers given
  final List<int> givenIds;   // IDs of stickers given
  final int stickersReceived; // Count of stickers received
  final List<int> receivedIds; // IDs of stickers received
  final DateTime tradedAt;    // Trade timestamp
  final String tradeType;     // "qr_bidirectional"
}
```

### 3.2 Repository Interface

#### `TradeRepository`
```dart
/// Abstract repository for trade operations
abstract class TradeRepository {
  /// Save a completed trade record
  Future<int> saveTradeRecord(TradeRecord record);
  
  /// Get all trade history for user
  Future<List<TradeRecord>> getTradeHistory();
  
  /// Get recent trades (last N)
  Future<List<TradeRecord>> getRecentTrades({int limit = 10});
  
  /// Delete old trade records
  Future<void> pruneOldTrades({int keepDays = 90});
}
```

### 3.3 Use Cases

#### `GenerateTradeQRUseCase`
```dart
/// Generates QR payload from current collection state
class GenerateTradeQRUseCase {
  /// Generate JSON payload for QR code
  String execute({
    required String uid,
    required List<int> missingStickerIds,
    required List<int> repeatedStickerIds,
    String albumId = 'panini_wc2026',
    int expirySeconds = 600,
  }) {
    final payload = {
      'v': 1,
      'uid': uid,
      'ts': DateTime.now().millisecondsSinceEpoch,
      'exp': expirySeconds,
      'album': albumId,
      'missing': missingStickerIds,
      'repeated': repeatedStickerIds,
    };
    return jsonEncode(payload);
  }
}
```

#### `CalculateTradeOfferUseCase`
```dart
/// Calculates bidirectional trade from two collections
class CalculateTradeOfferUseCase {
  /// Calculate trade offer from scanned QR and user's collection
  TradeOffer execute({
    required ScannedQRData partnerData,
    required Map<int, int> myStatusMap, // stickerId -> count
  }) {
    // Calculate what partner wants from me (intersection of partner.missing ∩ my.repeated)
    final partnerWantsFromMe = partnerData.missing
        .where((id) => (myStatusMap[id] ?? 0) > 1)
        .toList();
    
    // Calculate what I want from partner (intersection of my.missing ∩ partner.repeated)
    final iWantFromPartner = partnerData.repeated
        .where((id) => (myStatusMap[id] ?? 0) == 0)
        .toList();
    
    // Build trade offer...
  }
}
```

#### `ExecuteTradeUseCase`
```dart
/// Executes trade, updates collection, and records history
class ExecuteTradeUseCase {
  final CollectionCubit collectionCubit;
  final TradeRepository tradeRepository;
  
  /// Execute a trade offer
  Future<TradeResult> execute({
    required TradeOffer offer,
    required String partnerName,
  }) async {
    // Validate user has required stickers
    for (final sticker in offer.youGive) {
      if (!sticker.canGive) {
        return TradeResult.error('Missing sticker: ${sticker.stickerName}');
      }
    }
    
    // Decrement given stickers
    for (final sticker in offer.youGive) {
      collectionCubit.decrementSticker(sticker.stickerId);
    }
    
    // Increment received stickers
    for (final sticker in offer.youReceive) {
      collectionCubit.incrementSticker(sticker.stickerId);
    }
    
    // Record to history
    await tradeRepository.saveTradeRecord(TradeRecord(
      partnerId: offer.partnerData.partnerUid,
      partnerName: partnerName,
      stickersGiven: offer.youGive.length,
      givenIds: offer.youGive.map((s) => s.stickerId).toList(),
      stickersReceived: offer.youReceive.length,
      receivedIds: offer.youReceive.map((s) => s.stickerId).toList(),
      tradedAt: DateTime.now(),
      tradeType: 'qr_bidirectional',
    ));
    
    return TradeResult.success();
  }
}
```

### 3.4 Cubit State Machines

#### `TradeState`
```dart
/// Trade feature state
enum TradeStateStatus { initial, loading, loaded, scanning, confirming, executing, success, error }

class TradeState extends Equatable {
  final TradeStateStatus status;
  final List<TradeRecord> history;
  final String? errorMessage;
  final TradeOffer? currentOffer;
  
  const TradeState({
    this.status = TradeStateStatus.initial,
    this.history = const [],
    this.errorMessage,
    this.currentOffer,
  });
  
  // Factory methods for states...
  factory TradeState.loading() => const TradeState(status: TradeStateStatus.loading);
  factory TradeState.loaded(List<TradeRecord> history) => TradeState(status: TradeStateStatus.loaded, history: history);
  factory TradeState.error(String message) => TradeState(status: TradeStateStatus.error, errorMessage: message);
}
```

#### `TradeScannerState`
```dart
/// Scanner page state machine
enum TradeScannerStatus { idle, requestingPermission, scanning, parsed, expired, invalid }

class TradeScannerState extends Equatable {
  final TradeScannerStatus status;
  final ScannedQRData? scannedData;
  final String? errorMessage;
  final bool permissionGranted;
  
  const TradeScannerState({
    this.status = TradeScannerStatus.idle,
    this.scannedData,
    this.errorMessage,
    this.permissionGranted = false,
  });
  
  factory TradeScannerState.permissionDenied() => const TradeScannerState(
    status: TradeScannerStatus.idle,
    permissionGranted: false,
    errorMessage: 'Camera permission required to scan QR codes',
  );
}
```

---

## 4. Database Schema

### 4.1 Trade Records Table

```sql
CREATE TABLE trade_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  partner_id TEXT NOT NULL,
  partner_name TEXT NOT NULL DEFAULT 'Anonymous',
  stickers_given INTEGER NOT NULL DEFAULT 0,
  given_ids TEXT, -- JSON array [1,2,3]
  stickers_received INTEGER NOT NULL DEFAULT 0,
  received_ids TEXT, -- JSON array [4,5,6]
  traded_at INTEGER NOT NULL, -- Unix timestamp
  trade_type TEXT NOT NULL DEFAULT 'qr_bidirectional'
);

CREATE INDEX idx_trade_records_traded_at ON trade_records(traded_at DESC);
```

### 4.2 Drift Table Definition

```dart
/// Trade records table for history
class TradeRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get partnerId => text()();
  TextColumn get partnerName => text().withDefault(const Constant('Anonymous'))();
  IntColumn get stickersGiven => integer().withDefault(const Constant(0))();
  TextColumn get givenIds => text().nullable()(); // JSON
  IntColumn get stickersReceived => integer().withDefault(const Constant(0))();
  TextColumn get receivedIds => text().nullable()(); // JSON
  IntColumn get tradedAt => integer()();
  TextColumn get tradeType => text().withDefault(const Constant('qr_bidirectional'))();
}
```

---

## 5. UI Pages

### 5.1 Trade Page (`/trade`)
- Tab 4 in bottom navigation
- Two sections: "Show My QR" and "Scan QR"
- Trade history list at bottom
- FAB for quick scan access

### 5.2 QR Display Page (`/trade/qr`)
- Full-screen QR (centered, 280x280dp)
- Countdown timer (MM:SS format)
- "Expires in X:XX" label below QR
- Share button in app bar
- Close button to dismiss

### 5.3 Scanner Page (`/trade/scan`)
- Camera preview with overlay
- Centered scanning frame (250x250dp)
- "Point camera at QR code" instruction
- Flash toggle button
- Cancel button

### 5.4 Confirmation Page (`/trade/confirm`)
- Partner info header
- Two cards: "You Give" / "You Receive"
- Sticker list with checkmarks
- Count summary
- Confirm button (green, prominent)
- Cancel button (outlined)

---

## 6. Dependency Changes

### 6.1 pubspec.yaml Additions

```yaml
dependencies:
  # ... existing deps ...
  
  # QR Code Generation
  qr_flutter: ^4.1.0
  
  # QR Code Scanning
  mobile_scanner: ^5.2.0
  
  # JSON encoding (use dart:convert, no new dep needed)

dev_dependencies:
  # ... existing deps ...
```

### 6.2 Android Manifest Addition

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

### 6.3 iOS Info.plist Addition (Future)

```xml
<!-- ios/Runner/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>CromoManía needs camera access to scan trade QR codes</string>
```

---

## 7. Integration Points

### 7.1 Collection Cubit Integration

```dart
// In TradeCubit.execute()
final collectionCubit = context.read<CollectionCubit>();

// Decrement given
for (final sticker in offer.youGive) {
  collectionCubit.decrementSticker(sticker.stickerId);
}

// Increment received
for (final sticker in offer.youReceive) {
  collectionCubit.incrementSticker(sticker.stickerId);
}
```

### 7.2 Main.dart Navigation Integration

```dart
// Add to bottomNavigationBar items:
BottomNavigationBarItem(
  icon: Icon(Icons.swap_horiz),
  label: 'Trade',
),

// Add to IndexedStack children:
_TradeTab(),

// Add to BlocProviders:
BlocProvider<TradeCubit>(
  create: (context) => TradeCubit(
    tradeRepository: context.read<TradeRepository>(),
    collectionCubit: context.read<CollectionCubit>(),
  )..loadHistory(),
),
```

---

## 8. Error Handling

| Scenario | User Message | Action |
|----------|--------------|--------|
| Camera permission denied | "Camera access needed to scan QR codes" | Show settings button |
| QR expired | "This QR code has expired. Ask your friend to generate a new one." | Return to scanner |
| Invalid QR format | "This QR code is not valid for trading" | Return to scanner |
| Missing sticker during trade | "You no longer have sticker #X to trade" | Abort, reload offer |
| Network offline | "Trade saved locally. Will sync when online." | Continue, queue sync |

---

## 9. Testing Strategy

### 9.1 Unit Tests
- `CalculateTradeOfferUseCase` - Set intersection logic
- `ParseQRUseCase` - JSON parsing, expiry validation
- `TradeRepository` - CRUD operations

### 9.2 Widget Tests
- `TradeOfferCard` - Renders correctly with data
- `CountdownTimerWidget` - Timer display updates
- `TradeQRViewer` - QR displays and timer runs

### 9.3 Integration Tests
- Full QR → Scan → Confirm → Update flow

---

## 10. File List

### New Files (21)
```
lib/features/trade/data/models/trade_offer_model.dart
lib/features/trade/data/models/trade_record_model.dart
lib/features/trade/data/repositories/trade_repository_impl.dart
lib/features/trade/data/datasources/trade_local_datasource.dart
lib/features/trade/domain/entities/trade_offer.dart
lib/features/trade/domain/entities/trade_record.dart
lib/features/trade/domain/entities/scanned_qr_data.dart
lib/features/trade/domain/repositories/trade_repository.dart
lib/features/trade/domain/usecases/generate_trade_qr_usecase.dart
lib/features/trade/domain/usecases/calculate_trade_offer_usecase.dart
lib/features/trade/domain/usecases/execute_trade_usecase.dart
lib/features/trade/domain/usecases/parse_qr_usecase.dart
lib/features/trade/presentation/cubit/trade_cubit.dart
lib/features/trade/presentation/cubit/trade_state.dart
lib/features/trade/presentation/cubit/trade_scanner_cubit.dart
lib/features/trade/presentation/cubit/trade_scanner_state.dart
lib/features/trade/presentation/pages/trade_page.dart
lib/features/trade/presentation/pages/trade_qr_display_page.dart
lib/features/trade/presentation/pages/trade_scanner_page.dart
lib/features/trade/presentation/pages/trade_confirmation_page.dart
lib/features/trade/presentation/widgets/trade_qr_viewer.dart
lib/features/trade/presentation/widgets/trade_offer_card.dart
lib/features/trade/presentation/widgets/trade_history_list.dart
lib/features/trade/presentation/widgets/countdown_timer_widget.dart
lib/features/trade/trade.dart
```

### Modified Files (4)
```
lib/main.dart
pubspec.yaml
android/app/src/main/AndroidManifest.xml
database/app_database.dart
```

---

## 11. Implementation Order

1. **Database** - Add TradeRecords table to AppDatabase
2. **Domain** - Create entities, repository interface, use cases
3. **Data** - Implement TradeRepositoryImpl with Drift
4. **Cubits** - TradeCubit, TradeScannerCubit with states
5. **UI Pages** - Trade page, QR display, Scanner, Confirmation
6. **Widgets** - QR viewer, Offer card, History list, Timer
7. **Integration** - Wire into main.dart, CollectionCubit
8. **Android** - Add CAMERA permission
9. **Testing** - Unit tests for core logic

---

*SDD Design for CromoManía 2026 Phase 3 (QR Trade System)*