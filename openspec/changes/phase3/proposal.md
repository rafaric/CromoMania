# Proposal — CromoManía 2026 Phase 3 (QR Trade System)

## Intent

Build a bidirectional QR trade system that allows users to exchange stickers with friends. Users generate a QR code containing their missing/repeated sticker lists, friends scan it to see the trade offer, and both collections update atomically upon confirmation.

**Why this matters:** Competitors have unidirectional QR trades — only the scanner's collection updates. We implement bidirectional sync where both parties receive stickers automatically.

---

## Scope

### In Scope
- QR code generation with user's missing/repeated stickers
- QR code scanning (camera + ML Kit)
- Bidirectional trade calculation (set intersection)
- Trade confirmation flow
- Local collection updates on trade execution
- Trade history (local table)

### Out of Scope (Phase 4+)
- Real-time trade when both users online simultaneously
- Push notifications for trade requests
- Trade cancellation after confirmation
- Cross-album trades

---

## Capabilities

### Capability: QR Code Generation

**Solution:**
Generate QR containing JSON payload with user's sticker state.

**Payload Format:**
```json
{
  "v": 1,
  "uid": "firebase_uid",
  "ts": 1750000000000,
  "exp": 600,
  "album": "panini_wc2026",
  "missing": [1, 5, 10, 25, 33],
  "repeated": [3, 7, 12, 45]
}
```

**Implementation:**
```dart
class QRTradeGenerator {
  String generateTradeQR({
    required String uid,
    required List<int> missingStickers,
    required List<int> repeatedStickers,
  }) {
    final payload = {
      'v': 1,
      'uid': uid,
      'ts': DateTime.now().millisecondsSinceEpoch,
      'exp': 600,  // 10 minutes
      'album': 'panini_wc2026',
      'missing': missingStickers,
      'repeated': repeatedStickers,
    };
    return jsonEncode(payload);
  }
}
```

**QR Display:**
- Full-screen QR with countdown timer
- "Expires in 9:45" live countdown
- Close button to dismiss

---

### Capability: QR Code Scanning

**Solution:**
Use `mobile_scanner` package with camera permissions.

**Flow:**
1. Request camera permission
2. Open camera with QR overlay
3. Parse QR payload on detection
4. Validate: timestamp, expiry, format
5. Navigate to trade confirmation

**Implementation:**
```dart
class QRScannerPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      onDetect: (capture) {
        final barcodes = capture.barcodes;
        if (barcodes.isNotEmpty) {
          final data = barcodes.first.rawValue;
          final offer = QRTradeParser.parse(data);
          if (offer != null) {
            context.read<TradeScannerCubit>().offerScanned(offer);
          }
        }
      },
    );
  }
}
```

**Android Permission:**
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

---

### Capability: Trade Calculation (Bidirectional)

**Algorithm:**
```
AliceWants = intersection(Alice.missing, Bob.repeated)
BobWants = intersection(Bob.missing, Alice.repeated)
```

**Trade Offer Object:**
```dart
class TradeOffer {
  final String partnerUid;
  final String partnerName;
  final List<Sticker> stickersAliceWants;  // From Bob's repeated
  final List<Sticker> stickersBobWants;      // From Alice's repeated
  final DateTime expiresAt;
  
  bool get hasOverlap => stickersAliceWants.isNotEmpty && stickersBobWants.isNotEmpty;
  int get aliceReceives => stickersBobWants.length;
  int get bobReceives => stickersAliceWants.length;
}
```

**UI Confirmation:**
```
┌─────────────────────────────────┐
│  Trade Offer from Juan          │
├─────────────────────────────────┤
│                                 │
│  You give (Juan wants):         │
│  • Argentina #5                 │
│  • Brazil #12                   │
│  • Mexico #7                    │
│                                 │
│  You receive (Juan offers):     │
│  • Germany #23 ✓                │
│  • France #8 ✓                 │
│                                 │
├─────────────────────────────────┤
│  [Cancel]        [Confirm Trade] │
└─────────────────────────────────┘
```

---

### Capability: Trade Execution

**Solution:**
Update both users' collections locally (Firestore sync handles propagation).

**Local Update:**
```dart
class ExecuteTradeUseCase {
  Future<TradeResult> execute(TradeOffer offer) async {
    // Decrement given stickers
    for (final sticker in offer.stickersAliceWants) {
      await collectionCubit.decrementSticker(sticker.id);
    }
    
    // Increment received stickers  
    for (final sticker in offer.stickersBobWants) {
      await collectionCubit.incrementSticker(sticker.id);
    }
    
    // Record to trade history
    await tradeRepository.recordTrade(offer);
    
    return TradeResult.success(offer);
  }
}
```

**Trade Record:**
```dart
class TradeRecord {
  final String partnerId;
  final String partnerName;
  final int stickersGiven;
  final int stickersReceived;
  final DateTime tradedAt;
}
```

---

### Capability: Trade History

**Solution:**
Store completed trades in local table, display in Trade page.

**UI:**
```
┌─────────────────────────────────┐
│  Trade History                   │
├─────────────────────────────────┤
│  📤 Gave 3 · Got 2 · Juan · 2h  │
│  📤 Gave 1 · Got 4 · María · 1d│
│  📤 Gave 2 · Got 2 · Pedro · 3d│
└─────────────────────────────────┘
```

---

## Affected Areas

### New Files
```
lib/features/trade/
├── data/
│   ├── models/
│   │   ├── trade_offer_model.dart
│   │   └── trade_record_model.dart
│   └── repositories/
│       └── trade_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── trade_offer.dart
│   │   └── trade_record.dart
│   └── repositories/
│       └── trade_repository.dart
├── presentation/
│   ├── cubit/
│   │   ├── trade_cubit.dart
│   │   ├── trade_state.dart
│   │   ├── trade_scanner_cubit.dart
│   │   └── trade_scanner_state.dart
│   ├── pages/
│   │   ├── trade_page.dart
│   │   ├── trade_qr_display_page.dart
│   │   └── trade_confirmation_page.dart
│   └── widgets/
│       ├── trade_qr_viewer.dart
│       └── trade_offer_card.dart
└── main.dart (add Trade tab)
```

### Modified Files
- `pubspec.yaml` — Add qr_flutter, mobile_scanner
- `AndroidManifest.xml` — Add CAMERA permission
- `main.dart` — Add TradeCubit provider, Trade tab

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Camera permission denied | Medium | Medium | Show permission dialog with rationale |
| QR not scannable in low light | Low | Low | mobile_scanner handles this via ML Kit |
| Large sticker lists in QR | Low | Low | Use integer IDs only |
| Trade conflict after sync | Low | Medium | Timestamp-based conflict resolution |
| Network offline during trade | Medium | Low | Queue locally, sync when online |

---

## Rollback

```bash
git revert HEAD
# Remove trade feature files
# Remove CAMERA permission
# Remove qr_flutter, mobile_scanner from pubspec
```

---

## Success Criteria

| # | Criterion | Verification |
|---|-----------|--------------|
| 1 | User can generate QR with their collection | Manual test |
| 2 | QR displays countdown timer (10 min) | Visual check |
| 3 | Friend can scan QR with camera | Manual test |
| 4 | Trade offer calculates correctly | Unit test |
| 5 | Confirm updates both collections | Manual test |
| 6 | Trade appears in history | Manual test |
| 7 | Expired QR shows error message | Manual test |
| 8 | APK builds successfully | CI build |

---

*Proposal authored 2026-05-23 for CromoManía 2026 Phase 3 (QR Trade System)*