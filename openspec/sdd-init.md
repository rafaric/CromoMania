# SDD Init — Sticker Collector App Phase 1

**Document Version:** 1.0  
**Date:** 2026-05-22  
**Status:** In Progress  
**Scope:** Phase 1 — MVP Core (Frontend Only, Offline)

## Context

**Project:** Sticker Collector App — cross-platform mobile application for managing, tracking, and trading physical sticker collections (albums, figuritas, cromos, láminas, estampas).

**Problem Statement:** Market leader "Figuritas App" suffers from critical stability issues (crashes on sticker tap), abusive advertising (interstitial ads every 5s), no cloud backup, unidirectional QR trade, paywalled OCR, broken PDF export, and poor UX. Users lose data on device loss.

**Solution:** Build a rock-solid, offline-first sticker collection manager with ethical monetization, free OCR, bidirectional QR trades, cloud sync, and PDF export.

**Competitive Edge:**
- Rock-solid stability (offline-first, crash-free >99.9% target)
- Ethical monetization (rewarded ads only, never interstitial)
- Automatic cloud sync with multi-device support
- Bidirectional QR trade (both parties update atomically)
- Free batch OCR scanning
- Free working PDF export

## Session Preflight Choices

| Preference | Choice |
|------------|--------|
| **Execution Mode** | Interactive (pause between phases) |
| **Artifact Store** | OpenSpec (local `openspec/` directory in repo) |
| **Chained PR Strategy** | N/A (no remote configured yet) |
| **Review Budget** | ~400 lines per work unit |
| **Delivery Strategy** | Single PR, commit by work unit |

## Phase 1 Scope (Confirmed)

### In Scope (Fase 1)
- [ ] Album template schema and local DB (Drift/SQLite)
- [ ] Album browsing and sticker marking (tap = owned, long-press = repeated)
- [ ] Stats dashboard (owned/missing/repeated counts, percentages)
- [ ] Offline-first local experience (no cloud yet)
- [ ] PDF export (client-side, pure Dart)
- [ ] Android build pipeline (APK debug compilable)

### Out of Scope (Later Phases)
- [ ] Firebase Auth / cloud sync / multi-device
- [ ] OCR scanning
- [ ] QR trade system
- [ ] Push notifications
- [ ] Home screen widgets
- [ ] Backend API

## Technical Stack (Phase 1)

| Layer | Technology | Version |
|-------|-------------|---------|
| Framework | Flutter | 3.x (latest stable) |
| Language | Dart | Latest stable |
| State Management | flutter_bloc (Cubit) | ^8.1.0 |
| Local DB | drift (SQLite) | ^2.15.0 |
| PDF Generation | pdf | ^3.10.0 |
| Sharing | share_plus | ^7.2.0 |
| Architecture | Clean Architecture | Layered (data/domain/presentation) |
| Editor | VS Code | Latest |

## Constraints

- **Solo developer** with intermediate Flutter level
- **Debug targets:** Android emulator + physical Android device
- **No Flutter SDK installed** — needs installation first
- **No remote git repo** — local only initially
- **Offline-first** — all features work with zero network

## Acceptance Criteria

1. APK debug builds successfully and installs on Android device/emulator
2. User can browse album sections and sticker grid
3. User can mark stickers as owned/repeated with tap/long-press
4. Stats dashboard shows accurate counts and percentages
5. PDF export generates valid, printable document
6. App is fully functional offline
7. Clean Architecture folder structure established
8. 60fps scrolling on albums with 800+ stickers

## Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Flutter SDK installation issues | Low | Medium | Use git clone method, verify PATH |
| Drift migrations complexity | Medium | Medium | Start simple schema, plan migrations upfront |
| Performance issues with large grids | Medium | Low | Use ListView.builder, test with 800 stickers |
| PDF generation failures | Low | Low | Use pure Dart `pdf` package, test edge cases |

## Next Steps

1. **Flutter SDK Installation** — install Flutter, add to PATH, verify `flutter doctor`
2. **SDD Explore Phase** — deep dive into Flutter Clean Architecture, drift patterns, Flutter BLoC/Cubit
3. **SDD Proposal** — document proposed solutions for each feature
4. **SDD Spec** — detailed functional and non-functional specifications
5. **SDD Design** — architecture diagrams, file structure, data models
6. **SDD Tasks** — actionable implementation tasks with estimates
7. **SDD Apply** — implement code following tasks
8. **SDD Verify** — build APK, test features, verify acceptance criteria
9. **SDD Archive** — final documentation and learnings

---

*SDD initiated by el Gentleman for Sticker Collector App Phase 1.*