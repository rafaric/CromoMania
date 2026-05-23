# Sticker Collector App — Architecture & Technical Requirements Document

> **Document Version:** 1.0  
> **Date:** 2026-05-22  
> **Status:** Draft for review  
> **Target Platforms:** Android (API 26+), iOS (15+), optional Web (PWA)  

---

## 1. Executive Summary

This document defines the technical architecture and requirements for a cross-platform mobile application that allows users to manage, track, and trade physical sticker collections (albums, figuritas, cromos, láminas, estampas). The application targets the gap left by the market-leading app "Figuritas App" (21.2K reviews, 4.9★), which suffers from critical stability issues, abusive advertising, lack of cloud backup, and poor user experience in core flows.

### Competitive Edge (Must Resolve Competitor Pain Points)

| Pain Point (Competitor) | Our Differentiator |
|---|---|
| App crashes when marking stickers | Rock-solid stability; offline-first architecture |
| Abusive ads every 5s / scam ads | Ethical monetization; optional rewarded ads only |
| No cloud backup / device loss = data loss | Automatic cloud sync; multi-device support |
| QR trade is unidirectional | Bidirectional QR trade; both parties auto-update |
| OCR/scanning is paywalled | Free batch scanning with generous limits |
| Broken PDF export (paid) | Free, working PDF export with flags |
| Incomplete album sections | Full album coverage including regional variants |
| Repetitive sticker management is confusing | Dedicated "repetidas" section, decoupled from album |
| No player names, only numbers | Search by player name, team, or number |
| No alphabetical ordering | Sorting and filtering everywhere |

---

## 2. Requirements

### 2.1 Functional Requirements

#### FR-1 Album Management
- **FR-1.1** The system shall support multiple concurrent albums per user (e.g., World Cup 2026, Copa América, regional variants).
- **FR-1.2** Each album shall be modeled as a hierarchical structure: Album → Sections → Teams/Specials → Individual Stickers.
- **FR-1.3** The system shall support album variants (e.g., "Colombia Exclusive", "Hardcover Edition") with different sticker counts and special sections.
- **FR-1.4** Admin-facing CMS shall allow dynamic album onboarding without app store releases.

#### FR-2 Sticker Tracking (Core Loop)
- **FR-2.1** Users shall mark stickers as: **Owned**, **Missing**, or **Repeated**.
- **FR-2.2** Tapping a sticker cell toggles it to Owned. Long-press toggles to Repeated. A clear UI state prevents accidental misclicks.
- **FR-2.3** "Repeated" stickers shall be managed in a dedicated section, fully decoupled from the album progress logic.
- **FR-2.4** Users shall see real-time completion statistics: total owned, total missing, total repeated, percentage per section.
- **FR-2.5** The app shall display player name alongside sticker number.
- **FR-2.6** The app shall support search by sticker number, player name, team name, or section name.
- **FR-2.7** The app shall support sorting (alphabetical, by number, by status) and filtering (show only missing, only owned, only repeated).

#### FR-3 Batch Scanning (OCR)
- **FR-3.1** The app shall use device camera to scan physical stickers.
- **FR-3.2** The app shall support batch scanning (multiple stickers in a single photo).
- **FR-3.3** OCR shall detect sticker numbers from images and auto-mark them.
- **FR-3.4** A confirmation sheet shall allow the user to accept/reject OCR predictions before committing.
- **FR-3.5** Scanning shall be free with a daily batch limit (e.g., 50 stickers/day). Unlimited scanning is a premium feature.

#### FR-4 Trade & Exchange
- **FR-4.1** Users shall generate a trade QR code containing their "missing" and "repeated" lists.
- **FR-4.2** Scanning a friend's QR code shall compute the optimal trade: what I give (my repeated that they miss) vs. what I receive (their repeated that I miss).
- **FR-4.3** Upon confirming a trade, **both** users' collections shall update automatically via cloud sync.
- **FR-4.4** Trade history shall be persisted and visible.
- **FR-4.5** Optional: NFC tap-to-trade for nearby devices.

#### FR-5 Sharing & Export
- **FR-5.1** Users shall share their "missing" and "repeated" lists as plain text or image to any social app.
- **FR-5.2** The app shall export a printable PDF of missing/repeated stickers, including team flag icons (vector or emoji fallback).
- **FR-5.3** Export shall be free. PDF generation runs client-side to avoid server costs.

#### FR-6 Cloud Sync & Backup
- **FR-6.1** User data shall sync automatically to the cloud on every change.
- **FR-6.2** The app shall support **offline-first**: all reads/writes happen locally first, then sync in background.
- **FR-6.3** Conflict resolution shall use last-write-wins with optional manual merge UI.
- **FR-6.4** Users shall log in via **Sign in with Apple** (iOS) or **Sign in with Google** (Android).
- **FR-6.5** Anonymous/guest mode shall be supported with a one-time "link to account" migration flow.

#### FR-7 Widgets & Notifications
- **FR-7.1** Home screen widget (Android) / Lock Screen widget (iOS) showing album completion percentage.
- **FR-7.2** Push notification when a friend completes an album or when a new album is available.

#### FR-8 Album Lock
- **FR-8.1** Users shall lock the album screen to prevent accidental taps (e.g., long-press to unlock).

---

### 2.2 Non-Functional Requirements

#### NFR-1 Performance
- **NFR-1.1** Cold start < 1.5s on mid-range devices (Snapdragon 7-series / A13).
- **NFR-1.2** Sticker toggle latency < 50ms. No network call shall block the UI.
- **NFR-1.3** Albums with up to 800 stickers shall scroll at 60fps without jank.
- **NFR-1.4** OCR inference < 2s per batch on device.

#### NFR-2 Reliability & Stability
- **NFR-2.1** Crash-free rate target: > 99.9% (Firebase Crashlytics).
- **NFR-2.2** ANR-free rate target: > 99.95%.
- **NFR-2.3** All disk writes shall be atomic (SQLite transactions). No data corruption on app kill.

#### NFR-3 Offline-First
- **NFR-3.1** The app shall be fully usable with zero network connectivity.
- **NFR-3.2** Sync queue shall be resilient to app restarts and network changes.
- **NFR-3.3** Data stored locally shall be encrypted at rest using OS-level encryption (iOS Data Protection / Android EncryptedSharedPreferences + SQLCipher).

#### NFR-4 Security
- **NFR-4.1** All API communication over TLS 1.3.
- **NFR-4.2** OAuth 2.0 tokens shall be stored in OS secure enclaves (iOS Keychain / Android Keystore).
- **NFR-4.3** QR codes shall not expose raw user IDs; use short-lived signed JWTs or encoded opaque tokens.
- **NFR-4.4** Rate limiting on public APIs.

#### NFR-5 Accessibility
- **NFR-5.1** WCAG 2.1 AA compliance for color contrast, touch targets (min 48x48dp/pt), and screen reader labels.

#### NFR-6 Scalability (Backend)
- **NFR-6.1** Backend shall handle 100K MAU within 6 months without architecture changes.
- **NFR-6.2** Database queries shall be indexed; p99 read latency < 50ms.

---

## 3. Architecture Overview

### 3.1 High-Level Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT (Mobile)                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │   UI Layer   │  │  Domain/Biz  │  │   Data Layer         │ │
│  │  (Flutter)   │◄─┤    Logic     │◄─┤ - Local DB (SQLite)│ │
│  │              │  │  (Cubit/BLoC)  │  │ - Sync Engine        │ │
│  │  - AlbumView │  │              │  │ - OCR Engine (ML Kit)│ │
│  │  - ScanView  │  │  - Models    │  │ - PDF Generator      │ │
│  │  - TradeView │  │  - Use Cases │  │ - QR Generator       │ │
│  └──────────────┘  └──────────────┘  └──────────────────────┘ │
│         ▲                                              │        │
│         │              OS Services                       │        │
│         └────── Camera / Biometrics / Push / Widgets ───┘        │
└─────────────────────────────────────────────────────────────────┘
                              │ HTTPS/REST + WebSocket
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        BACKEND (Cloud)                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │  API Gateway │  │  App Server  │  │   Data Stores        │ │
│  │  (Cloudflare)│──┤  (Node/Fastify│──┤ - PostgreSQL (User   │ │
│  │              │  │   or Go/Gin)  │  │   data, Albums)      │ │
│  └──────────────┘  └──────────────┘  │ - Redis (Sessions,    │ │
│         ▲                              │   Sync Queue)        │ │
│         │                              │ - S3/Cloud Storage   │ │
│         │                              │   (Flag assets, PDFs)│ │
│         │                              └──────────────────────┘ │
│         │                              ┌──────────────────────┐ │
│         └──────────── Auth0 / Firebase─┤   Auth & Identity    │ │
│                    Auth               │   (Firebase Auth or   │ │
│                                       │    Auth0)              │ │
│                                       └──────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Technology Stack Recommendation

### 4.1 Option A: Flutter (Recommended)

| Layer | Technology | Justification |
|---|---|---|
| **Framework** | Flutter 3.24+ (Dart) | Single codebase for Android/iOS. Near-native performance via Skia/Impeller. Excellent camera plugin ecosystem. Hot reload for fast iteration. Strong community in LATAM. |
| **State Management** | `flutter_bloc` (Cubit) | Predictable, testable, scalable. Industry standard for production Flutter apps. |
| **Local DB** | `drift` (SQLite) or `isar` | Drift: type-safe SQL with migrations. Isar: faster NoSQL if schema stays simple. **Recommendation: Drift** for relational album structures. |
| **Sync** | Custom sync engine over REST + Firebase Cloud Messaging | REST for data. FCM for push-triggered sync ("your friend completed a trade"). |
| **Auth** | `firebase_auth` + `google_sign_in` + `sign_in_with_apple` | Covers both platforms. Anonymous auth supported. Free tier generous. |
| **OCR** | Google ML Kit `text_recognition` | On-device, free, works offline. Supports Latin script well. |
| **PDF** | `pdf` package (Dart) | Pure Dart, generates PDFs client-side. Zero server cost. Full vector flag support. |
| **QR** | `qr_flutter` + `mobile_scanner` | Generate and scan QR codes. `mobile_scanner` uses ML Kit under the hood, fast and reliable. |
| **Widgets** | `home_widget` | Cross-platform home screen widgets. |
| **Backend** | Node.js (Fastify) or Go (Gin) + PostgreSQL + Redis | Fastify for DX and ecosystem. Go for raw performance and lower memory. |
| **Hosting** | Railway / Render / Fly.io | Cost-effective for MVP. Scale to AWS/GCP later. |
| **CI/CD** | GitHub Actions + Codemagic / GitHub Actions | Automated builds, tests, and deployment to Play Store / App Store. |

### 4.2 Option B: Kotlin Multiplatform (Compose Multiplatform)

| Layer | Technology | Justification |
|---|---|---|
| **Shared Logic** | Kotlin Multiplatform | Share domain, data, and sync logic. Write UI per platform (Compose for Android, SwiftUI for iOS) or shared with Compose Multiplatform. |
| **Android UI** | Jetpack Compose | Native, first-class. |
| **iOS UI** | SwiftUI | Native, best iOS integration (widgets, lock screen, Apple ecosystem). |
| **Local DB** | SQLDelight (KMP) | Type-safe SQL, shared between platforms. |
| **Sync / Auth** | Ktor client + Firebase SDKs | KMP-compatible networking. Firebase KMP SDK is experimental but improving. |
| **OCR** | ML Kit (Android) / Vision (iOS) | Platform-native, best performance. Requires expect/actual abstraction. |
| **Trade-off** | More native fidelity, but higher dev cost and two UI codebases (unless Compose Multiplatform). |

### 4.3 Decision Matrix

| Criteria | Flutter | KMP + Native UI |
|---|---|---|
| Time to MVP | ⭐⭐⭐ Fast | ⭐⭐ Slower |
| Team size needed | ⭐⭐⭐ Small (1-2 devs) | ⭐⭐ Medium (2-3 devs) |
| Native performance | ⭐⭐ Very good | ⭐⭐⭐ Native |
| iOS ecosystem integration | ⭐⭐ Good | ⭐⭐⭐ Excellent |
| OCR / Camera maturity | ⭐⭐⭐ Excellent plugins | ⭐⭐ Requires bridging |
| Widgets / Lock Screen | ⭐⭐ Supported | ⭐⭐⭐ First-class |
| Long-term maintenance | ⭐⭐⭐ One codebase | ⭐⭐ Two UIs to maintain |

**Verdict:** For a lean team targeting quick market entry with proven reliability, **Flutter (Option A)** is the recommended primary stack. If the team grows and iOS-native feel is critical, a migration path to KMP shared logic with native UIs can be evaluated later.

---

## 5. Data Model

### 5.1 Core Entities

```
User
├── id (UUID)
├── auth_provider (google | apple | anonymous)
├── email (nullable)
├── display_name
├── created_at
├── last_sync_at
└── albums[] → UserAlbum

UserAlbum (synced to cloud)
├── id (UUID)
├── user_id → User
├── album_template_id → AlbumTemplate
├── variant_id (e.g., "colombia-exclusive")
├── name (customizable, e.g., "Mi Mundial 2026")
├── stickers[] → UserSticker
├── completion_stats (derived: owned_count, missing_count, repeated_count, %)
├── created_at
└── updated_at

UserSticker
├── id (UUID)
├── user_album_id → UserAlbum
├── sticker_template_id → StickerTemplate
├── status (owned | missing | repeated)
├── repeated_count (int, default 1)
├── obtained_at (nullable)
└── updated_at

AlbumTemplate (server-managed, cached locally)
├── id (UUID)
├── name (e.g., "Mundial 2026")
├── publisher (e.g., "Panini")
├── total_stickers
├── sections[] → AlbumSection
└── variants[] → AlbumVariant

AlbumSection
├── id
├── album_template_id
├── name (e.g., "Equipo Argentina", "Historia de los Mundiales")
├── sort_order
└── stickers[] → StickerTemplate

StickerTemplate
├── id
├── section_id
├── number (string, e.g., "ARG1", "00", "FWC1")
├── player_name (nullable)
├── team_name (nullable)
├── type (standard | shiny | golden | special)
├── image_url (nullable, for UI enrichment)
└── sort_order

AlbumVariant
├── id
├── album_template_id
├── name (e.g., "Edición Colombia")
├── region_code
├── section_modifications (JSON: add/remove/modify sections)
└── total_stickers

TradeSession
├── id (UUID)
├── initiator_user_id → User
├── responder_user_id → User
├── initiator_offered[] (UserSticker IDs)
├── responder_offered[] (UserSticker IDs)
├── status (pending | accepted | rejected | cancelled)
├── qr_payload (signed JWT, short-lived)
├── created_at
└── resolved_at
```

### 5.2 Local Database Schema (SQLite / Drift)

```sql
-- Albums cached from server
CREATE TABLE album_templates (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    publisher TEXT,
    total_stickers INTEGER NOT NULL,
    json_data TEXT NOT NULL, -- full JSON for flexibility
    downloaded_at INTEGER NOT NULL
);

-- User's active albums
CREATE TABLE user_albums (
    id TEXT PRIMARY KEY,
    server_id TEXT UNIQUE, -- nullable until synced
    album_template_id TEXT NOT NULL REFERENCES album_templates(id),
    variant_id TEXT,
    custom_name TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    sync_status TEXT NOT NULL -- pending | synced | conflict
);

-- Individual sticker state
CREATE TABLE user_stickers (
    id TEXT PRIMARY KEY,
    user_album_id TEXT NOT NULL REFERENCES user_albums(id),
    sticker_template_id TEXT NOT NULL,
    status TEXT NOT NULL CHECK(status IN ('owned', 'missing', 'repeated')),
    repeated_count INTEGER DEFAULT 1,
    updated_at INTEGER NOT NULL
);

CREATE INDEX idx_stickers_album ON user_stickers(user_album_id);
CREATE INDEX idx_stickers_status ON user_stickers(status);
```

---

## 6. Key Technical Flows

### 6.1 Offline-First Sync Flow

```
User taps sticker → Toggle in local DB → Queue sync task →
    IF online: POST /sync/batch → Server applies → Return server_timestamp →
    Update local sync_status = synced
    IF offline: Task stays in queue → Retry with exponential backoff
```

**Conflict Resolution:**
- Server maintains `updated_at` per `UserAlbum`.
- Client sends its `updated_at` with the batch.
- If server record is newer, return 409 with server state; client shows merge UI.
- Otherwise, server accepts and returns new timestamp.

### 6.2 Bidirectional QR Trade Flow

```
Alice (wants to trade):
  1. Opens Trade tab → App computes: her_missing ∩ friend_repeated
  2. Generates QR payload (signed JWT):
     { user_id: alice, missing: ["FWC1", "FWC2"], repeated: ["ARG5"], exp: 10min }
  3. Shows QR code.

Bob (scans QR):
  4. Scans → App decodes JWT → Computes match:
     Bob gives Alice: intersection(Bob.repeated, Alice.missing)
     Alice gives Bob: intersection(Alice.repeated, Bob.missing)
  5. Shows preview: "You give 3, you receive 2"
  6. Bob taps Confirm → App creates TradeSession →
     POST /trades with payload + Bob's auth token

Server:
  7. Validates JWT signature and expiry.
  8. Verifies both users' current sticker states.
  9. Atomically updates both UserAlbums in a transaction.
  10. Returns 200 + updated albums to Bob.
  11. Pushes FCM notification to Alice: "Trade completed with Bob!"

Alice:
  12. Receives push → Syncs → Album updates automatically.
```

> **Competitor's bug:** They only update the scanner. We update both atomically via the server.

### 6.3 OCR Batch Scan Flow

```
1. User opens Camera → Captures photo with multiple stickers visible.
2. App sends image to ML Kit Text Recognition (on-device).
3. App receives bounding boxes + raw text.
4. App filters candidates: regex "^\d{1,3}$" or "^[A-Z]{3}\d{1,2}$".
5. App maps candidate numbers to StickerTemplate entries in current album.
6. Bottom sheet appears: "Detected 5 stickers. Tap to review."
7. User confirms → Bulk insert into local DB → Sync queue.
```

---

## 7. Backend Architecture

### 7.1 API Design (REST + JSON)

```
POST   /auth/token          (exchange Firebase token for app JWT)
GET    /albums               (list available album templates)
GET    /albums/:id           (full album template with sections/stickers)
POST   /albums/:id/start     (user starts tracking an album)

POST   /sync/batch           (push local changes, get server state)
GET    /sync/state           (pull latest state for user)

POST   /trades               (initiate or accept trade)
GET    /trades               (trade history)
GET    /trades/:id           (trade detail)

GET    /users/me             (profile, stats)
GET    /users/me/albums      (all user albums with stats)

POST   /feedback             (user feedback, crash logs)
```

### 7.2 Infrastructure

| Component | Choice | Notes |
|---|---|---|
| API Server | Node.js (Fastify) | Type-safe with Zod validation. Fast startup. |
| Database | PostgreSQL 16 | Relational data. JSONB for flexible album/variant schemas. |
| Cache / Sessions | Redis 7 | Sync queues, rate limiting, session storage. |
| Object Storage | Cloudflare R2 / AWS S3 | Flag SVGs, sticker images, generated PDFs. |
| Auth | Firebase Auth | Handles OAuth providers, anonymous auth, token refresh. |
| Push | Firebase Cloud Messaging | Free, cross-platform. |
| Monitoring | Sentry + Prometheus/Grafana | Error tracking and metrics. |

### 7.3 Database Indexing Strategy

```sql
-- Sync queries
CREATE INDEX idx_user_albums_user ON user_albums(user_id, updated_at);
CREATE INDEX idx_user_stickers_album ON user_stickers(user_album_id, status);

-- Trade lookups
CREATE INDEX idx_trades_users ON trades(initiator_id, responder_id, status);

-- Album lookups
CREATE INDEX idx_stickers_template ON sticker_templates(section_id, sort_order);
CREATE INDEX idx_album_variants ON album_variants(album_template_id);
```

---

## 8. Mobile Architecture Details

### 8.1 Flutter Layered Architecture

```
lib/
├── main.dart
├── src/
│   ├── app.dart                      # MaterialApp / CupertinoApp, routes
│   ├── core/
│   │   ├── constants/                # App constants, theme
│   │   ├── errors/                   # Failure classes, exception handling
│   │   ├── network/                  # Dio config, interceptors, retry logic
│   │   └── usecases/                 # Base UseCase class
│   ├── features/
│   │   ├── album/
│   │   │   ├── data/
│   │   │   │   ├── models/           # DTOs (AlbumModel, StickerModel)
│   │   │   │   ├── repositories/     # AlbumRepositoryImpl
│   │   │   │   └── datasources/      # Local (Drift) + Remote (API)
│   │   │   ├── domain/
│   │   │   │   ├── entities/         # Pure domain objects (Album, Sticker)
│   │   │   │   ├── repositories/     # Abstract interfaces
│   │   │   │   └── usecases/         # GetAlbums, ToggleSticker, etc.
│   │   │   └── presentation/
│   │   │       ├── bloc/             # AlbumCubit, StickerGridCubit
│   │   │       ├── widgets/          # Reusable sticker cells
│   │   │       └── pages/            # AlbumPage, SectionPage
│   │   ├── scan/
│   │   ├── trade/
│   │   ├── export/
│   │   └── auth/
│   └── services/
│       ├── sync_service.dart         # Background sync engine
│       ├── pdf_service.dart          # PDF generation
│       ├── ocr_service.dart          # ML Kit wrapper
│       └── notification_service.dart # FCM handling
```

### 8.2 State Management Pattern

Use **Cubit** (simpler BLoC variant) for every feature:

```dart
// album_cubit.dart
class AlbumCubit extends Cubit<AlbumState> {
  final ToggleSticker _toggleSticker;
  final SyncService _syncService;

  Future<void> toggleSticker(String stickerId) async {
    emit(state.copyWith(status: AlbumStatus.updating));
    
    final result = await _toggleSticker(ToggleStickerParams(id: stickerId));
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (updatedAlbum) {
        emit(state.copyWith(album: updatedAlbum, status: AlbumStatus.success));
        _syncService.queue(stickerId); // non-blocking
      },
    );
  }
}
```

### 8.3 Critical Stability Measures

To prevent the competitor's #1 issue (crashes on tap):

1. **Immutable state**: Never mutate state objects; always emit new copies.
2. **Debounced writes**: If user rapidly taps 10 stickers, batch local DB writes.
3. **Graceful degradation**: If ML Kit OCR fails, fallback to manual input.
4. **Error boundaries**: Wrap every page in `ErrorBoundaryWidget` to prevent app crash on unhandled widget errors.
5. **Memory management**: Use `ListView.builder` (not `ListView`) for large sticker grids. Dispose camera controller immediately after scan.

---

## 9. Security & Privacy

| Concern | Mitigation |
|---|---|
| QR payload tampering | Sign JWTs with HS256, server-side secret. Short expiry (10 min). |
| Man-in-the-middle | Certificate pinning on API client. TLS 1.3 only. |
| Data at rest | SQLCipher for local DB. iOS Data Protection class `NSFileProtectionComplete`. |
| Anonymous auth abuse | Rate limit album creation. Require email verification for social features. |
| PII exposure | Store minimal PII. Pseudonymize user IDs in analytics. |

---

## 10. Monetization Strategy (Ethical)

| Tier | Price | Features |
|---|---|---|
| **Free** | $0 | Full album tracking, unlimited manual entry, PDF export, 50 stickers/day OCR, basic widgets, ads (optional rewarded only, NEVER interstitial). |
| **Pro** | $3.99/mo or $19.99/yr | Unlimited OCR, cloud sync, multi-device, advanced stats, priority album updates, no ads (even optional), custom album themes. |
| **Lifetime** | $49.99 one-time | All Pro features forever. |

**Ad Policy:**
- No interstitial ads.
- No banner ads during the core album interaction.
- Optional rewarded video for extra daily OCR scans (user-initiated).
- Strict ad provider vetting (Google AdMob only; block sensitive categories).

---

## 11. Implementation Roadmap

### Phase 1 — MVP Core (Weeks 1-4)
- [ ] Album template schema and local DB (Drift)
- [ ] Album browsing and sticker marking (tap/long-press)
- [ ] Stats dashboard
- [ ] Offline-first local experience (no cloud yet)
- [ ] PDF export (client-side)
- [ ] Android + iOS build pipelines

### Phase 2 — Cloud & Sync (Weeks 5-6)
- [ ] Firebase Auth (Google / Apple / Anonymous)
- [ ] Backend API (Fastify/Go + PostgreSQL)
- [ ] Sync engine (offline queue + conflict resolution)
- [ ] Multi-device testing

### Phase 3 — Social & Trade (Weeks 7-8)
- [ ] QR generation and scanning
- [ ] Bidirectional trade logic (server-side atomic)
- [ ] Share to social apps (text + image)
- [ ] Push notifications

### Phase 4 — Smart Features (Weeks 9-10)
- [ ] ML Kit OCR integration
- [ ] Batch scanning flow
- [ ] Search and filters (name, number, team)
- [ ] Dedicated "repetidas" management

### Phase 5 — Polish & Scale (Weeks 11-12)
- [ ] Home/Lock screen widgets
- [ ] Album variants support
- [ ] Accessibility audit
- [ ] Performance profiling (60fps target)
- [ ] Beta launch (TestFlight + Play Console Internal)

---

## 12. Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| OCR accuracy poor for low-quality stickers | High | Medium | Allow manual override. Use confidence threshold. Fallback to manual input. |
| Competitor patches their crashes quickly | Medium | High | Our moat is the holistic UX (cloud + OCR + trade + no abusive ads), not a single feature. |
| Backend costs spike at launch | Medium | Medium | Use serverless-friendly stack. Cache album templates aggressively. Client-side PDF generation. |
| Album publishers release variants we don't support | High | Medium | Build admin CMS for dynamic album onboarding. Community request system. |
| iOS App Store rejection for " sticker collection utility" | Low | Medium | Clear value prop. No gambling mechanics. Comply with all guidelines. |

---

## 13. Success Metrics

| Metric | Target (Month 3) |
|---|---|
| Crash-free users | > 99.9% |
| Day-1 retention | > 45% |
| Day-7 retention | > 25% |
| Cloud sync adoption | > 60% of users |
| Average review rating | > 4.7★ |
| OCR usage rate | > 30% of active users |
| Trade completion rate | > 70% of initiated trades |

---

## 14. Appendix

### A. Supported Albums (Launch)
- FIFA World Cup 2026 (Panini) — all regional variants
- Copa América 2026 (if applicable)
- Extensible to: NBA, Pokémon, local leagues

### B. Flag Asset Strategy
- Use open-source flag packs (e.g., `flag-icons` or `openmoji`).
- Store as SVGs in app bundle (offline) with CDN fallback.
- PDF generation embeds SVGs as vector paths for crisp printing.

### C. Open Source / Third-Party Dependencies (Flutter)
```yaml
dependencies:
  flutter_bloc: ^8.1.0
  drift: ^2.15.0
  sqlite3_flutter_libs: ^0.5.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0  # optional, for simple sync
  google_mlkit_text_recognition: ^0.11.0
  mobile_scanner: ^3.5.0
  pdf: ^3.10.0
  share_plus: ^7.2.0
  home_widget: ^0.13.0
  dio: ^5.4.0
  freezed_annotation: ^2.4.0
  json_serializable: ^6.7.0
```

---

*Document prepared by el Gentleman — Pi coding-agent harness.*
*For questions or revisions, open a discussion on this document.*
