# Statistics Specification

## Purpose

Define how the application calculates, displays, and updates collection statistics, providing users with insights into their progress toward completing the album.

---

## Requirements

### Requirement: Stats Dashboard Display

The system MUST display a statistics dashboard showing collection metrics.

#### Scenario: Dashboard Initial Load

- GIVEN the user navigates to the stats dashboard
- WHEN the page loads
- THEN the system MUST display: completion percentage, owned count, missing count, repeated count

#### Scenario: Dashboard Layout

- GIVEN the user views the stats dashboard
- THEN the display MUST include:
  - A visual progress indicator (ring or bar)
  - Numeric metrics for owned, missing, and repeated stickers
  - Completion percentage prominently displayed

---

### Requirement: Completion Percentage Calculation

The system MUST calculate completion percentage as (owned stickers / total stickers) × 100.

#### Scenario: Calculate 0% Completion

- GIVEN the album has 100 stickers total
- WHEN the user has 0 owned stickers
- THEN the completion percentage MUST display as 0%

#### Scenario: Calculate 50% Completion

- GIVEN the album has 100 stickers total
- WHEN the user has 50 owned stickers
- THEN the completion percentage MUST display as 50%

#### Scenario: Calculate 100% Completion

- GIVEN the album has 100 stickers total
- WHEN the user has 100 owned stickers
- THEN the completion percentage MUST display as 100%

#### Scenario: Round to Nearest Integer

- GIVEN the actual completion is 42.5%
- WHEN the percentage is displayed
- THEN the system MUST round to the nearest integer for display (43%)

---

### Requirement: Missing Sticker Count

The system MUST calculate and display the count of stickers not yet owned.

#### Scenario: Calculate Missing Count

- GIVEN the album has 100 stickers total
- WHEN the user has 35 owned stickers
- THEN the missing count MUST display as 65

#### Scenario: Zero Missing at Completion

- GIVEN the user owns all 100 stickers
- WHEN the missing count is calculated
- THEN the missing count MUST display as 0

---

### Requirement: Owned Sticker Count

The system MUST calculate and display the count of stickers owned (count > 0).

#### Scenario: Count Owned Stickers

- GIVEN collection status shows 42 stickers with count > 0
- WHEN the owned count is calculated
- THEN the owned count MUST display as 42

---

### Requirement: Repeated Sticker Count

The system MUST calculate and display total count of duplicate stickers (excess over 1 per sticker).

#### Scenario: Calculate Repeated Count with Duplicates

- GIVEN collection status shows:
  - 5 stickers with count = 3 each
  - 10 stickers with count = 2 each
- WHEN the repeated count is calculated
- THEN the repeated count MUST display as: (5 × 2) + (10 × 1) = 20

#### Scenario: No Repeated Stickers

- GIVEN all owned stickers have count = 1
- WHEN the repeated count is calculated
- THEN the repeated count MUST display as 0

---

### Requirement: Real-Time Stats Updates

The system MUST update stats automatically when collection state changes.

#### Scenario: Update Stats After Tap

- GIVEN the stats dashboard is displayed
- WHEN the user taps a missing sticker (making it owned)
- THEN the stats MUST update to reflect: +1 owned, -1 missing, completion % increase

#### Scenario: Update Stats After Long-Press

- GIVEN the stats dashboard is displayed
- WHEN the user long-presses an owned sticker (making it missing)
- THEN the stats MUST update to reflect: -1 owned, +1 missing, completion % decrease

---

### Requirement: Stats Snapshot Persistence

The system MUST persist the last calculated stats snapshot for instant display on app launch.

#### Scenario: Load Cached Stats on Startup

- GIVEN the user has collection data from previous session
- WHEN the app starts
- THEN the stats dashboard SHOULD display cached stats immediately while recalculating from current data

---

### Requirement: Section-Specific Stats

The system MUST provide stats filtered by album section.

#### Scenario: Display Section Stats

- GIVEN the user views the stats dashboard
- WHEN the user taps on a section stat card
- THEN the system SHOULD navigate to a filtered view showing only that section's stickers

---

## Non-Functional Requirements

### NFR-1: Stats Calculation Performance

The system MUST calculate all stats within 100ms for albums with up to 670 stickers.

### NFR-2: Pre-Calculated Stats

The system SHOULD pre-calculate stats on collection state change rather than on every dashboard build.

### NFR-3: Efficient Stats State Management

The system MUST use immutable state copy-on-write so stats calculations do not trigger unnecessary rebuilds of unrelated widgets.

### NFR-4: Progress Indicator Animation

The system SHOULD animate the progress indicator when stats update to provide visual feedback.