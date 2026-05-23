# SDD Init — CromoManía 2026 Phase 2

**Document Version:** 1.0  
**Date:** 2026-05-23  
**Status:** In Progress  
**Scope:** Phase 2 — Firebase Auth + Cloud Sync

## Context

**Project:** CromoManía 2026 — Sticker Collector App

**Phase 1 Complete:** MVP offline with album browsing, sticker marking, stats dashboard, PDF export.

**Phase 2 Goal:** Add Firebase Authentication (Google Sign In) and Cloud Firestore sync to enable multi-device support and cloud backup.

## Session Preflight Choices

| Preference | Choice |
|------------|--------|
| **Execution Mode** | Interactive (pause between phases) |
| **Artifact Store** | OpenSpec (local `openspec/` directory) |
| **Chained PR Strategy** | Single commit (same as Phase 1) |
| **Review Budget** | ~400 lines per work unit |
| **Delivery Strategy** | Single PR |

## Phase 2 Scope (Confirmed)

### In Scope
- [ ] Firebase Auth with Google Sign In
- [ ] Cloud Firestore for user data sync
- [ ] Offline-first sync engine (local → cloud)
- [ ] User profile (display name, email)
- [ ] Multi-device collection sync

### Out of Scope (Phase 3+)
- [ ] Apple Sign In
- [ ] QR Trade System
- [ ] Push Notifications
- [ ] OCR Scanning
- [ ] Home Screen Widgets

## Technical Stack (Phase 2)

| Layer | Technology |
|-------|------------|
| Auth | Firebase Auth + Google Sign In |
| Database | Cloud Firestore |
| Sync | Custom sync engine (offline queue) |
| Local DB | Drift (continue from Phase 1) |
| State | Cubit (continue from Phase 1) |

## Constraints

- **No SHA-1** for now — testing on emulators only
- **Physical device testing** requires SHA-1 configuration later
- **Conflict resolution:** Last-write-wins (simpler for MVP)

## Acceptance Criteria

1. User can sign in with Google account
2. User can sign out
3. Collection data syncs to Firestore on every change
4. App loads user data from Firestore on sign-in
5. App works offline (syncs when online)
6. No conflicts (last-write-wins)
7. Debug APK builds successfully

## Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Google Sign In without SHA-1 | High | Low | Works on emulators, document SHA-1 setup |
| Sync conflicts | Medium | Medium | Last-write-wins, document merge UI for later |
| Firestore security rules | Medium | High | Start with public read/write, secure later |
| Offline sync reliability | Medium | Medium | Test with airplane mode, exponential backoff |

## Next Steps

1. **SDD Explore** — Research Firebase Auth patterns, Firestore sync strategies
2. **SDD Proposal** — Document proposed auth and sync architecture
3. **SDD Spec** — Detailed specs for auth flow and sync engine
4. **SDD Design** — Architecture, Firestore schema, sync logic
5. **SDD Tasks** — Implementation tasks
6. **SDD Apply** — Code implementation
7. **SDD Verify** — Build and test
8. **SDD Archive** — Final documentation

---

*SDD Phase 2 initiated for CromoManía 2026*