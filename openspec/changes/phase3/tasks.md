# SDD Tasks — CromoManía 2026 Phase 3 (QR Trade System)

**Change ID:** phase3  
**Status:** Draft  
**Date:** 2026-05-23

---

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~2,200 (25 new Dart files + 4 modified) |
| 400-line budget risk | **High** |
| Chained PRs recommended | **Yes** |
| Suggested split | 5 PRs (Foundation → Logic → State → UI → Integration) |
| Delivery strategy | auto-chain |
| Chain strategy | pending |

**Decision needed before apply:** Yes  
**Chained PRs recommended:** Yes  
**Chain strategy:** pending  
**400-line budget risk:** High

---

## Implementation Order

The feature is split into 5 autonomous work units that can be implemented and reviewed independently.

---

## PR 1: Foundation (Database + Domain + Repository Interface)

### Task 1.1: Add TradeRecords table to AppDatabase

**File:** `database/app_database.dart`

- Import Drift table utilities
- Add `TradeRecords` class extending `Table`
- Define columns: `id` (autoIncrement), `partnerId`, `partnerName` (default 'Anonymous'), `stickersGiven`, `givenIds` (TEXT, nullable), `stickersReceived`, `receivedIds` (TEXT, nullable), `tradedAt`, `tradeType`
- Add index on `tradedAt` descending
- Run `dart run build_runner build` to generate code

**Verification:** Build succeeds, `AppDatabase` has `tradeRecords` table

---

### Task 1.2: Create ScannedQRData entity

**File:** `lib/features/trade/domain/entities/scanned_qr_data.dart`

- Create `ScannedQRData` class with fields: `version`, `partnerUid`, `timestamp`, `expirySeconds`, `albumId`, `missing` (List<int>), `repeated` (List<int>)
- Add `isExpired` getter: checks if current time - timestamp > expirySeconds
- Add `remainingSeconds` getter: calculates clamped remaining time
- Add `.copyWith()` method
- Add `toString()` for debug

**Verification:** Unit test for expiry logic

---

### Task 1.3: Create TradeOffer entity

**File:** `lib/features/trade/domain/entities/trade_offer.dart`

- Create `StickerToGive` class: `stickerId`, `stickerNumber`, `stickerName`, `availableCount`, `canGive` getter
- Create `StickerToReceive` class: `stickerId`, `stickerNumber`, `stickerName`
- Create `TradeOffer` class: `partnerData` (ScannedQRData), `youGive` (List<StickerToGive>), `youReceive` (List<StickerToReceive>), `expiresAt`
- Add `hasTrade` getter: both lists non-empty
- Add `hasExchange` getter: either list non-empty
- Add `youReceiveCount`, `youGiveCount` getters

**Verification:** Unit tests for hasTrade/hasExchange logic

---

### Task 1.4: Create TradeRecord entity

**File:** `lib/features/trade/domain/entities/trade_record.dart`

- Create `TradeRecord` class with all fields from spec
- Add `id` as optional int (null for new records)
- Add `timeAgo` getter returning relative string ("2h", "1d")
- Add `.copyWith()` method

**Verification:** Dart analysis passes

---

### Task 1.5: Create TradeRepository interface

**File:** `lib/features/trade/domain/repositories/trade_repository.dart`

- Define `TradeRepository` abstract class
- Method: `Future<int> saveTradeRecord(TradeRecord record)`
- Method: `Future<List<TradeRecord>> getTradeHistory()`
- Method: `Future<List<TradeRecord>> getRecentTrades({int limit = 10})`
- Method: `Future<void> pruneOldTrades({int keepDays = 90})`

**Verification:** Interface compiles, no implementation

---

### Task 1.6: Create TradeRepositoryImpl

**File:** `lib/features/trade/data/repositories/trade_repository_impl.dart`

- Implement `TradeRepository` interface
- Use `AppDatabase` instance for CRUD
- `saveTradeRecord`: Insert to trade_records table, return inserted ID
- `getTradeHistory`: Select all ordered by traded_at DESC
- `getRecentTrades`: Select with LIMIT
- `pruneOldTrades`: Delete where traded_at < cutoff timestamp

**Verification:** Unit tests for all methods

---

## PR 2: Business Logic (Use Cases)

### Task 2.1: Create ParseQRUseCase

**File:** `lib/features/trade/domain/usecases/parse_qr_usecase.dart`

- Class `ParseQRUseCase`
- Method `ScannedQRData? execute(String rawQR)`
- Parse JSON, validate required fields exist
- Validate version == 1
- Validate timestamp and expiry present
- Return null with error for invalid payloads
- Add error message enum for different invalid cases

**Verification:** Unit tests: valid JSON, invalid JSON, missing fields, wrong version

---

### Task 2.2: Create GenerateTradeQRUseCase

**File:** `lib/features/trade/domain/usecases/generate_trade_qr_usecase.dart`

- Class `GenerateTradeQRUseCase`
- Method `String execute({required String uid, required List<int> missingStickerIds, required List<int> repeatedStickerIds, String albumId = 'panini_wc2026', int expirySeconds = 600})`
- Build JSON payload per spec format
- Return JSON-encoded string

**Verification:** Unit test validates output format

---

### Task 2.3: Create CalculateTradeOfferUseCase

**File:** `lib/features/trade/domain/usecases/calculate_trade_offer_usecase.dart`

- Class `CalculateTradeOfferUseCase`
- Method `TradeOffer execute({required ScannedQRData partnerData, required Map<int, int> myStatusMap})`
- `myStatusMap`: stickerId -> count (0=missing, 1=have one, 2+=repeated)
- Calculate `youGive`: partner missing ∩ my count > 1
- Calculate `youReceive`: my missing ∩ partner repeated
- Build `StickerToGive` and `StickerToReceive` with placeholder names (actual names from CollectionCubit later)
- Return `TradeOffer`

**Verification:** Unit tests for all intersection scenarios from spec

---

### Task 2.4: Create ExecuteTradeUseCase

**File:** `lib/features/trade/domain/usecases/execute_trade_usecase.dart`

- Class `ExecuteTradeUseCase`
- Method `Future<TradeResult> execute({required TradeOffer offer, required String partnerName})`
- Inject `CollectionCubit` and `TradeRepository`
- Validate all `StickerToGive.canGive`
- Decrement given stickers via `collectionCubit.decrementSticker()`
- Increment received stickers via `collectionCubit.incrementSticker()`
- Save to `tradeRepository`
- Return `TradeResult.success()` or `TradeResult.error(message)`

**Verification:** Unit test with mock cubits

---

## PR 3: State Management (Cubits)

### Task 3.1: Create TradeState

**File:** `lib/features/trade/presentation/cubit/trade_state.dart`

- Enum `TradeStateStatus`: initial, loading, loaded, error
- Class `TradeState` extends `Equatable`
- Fields: `status`, `history` (List<TradeRecord>), `errorMessage`
- Factory constructors: `initial()`, `loading()`, `loaded(List<TradeRecord>)`, `error(String)`

**Verification:** Dart analysis passes

---

### Task 3.2: Create TradeCubit

**File:** `lib/features/trade/presentation/cubit/trade_cubit.dart`

- Class `TradeCubit` extends `Cubit<TradeState>`
- Inject `TradeRepository`
- Constructor calls `loadHistory()`
- Method `loadHistory()`: load from repo, emit `loaded()`
- Method `clearError()`: emit current with null error
- Method `refreshHistory()`: reload after trade

**Verification:** Widget test for state transitions

---

### Task 3.3: Create TradeScannerState

**File:** `lib/features/trade/presentation/cubit/trade_scanner_state.dart`

- Enum `TradeScannerStatus`: idle, requestingPermission, scanning, parsed, expired, invalid
- Class `TradeScannerState` extends `Equatable`
- Fields: `status`, `scannedData`, `errorMessage`, `permissionGranted`
- Factory: `permissionDenied()`

**Verification:** Dart analysis passes

---

### Task 3.4: Create TradeScannerCubit

**File:** `lib/features/trade/presentation/cubit/trade_scanner_cubit.dart`

- Class `TradeScannerCubit` extends `Cubit<TradeScannerState>`
- Inject `ParseQRUseCase`
- Method `onQRScanned(String rawValue)`: parse QR, emit `parsed` or `expired`/`invalid`
- Method `reset()`: return to `idle`
- Method `onPermissionDenied()`: emit `permissionDenied()`
- Method `onPermissionGranted()`: emit `scanning`

**Verification:** Unit tests for all scanner states

---

## PR 4: UI Layer (Pages + Widgets)

### Task 4.1: Create CountdownTimerWidget

**File:** `lib/features/trade/presentation/widgets/countdown_timer_widget.dart`

- StatefulWidget with `TickerProviderStateMixin`
- Props: `DateTime expiresAt`, `VoidCallback? onExpired`
- Internal timer: update every second
- Display format: "M:SS" or "MM:SS"
- At 0: call `onExpired`, show "QR Expired" text
- Dispose timer on widget disposal

**Verification:** Widget test with mock timer

---

### Task 4.2: Create TradeQRViewer

**File:** `lib/features/trade/presentation/widgets/trade_qr_viewer.dart`

- StatelessWidget using `qr_flutter.QrImageView`
- Props: `String payload`, `DateTime expiresAt`
- Layout: centered QR (280x280), `CountdownTimerWidget` below
- Wrap in Card with elevation

**Verification:** Widget test renders QR

---

### Task 4.3: Create TradeOfferCard

**File:** `lib/features/trade/presentation/widgets/trade_offer_card.dart`

- StatelessWidget for confirmation page
- Props: `TradeOffer offer`, `List<Sticker> allStickers`
- Layout: two sections ("You Give" / "You Receive")
- Each section: header, list of `StickerListTile` with checkmark
- Summary footer: "Give X · Receive Y"
- Use Card with dividers

**Verification:** Widget test with mock data

---

### Task 4.4: Create TradeHistoryList

**File:** `lib/features/trade/presentation/widgets/trade_history_list.dart`

- StatelessWidget
- Props: `List<TradeRecord> history`
- ListView.builder with `TradeHistoryTile`
- Format: "📤 Gave {x} · Got {y} · {partnerName} · {timeAgo}"
- Empty state: "No trades yet"
- Pull-to-refresh enabled

**Verification:** Widget test with empty and populated lists

---

### Task 4.5: Create TradePage

**File:** `lib/features/trade/presentation/pages/trade_page.dart`

- StatefulWidget with `Scaffold`
- AppBar: "Trade" title
- Body: Column with:
  - "Show My QR" button (elevated, navigates to QR display)
  - "Scan QR" button (outlined, navigates to scanner)
  - `TradeHistoryList` at bottom
- Use `BlocBuilder<TradeCubit>` for history
- FAB: quick access to scanner

**Verification:** Navigation test to both routes

---

### Task 4.6: Create TradeQRDisplayPage

**File:** `lib/features/trade/presentation/pages/trade_qr_display_page.dart`

- StatefulWidget (needs state for countdown)
- Hook into `CollectionCubit` to get missing/repeated lists
- Call `GenerateTradeQRUseCase` with current collection
- Body: `TradeQRViewer` with generated payload and expiry
- AppBar actions: share button
- Auto-refresh collection on resume

**Verification:** Manual test generates valid QR

---

### Task 4.7: Create TradeScannerPage

**File:** `lib/features/trade/presentation/pages/trade_scanner_page.dart`

- StatefulWidget
- Use `BlocConsumer<TradeScannerCubit>` for state
- States:
  - `requestingPermission`: show loading + rationale
  - `scanning`: show `MobileScanner` with overlay frame
  - `parsed`: navigate to confirmation with scanned data
  - `expired`/`invalid`: show error snackbar, reset
  - `idle` with no permission: show settings button
- Handle flash toggle
- Close button to dismiss

**Verification:** Manual test with real QR

---

### Task 4.8: Create TradeConfirmationPage

**File:** `lib/features/trade/presentation/pages/trade_confirmation_page.dart`

- StatefulWidget
- Route args: `ScannedQRData`
- Hook into `CollectionCubit` to get current status map
- Call `CalculateTradeOfferUseCase` to get offer
- Body: `TradeOfferCard` if hasExchange, else "No stickers to trade" message
- Bottom buttons: "Cancel" (outlined), "Confirm Trade" (elevated, green)
- On confirm: call `ExecuteTradeUseCase`, show result, pop back
- On cancel: pop back

**Verification:** Manual test full flow

---

### Task 4.9: Create Trade barrel export

**File:** `lib/features/trade/trade.dart`

- Export all public classes from domain, data, presentation
- Export paths for all subdirectories

**Verification:** Dart analysis passes

---

## PR 5: Integration + Testing

### Task 5.1: Add dependencies to pubspec.yaml

**File:** `pubspec.yaml`

- Add `qr_flutter: ^4.1.0` under dependencies
- Add `mobile_scanner: ^5.2.0` under dependencies
- Run `flutter pub get`

**Verification:** Packages resolved without conflicts

---

### Task 5.2: Add CAMERA permission to Android

**File:** `android/app/src/main/AndroidManifest.xml`

- Add `<uses-permission android:name="android.permission.CAMERA" />`
- Add `<uses-feature android:name="android.hardware.camera" android:required="false" />`
- Add `<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />`

**Verification:** APK installs, camera permission requested

---

### Task 5.3: Add TradeCubit to main.dart

**File:** `lib/main.dart`

- Import `TradeCubit` and `TradeRepository`
- Add BlocProvider: `BlocProvider<TradeCubit>(create: (context) => TradeCubit(tradeRepository: context.read<TradeRepository>())..loadHistory())`
- Add Trade tab to `BottomNavigationBar`
- Add Trade page to `IndexedStack` children

**Verification:** App builds, Trade tab accessible

---

### Task 5.4: Write unit tests for core logic

**Files:** `test/features/trade/`

- `parse_qr_usecase_test.dart`: valid, invalid, expired, wrong version
- `calculate_trade_offer_usecase_test.dart`: all intersection scenarios
- `execute_trade_usecase_test.dart`: success, insufficient stickers
- `trade_cubit_test.dart`: load history, refresh
- `trade_scanner_cubit_test.dart`: all scanner states

**Verification:** `flutter test` passes all

---

### Task 5.5: Write widget tests for UI

**Files:** `test/features/trade/`

- `countdown_timer_widget_test.dart`: timer display, expiry callback
- `trade_offer_card_test.dart`: renders correctly with data
- `trade_history_list_test.dart`: empty and populated states

**Verification:** `flutter test` passes all

---

### Task 5.6: Build verification

**Verification:** Run `flutter build apk --debug`

- APK builds without errors
- Size reasonable (< 50MB with new deps)

---

## Rollback Plan

If any PR fails or needs rollback:

```bash
# Revert specific PR
git revert <pr-commit-hash>

# Or remove trade feature entirely
git rm -rf lib/features/trade
git revert <pr-commit-hash>
# Remove from pubspec.yaml, main.dart, AndroidManifest.xml
```

---

## Success Criteria Tracking

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| 1 | User can generate QR with their collection | Manual test (PR 5) |
| 2 | QR displays countdown timer (10 min) | Visual check (PR 4) |
| 3 | Friend can scan QR with camera | Manual test (PR 5) |
| 4 | Trade offer calculates correctly | Unit test (PR 2) |
| 5 | Confirm updates both collections | Manual test (PR 5) |
| 6 | Trade appears in history | Manual test (PR 5) |
| 7 | Expired QR shows error message | Unit test + manual (PR 4) |
| 8 | APK builds successfully | CI build (PR 5) |

---

*SDD Tasks for CromoManía 2026 Phase 3 (QR Trade System)*