# SDD Design — CromoManía 2026 Phase 2

**Document Version:** 1.0  
**Date:** 2026-05-23  
**Status:** Ready for Implementation  
**Change ID:** phase2

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Folder Structure](#2-folder-structure)
3. [Firestore Schema Design](#3-firestore-schema-design)
4. [Sync State Machine](#4-sync-state-machine)
5. [Class Contracts](#5-class-contracts)
6. [Data Flow Diagrams](#6-data-flow-diagrams)
7. [Integration with Phase 1](#7-integration-with-phase-1)
8. [Design Decisions](#8-design-decisions)

---

## 1. Architecture Overview

### 1.1 High-Level Architecture (Phase 1 + Phase 2)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              PRESENTATION LAYER                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  AuthGate   │  │  Collection │  │   Stats     │  │    PDF      │        │
│  │    Page    │  │    Page     │  │  Dashboard  │  │   Export    │        │
│  └──────┬──────┘  └──────┬──────┘  └─────────────┘  └─────────────┘        │
│         │                │                                                   │
│         ▼                ▼                                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                          │
│  │  AuthCubit  │  │ Collection  │  │  SyncCubit  │                          │
│  │             │  │   Cubit     │  │             │                          │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘                          │
└─────────┼───────────────┼─────────────────┼─────────────────────────────────┘
          │               │                 │
          ▼               ▼                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                DOMAIN LAYER                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ AuthRepo    │  │ Collection  │  │ SyncEngine  │  │  Profile    │        │
│  │ (interface) │  │    Repo     │  │             │  │   Entity    │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
          │               │                 │
          ▼               ▼                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                DATA LAYER                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Firebase   │  │  Firestore  │  │ SyncQueue   │  │   Drift     │        │
│  │AuthService │  │   Repo      │  │    Repo     │  │   (Phase1)  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
          │               │                 │
          ▼               ▼                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           INFRASTRUCTURE LAYER                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Firebase   │  │ Cloud       │  │   Drift     │  │ Connectivity│        │
│  │  Auth SDK   │  │ Firestore   │  │  SQLite DB  │  │   Service   │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Phase 2 Component Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PHASE 2 COMPONENTS                                │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         AUTH FLOW                                    │   │
│  │                                                                       │   │
│  │   User ──▶ AuthGatePage ──▶ GoogleSignIn ──▶ FirebaseAuth            │   │
│  │                                      │                │               │   │
│  │                                      ▼                ▼               │   │
│  │                              GoogleDialog ──▶ UserCredential          │   │
│  │                                      │                │               │   │
│  │                                      └────────┬───────┘               │   │
│  │                                               │                       │   │
│  │                                               ▼                       │   │
│  │                                    AuthCubit (authStateChanges)        │   │
│  │                                               │                       │   │
│  │                                    ┌──────────┴──────────┐             │   │
│  │                                    │                     │              │   │
│  │                              Signed In            Not Signed In       │   │
│  │                                    │                     │              │   │
│  │                                    ▼                     ▼              │   │
│  │                            Navigate to Home      Show AuthGate         │   │
│  │                                   │                                       │   │
│  │                                   ▼                                       │   │
│  │                           Initialize Sync Engine                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         SYNC FLOW                                     │   │
│  │                                                                       │   │
│  │   Local Change ──▶ CollectionCubit ──▶ SyncEngine.queueChange()    │   │
│  │                           │                     │                      │   │
│  │                           │                     ▼                      │   │
│  │                           │            ┌────────────────┐            │   │
│  │                           │            │  Write to Drift │            │   │
│  │                           │            │  (immediate)    │            │   │
│  │                           │            └───────┬────────┘            │   │
│  │                           │                    │                      │   │
│  │                           │                    ▼                      │   │
│  │                           │            ┌────────────────┐            │   │
│  │                           │            │ Add to SyncQueue│           │   │
│  │                           │            └───────┬────────┘            │   │
│  │                           │                    │                      │   │
│  │                           │                    ▼                      │   │
│  │                           │            ┌────────────────┐            │   │
│  │                           │            │ Connectivity   │            │   │
│  │                           │            │   Check        │            │   │
│  │                           │            └───┬─────────┬──┘            │   │
│  │                           │                │         │               │   │
│  │                         Online         Offline                          │   │
│  │                           │              │                              │   │
│  │                           ▼              ▼                              │   │
│  │                    Process Queue     Wait for                          │   │
│  │                    Push to Firestore  Reconnect                         │   │
│  │                           │              │                              │   │
│  │                           ▼              └──────────────────────────▶   │   │
│  │                    Firestore Doc Update                                │   │
│  │                           │                                             │   │
│  │                           ▼                                             │   │
│  │                    Mark Queue Item as "processed"                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     REAL-TIME SYNC LISTENER                          │   │
│  │                                                                       │   │
│  │   Firestore ──▶ onSnapshot ──▶ _onRemoteChange()                   │   │
│  │       │                        │                                      │   │
│  │       │                        ▼                                      │   │
│  │       │              Compare updatedAt timestamps                     │   │
│  │       │                        │                                      │   │
│  │       │              ┌─────────┴─────────┐                            │   │
│  │       │              │                   │                            │   │
│  │       │        Remote newer        Local newer                        │   │
│  │       │              │                   │                            │   │
│  │       │              ▼                   ▼                            │   │
│  │       │        Update local DB    Local already in queue             │   │
│  │       │        (remote wins)     Will sync to cloud                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 ASCII Architecture Diagram

```
                              ┌─────────────────────────────────────────────────────┐
                              │                  FEATURES                          │
         ┌────────────────────┼──────────────────────┼──────────────────────┐      │
         │                    │                      │                      │      │
         ▼                    ▼                      ▼                      ▼      │
   ┌─────────────┐    ┌─────────────┐         ┌─────────────┐        ┌───────────┐
   │    Auth     │    │  Collection │         │   Stats     │        │    PDF    │
   │  Feature    │    │   Feature   │         │  Feature    │        │  Feature  │
   │  (Phase 2)  │    │   (Phase 1) │         │  (Phase 1)  │        │ (Phase 1) │
   └──────┬──────┘    └──────┬──────┘         └─────────────┘        └───────────┘
          │                   │                                            │
          │                   │                                            │
          ▼                   ▼                                            ▼
   ┌────────────────────────────────────────────────────────────────────────────────┐
   │                              CORE LAYER                                        │
   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
   │  │   Theme     │  │  Constants  │  │    Utils    │  │  SyncStatus │            │
   │  │  (Phase 1)  │  │  (Phase 1)  │  │  (Phase 1)  │  │  (Phase 2)  │            │
   │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘            │
   └────────────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
   ┌────────────────────────────────────────────────────────────────────────────────┐
   │                           APP LAYER                                          │
   │                                                                                │
   │  ┌──────────────────────────────────────────────────────────────────────────┐  │
   │  │                              main.dart                                   │  │
   │  │  ┌────────────────────────────────────────────────────────────────────┐ │  │
   │  │  │  1. Firebase.initializeApp() ──▶ Initialize Firebase                │ │  │
   │  │  │  2. Database.open() ──▶ Drift LazyDatabase                          │ │  │
   │  │  │  3. RepositoryProviders ──▶ Dependency Injection                   │ │  │
   │  │  │  4. BlocProviders ──▶ AuthCubit, SyncCubit, CollectionCubit        │ │  │
   │  │  │  5. runApp() ──▶ StickerCollectorApp with AuthGate                  │ │  │
   │  │  └────────────────────────────────────────────────────────────────────┘ │  │
   │  └──────────────────────────────────────────────────────────────────────────┘  │
   │                                                                                │
   │  ┌──────────────────────────────────────────────────────────────────────────┐  │
   │  │                           App Router                                     │  │
   │  │  ┌────────────────────────────────────────────────────────────────────┐ │  │
   │  │  │                                                                      │ │  │
   │  │  │         AuthGate (if not signed in)                                │ │  │
   │  │  │              │                                                      │ │  │
   │  │  │              ├── / → AuthGatePage                                   │ │  │
   │  │  │              │     └── "Sign in with Google" button                │ │  │
   │  │  │              │                                                      │ │  │
   │  │  │              ▼                                                      │ │  │
   │  │  │   Main App Shell (if signed in)                                   │ │  │
   │  │  │              │                                                      │ │  │
   │  │  │              ├── / → AlbumListPage                                 │ │  │
   │  │  │              ├── /album/:id → AlbumDetailPage                     │ │  │
   │  │  │              ├── /stats → StatsDashboardPage                       │ │  │
   │  │  │              ├── /export → PdfExportPage                           │ │  │
   │  │  │              └── /profile → ProfileDrawer (slide-in)              │ │  │
   │  │  │                                                                      │ │  │
   │  │  └────────────────────────────────────────────────────────────────────┘ │  │
   │  └──────────────────────────────────────────────────────────────────────────┘  │
   └────────────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
   ┌────────────────────────────────────────────────────────────────────────────────┐
   │                        DATA / INFRASTRUCTURE                                  │
   │                                                                                │
   │  ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────────────┐    │
   │  │ Firebase Auth   │   │ Cloud Firestore │   │   Drift Database        │    │
   │  │                 │   │                 │   │   (Phase 1 tables +     │    │
   │  │ - Google SignIn │   │ - /users/{uid}   │   │    SyncQueue table)    │    │
   │  │ - User session  │   │ - profile/      │   │                         │    │
   │  │ - Auth state    │   │ - stickers/     │   │ - albums, sections      │    │
   │  │                 │   │                 │   │ - stickers, collection   │    │
   │  └────────┬────────┘   └────────┬────────┘   │ - sync_queue ⭐NEW     │    │
   │           │                     │             └────────────┬────────────┘    │
   │           │                     │                          │                │
   │           ▼                     ▼                          ▼                │
   │  ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────────────┐    │
   │  │ FirebaseAuth    │   │ FirestoreRepo   │   │ SyncQueueRepo           │    │
   │  │ Service          │   │                 │   │ (Drift DAO)             │    │
   │  │                 │   │                 │   │                         │    │
   │  └────────┬────────┘   └────────┬────────┘   └────────────┬────────────┘    │
   │           │                     │                          │                │
   │           │                     │                          │                │
   │           └──────────┬──────────┴──────────────────────────┘                │
   │                      │                                                        │
   │                      ▼                                                        │
   │              ┌─────────────────┐                                              │
   │              │   SyncEngine    │  ⭐ Phase 2 Core Component                   │
   │              │                 │                                              │
   │              │ - queueChange() │                                              │
   │              │ - processQueue()│                                              │
   │              │ - onRemoteChange│                                              │
   │              │ - conflictResolv│                                              │
   │              └────────┬────────┘                                              │
   │                       │                                                       │
   │                       ▼                                                       │
   │              ┌─────────────────┐                                              │
   │              │ ConnectivitySvc │  ⭐ Network monitoring                       │
   │              │                 │                                              │
   │              │ - isOnline()    │                                              │
   │              │ - onConnectivity│                                              │
   │              └─────────────────┘                                              │
   │                                                                                │
   └────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Folder Structure

### 2.1 Complete Project Structure (Phase 1 + Phase 2)

```
lib/
├── main.dart                                    # Firebase init, providers, app entry
│
├── core/                                        # Shared utilities (Phase 1)
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── date_utils.dart
│       └── status_utils.dart
│
├── database/                                    # Drift database (Phase 1 + Phase 2)
│   ├── app_database.dart
│   ├── app_database.g.dart
│   ├── tables/
│   │   ├── albums_table.dart                   # Phase 1
│   │   ├── sections_table.dart                 # Phase 1
│   │   ├── stickers_table.dart                  # Phase 1
│   │   ├── collection_status_table.dart         # Phase 1
│   │   └── sync_queue_table.dart               # ⭐ Phase 2 - NEW
│   └── daos/
│       ├── album_dao.dart                      # Phase 1
│       ├── collection_dao.dart                  # Phase 1
│       └── sync_queue_dao.dart                 # ⭐ Phase 2 - NEW
│
├── auth/                                        # ⭐ Phase 2 - NEW Feature
│   ├── data/
│   │   └── firebase_auth_service.dart          # Google Sign In + Firebase Auth
│   ├── domain/
│   │   ├── entities/
│   │   │   └── user_profile.dart               # User profile data class
│   │   └── repositories/
│   │       └── auth_repository.dart            # Abstract interface
│   └── presentation/
│       ├── cubit/
│       │   ├── auth_cubit.dart                 # Auth state machine
│       │   └── auth_state.dart
│       └── pages/
│           └── auth_gate_page.dart             # Sign in screen
│
├── sync/                                        # ⭐ Phase 2 - NEW Feature
│   ├── data/
│   │   ├── firestore_repository.dart           # Firestore CRUD operations
│   │   └── sync_queue_repository_impl.dart     # Sync queue DAO wrapper
│   ├── domain/
│   │   ├── sync_engine.dart                    # Core sync logic
│   │   ├── sync_queue_item.dart                # Queue item entity
│   │   └── sync_status.dart                    # Sync status enum
│   └── presentation/
│       └── cubit/
│           ├── sync_cubit.dart                  # Sync state machine
│           └── sync_state.dart
│
├── profile/                                      # ⭐ Phase 2 - NEW Feature
│   └── presentation/
│       ├── pages/
│       │   └── profile_page.dart               # Profile screen
│       └── widgets/
│           └── user_profile_drawer.dart         # Drawer with user info + sync status
│
├── connectivity/                                # ⭐ Phase 2 - NEW
│   └── connectivity_service.dart               # Network monitoring service
│
├── features/                                    # Phase 1 Features
│   ├── album/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── local/
│   │   │   │       ├── album_local_datasource.dart
│   │   │   │       └── seed_data.dart
│   │   │   ├── models/
│   │   │   │   ├── album_model.dart
│   │   │   │   ├── section_model.dart
│   │   │   │   └── sticker_model.dart
│   │   │   └── repositories/
│   │   │       └── album_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── album.dart
│   │   │   │   ├── section.dart
│   │   │   │   └── sticker.dart
│   │   │   └── repositories/
│   │   │       └── album_repository.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── album_cubit.dart
│   │       │   ├── album_state.dart
│   │       │   └── section_stickers_cubit.dart
│   │       ├── pages/
│   │       │   ├── album_list_page.dart
│   │       │   ├── album_detail_page.dart
│   │       │   └── section_stickers_page.dart
│   │       └── widgets/
│   │           ├── album_card.dart
│   │           └── section_tile.dart
│   │
│   ├── collection/                              # Phase 1
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
│   │           └── sticker_tile.dart
│   │
│   ├── stats/                                   # Phase 1
│   │   ├── domain/
│   │   │   └── stats_calculator.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── stats_cubit.dart
│   │       │   └── stats_state.dart
│   │       ├── pages/
│   │       │   └── stats_dashboard_page.dart
│   │       └── widgets/
│   │           ├── progress_ring.dart
│   │           └── stat_card.dart
│   │
│   └── pdf_export/                              # Phase 1
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
│
├── firebase_options.dart                        # ⭐ Phase 2 - Firebase config
├── app.dart                                     # Main app with providers (updated)
└── router.dart                                  # Navigation (updated with auth gate)

android/
└── app/
    ├── build.gradle                             # Updated: google-services plugin
    └── google-services.json                     # ⭐ Phase 2 - Firebase config (gitignored)

test/                                            # Unit tests

openspec/
└── changes/phase2/
    ├── specs/
    │   ├── auth/spec.md                         # ✅ Done
    │   ├── sync/spec.md                         # ✅ Done
    │   └── profile/spec.md                       # ✅ Done
    ├── proposal.md                              # ✅ Done
    ├── design.md                                # ⭐ This document
    └── tasks.md                                 # TBD
```

### 2.2 New Files Summary

| Category | File | Purpose |
|----------|------|---------|
| **Auth Feature** | `auth/data/firebase_auth_service.dart` | Google Sign In + Firebase Auth SDK wrapper |
| | `auth/domain/entities/user_profile.dart` | User profile data class |
| | `auth/domain/repositories/auth_repository.dart` | Auth repository interface |
| | `auth/presentation/cubit/auth_cubit.dart` | Auth state management |
| | `auth/presentation/cubit/auth_state.dart` | Auth state definitions |
| | `auth/presentation/pages/auth_gate_page.dart` | Sign-in UI |
| **Sync Feature** | `sync/data/firestore_repository.dart` | Firestore CRUD operations |
| | `sync/data/sync_queue_repository_impl.dart` | Sync queue DAO wrapper |
| | `sync/domain/sync_engine.dart` | Core sync logic |
| | `sync/domain/sync_queue_item.dart` | Sync queue entity |
| | `sync/domain/sync_status.dart` | Sync status enum |
| | `sync/presentation/cubit/sync_cubit.dart` | Sync state management |
| | `sync/presentation/cubit/sync_state.dart` | Sync state definitions |
| **Profile Feature** | `profile/presentation/pages/profile_page.dart` | Profile page |
| | `profile/presentation/widgets/user_profile_drawer.dart` | Profile drawer widget |
| **Connectivity** | `connectivity/connectivity_service.dart` | Network monitoring |
| **Database** | `database/tables/sync_queue_table.dart` | Sync queue table definition |
| | `database/daos/sync_queue_dao.dart` | Sync queue DAO |
| **Config** | `firebase_options.dart` | Firebase configuration |
| **Updated** | `main.dart` | Firebase init + providers |
| | `app.dart` | Add AuthCubit provider |
| | `pubspec.yaml` | Add Firebase packages |

---

## 3. Firestore Schema Design

### 3.1 Firestore Structure

```
Firestore Root
└── users/
    └── {uid}/
        ├── profile/
        │   └── (singleton document)
        │       ├── displayName: string      # "Juan Pérez"
        │       ├── email: string            # "juan@email.com"
        │       ├── photoUrl: string|null    # Google profile photo URL
        │       ├── createdAt: timestamp     # First sign-in time
        │       └── lastSyncedAt: timestamp   # Last successful sync time
        │
        └── stickers/
            └── {stickerId}/
                ├── status: 'owned'|'repeated'|'missing'   # Derived from count
                ├── count: number                # 0 = missing, 1 = owned, 2+ = repeated
                ├── updatedAt: timestamp        # Last modification time (server timestamp)
                └── source: 'local'|'remote'|'sync'  # Debug: origin of last change
```

### 3.2 Firestore Schema Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            FIRESTORE SCHEMA                                      │
└─────────────────────────────────────────────────────────────────────────────────┘

                              ┌─────────────┐
                              │   (root)    │
                              └──────┬──────┘
                                     │
                                     ▼
                              ┌─────────────┐
                              │   users     │
                              │  (collection)
                              └──────┬──────┘
                                     │
                            ┌────────┴────────┐
                            │                 │
                            ▼                 ▼
                     ┌─────────────┐   ┌─────────────┐
                     │   {uid}    │   │   {uid}    │  ... more users
                     │ (document)  │   │ (document)  │
                     └──────┬──────┘   └─────────────┘
                            │
                            │
              ┌─────────────┴─────────────┐
              │                           │
              ▼                           ▼
      ┌───────────────┐           ┌───────────────┐
      │   profile     │           │   stickers    │
      │  (subcoll)    │           │  (subcoll)    │
      └───────┬───────┘           └───────┬───────┘
              │                           │
              │                           │
              ▼                           │
      ┌───────────────┐                   │
      │    (doc)      │                   │
      │  (singleton)  │                   │
      ├───────────────┤                   │
      │ displayName   │                   │
      │ email         │                   │
      │ photoUrl      │                   │
      │ createdAt     │                   │
      │ lastSyncedAt  │                   │
      └───────────────┘                   │
                                          ▼
                              ┌─────────────────────────┐
                              │      {stickerId}         │
                              │      (document)          │
                              ├───────────────────────────┤
                              │ status: 'owned'           │
                              │ count: 2                  │
                              │ updatedAt: Timestamp      │
                              │ source: 'local'           │
                              └───────────────────────────┘
                                          │
                                          │
                              ┌───────────┴───────────┐
                              │                       │
                              ▼                       ▼
                    ┌───────────────┐       ┌───────────────┐
                    │  {stickerId2} │  ...  │  {stickerIdN} │
                    │  (document)   │       │  (document)   │
                    └───────────────┘       └───────────────┘


TOTAL STICKERS PER USER = number of documents in stickers subcollection
Typically 670 for full WC 2026 album

```

### 3.3 Firestore Document Schema (JSON)

**User Profile Document:**
```json
{
  "displayName": "Juan Pérez",
  "email": "juan@email.com",
  "photoUrl": "https://lh3.googleusercontent.com/...",
  "createdAt": {
    "_seconds": 1700000000,
    "_nanoseconds": 0
  },
  "lastSyncedAt": {
    "_seconds": 1700003600,
    "_nanoseconds": 0
  }
}
```

**Sticker Document:**
```json
{
  "status": "owned",
  "count": 2,
  "updatedAt": {
    "_seconds": 1700007200,
    "_nanoseconds": 0
  },
  "source": "local"
}
```

### 3.4 Firestore Indexes

| Index | Collection | Fields | Purpose |
|-------|------------|--------|---------|
| idx_user_stickers | users/{uid}/stickers | count ASC | Sort by count |
| idx_user_stickers_status | users/{uid}/stickers | status ASC | Filter by status |

*Note: Single-field indexes are auto-created by Firestore for equality queries.
Compound indexes may be needed for future optimization.*

### 3.5 Security Rules (Initial - Permissive)

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // User can read/write only their own data
    match /users/{userId}/stickers/{stickerId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /users/{userId}/profile/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow authenticated users to read their own collection
    match /users/{userId}/{document=**} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

*Note: Phase 2 uses permissive rules. Phase 3 will implement stricter rules.*

---

## 4. Sync State Machine

### 4.1 Sync Engine State Machine

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          SYNC STATE MACHINE                                  │
└─────────────────────────────────────────────────────────────────────────────┘

                               ┌─────────────────┐
                               │    IDLE         │
                               │                 │
                               │ No pending      │
                               │ items, online   │
                               └────────┬────────┘
                                        │
                                        │ (Local change occurs)
                                        ▼
                               ┌─────────────────┐
                               │   QUEUED        │
                               │                 │
                               │ Change added    │
                               │ to sync queue   │
                               │                 │
                               └────────┬────────┘
                                        │
                                        │ (Connectivity restored OR immediate sync)
                                        ▼
                               ┌─────────────────┐
                               │   PROCESSING    │
                               │                 │
                               │ Pushing items   │
                               │ to Firestore    │
                               │                 │
                               └────────┬────────┘
                                        │
                    ┌───────────────────┴───────────────────┐
                    │                                       │
                    ▼                                       ▼
           ┌─────────────────┐                     ┌─────────────────┐
           │     SUCCESS     │                     │    FAILURE      │
           │                 │                     │                 │
           │ Item pushed,    │                     │ Network error   │
           │ marked done     │                     │ or quota error  │
           └────────┬────────┘                     └────────┬────────┘
                    │                                       │
                    │ (More items in queue?)                │ (Retry count < 3?)
                    │                                       │
              ┌─────┴─────┐                           ┌─────┴─────┐
              │           │                           │           │
              ▼           ▼                           ▼           ▼
         [YES]        [NO]                        [YES]        [NO]
              │           │                           │           │
              ▼           ▼                           ▼           ▼
       ┌───────────┐ ┌───────────┐           ┌───────────┐ ┌───────────┐
       │  QUEUED   │ │   IDLE    │           │  RETRY    │ │  FAILED   │
       │(next item)│ │  (done)   │           │(backoff)  │ │ (manual)  │
       └───────────┘ └───────────┘           └───────────┘ └───────────┘


STATE TRANSITIONS:

IDLE → QUEUED:
  Trigger: User taps sticker while online OR connectivity restored
  Action: SyncEngine.queueChange() adds item to queue

QUEUED → PROCESSING:
  Trigger: connectivity_plus emits 'online' OR immediate sync requested
  Action: SyncEngine.processQueue() starts processing

PROCESSING → SUCCESS:
  Trigger: Firestore setDocument() completes without error
  Action: Mark item as 'processed', remove from queue

PROCESSING → FAILURE:
  Trigger: Firestore error (network, quota, permission)
  Action: Increment retry count, schedule retry with backoff

SUCCESS → QUEUED (if more items):
  Trigger: Queue has more pending items
  Action: Process next item

SUCCESS → IDLE:
  Trigger: Queue is empty
  Action: Update sync status to 'synced'

FAILURE → RETRY:
  Trigger: Retry count < 3
  Action: Wait exponential backoff (1s, 2s, 4s)

FAILURE → FAILED:
  Trigger: Retry count >= 3
  Action: Mark as 'failed', emit error state, require manual intervention

RETRY → PROCESSING:
  Trigger: Backoff timer expires
  Action: Attempt to process item again
```

### 4.2 Sync Queue Item States

```
SYNC QUEUE ITEM LIFECYCLE:

┌─────────────┐    Create    ┌─────────────┐    Process    ┌─────────────┐
│   (none)    │──────────────▶│   PENDING   │──────────────▶│ PROCESSING  │
└─────────────┘              └─────────────┘              └──────┬──────┘
                                                                  │
                            ┌─────────────────────────────────────┼─────┐
                            │                                     │     │
                            ▼                                     ▼     │
                   ┌─────────────┐                         ┌─────────────┐
                   │  PROCESSED  │                         │   FAILED   │
                   │             │                         │             │
                   │ Sync success│                         │ Retry count │
                   │ Remove from │                         │ >= 3        │
                   │ queue       │                         │ Manual review│
                   └─────────────┘                         └─────────────┘
                            ▲                                     ▲
                            │                                     │
                            │         ┌─────────────┐              │
                            └─────────│   RETRY     │──────────────┘
                                      │             │
                                      │ Backoff:    │
                                      │ 1s, 2s, 4s  │
                                      └─────────────┘
```

### 4.3 Sync Status States (UI Display)

| State | Icon | Description | Color |
|-------|------|-------------|-------|
| `idle` | ☁️ | No sync in progress, no pending items | Grey |
| `syncing` | 🔄 | Actively pushing to Firestore | Blue |
| `synced` | ✅ | All items synced, last sync successful | Green |
| `offline` | 📴 | Device offline, items queued | Orange |
| `error` | ⚠️ | Sync failed, needs manual review | Red |

---

## 5. Class Contracts

### 5.1 Auth Feature Contracts

```dart
// auth/domain/entities/user_profile.dart
class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastSyncedAt;
  
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.lastSyncedAt,
  });
  
  /// Create from Firebase User
  factory UserProfile.fromFirebaseUser(User user) {
    return UserProfile(
      uid: user.uid,
      displayName: user.displayName ?? 'User',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastSyncedAt: null,
    );
  }
}
```

```dart
// auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  /// Stream of auth state changes (null when signed out)
  Stream<UserProfile?> get authStateChanges;
  
  /// Get current user if signed in
  UserProfile? get currentUser;
  
  /// Sign in with Google
  Future<UserProfile> signInWithGoogle();
  
  /// Sign out completely
  Future<void> signOut();
  
  /// Check if user is currently signed in
  bool get isSignedIn;
}
```

```dart
// auth/data/firebase_auth_service.dart
class FirebaseAuthService implements AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  FirebaseAuth get _auth => FirebaseAuth.instance;
  
  @override
  Stream<UserProfile?> get authStateChanges {
    return _auth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return UserProfile.fromFirebaseUser(firebaseUser);
    });
  }
  
  @override
  UserProfile? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserProfile.fromFirebaseUser(user);
  }
  
  @override
  bool get isSignedIn => _auth.currentUser != null;
  
  @override
  Future<UserProfile> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw AuthException('Google sign-in cancelled by user');
      }
      
      final googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      return UserProfile.fromFirebaseUser(userCredential.user!);
    } on PlatformException catch (e) {
      if (e.code == 'MISSING_DEBUG_SHA1') {
        throw AuthException(
          'SHA-1 not configured. Run: keytool -list -v -keystore ~/.android/debug.keystore'
        );
      }
      throw AuthException('Sign-in failed: ${e.message}');
    } catch (e) {
      throw AuthException('Sign-in failed: $e');
    }
  }
  
  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
```

```dart
// auth/presentation/cubit/auth_state.dart
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? errorMessage;
  
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });
  
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  
  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
```

```dart
// auth/presentation/cubit/auth_cubit.dart
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  
  AuthCubit(this._authRepository) : super(const AuthState());
  
  /// Initialize auth state listener
  void initialize() {
    emit(state.copyWith(status: AuthStatus.loading));
    
    _authRepository.authStateChanges.listen(
      (user) {
        if (user != null) {
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            errorMessage: null,
          ));
        } else {
          emit(state.copyWith(
            status: AuthStatus.unauthenticated,
            user: null,
          ));
        }
      },
      onError: (error) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.toString(),
        ));
      },
    );
  }
  
  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Unexpected error: $e',
      ));
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      await _authRepository.signOut();
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Sign-out failed: $e',
      ));
    }
  }
}
```

### 5.2 Sync Feature Contracts

```dart
// sync/domain/sync_status.dart
enum SyncStatus {
  idle,       // No sync in progress
  syncing,    // Actively syncing
  synced,     // All synced
  offline,    // Offline with pending
  error,      // Sync failed
}

extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.idle:
        return 'Synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.error:
        return 'Sync Error';
    }
  }
  
  bool get isActive => this == SyncStatus.syncing;
  bool get isSuccess => this == SyncStatus.synced || this == SyncStatus.idle;
}
```

```dart
// sync/domain/sync_queue_item.dart
enum SyncOperation { upsert, delete }

enum SyncItemStatus { pending, processing, processed, failed }

class SyncQueueItem {
  final int id;
  final String stickerId;
  final SyncOperation operation;
  final Map<String, dynamic> payload;
  final int retryCount;
  final SyncItemStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? errorMessage;
  
  const SyncQueueItem({
    required this.id,
    required this.stickerId,
    required this.operation,
    required this.payload,
    this.retryCount = 0,
    this.status = SyncItemStatus.pending,
    required this.createdAt,
    this.processedAt,
    this.errorMessage,
  });
  
  /// Create a new item for queueing
  factory SyncQueueItem.create({
    required String stickerId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
  }) {
    return SyncQueueItem(
      id: 0,  // Will be set by DAO
      stickerId: stickerId,
      operation: operation,
      payload: payload,
      retryCount: 0,
      status: SyncItemStatus.pending,
      createdAt: DateTime.now(),
    );
  }
  
  /// Check if can retry
  bool get canRetry => retryCount < 3 && status != SyncItemStatus.processed;
  
  /// Get next retry delay in milliseconds
  int get nextRetryDelayMs {
    return 1000 * (1 << retryCount);  // 1s, 2s, 4s
  }
}
```

```dart
// sync/domain/sync_engine.dart
class SyncEngine {
  final FirebaseFirestore _firestore;
  final SyncQueueRepository _syncRepo;
  final CollectionRepository _collectionRepo;
  final ConnectivityService _connectivity;
  
  String? _currentUid;
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _firestoreSubscription;
  
  /// Initialize sync engine with authenticated user
  Future<void> initialize(String uid) async {
    _currentUid = uid;
    
    // Start connectivity listener
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        _processSyncQueue();
      }
    });
    
    // Listen to Firestore remote changes
    _firestoreSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('stickers')
        .snapshots()
        .listen(_onRemoteChange);
    
    // Initial pull from cloud
    await _pullFromCloud();
    
    // Process any pending queue items
    if (await _connectivity.isOnline) {
      await _processSyncQueue();
    }
  }
  
  /// Queue a local change for sync
  Future<void> queueChange({
    required String stickerId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
  }) async {
    // 1. Write to local Drift DB immediately (optimistic update)
    await _collectionRepo.saveStatus(stickerId, payload);
    
    // 2. Add to sync queue
    final item = SyncQueueItem.create(
      stickerId: stickerId,
      operation: operation,
      payload: payload,
    );
    await _syncRepo.addItem(item);
    
    // 3. Try immediate sync if online
    if (await _connectivity.isOnline) {
      await _processSyncQueue();
    }
  }
  
  /// Process all pending queue items
  Future<void> _processSyncQueue() async {
    final pendingItems = await _syncRepo.getPendingItems();
    
    for (final item in pendingItems) {
      if (!item.canRetry) continue;
      
      await _syncRepo.updateStatus(item.id, SyncItemStatus.processing);
      
      try {
        await _pushToCloud(item);
        await _syncRepo.markAsProcessed(item.id);
      } catch (e) {
        if (_isTransientError(e)) {
          await _syncRepo.incrementRetry(item.id);
        } else {
          await _syncRepo.markAsFailed(item.id, e.toString());
        }
      }
    }
  }
  
  /// Push single item to Firestore
  Future<void> _pushToCloud(SyncQueueItem item) async {
    final docRef = _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('stickers')
        .doc(item.stickerId);
    
    if (item.operation == SyncOperation.delete) {
      await docRef.delete();
    } else {
      await docRef.set({
        ...item.payload,
        'updatedAt': FieldValue.serverTimestamp(),
        'source': 'local',
      });
    }
  }
  
  /// Handle remote Firestore changes
  Future<void> _onRemoteChange(QuerySnapshot snapshot) async {
    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified) {
        final remoteData = change.doc.data()!;
        final stickerId = change.doc.id;
        final localData = await _collectionRepo.getStatus(stickerId);
        
        // Last-write-wins conflict resolution
        if (localData == null || 
            _isRemoteNewer(remoteData, localData)) {
          // Remote is newer - update local
          await _collectionRepo.updateStatus(
            stickerId,
            remoteData,
            source: 'remote',
          );
        }
        // else: Local is newer - will sync to cloud via queue
      }
    }
  }
  
  /// Pull all data from cloud on sign-in
  Future<void> _pullFromCloud() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('stickers')
        .get();
    
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final stickerId = doc.id;
      final localData = await _collectionRepo.getStatus(stickerId);
      
      if (localData == null) {
        // New from cloud - save locally
        await _collectionRepo.insertStatus(stickerId, data);
      } else if (_isRemoteNewer(data, localData)) {
        // Cloud is newer - update local
        await _collectionRepo.updateStatus(stickerId, data, source: 'remote');
      }
      // else: Local is newer - keep local, will sync later
    }
  }
  
  bool _isRemoteNewer(
    Map<String, dynamic> remote,
    Map<String, dynamic> local,
  ) {
    final remoteTime = (remote['updatedAt'] as Timestamp?)?.toDate();
    final localTime = local['updatedAt'] as DateTime?;
    
    if (remoteTime == null || localTime == null) return true;
    return remoteTime.isAfter(localTime);
  }
  
  bool _isTransientError(dynamic e) {
    if (e is FirebaseException) {
      return e.code == 'unavailable' || 
             e.code == 'network-error' ||
             e.code == 'deadline-exceeded';
    }
    return false;
  }
  
  /// Dispose all subscriptions
  void dispose() {
    _connectivitySubscription?.cancel();
    _firestoreSubscription?.cancel();
    _currentUid = null;
  }
}
```

```dart
// sync/presentation/cubit/sync_state.dart
class SyncState {
  final SyncStatus status;
  final int pendingCount;
  final DateTime? lastSyncedAt;
  final String? errorMessage;
  
  const SyncState({
    this.status = SyncStatus.idle,
    this.pendingCount = 0,
    this.lastSyncedAt,
    this.errorMessage,
  });
  
  String get lastSyncedText {
    if (lastSyncedAt == null) return 'Never';
    final diff = DateTime.now().difference(lastSyncedAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
  
  SyncState copyWith({
    SyncStatus? status,
    int? pendingCount,
    DateTime? lastSyncedAt,
    String? errorMessage,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
```

```dart
// sync/presentation/cubit/sync_cubit.dart
class SyncCubit extends Cubit<SyncState> {
  final SyncEngine _syncEngine;
  final ConnectivityService _connectivity;
  final SyncQueueRepository _syncRepo;
  
  SyncCubit({
    required SyncEngine syncEngine,
    required ConnectivityService connectivity,
    required SyncQueueRepository syncRepo,
  }) : _syncEngine = syncEngine,
       _connectivity = connectivity,
       _syncRepo = syncRepo,
       super(const SyncState());
  
  /// Start sync engine for authenticated user
  Future<void> startSync(String uid) async {
    await _syncEngine.initialize(uid);
    await _updateStatus();
    
    // Listen for sync queue changes
    _syncRepo.watchPendingCount().listen((count) {
      emit(state.copyWith(pendingCount: count));
      _updateSyncStatus();
    });
  }
  
  /// Stop sync engine (on sign-out)
  void stopSync() {
    _syncEngine.dispose();
    emit(const SyncState());
  }
  
  /// Force sync all pending items
  Future<void> forceSync() async {
    if (!await _connectivity.isOnline) {
      emit(state.copyWith(
        status: SyncStatus.offline,
        errorMessage: 'No internet connection',
      ));
      return;
    }
    
    emit(state.copyWith(status: SyncStatus.syncing));
    
    try {
      await _syncEngine.processQueue();
      emit(state.copyWith(
        status: SyncStatus.synced,
        lastSyncedAt: DateTime.now(),
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  
  Future<void> _updateStatus() async {
    final isOnline = await _connectivity.isOnline;
    final pendingCount = await _syncRepo.getPendingCount();
    
    if (!isOnline && pendingCount > 0) {
      emit(state.copyWith(
        status: SyncStatus.offline,
        pendingCount: pendingCount,
      ));
    } else if (pendingCount == 0) {
      emit(state.copyWith(
        status: SyncStatus.synced,
        pendingCount: 0,
      ));
    } else {
      emit(state.copyWith(pendingCount: pendingCount));
    }
  }
  
  void _updateSyncStatus() {
    if (state.pendingCount > 0) {
      if (_connectivity.isOnlineSync) {
        emit(state.copyWith(status: SyncStatus.syncing));
      } else {
        emit(state.copyWith(status: SyncStatus.offline));
      }
    } else {
      emit(state.copyWith(status: SyncStatus.synced));
    }
  }
}
```

### 5.3 Profile Feature Contracts

```dart
// profile/presentation/widgets/user_profile_drawer.dart
class UserProfileDrawer extends StatelessWidget {
  final UserProfile user;
  final SyncState syncState;
  final VoidCallback onSignOut;
  final VoidCallback onExportCollection;
  final VoidCallback onOpenSettings;
  
  const UserProfileDrawer({
    super.key,
    required this.user,
    required this.syncState,
    required this.onSignOut,
    required this.onExportCollection,
    required this.onOpenSettings,
  });
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: min(320, MediaQuery.of(context).size.width * 0.8),
      child: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            
            // Avatar
            _buildAvatar(),
            
            // Name and email
            _buildUserInfo(),
            
            const Divider(),
            
            // Sync status
            _buildSyncStatus(),
            
            const Divider(),
            
            // Actions
            _buildActions(),
            
            const Spacer(),
            
            // Sign out
            _buildSignOutButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAvatar() {
    final hasPhoto = user.photoUrl != null;
    
    return CircleAvatar(
      radius: 32,
      backgroundColor: _avatarColor(user.displayName),
      backgroundImage: hasPhoto ? NetworkImage(user.photoUrl!) : null,
      child: hasPhoto ? null : Text(
        _initials(user.displayName),
        style: const TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
  
  Widget _buildSyncStatus() {
    return ListTile(
      leading: _syncIcon(),
      title: Text(_syncTitle()),
      subtitle: Text('${syncState.pendingCount} stickers pending'),
    );
  }
  
  Widget _syncIcon() {
    switch (syncState.status) {
      case SyncStatus.idle:
        return const Icon(Icons.cloud_done, color: Colors.grey);
      case SyncStatus.syncing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.synced:
        return const Icon(Icons.cloud_done, color: Colors.green);
      case SyncStatus.offline:
        return const Icon(Icons.cloud_off, color: Colors.orange);
      case SyncStatus.error:
        return const Icon(Icons.cloud_off, color: Colors.red);
    }
  }
  
  String _syncTitle() {
    switch (syncState.status) {
      case SyncStatus.idle:
      case SyncStatus.synced:
        return 'Synced ${syncState.lastSyncedText}';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.offline:
        return 'Offline - ${syncState.pendingCount} pending';
      case SyncStatus.error:
        return 'Sync error';
    }
  }
}
```

---

## 6. Data Flow Diagrams

### 6.1 Sign-In Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          SIGN-IN DATA FLOW                                  │
└─────────────────────────────────────────────────────────────────────────────┘

User Action
    │
    ▼
AuthGatePage
    │
    │ "Sign in with Google" button tapped
    ▼
AuthCubit.signInWithGoogle()
    │
    │ emit(AuthState.loading)
    ▼
FirebaseAuthService.signInWithGoogle()
    │
    ├─▶ GoogleSignIn.signIn()
    │        │
    │        ▼
    │    Google Consent Dialog (native)
    │        │
    │        ├── [Cancel] ──▶ return null
    │        │                    │
    │        │                    ▼
    │        │            throw AuthException('cancelled')
    │        │
    │        └── [Accept] ──▶ googleUser
    │                           │
    │                           ▼
    │                    googleUser.authentication
    │                           │
    │                           ▼
    │                    GoogleAuthProvider.credential()
    │                           │
    │                           ▼
    └─▶ FirebaseAuth.signInWithCredential(credential)
             │
             ▼
        UserCredential
             │
             ▼
        UserProfile.fromFirebaseUser(user)
             │
             ▼
        emit(AuthState.authenticated, user: user)
             │
             ▼
        App navigates to home (AlbumListPage)
             │
             ▼
        SyncEngine.initialize(uid)
             │
             ├──▶ ConnectivityService starts listening
             ├──▶ Firestore listener starts
             └──▶ _pullFromCloud() - fetch user's collection


ERROR HANDLING:

PlatformException(code: 'MISSING_DEBUG_SHA1')
    │
    ▼
throw AuthException('SHA-1 not configured')
    │
    ▼
emit(AuthState.error, message: error)
    │
    ▼
AuthGatePage shows SnackBar with error

FirebaseException(network)
    │
    ▼
throw AuthException('No internet connection')
    │
    ▼
emit(AuthState.error, message: error)
```

### 6.2 Sticker Tap Sync Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     STICKER TAP → SYNC FLOW                                  │
└─────────────────────────────────────────────────────────────────────────────┘

User Action: Tap Sticker Tile
    │
    ▼
SectionStickersPage
    │
    │ collectionCubit.incrementSticker(stickerId)
    ▼
CollectionCubit._updateStickerCount(stickerId, delta: +1)
    │
    │ 1. Calculate new count
    │ 2. Create CollectionStatusModel
    │ 3. Emit(state.copyWith(statusMap: newMap))
    │
    ├─────────────────────────┐
    │                         │
    ▼                         ▼
UI Updates Immediately    Background: Persist
(optimistic)              (fire-and-forget)
    │                         │
    │                         ▼
    │               CollectionRepository.saveStatus()
    │                         │
    │                         ▼
    │               Drift: collection_status table
    │                         │
    └────────────────────┬────┘
                       │
                       ▼
              SyncEngine.queueChange()
                       │
                       │ 1. Write to local Drift (already done above)
                       │ 2. Add to sync queue
                       │
                       ▼
              SyncQueueTable.insert()
                       │
                       ├──────────────────────────────┐
                       │                              │
                       ▼                              ▼
              [Online?]                      [Offline?]
                       │                              │
                       │                              │
                       ▼                              ▼
              Process sync immediately         Wait for connectivity
                       │                              │
                       ▼                              ▼
              SyncEngine._pushToCloud()        Item stays in queue (status: pending)
                       │                         (processed when online)
                       │
                       ▼
              Firestore: users/{uid}/stickers/{stickerId}.set()
                       │
                       ├──────────────────────────────┐
                       │                              │
                       ▼                              ▼
              [Success]                        [Failure]
                       │                              │
                       ▼                              ▼
              SyncQueueTable.markAsProcessed()  SyncQueueTable.incrementRetry()
                       │                         (retryCount + 1)
                       │                              │
                       ▼                              ▼
              SyncCubit emits synced state     If retryCount < 3:
                                              schedule retry with backoff
                                              Else:
                                              markAsFailed()
```

### 6.3 Multi-Device Sync Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     MULTI-DEVICE SYNC FLOW                                   │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────┐                           ┌──────────────┐
│   Device A   │                           │   Device B   │
│   (Phone)    │                           │   (Tablet)   │
└──────┬───────┘                           └──────┬───────┘
       │                                         │
       │ User taps sticker A7 on Phone           │
       ▼                                         │
SyncEngine.queueChange(stickerId: 'A7')          │
       │                                         │
       ├─▶ Write to local Drift                 │
       ├─▶ Add to sync queue                    │
       └─▶ Push to Firestore                    │
                    │                           │
                    ▼                           │
           ┌────────────────┐                  │
           │    Firestore    │                  │
           │ users/{uid}/   │                  │
           │   stickers/A7  │                  │
           └───────┬────────┘                  │
                   │                            │
                   │ onSnapshot event          │
                   │ <─────────────────────────┘
                   ▼
           SyncEngine._onRemoteChange()
                   │
                   │ Compare updatedAt timestamps
                   │ Device A (local) 2024-01-15 14:30:00
                   │ Device B (remote) 2024-01-15 14:25:00
                   │
                   │ Local is newer (14:30 > 14:25)
                   │ -> Do nothing, local will sync
                   │
                   ▼
           SyncQueueTable item added for A7
                   │
                   ▼
           Push to Firestore (when online)
                   │
                   ▼
           Firestore updated with Device A data
                   │
                   └──────────────────────────────▶
                                                  │
                                                  │ onSnapshot event
                                                  ▼
                                         SyncEngine._onRemoteChange()
                                                  │
                                                  │ Compare updatedAt
                                                  │ Device B (local) 14:25
                                                  │ Firestore (remote) 14:30
                                                  │
                                                  │ Remote is newer (14:30 > 14:25)
                                                  │ -> Update local with remote data
                                                  │
                                                  ▼
                                         Drift: collection_status
                                         Updated with Firestore data
                                                  │
                                                  ▼
                                         UI refreshes sticker A7
                                                  │
                                                  ▼
                                         Result: Both devices now show
                                         sticker A7 with count=2, updatedAt=14:30
```

### 6.4 Offline → Online Sync Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     OFFLINE → ONLINE SYNC FLOW                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ Phase 1: User is OFFLINE, makes changes                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│ User taps 3 stickers while offline                                       │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │                         PHONE (Offline)                             │ │
│ │                                                                     │ │
│ │  Tap A1 ──▶ local DB updated, queue item added (pending)          │ │
│ │  Tap B5 ──▶ local DB updated, queue item added (pending)          │ │
│ │  Tap C3 ──▶ local DB updated, queue item added (pending)          │ │
│ │                                                                     │ │
│ │  SyncQueueTable:                                                   │ │
│ │  ┌────┬────────────┬──────────┬─────────┐                        │ │
│ │  │ ID │ stickerId  │ status   │ retry   │                        │ │
│ │  ├────┼────────────┼──────────┼─────────┤                        │ │
│ │  │ 1  │ A1         │ pending  │ 0       │                        │ │
│ │  │ 2  │ B5         │ pending  │ 0       │                        │ │
│ │  │ 3  │ C3         │ pending  │ 0       │                        │ │
│ │  └────┴────────────┴──────────┴─────────┘                        │ │
│ │                                                                     │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│ User closes app, puts phone in drawer, travels                           │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ Phase 2: User comes back ONLINE (connects to WiFi)                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │                         PHONE (Online)                              │ │
│ │                                                                     │ │
│ │  1. App starts                                                      │ │
│ │  2. ConnectivityService emits 'online' event                        │ │
│ │  3. AuthCubit confirms user still signed in                         │ │
│ │  4. SyncEngine.initialize(uid) called                               │ │
│ │  5. _processSyncQueue() starts                                     │ │
│ │                                                                     │ │
│ │  Process item 1 (A1):                                              │ │
│ │  ├─▶ Firestore.set('users/{uid}/stickers/A1', {...})              │ │
│ │  ├─▶ Success                                                       │ │
│ │  └─▶ markAsProcessed(1)                                            │ │
│ │                                                                     │ │
│ │  Process item 2 (B5):                                              │ │
│ │  ├─▶ Firestore.set('users/{uid}/stickers/B5', {...})              │ │
│ │  ├─▶ Success                                                       │ │
│ │  └─▶ markAsProcessed(2)                                            │ │
│ │                                                                     │ │
│ │  Process item 3 (C3):                                              │ │
│ │  ├─▶ Firestore.set('users/{uid}/stickers/C3', {...})              │ │
│ │  ├─▶ Success                                                       │ │
│ │  └─▶ markAsProcessed(3)                                            │ │
│ │                                                                     │ │
│ │  SyncQueueTable:                                                   │ │
│ │  ┌────┬────────────┬────────────┐                                 │ │
│ │  │ ID │ stickerId  │ status     │                                 │ │
│ │  ├────┼────────────┼────────────┤                                 │ │
│ │  │ 1  │ A1         │ processed  │  ✓                              │ │
│ │  │ 2  │ B5         │ processed  │  ✓                              │ │
│ │  │ 3  │ C3         │ processed  │  ✓                              │ │
│ │  └────┴────────────┴────────────┘                                 │ │
│ │                                                                     │ │
│ │  SyncCubit emits: status=synced, lastSyncedAt=now                  │ │
│ │                                                                     │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│ Now user opens tablet (same account, different device)                  │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │                         TABLET (Online)                             │ │
│ │                                                                     │ │
│ │  1. User signs in to same Google account                           │ │
│ │  2. SyncEngine._pullFromCloud() fetches all stickers               │ │
│ │  3. A1, B5, C3 pulled from Firestore with synced data              │ │
│ │  4. Local DB on tablet updated                                      │ │
│ │  5. CollectionCubit emits new state                                 │ │
│ │  6. UI shows all 3 stickers as owned (synced from phone)           │ │
│ │                                                                     │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Integration with Phase 1

### 7.1 Changes to Existing Files

**main.dart:**
```dart
// Phase 2: Add Firebase initialization before runApp()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Phase 2: Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Phase 1: Initialize database
  final database = AppDatabase();
  
  // Create repositories
  final authService = FirebaseAuthService();
  final collectionRepo = CollectionRepositoryImpl(database.collectionDao);
  final syncQueueRepo = SyncQueueRepositoryImpl(database.syncQueueDao);
  final connectivity = ConnectivityService();
  
  // Phase 2: Create sync engine
  final firestore = FirebaseFirestore.instance;
  final syncEngine = SyncEngine(
    firestore: firestore,
    syncRepo: syncQueueRepo,
    collectionRepo: collectionRepo,
    connectivity: connectivity,
  );
  
  runApp(
    StickerCollectorApp(
      database: database,
      authService: authService,
      syncEngine: syncEngine,
      connectivity: connectivity,
      syncQueueRepo: syncQueueRepo,
      collectionRepo: collectionRepo,
    ),
  );
}
```

**app.dart:**
```dart
// Phase 2: Add AuthCubit and SyncCubit providers
class StickerCollectorApp extends StatelessWidget {
  // ... constructor with all dependencies
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Phase 1 cubits
        BlocProvider(create: (_) => AlbumCubit(albumRepo)),
        BlocProvider(create: (_) => CollectionCubit(collectionRepo)),
        BlocProvider(create: (_) => StatsCubit(StatsCalculator())),
        
        // Phase 2 cubits
        BlocProvider(
          create: (_) => AuthCubit(authService)..initialize(),
        ),
        BlocProvider(
          create: (_) => SyncCubit(
            syncEngine: syncEngine,
            connectivity: connectivity,
            syncRepo: syncQueueRepo,
          ),
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          // Show loading during auth check
          if (authState.status == AuthStatus.initial ||
              authState.status == AuthStatus.loading) {
            return const MaterialApp(home: SplashScreen());
          }
          
          // Show auth gate if not signed in
          if (!authState.isAuthenticated) {
            return const MaterialApp(home: AuthGatePage());
          }
          
          // Show main app if signed in
          return MaterialApp(
            home: MainShell(
              syncState: context.watch<SyncCubit>().state,
            ),
          );
        },
      ),
    );
  }
}
```

**database/app_database.dart:**
```dart
// Phase 2: Add SyncQueue table
part 'app_database.g.dart';

@DriftDatabase(tables: [Albums, Sections, Stickers, CollectionStatuses, SyncQueueTable])
class AppDatabase extends _$AppDatabase {
  // ... existing code
  
  @override
  int get schemaVersion => 2;  // Increment for Phase 2
  
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAllTables();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Phase 2 migration: add sync_queue table
          await m.createTable(syncQueueTable);
        }
      },
    );
  }
  
  // Phase 2: Expose SyncQueueDao
  SyncQueueDao get syncQueueDao => SyncQueueDao(this);
}
```

### 7.2 CollectionCubit Integration

```dart
// Phase 2: CollectionCubit now triggers sync
class CollectionCubit extends Cubit<CollectionState> {
  final CollectionRepository _collectionRepo;
  final SyncEngine? _syncEngine;  // Phase 2: Nullable for offline mode
  
  CollectionCubit(this._collectionRepo, {SyncEngine? syncEngine})
      : _syncEngine = syncEngine,
        super(const CollectionState());
  
  void incrementSticker(int stickerId) {
    _updateStickerCount(stickerId, delta: 1);
    
    // Phase 2: Queue sync
    _syncEngine?.queueChange(
      stickerId: stickerId.toString(),
      operation: SyncOperation.upsert,
      payload: {
        'status': _deriveStatus(1),
        'count': 1,
        'source': 'local',
      },
    );
  }
  
  void decrementSticker(int stickerId) {
    _updateStickerCount(stickerId, delta: -1);
    
    // Phase 2: Queue sync
    final newCount = state.statusMap[stickerId]?.count ?? 0;
    _syncEngine?.queueChange(
      stickerId: stickerId.toString(),
      operation: SyncOperation.upsert,
      payload: {
        'status': _deriveStatus(newCount),
        'count': newCount,
        'source': 'local',
      },
    );
  }
  
  String _deriveStatus(int count) {
    if (count == 0) return 'missing';
    if (count == 1) return 'owned';
    return 'repeated';
  }
}
```

---

## 8. Design Decisions

### 8.1 Decision: Server Timestamps for Conflict Resolution

**Decision:** Use Firestore `FieldValue.serverTimestamp()` for all timestamp fields.

**Rationale:**
- Device clocks can be wrong (user changes time, different timezones)
- Server timestamps are authoritative for conflict resolution
- Firestore guarantees monotonic ordering of server timestamps per document

**Implementation:**
```dart
// When pushing to Firestore
await docRef.set({
  'count': newCount,
  'updatedAt': FieldValue.serverTimestamp(),  // Use server time
  'source': 'local',
});

// When comparing
final remoteTime = (remote['updatedAt'] as Timestamp?)?.toDate();
final localTime = (local['updatedAt'] as DateTime?);
if (remoteTime != null && localTime != null) {
  return remoteTime.isAfter(localTime);
}
```

### 8.2 Decision: Optimistic Updates with Async Sync

**Decision:** UI updates immediately (optimistic), sync happens asynchronously in background.

**Rationale:**
- Users expect instant feedback when tapping stickers
- Network latency shouldn't block UI responsiveness
- Queue ensures sync even if user switches screens quickly
- Offline mode works seamlessly (local-first)

**Flow:**
1. User taps sticker → UI updates instantly (count +1)
2. Write to local Drift (optimistic)
3. Add to sync queue
4. Process queue when online (background)

### 8.3 Decision: Last-Write-Wins Conflict Resolution

**Decision:** Compare `updatedAt` timestamps; newer write wins.

**Rationale:**
- Simple to implement and reason about
- Works well for single-user, multi-device scenario
- Deterministic (same result on all devices)
- Sufficient for MVP; can add CRDT/operational transform later if needed

**Comparison Logic:**
```dart
bool _isRemoteNewer(Map<String, dynamic> remote, Map<String, dynamic> local) {
  final remoteTime = (remote['updatedAt'] as Timestamp?)?.toDate();
  final localTime = local['updatedAt'] as DateTime?;
  
  if (remoteTime == null || localTime == null) {
    return true;  // If can't compare, prefer remote
  }
  return remoteTime.isAfter(localTime);
}
```

### 8.4 Decision: User-Scoped Firestore Collections

**Decision:** Firestore path is `users/{uid}/stickers/{stickerId}`.

**Rationale:**
- Natural fit for per-user data isolation
- Security rules are simple: users can only access their own data
- Scales to millions of users without issues
- Easier to implement than shared/trade collections (Phase 3)

**Alternative Considered: Flat Collection**
```
Firestore: /stickers/{stickerId}
  - Has userId field
  - Security rules check: request.auth.uid == resource.data.userId
  - Pro: Single collection, easier queries
  - Con: Security rules more complex, more data per document
```

### 8.5 Decision: Sync Queue in Local Drift DB

**Decision:** Store pending sync items in local Drift database, not in memory.

**Rationale:**
- Survives app restart/crash
- Survives phone shutdown
- Guaranteed persistence across all scenarios
- Can be inspected/debugged via SQLite tools
- Natural fit with existing Phase 1 architecture

**Queue Item Lifecycle:**
```
create → pending → processing → processed (delete)
                         ↓
                       retry (if transient error)
                         ↓
                       failed (if retry count >= 3)
```

### 8.6 Decision: Connectivity Service as Singleton

**Decision:** `ConnectivityService` is a singleton observable, not injected per-feature.

**Rationale:**
- Multiple features need to know connectivity state (sync, profile drawer)
- Single source of truth for connectivity
- Easy to test (mock singleton)
- Works with `connectivity_plus` which already is a singleton per platform

**Implementation:**
```dart
// connectivity_service.dart
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();
  static ConnectivityService get instance => _instance;
  
  ConnectivityService._();
  
  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((result) => result != NetworkResult.none);
  
  Future<bool> get isOnline async {
    final result = await _connectivity.checkWifiConnection();
    return result != NetworkResult.none;
  }
}
```

### 8.7 Decision: Auth Gate Pattern (Not Anonymous Auth)

**Decision:** Require Google sign-in to use the app; no anonymous/auth offline mode for Phase 2.

**Rationale:**
- Simplifies data model (no "anonymous" vs "authenticated" user distinction)
- All data is associated with a real user ID
- Firestore security rules are straightforward
- Phase 3 can add anonymous auth if needed for "try before buying"

**Trade-off:**
- Users must sign in immediately (no browsing first)
- Requires Google Play Services on Android
- Won't work on Kindle Fire (no Google Play Services)

**Mitigation:**
- Works on emulators without SHA-1
- Works on devices with proper SHA-1 configured
- Document SHA-1 setup for physical device testing

---

## 9. Implementation Order

| Step | Task | Files | Effort | Dependencies |
|------|------|-------|--------|--------------|
| 1 | Add dependencies | `pubspec.yaml` | Low | None |
| 2 | Firebase config | `firebase_options.dart`, `google-services.json` | Low | None |
| 3 | Sync queue table | `database/tables/sync_queue_table.dart` | Medium | Drift |
| 4 | Sync queue DAO | `database/daos/sync_queue_dao.dart` | Medium | Step 3 |
| 5 | Connectivity service | `connectivity/connectivity_service.dart` | Low | None |
| 6 | Auth service | `auth/data/firebase_auth_service.dart` | Medium | Step 1 |
| 7 | Auth cubit | `auth/presentation/cubit/` | Medium | Step 6 |
| 8 | Auth gate page | `auth/presentation/pages/auth_gate_page.dart` | Medium | Step 7 |
| 9 | Firestore repository | `sync/data/firestore_repository.dart` | Medium | Step 1 |
| 10 | Sync engine | `sync/domain/sync_engine.dart` | High | Steps 3,5,9 |
| 11 | Sync cubit | `sync/presentation/cubit/` | Medium | Step 10 |
| 12 | Profile drawer | `profile/presentation/widgets/user_profile_drawer.dart` | Medium | Steps 7,11 |
| 13 | Update main.dart | Firebase init, providers | Medium | Steps 1-11 |
| 14 | Update app.dart | Add AuthCubit, SyncCubit | Medium | Step 13 |
| 15 | Integration tests | Test sync scenarios | High | Steps 1-14 |
| 16 | APK build verification | `flutter build apk --debug` | Low | All |

---

*SDD Design completed 2026-05-23 for CromoManía 2026 Phase 2*
*Status: Ready for SDD Tasks and Implementation*