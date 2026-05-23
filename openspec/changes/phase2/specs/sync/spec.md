# Sync Specification

## Purpose

Provide an offline-first synchronization engine that keeps local sticker collection data in sync with Cloud Firestore, handling network connectivity changes and conflicts transparently.

## Requirements

### Requirement: Sync Queue Management

The system MUST queue local changes for cloud synchronization when the user is offline or immediately sync when online.

#### Scenario: Local Change While Online

- GIVEN the user is online (connectivity confirmed)
- WHEN the user marks a sticker as "owned"
- THEN the system MUST write to local Drift DB immediately
- AND queue the change in the sync queue
- AND push the change to Firestore within 2 seconds

#### Scenario: Local Change While Offline

- GIVEN the user is offline (no connectivity)
- WHEN the user marks a sticker as "owned"
- THEN the system MUST write to local Drift DB immediately
- AND queue the change in the sync queue with status "pending"
- AND display a visual indicator showing the change is queued

#### Scenario: Queue Persists Across App Restarts

- GIVEN changes are queued in the sync queue
- WHEN the app is closed and reopened
- THEN the queued items MUST remain in the database
- AND be processed once connectivity is restored

### Requirement: Automatic Sync Processing

The system MUST automatically process pending sync queue items when the device regains network connectivity.

#### Scenario: Connectivity Restored

- GIVEN there are pending items in the sync queue
- WHEN network connectivity is restored
- THEN the system MUST trigger sync queue processing within 5 seconds
- AND process items in FIFO order (oldest first)
- AND update Firestore with each pending item

#### Scenario: All Pending Items Synced

- GIVEN the sync queue has 10 pending items
- WHEN connectivity is restored and sync completes
- THEN all 10 items MUST be pushed to Firestore
- AND all 10 items MUST be marked as "processed" in the local queue

### Requirement: Cloud Pull on Sign-In

The system MUST pull user data from Firestore when a user signs in to ensure the local cache reflects the latest cloud state.

#### Scenario: First-Time Sign-In on New Device

- GIVEN a user signs in with no local data
- WHEN sign-in completes
- THEN the system MUST fetch all sticker documents from Firestore `/users/{uid}/stickers/`
- AND save each sticker to the local Drift database

#### Scenario: Subsequent Sign-In (Merge)

- GIVEN a user signs in with existing local data
- WHEN sign-in completes
- THEN the system MUST fetch all sticker documents from Firestore
- AND compare `updatedAt` timestamps
- AND for each sticker where cloud is newer, update local with cloud data
- AND for each sticker where local is newer, the local data is already in queue to sync

### Requirement: Real-Time Cloud Listener

The system MUST listen to Firestore document changes to receive updates from other devices in real-time.

#### Scenario: Remote Change Received

- GIVEN the user is signed in and online
- WHEN another device modifies a sticker and Firestore delivers the update
- THEN the system MUST receive the `onSnapshot` event
- AND compare the remote `updatedAt` with local `updatedAt`
- AND if remote is newer, update local Drift database

#### Scenario: App in Foreground Receives Remote Update

- GIVEN the app is in the foreground
- WHEN a remote Firestore change is received
- THEN the UI MUST reflect the updated data within 500ms

### Requirement: Conflict Resolution (Last-Write-Wins)

The system MUST resolve sync conflicts using a last-write-wins strategy based on `updatedAt` timestamps.

#### Scenario: Local Change is Newer

- GIVEN a local change has `updatedAt: 2024-01-15 14:30:00`
- AND the corresponding Firestore document has `updatedAt: 2024-01-15 14:25:00`
- WHEN sync processes the local change
- THEN the cloud MUST be updated with the local data (local wins)

#### Scenario: Remote Change is Newer

- GIVEN the local database has `updatedAt: 2024-01-15 14:25:00`
- AND Firestore has `updatedAt: 2024-01-15 14:30:00`
- WHEN the sync engine detects the remote change
- THEN the local database MUST be updated with the remote data (remote wins)

#### Scenario: Same Timestamp

- GIVEN both local and remote have the same `updatedAt` timestamp
- WHEN a conflict is detected
- THEN the local value SHALL be kept (deterministic tie-breaker)

### Requirement: Sync Status Indicator

The system MUST provide visual feedback about the current sync status.

#### Scenario: Syncing in Progress

- GIVEN there are pending items in the sync queue
- WHEN sync is actively processing
- THEN the sync indicator MUST display "Syncing..."
- AND show a progress indicator (spinner)

#### Scenario: Sync Complete

- GIVEN all pending items have been processed
- WHEN sync completes successfully
- THEN the sync indicator MUST display "Synced {time ago}"
- AND show a checkmark icon

#### Scenario: Offline with Pending Changes

- GIVEN there are pending items in the sync queue
- AND the device is offline
- THEN the sync indicator MUST display "Offline - {count} pending"
- AND show a cloud-offline icon

### Requirement: Retry on Failure

The system MUST retry failed sync operations with exponential backoff.

#### Scenario: Network Error During Sync

- GIVEN a sync item is being pushed to Firestore
- WHEN the network request fails with a transient error
- THEN the system MUST retry the item up to 3 times
- AND use exponential backoff: 1s, 2s, 4s between retries
- AND if all retries fail, mark the item as "failed" for manual review

#### Scenario: Firestore Unavailable

- GIVEN the device is online but Firestore is unavailable
- WHEN a sync operation is attempted
- THEN the system MUST catch the `FirebaseException` with code "unavailable"
- AND increment the retry count for that item
- AND schedule a retry for the next backoff interval

### Requirement: Sync Engine Lifecycle

The sync engine MUST be properly initialized and disposed based on auth state.

#### Scenario: User Signs In

- GIVEN a user successfully signs in
- WHEN the `authStateChanges` emits the authenticated user
- THEN the sync engine MUST be initialized with the user's `uid`
- AND start listening for connectivity changes
- AND start listening for Firestore remote changes

#### Scenario: User Signs Out

- GIVEN the sync engine is running
- WHEN the user signs out
- THEN the sync engine MUST cancel all Firestore subscriptions
- AND cancel connectivity listeners
- AND stop processing the sync queue
- AND the sync status MUST reset to "Not signed in"

## Technical Specifications

### Firestore Schema

```
firestore/
└── users/
    └── {uid}/
        ├── profile/
        │   ├── displayName: string
        │   ├── email: string
        │   ├── photoUrl: string
        │   ├── createdAt: timestamp
        │   └── lastSyncedAt: timestamp
        │
        └── stickers/
            └── {stickerId}/
                ├── status: 'owned' | 'repeated' | 'missing'
                ├── count: number
                ├── updatedAt: timestamp
                └── source: 'local' | 'remote' | 'sync'
```

### Sync Queue Table Schema (Drift)

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Auto-increment primary key |
| stickerId | TEXT | Sticker identifier |
| operation | TEXT | 'upsert' or 'delete' |
| payload | TEXT | JSON-encoded sticker data |
| retryCount | INTEGER | Number of retry attempts (default 0) |
| status | TEXT | 'pending', 'processing', 'processed', 'failed' |
| createdAt | DATETIME | When the item was queued |
| processedAt | DATETIME (nullable) | When the item was successfully synced |

### Sync Status States

| State | Icon | Description |
|-------|------|-------------|
| idle | ☁️ | Not syncing, no pending items |
| syncing | 🔄 | Actively pushing to cloud |
| synced | ✓ | All items synced successfully |
| offline | 📴 | Device offline with pending items |
| error | ⚠️ | Sync failed, items need attention |

### Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| cloud_firestore | ^5.0.0 | Firestore database |
| connectivity_plus | ^6.0.0 | Network connectivity monitoring |
| drift | ^2.16.0 | Local database (from Phase 1) |