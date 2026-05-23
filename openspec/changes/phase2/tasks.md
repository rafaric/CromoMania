# SDD Tasks — CromoManía 2026 Phase 2 (Firebase Auth + Cloud Sync)

**Change ID:** phase2  
**Document Version:** 1.0  
**Date:** 2026-05-23  
**Status:** Ready for Implementation

---

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~2,800 - 3,200 lines (new + modified) |
| 400-line budget risk | Medium |
| Chained PRs recommended | Yes |
| Suggested split | Foundation/Auth → Sync → Profile/Integration |
| Delivery strategy | ask-on-risk |
| Chain strategy | feature-branch-chain |

**Rationale:**  
- 40+ new files across 5 feature groups  
- Heavy integration work with existing Phase 1 codebase  
- Firebase + Firestore SDK complexity adds verification overhead  
- Recommend 3 PRs to keep each review under 400 lines

**Decision needed before apply:** Yes  
**Chained PRs recommended:** Yes  
**Chain strategy:** feature-branch-chain  
**400-line budget risk:** Medium

---

## Work Unit Overview

```
PR 1: Foundation + Auth
├── Group 1: Foundation (Firebase, Connectivity, DB)
└── Group 2: Auth (AuthCubit, FirebaseAuthService, AuthGatePage)

PR 2: Sync Engine
├── Group 3: Sync (SyncEngine, FirestoreRepo, SyncQueueTable)

PR 3: Profile + Integration
├── Group 4: Profile (UserProfileDrawer, ProfilePage)
└── Group 5: Integration (main.dart, app.dart wiring, CollectionCubit)
```

---

## Group 1: Foundation

**Objective:** Set up Firebase infrastructure, connectivity monitoring, and sync queue database table.

### Task 1.1: Add Firebase Dependencies

**File:** `pubspec.yaml`  
**Verification:** `flutter pub get` succeeds, no version conflicts

```yaml
# Add to dependencies section:
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
cloud_firestore: ^5.0.0
google_sign_in: ^6.2.0

# Add to dependencies section (if not present):
connectivity_plus: ^6.0.0
```

### Task 1.2: Create Firebase Configuration File

**File:** `lib/firebase_options.dart`  
**Verification:** File created with `DefaultFirebaseOptions` class matching `google-services.json`

```dart
// Implementation required:
// - DefaultFirebaseOptions class with platform-specific configs
// - Android: google-services.json values
// - iOS: GoogleService-Info.plist values (placeholder for Phase 3)
```

### Task 1.3: Configure Android for Firebase

**Files:** `android/app/build.gradle`, `android/app/google-services.json`  
**Verification:** `flutter build apk --debug` succeeds with Firebase initialized

**build.gradle changes:**
```groovy
plugins {
    id "com.google.gms.google-services" version "4.4.0" apply false
}

// Inside android {} block:
apply plugin: 'com.google.gms.google-services'
```

**google-services.json:**
- Place placeholder Firebase config (gitignored per security)
- Document SHA-1 setup requirement for physical device testing

### Task 1.4: Implement Connectivity Service

**File:** `lib/connectivity/connectivity_service.dart`  
**Verification:** Unit test verifies `isOnline` returns correct state; integration test verifies stream emits on connectivity change

```dart
// Required functionality:
// - Stream<ConnectivityResult> onConnectivityChanged
// - Future<bool> isOnline()
// - Proper subscription disposal
```

### Task 1.5: Add Sync Queue Table to Drift

**Files:** `lib/database/tables/sync_queue_table.dart`, `lib/database/app_database.dart`  
**Verification:** `build_runner` generates correct `.g.dart`; existing database migrations unaffected

**SyncQueueTable columns:**
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | autoIncrement |
| stickerId | TEXT | indexed |
| operation | TEXT | 'upsert' or 'delete' |
| payload | TEXT | JSON-encoded |
| retryCount | INTEGER | default 0 |
| status | TEXT | 'pending' |
| createdAt | DATETIME | |
| processedAt | DATETIME | nullable |

### Task 1.6: Create Sync Queue DAO

**File:** `lib/database/daos/sync_queue_dao.dart`  
**Verification:** Unit tests verify CRUD operations on sync_queue table

```dart
// Required methods:
// - Future<int> insert(SyncQueueTableCompanion)
// - Future<List<SyncQueueItem>> getPendingItems()
// - Future<void> markAsProcessed(int id)
// - Future<void> incrementRetry(int id)
// - Future<void> markAsFailed(int id, String error)
```

---

## Group 2: Auth Feature

**Objective:** Implement Firebase Authentication with Google Sign In, AuthCubit state management, and AuthGatePage UI.

### Task 2.1: Create User Profile Entity

**File:** `lib/auth/domain/entities/user_profile.dart`  
**Verification:** `dart analyze` passes; Equatable equality works correctly

```dart
// Properties:
// - uid: String
// - displayName: String?
// - email: String?
// - photoUrl: String?
// - createdAt: DateTime?
```

### Task 2.2: Define Auth Repository Interface

**File:** `lib/auth/domain/repositories/auth_repository.dart`  
**Verification:** Interface covers all auth operations; FirebaseAuthService implements it

```dart
// Required methods:
// - Stream<User?> get authStateChanges
// - Future<UserCredential> signInWithGoogle()
// - Future<void> signOut()
// - User? get currentUser
```

### Task 2.3: Implement FirebaseAuthService

**File:** `lib/auth/data/firebase_auth_service.dart`  
**Verification:** Unit tests mock GoogleSignIn and FirebaseAuth; integration test with real Firebase in debug

```dart
// Required functionality:
// - GoogleSignIn with email + profile scopes
// - signInWithGoogle() → UserCredential
// - signOut() clears both Google and Firebase
// - authStateChanges stream from FirebaseAuth
```

### Task 2.4: Define Auth States

**File:** `lib/auth/presentation/cubit/auth_state.dart`  
**Verification:** All states cover auth flow; transitions are logical

```dart
// States required:
// - AuthInitial
// - AuthLoading
// - AuthAuthenticated(User user)
// - AuthUnauthenticated
// - AuthError(String message)
```

### Task 2.5: Implement AuthCubit

**File:** `lib/auth/presentation/cubit/auth_cubit.dart`  
**Verification:** Unit tests verify state transitions; integration with Firebase works

```dart
// Required functionality:
// - Listen to authStateChanges on initialization
// - signInWithGoogle() → emit(AuthAuthenticated)
// - signOut() → emit(AuthUnauthenticated)
// - handleAuthException() for error states
```

### Task 2.6: Build Auth Gate Page

**File:** `lib/auth/presentation/pages/auth_gate_page.dart`  
**Verification:** UI matches spec; Google Sign In button triggers auth flow; error SnackBars display

**UI Requirements:**
- App logo centered
- Tagline text
- "Sign in with Google" button (primary style)
- Privacy policy link (optional)
- Loading state during authentication
- Error handling with SnackBar

---

## Group 3: Sync Engine

**Objective:** Implement offline-first sync engine with Firestore, sync queue processing, and conflict resolution.

### Task 3.1: Define Sync Queue Item Entity

**File:** `lib/sync/domain/sync_queue_item.dart`  
**Verification:** `dart analyze` passes; JSON serialization works

```dart
// Properties:
// - id: int?
// - stickerId: String
// - operation: SyncOperation ('upsert' | 'delete')
// - payload: Map<String, dynamic>
// - retryCount: int
// - status: SyncQueueStatus
// - createdAt: DateTime
// - processedAt: DateTime?
```

### Task 3.2: Define Sync Status Enum

**File:** `lib/sync/domain/sync_status.dart`  
**Verification:** All status states present; to/from string methods work

```dart
// Status values:
// - idle
// - syncing
// - synced
// - offline
// - error
```

### Task 3.3: Implement Firestore Repository

**File:** `lib/sync/data/firestore_repository.dart`  
**Verification:** Unit tests mock Firestore; integration test verifies actual Firestore operations

```dart
// Required methods:
// - Future<void> upsertSticker(String uid, String stickerId, Map data)
// - Future<void> deleteSticker(String uid, String stickerId)
// - Future<Map<String, dynamic>?> getSticker(String uid, String stickerId)
// - Future<Map<String, dynamic>> getAllStickers(String uid)
// - Stream<QuerySnapshot> watchStickers(String uid)
```

### Task 3.4: Implement Sync Queue Repository

**File:** `lib/sync/data/sync_queue_repository_impl.dart`  
**Verification:** Unit tests verify queue operations

```dart
// Required methods:
// - Future<int> addToQueue(SyncQueueItem)
// - Future<List<SyncQueueItem>> getPendingItems()
// - Future<void> markAsProcessed(int id)
// - Future<void> incrementRetry(int id)
// - Future<void> markAsFailed(int id, String error)
```

### Task 3.5: Implement Sync Engine

**File:** `lib/sync/domain/sync_engine.dart`  
**Verification:** Unit tests mock all dependencies; integration test with real Firestore

**Core functionality:**
```dart
// Required methods:
// - Future<void> initialize(String uid) → setup listeners
// - Future<void> queueChange(String stickerId, Map payload)
// - Future<void> _processSyncQueue()
// - Future<void> _onRemoteChange(QuerySnapshot)
// - void dispose() → cancel subscriptions

// Conflict resolution:
// - Compare updatedAt timestamps
// - Last-write-wins strategy
```

### Task 3.6: Define Sync States

**File:** `lib/sync/presentation/cubit/sync_state.dart`  
**Verification:** All sync states cover UI needs

```dart
// States required:
// - SyncInitial
// - SyncIdle
// - SyncSyncing(int pendingCount)
// - SyncSynced(DateTime lastSyncedAt)
// - SyncOffline(int pendingCount)
// - SyncError(String message)
```

### Task 3.7: Implement SyncCubit

**File:** `lib/sync/presentation/cubit/sync_cubit.dart`  
**Verification:** Unit tests verify state transitions; UI receives correct updates

```dart
// Required functionality:
// - SyncEngine injected via constructor
// - Update state on sync events
// - Expose syncStatus for UI binding
```

### Task 3.8: Create Firestore Security Rules

**File:** `firestore.rules`  
**Verification:** Firebase CLI validates rules; test authentication scenario

```javascript
// Rules: User can only read/write their own /users/{uid}/stickers
// Initially permissive; document Phase 3 hardening plan
```

---

## Group 4: Profile Feature

**Objective:** Display authenticated user info, sync status, and provide navigation to settings/export/sign-out.

### Task 4.1: Build User Profile Drawer Widget

**File:** `lib/profile/presentation/widgets/user_profile_drawer.dart`  
**Verification:** UI matches spec layout; avatar displays correctly; drawer slides properly

**UI Components:**
- Close button (X) in header
- Circular avatar (64dp) with CachedNetworkImage
- Display name (bold, 16sp)
- Email (secondary, 14sp)
- Sync status card with icon
- Action items (Settings, Export, Stats)
- Sign Out button (destructive style)

**Avatar Fallback:**
- Initials from displayName
- Background color from name hash
- Graceful error handling for image load failure

### Task 4.2: Build Profile Page

**File:** `lib/profile/presentation/pages/profile_page.dart`  
**Verification:** Page renders user data; navigation works to/from drawer

```dart
// Container page for drawer content
// Wraps UserProfileDrawer
```

### Task 4.3: Create Sign Out Confirmation Dialog

**File:** `lib/profile/presentation/widgets/sign_out_dialog.dart`  
**Verification:** Dialog displays correctly; cancel/dismiss behavior works

---

## Group 5: Integration

**Objective:** Wire Phase 2 components into existing app architecture; update main.dart, app.dart, and CollectionCubit.

### Task 5.1: Update Main.dart with Firebase Init

**File:** `lib/main.dart`  
**Verification:** App cold-starts with Firebase initialized before runApp()

**Required changes:**
```dart
// 1. await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
// 2. await DatabaseInstance.initialize()
// 3. Register RepositoryProviders
// 4. Register BlocProviders (AuthCubit, SyncCubit, existing cubits)
// 5. runApp() with AuthGate
```

### Task 5.2: Update App.dart with BlocProviders

**File:** `lib/app.dart`  
**Verification:** AuthGatePage shown for unauthenticated users; MainAppShell shown for authenticated

**Required providers:**
- AuthCubit (reads auth state)
- SyncCubit (manages sync status)
- Existing AlbumCubit, CollectionCubit, StatsCubit

### Task 5.3: Create Main App Shell

**File:** `lib/app_shell.dart`  
**Verification:** Scaffold with AppBar containing profile drawer trigger; existing pages accessible

**Structure:**
```dart
// Scaffold with:
// - AppBar: App title, profile avatar button
// - Drawer: UserProfileDrawer
// - Body: Navigator with existing routes
```

### Task 5.4: Update CollectionCubit Integration

**File:** `lib/features/collection/presentation/cubit/collection_cubit.dart`  
**Verification:** Collection changes trigger SyncEngine.queueChange(); UI updates immediately from local DB

**Required changes:**
```dart
// On state change (sticker tapped):
// 1. Update local Drift DB (existing behavior)
// 2. Call SyncEngine.queueChange() if user authenticated
// 3. UI updates from local DB (immediate)
```

### Task 5.5: Update Collection Page with Profile Drawer

**File:** `lib/features/collection/presentation/pages/collection_page.dart`  
**Verification:** AppBar shows profile drawer trigger; drawer accessible

### Task 5.6: Add Navigation Route for Auth Gate

**File:** `lib/router.dart`  
**Verification:** `/` routes to AuthGatePage when not authenticated; navigates to AppShell when authenticated

### Task 5.7: End-to-End Integration Test

**Files:** `test/integration/phase2_integration_test.dart`  
**Verification:** All scenarios from spec pass

**Test scenarios:**
1. Cold start → AuthGatePage shown
2. Sign in → Home shown
3. Mark sticker owned → Firestore updated
4. Sign out → AuthGatePage shown
5. Offline mark sticker → Sync when online
6. Conflict resolution (last-write-wins)

---

## Verification Checklist

### Unit Tests Required

| Component | Test Coverage |
|-----------|---------------|
| `FirebaseAuthService` | signIn, signOut, authState stream |
| `SyncEngine` | queueChange, processQueue, conflict resolution |
| `SyncQueueDao` | CRUD operations |
| `AuthCubit` | All state transitions |
| `SyncCubit` | All state transitions |
| `UserProfileDrawer` | Avatar fallback, sign out dialog |

### Integration Tests Required

| Scenario | Verification Method |
|----------|---------------------|
| Firebase init on cold start | Debug APK build + manual test |
| Google Sign In flow | Physical device or emulator test |
| Firestore sync | Firestore console verification |
| Offline → Online sync | Airplane mode + enable wifi |
| Multi-device sync | Two devices signed in, modify same sticker |

### Manual Verification Checklist

- [ ] `flutter build apk --debug` succeeds
- [ ] SHA-1 documented for physical device testing
- [ ] google-services.json gitignored
- [ ] Auth state persists across app restart
- [ ] Profile drawer displays correct user info
- [ ] Sign out clears session completely
- [ ] Sync status indicator updates correctly
- [ ] No crashes in airplane mode
- [ ] All Phase 1 features still work (regression)

---

## Dependency Graph

```
Group 1 (Foundation)
├── Task 1.1 → 1.2 → 1.3 → 1.4 → 1.5 → 1.6
└── PREREQUISITE: None

Group 2 (Auth) [Depends on Group 1]
├── Task 2.1 → 2.2 → 2.3 → 2.4 → 2.5 → 2.6
└── PREREQUISITE: Tasks 1.1, 1.2, 1.3 complete

Group 3 (Sync) [Depends on Group 1]
├── Task 3.1 → 3.2 → 3.3 → 3.4 → 3.5 → 3.6 → 3.7 → 3.8
└── PREREQUISITE: Tasks 1.4, 1.5, 1.6 complete

Group 4 (Profile) [Depends on Group 2]
├── Task 4.1 → 4.2 → 4.3
└── PREREQUISITE: Task 2.5, 2.6 complete

Group 5 (Integration) [Depends on Groups 2, 3, 4]
├── Task 5.1 → 5.2 → 5.3 → 5.4 → 5.5 → 5.6 → 5.7
└── PREREQUISITE: Tasks 2.6, 3.7, 4.1 complete
```

---

## File Manifest

### New Files (46 files)

**Foundation (6):**
- `lib/firebase_options.dart`
- `lib/connectivity/connectivity_service.dart`
- `lib/database/tables/sync_queue_table.dart`
- `lib/database/daos/sync_queue_dao.dart`
- `android/app/google-services.json`
- `firestore.rules`

**Auth (6):**
- `lib/auth/domain/entities/user_profile.dart`
- `lib/auth/domain/repositories/auth_repository.dart`
- `lib/auth/data/firebase_auth_service.dart`
- `lib/auth/presentation/cubit/auth_state.dart`
- `lib/auth/presentation/cubit/auth_cubit.dart`
- `lib/auth/presentation/pages/auth_gate_page.dart`

**Sync (8):**
- `lib/sync/domain/sync_queue_item.dart`
- `lib/sync/domain/sync_status.dart`
- `lib/sync/data/firestore_repository.dart`
- `lib/sync/data/sync_queue_repository_impl.dart`
- `lib/sync/domain/sync_engine.dart`
- `lib/sync/presentation/cubit/sync_state.dart`
- `lib/sync/presentation/cubit/sync_cubit.dart`
- `test/sync/sync_engine_test.dart`

**Profile (3):**
- `lib/profile/presentation/widgets/user_profile_drawer.dart`
- `lib/profile/presentation/pages/profile_page.dart`
- `lib/profile/presentation/widgets/sign_out_dialog.dart`

**Integration (5):**
- `lib/app_shell.dart`
- `test/integration/phase2_integration_test.dart`
- (Modified files: main.dart, app.dart, router.dart, collection_cubit.dart, collection_page.dart)

### Modified Files (5 files)

| File | Modification Type |
|------|-------------------|
| `pubspec.yaml` | Add Firebase + connectivity packages |
| `android/app/build.gradle` | Add google-services plugin |
| `lib/main.dart` | Firebase init, provider setup |
| `lib/app.dart` | BlocProvider additions |
| `lib/features/collection/presentation/cubit/collection_cubit.dart` | Sync integration |

---

## Risk Mitigation Notes

| Risk | Mitigation | Verification |
|------|------------|--------------|
| SHA-1 missing for physical devices | Document setup; works on emulator | Add README section |
| Sync conflicts on rapid taps | Local-first queue; debounce if needed | Stress test with multiple taps |
| Firestore quota exceeded | Implement batch writes; retry logic | Monitor Firebase console |
| Offline data loss | Sync queue persists; best-effort sync | Airplane mode tests |
| Auth state persistence | Use authStateChanges stream | Restart app test |

---

*Tasks authored 2026-05-23 for CromoManía 2026 Phase 2*  
*Status: Ready for supervisor review*
