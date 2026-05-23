# Proposal — CromoManía 2026 Phase 2

## Intent

Add Firebase Authentication (Google Sign In) and Cloud Firestore sync to enable multi-device support and cloud backup for the CromoManía sticker collector app. Phase 2 transforms the existing offline-first MVP into a cloud-connected experience where users can sign in with their Google account and their collection automatically syncs across devices.

**Why this matters:** Phase 1 delivered a solid offline experience, but users need cloud backup to protect their collection progress and multi-device sync to manage stickers from their phone, tablet, or desktop. Firebase + Firestore provides the simplest path to achieve this without building custom backend infrastructure.

---

## Scope

### In Scope

| Feature | Description |
|---------|-------------|
| **Firebase Auth** | Google Sign In integration with Firebase Auth SDK |
| **User Profile** | Display Google user info (name, email, avatar) |
| **Firestore Schema** | User subcollections for sticker collection data |
| **Sync Engine** | Offline-first queue with automatic background sync |
| **Multi-Device Sync** | Real-time collection sync via Firestore listeners |
| **Auth State Persistence** | Remember sign-in across app restarts |

### Out of Scope (Phase 3+)

| Feature | Deferred To |
|---------|-------------|
| Apple Sign In | Phase 3 |
| QR Trade System | Phase 3 |
| Push Notifications | Phase 3 |
| OCR Batch Scanning | Phase 3 |
| Home Screen Widgets | Phase 3 |
| Manual conflict resolution UI | Phase 4+ |
| Anonymous auth fallback | Deferred |

---

## Capabilities

### Capability: Firebase Auth with Google Sign In

**Solution:**
Integrate Firebase Auth with Google Sign In for seamless authentication.

**Auth Flow:**

```
┌─────────────────────────────────────────────────────────────────┐
│                      App Launch                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐     ┌─────────────────┐                   │
│  │ Firebase Auth   │────▶│ Check AuthState │                   │
│  │ Initialize      │     │                 │                   │
│  └─────────────────┘     └────────┬────────┘                   │
│                                    │                             │
│                          ┌─────────▼─────────┐                 │
│                          │ User signed in?   │                 │
│                          └─────────┬─────────┘                 │
│                      Yes            │            No             │
│                 ┌────────┐          │      ┌────────────┐      │
│                 │ Load   │          │      │ Show Auth  │      │
│                 │ from   │          │      │ Screen     │      │
│                 │ Firestore│◀────────┤      │            │      │
│                 └────────┘          │      │ ┌────────┐ │      │
│                          ┌─────────▼────────▼────────┐│       │
│                          │ User taps "Sign in with    ││       │
│                          │ Google" button            ││       │
│                          └─────────┬──────────────────┘│       │
│                                    │                        │
│                          ┌─────────▼─────────┐             │
│                          │ Google Sign In     │             │
│                          │ Consent Dialog     │             │
│                          └─────────┬─────────┘             │
│                                    │                          │
│                          ┌─────────▼─────────┐             │
│                          │ Firebase Auth      │             │
│                          │ returns User object│             │
│                          └─────────┬─────────┘             │
│                                    │                          │
│                          ┌─────────▼─────────┐             │
│                          │ Fetch/Create      │             │
│                          │ Firestore user doc│             │
│                          └─────────┬─────────┘             │
│                                    │                          │
│                          ┌─────────▼─────────┐             │
│                          │ Navigate to Home   │             │
│                          │ Load collection    │             │
│                          └───────────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

**Implementation:**

```dart
// auth/firebase_auth_service.dart
class FirebaseAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  FirebaseAuth get _auth => FirebaseAuth.instance;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  Future<UserCredential> signInWithGoogle() async {
    // Trigger Google Sign In flow
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw AuthException('Google sign-in cancelled');
    }
    
    // Obtain auth credentials from Google
    final googleAuth = await googleUser.authentication;
    
    // Sign in to Firebase with Google credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    return await _auth.signInWithCredential(credential);
  }
  
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
  
  User? get currentUser => _auth.currentUser;
}
```

**UI Screens:**

1. **Auth Gate Screen** (`auth_gate_page.dart`)
   - App logo and tagline
   - "Sign in with Google" button (Firebase UI style)
   - Privacy policy link
   - Skip option (loads offline/anonymous mode)

2. **Profile Drawer** (added to main navigation)
   - User avatar (circular, 64dp)
   - Display name
   - Email address
   - "Sign Out" button
   - Sync status indicator

---

### Capability: Cloud Firestore Sync Engine

**Solution:**
Implement an offline-first sync engine that queues local changes and pushes to Firestore when online, with automatic conflict resolution via last-write-wins.

**Firestore Schema:**

```
firestore/
└── users/
    └── {uid}/
        ├── profile/           # User metadata
        │   ├── displayName: string
        │   ├── email: string
        │   ├── photoUrl: string
        │   ├── createdAt: timestamp
        │   └── lastSyncedAt: timestamp
        │
        └── stickers/          # Sticker collection data
            └── {stickerId}/
                ├── status: 'owned' | 'repeated' | 'missing'
                ├── count: number
                ├── updatedAt: timestamp
                └── source: 'local' | 'remote' | 'sync'
```

**Sync Architecture:**

```
┌─────────────────────────────────────────────────────────────────┐
│                      Application Layer                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────┐    ┌───────────────┐    ┌───────────────┐   │
│  │ Collection    │───▶│ SyncEngine    │───▶│ Firestore     │   │
│  │ Cubit         │◀───│               │◀───│ Repository    │   │
│  └───────────────┘    └───────────────┘    └───────────────┘   │
│         │                    │                    │            │
│         │              ┌─────▼─────┐              │            │
│         │              │ Sync Queue│              │            │
│         │              │ (Drift)   │              │            │
│         │              └─────┬─────┘              │            │
│         │                    │                    │            │
└─────────┼────────────────────┼────────────────────┼────────────┘
          │                    │                    │
          ▼                    ▼                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Data Layer                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────┐              ┌───────────────┐             │
│  │ Drift DB      │              │ Cloud Firestore│             │
│  │ (Local)       │◀────────────▶│ (Remote)      │             │
│  └───────────────┘     Sync     └───────────────┘             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Sync Queue Table (Drift):**

```dart
// database/tables/sync_queue_table.dart
class SyncQueueTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get stickerId => text()();
  TextColumn get operation => text()(); // 'upsert' | 'delete'
  TextColumn get payload => text()(); // JSON payload
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get processedAt => dateTime().nullable()();
}
```

**Sync Engine Logic:**

```dart
// sync/sync_engine.dart
class SyncEngine {
  final FirebaseFirestore _firestore;
  final SyncRepository _syncRepo;
  final CollectionRepository _collectionRepo;
  final ConnectivityService _connectivity;
  
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _firestoreSubscription;
  
  /// Initialize sync engine - start listening for changes
  Future<void> initialize(String uid) async {
    _uid = uid;
    
    // Start connectivity listener
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) _processSyncQueue();
    });
    
    // Listen to Firestore remote changes
    _firestoreSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('stickers')
        .snapshots()
        .listen(_onRemoteChange);
    
    // Initial sync from cloud to local
    await _pullFromCloud();
  }
  
  /// Queue local change for sync
  Future<void> queueChange({
    required String stickerId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    // 1. Write to local Drift DB immediately
    await _collectionRepo.updateStickerStatus(stickerId, payload);
    
    // 2. Queue for cloud sync
    await _syncRepo.addToQueue(SyncQueueItem(
      stickerId: stickerId,
      operation: operation,
      payload: jsonEncode(payload),
      createdAt: DateTime.now(),
      status: 'pending',
    ));
    
    // 3. Try to sync immediately if online
    if (await _connectivity.isOnline) {
      await _processSyncQueue();
    }
  }
  
  /// Process pending sync queue
  Future<void> _processSyncQueue() async {
    final pendingItems = await _syncRepo.getPendingItems();
    
    for (final item in pendingItems) {
      try {
        await _pushToCloud(item);
        await _syncRepo.markAsProcessed(item.id);
      } on FirebaseException catch (e) {
        if (e.code == 'unavailable') {
          // Network issue - will retry later
          await _syncRepo.incrementRetry(item.id);
        } else {
          // Log error, keep in queue for manual review
          await _syncRepo.markAsFailed(item.id, e.message);
        }
      }
    }
  }
  
  /// Handle remote changes from Firestore
  Future<void> _onRemoteChange(QuerySnapshot snapshot) async {
    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified) {
        final remoteData = change.doc.data()!;
        final localData = await _collectionRepo.getStickerStatus(change.doc.id);
        
        // Last-write-wins conflict resolution
        if (localData == null || 
            remoteData['updatedAt'].toDate().isAfter(localData.updatedAt)) {
          // Remote wins - update local
          await _collectionRepo.updateStickerStatus(
            change.doc.id, 
            remoteData,
            source: 'remote',
          );
        }
        // else: Local wins - already in queue, will sync to cloud
      }
    }
  }
  
  /// Pull all user data from cloud on first sign-in
  Future<void> _pullFromCloud() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('stickers')
        .get();
    
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final localStatus = await _collectionRepo.getStickerStatus(doc.id);
      
      if (localStatus == null) {
        // New sticker from cloud - save locally
        await _collectionRepo.insertStickerStatus(doc.id, data);
      } else if (data['updatedAt'].toDate().isAfter(localStatus.updatedAt)) {
        // Cloud is newer - update local
        await _collectionRepo.updateStickerStatus(doc.id, data, source: 'remote');
      }
      // else: Local is newer or same - keep local
    }
  }
  
  void dispose() {
    _connectivitySubscription?.cancel();
    _firestoreSubscription?.cancel();
  }
}
```

**Conflict Resolution Strategy:**

| Scenario | Resolution | Rationale |
|----------|------------|-----------|
| Local newer than remote | Keep local, push to cloud | User's most recent interaction wins |
| Remote newer than local | Pull from cloud, update local | Other device's change wins |
| Both same timestamp | Keep local | First write in local queue wins |
| Network offline | Queue locally, sync when online | Offline-first guarantee |

**Timestamp Resolution:**
```dart
// Use server timestamp for Firestore (more reliable than local)
final serverTimestamp = FieldValue.serverTimestamp();

// Compare with local DateTime
// Firestore Timestamp → DateTime via .toDate()
```

---

### Capability: User Profile Display

**Solution:**
Display Google user information in a drawer accessible from all main screens.

**Profile Drawer UI:**

```
┌────────────────────────────────┐
│  ╳  Close                      │
├────────────────────────────────┤
│                                │
│        ┌──────────┐            │
│        │  (◉)     │  ← Avatar  │
│        │  64x64   │            │
│        └──────────┘            │
│                                │
│   Juan Pérez                   │
│   juan@email.com               │
│                                │
├────────────────────────────────┤
│                                │
│  ☁️ Sync Status                │
│  ┌──────────────────────────┐ │
│  │ ✓ Synced 2 min ago       │ │
│  │ 428 stickers backed up   │ │
│  └──────────────────────────┘ │
│                                │
├────────────────────────────────┤
│                                │
│  ⚙️ Settings                   │
│  📤 Export Collection          │
│  📊 Statistics                │
│                                │
├────────────────────────────────┤
│                                │
│  🚪 Sign Out                   │
│                                │
└────────────────────────────────┘
```

---

## Affected Areas

### New Files (Phase 2)

```
lib/
├── main.dart                           # Firebase init, auth gate
├── firebase_options.dart              # Firebase config file
├── auth/
│   ├── data/
│   │   └── firebase_auth_service.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   └── user_profile.dart
│   │   └── repositories/
│   │       └── auth_repository.dart
│   └── presentation/
│       ├── cubit/
│       │   ├── auth_cubit.dart
│       │   └── auth_state.dart
│       └── pages/
│           └── auth_gate_page.dart
├── sync/
│   ├── data/
│   │   ├── firestore_repository.dart
│   │   └── sync_repository_impl.dart
│   ├── domain/
│   │   ├── sync_engine.dart
│   │   ├── sync_queue_item.dart
│   │   └── sync_status.dart
│   └── presentation/
│       └── cubit/
│           └── sync_cubit.dart
├── profile/
│   └── presentation/
│       ├── pages/
│       │   └── profile_page.dart
│       └── widgets/
│           └── user_profile_drawer.dart
├── connectivity/
│   └── connectivity_service.dart      # Network monitoring
└── database/
    └── tables/
        └── sync_queue_table.dart     # Sync queue persistence
```

### Modified Files

| File | Changes |
|------|---------|
| `pubspec.yaml` | Add `firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in`, `connectivity_plus` |
| `android/app/build.gradle` | Add Google Services plugin, SHA-1 placeholder comment |
| `android/app/google-services.json` | Placeholder Firebase config (gitignored) |
| `lib/main.dart` | Add Firebase init, AuthCubit provider, sync engine init |
| `lib/database/app_database.dart` | Add SyncQueueTable, SyncQueueDao |
| `lib/features/collection/presentation/cubit/collection_cubit.dart` | Integrate sync engine on state changes |
| `lib/features/collection/presentation/pages/collection_page.dart` | Add profile drawer |
| `lib/app.dart` | Add BlocProvider for AuthCubit, SyncCubit |

### File Deletions (None for Phase 2)

Phase 2 is purely additive - no existing files are deleted.

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Google Sign In without SHA-1 | High | Low | Works on emulators; document SHA-1 setup for physical devices |
| Sync conflicts | Medium | Medium | Last-write-wins by default; implement timestamp comparison |
| Firestore security rules misconfigured | Medium | High | Start with permissive rules (authenticated read/write); secure in Phase 3 |
| Offline sync reliability | Medium | Medium | Test with airplane mode; implement exponential backoff for retries |
| Firebase dependency on network | Low | High | Offline-first queue ensures local-first; cloud sync is best-effort |
| User data growing large | Low | Low | Firestore subcollections scale naturally; implement pagination if needed |
| Auth state persistence issues | Low | Medium | Use `authStateChanges()` stream; verify token refresh on app resume |
| Race conditions on rapid tap | Medium | Low | Queue changes locally; debounce sync calls if needed |

### SHA-1 Configuration Note

```bash
# Current limitation: Physical device testing requires SHA-1 fingerprint
# Until SHA-1 is configured in Firebase Console:
# - Development: Works on Android emulators
# - Physical devices: Sign-in will fail with DeveloperError

# To configure SHA-1 (post-Phase 2):
1. Generate fingerprint: keytool -list -v -keystore ~/.android/debug.keystore
2. Add SHA-1 to Firebase Console > Project Settings > Android app
3. Download updated google-services.json
4. Rebuild APK
```

---

## Rollback

**If Phase 2 fails or needs reversal:**

### Option 1: Git Revert (Recommended)

```bash
# Revert all Phase 2 changes
git revert HEAD

# Or revert specific features
git revert <commit-hash-for-feature>
```

### Option 2: Feature Flag (Forward-Compatible)

```dart
// In main.dart
if (AppConfig.enableCloudSync && Firebase.ready) {
  // Phase 2 behavior
  runApp(CloudConnectedApp());
} else {
  // Phase 1 behavior (offline-only)
  runApp(OfflineApp());
}
```

### Option 3: Partial Rollback via Feature Flags

| Component | Feature Flag | Default |
|-----------|--------------|---------|
| Firebase Auth | `enableFirebaseAuth` | `true` |
| Cloud Sync | `enableCloudSync` | `true` |
| Firestore | `enableFirestore` | `true` |

### Rollback Sequence

1. **Before Code Changes:** Tag as `rollback-point/phase2-start`
2. **After Auth Integration:** Tag as `rollback-point/phase2-auth-complete`
3. **After Sync Engine:** Tag as `rollback-point/phase2-sync-complete`
4. **After Testing:** Tag as `phase2-complete`

### Data Migration Considerations

- **No schema migrations needed** - Phase 2 adds new tables, doesn't modify existing ones
- **Sync queue is recoverable** - Pending sync items can be reprocessed after rollback
- **Firestore data persists** - Users can sign in again after rollback to recover cloud data

---

## Success Criteria

### Functional Acceptance

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| F1 | User can sign in with Google account | Tap "Sign in with Google", complete auth flow |
| F2 | Authenticated user profile shows name and email | Verify profile drawer displays correct info |
| F3 | User can sign out | Tap sign out, verify redirect to auth screen |
| F4 | Collection data syncs to Firestore on change | Add sticker, verify Firestore document updated |
| F5 | App loads user collection from Firestore on sign-in | Sign in on new device, verify collection loads |
| F6 | App works offline (no network) | Enable airplane mode, tap stickers, verify local DB updated |
| F7 | Offline changes sync when connection restored | Tap offline, enable wifi, verify sync completes |
| F8 | No data loss on conflict (last-write-wins) | Modify sticker on two devices, verify latest change wins |
| F9 | Sync status indicator shows accurate state | Verify sync indicator updates during sync |
| F10 | Auth state persists across app restarts | Close app, reopen, verify still signed in |

### Non-Functional Acceptance

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| N1 | Debug APK builds successfully | `flutter build apk --debug` completes without errors |
| N2 | Firebase Auth initializes without crashes | Cold start with network available |
| N3 | Offline tap < 50ms latency | Tap sticker offline, verify UI updates immediately |
| N4 | Sync completes within 5 seconds for single change | Time from tap to Firestore write |
| N5 | Memory usage < 200MB with sync enabled | Android Studio profiler |
| N6 | No crashes on airplane mode + sign-in attempt | Try sign-in offline, verify graceful error |

### Architecture Quality

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| A1 | Firebase initialization in `main()` before `runApp` | Code review |
| A2 | Auth state managed via Cubit stream | `authStateChanges()` wired to AuthCubit |
| A3 | Sync engine decoupled from UI layer | SyncEngine has no Flutter dependencies |
| A4 | Firestore operations use batch writes where possible | Review sync queue processing |
| A5 | Connectivity service provides reactive stream | `onConnectivityChanged` properly subscribed |

---

## Dependencies

### Pub Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  google_sign_in: ^6.2.0
  
  # Connectivity
  connectivity_plus: ^6.0.0
  
  # State Management (from Phase 1)
  flutter_bloc: ^8.1.0
  equatable: ^2.0.0
  
  # Local DB (from Phase 1)
  drift: ^2.16.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  drift_dev: ^2.16.0
  build_runner: ^2.4.0
  google_fonts: ^6.1.0
```

### Firebase Configuration

```json
// android/app/google-services.json (placeholder - gitignored)
{
  "project_info": {
    "project_number": "000000000000",
    "project_id": "cromania-2026-placeholder",
    "storage_bucket": "cromania-2026-placeholder.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:000000000000:android:0000000000000000",
        "android_client_info": {
          "package_name": "com.cromania.stickercollector"
        }
      },
      "oauth_client": [
        {
          "client_id": "000000000000-xxxxxxxxxxxxxxxx.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

---

## Implementation Order

| Step | Task | Files | Effort |
|------|------|-------|--------|
| 1 | Add Firebase packages to `pubspec.yaml` | `pubspec.yaml` | Low |
| 2 | Create Firebase config files | `firebase_options.dart`, `google-services.json` | Low |
| 3 | Initialize Firebase in `main.dart` | `main.dart` | Medium |
| 4 | Implement `FirebaseAuthService` | `auth/data/firebase_auth_service.dart` | Medium |
| 5 | Create Auth Cubit and States | `auth/presentation/cubit/` | Medium |
| 6 | Build Auth Gate Screen | `auth/presentation/pages/auth_gate_page.dart` | Medium |
| 7 | Add Sync Queue Drift table | `database/tables/sync_queue_table.dart` | Medium |
| 8 | Implement Sync Engine | `sync/domain/sync_engine.dart` | High |
| 9 | Implement Connectivity Service | `connectivity/connectivity_service.dart` | Low |
| 10 | Create User Profile Drawer | `profile/presentation/widgets/` | Medium |
| 11 | Integrate sync with Collection Cubit | `collection/presentation/cubit/` | High |
| 12 | Add Firestore security rules | `firestore.rules` | Medium |
| 13 | Test offline/online sync scenarios | All | High |
| 14 | Build and verify APK | - | Low |

---

*Proposal authored 2026-05-23 for CromoManía 2026 Phase 2*
*Status: Ready for supervisor review*