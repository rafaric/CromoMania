# Collection Specification

## Purpose

Define how the application tracks and manages the user's sticker collection state, including the state machine for marking stickers as owned, repeated, or missing.

---

## Requirements

### Requirement: Collection State Machine

The system MUST implement a state machine for sticker collection status with the following transitions:

#### Scenario: Mark Missing Sticker as Owned

- GIVEN a sticker has status = missing (count = 0)
- WHEN the user taps on the sticker tile
- THEN the system MUST change the status to owned and set count = 1

#### Scenario: Increment Owned Sticker Count

- GIVEN a sticker has status = owned (count = 1)
- WHEN the user taps on the sticker tile
- THEN the system MUST increment the count to 2 and change status to repeated

#### Scenario: Increment Repeated Sticker Count

- GIVEN a sticker has status = repeated (count >= 2)
- WHEN the user taps on the sticker tile
- THEN the system MUST increment the count by 1, preserving repeated status

#### Scenario: Decrement Sticker Count via Long-Press

- GIVEN a sticker has status = owned (count = 1)
- WHEN the user long-presses on the sticker tile
- THEN the system MUST change the status to missing and set count = 0

#### Scenario: Decrement Repeated Sticker Count

- GIVEN a sticker has status = repeated (count > 1)
- WHEN the user long-presses on the sticker tile
- THEN the system MUST decrement the count by 1

#### Scenario: Repeated to Single via Long-Press

- GIVEN a sticker has status = repeated with count = 2
- WHEN the user long-presses on the sticker tile
- THEN the system MUST decrement count to 1 and change status to owned

---

### Requirement: Visual Feedback for State Changes

The system MUST provide immediate visual feedback when collection state changes.

#### Scenario: Missing Sticker Visual

- GIVEN a sticker with status = missing
- THEN the tile MUST display: empty cell background, gray border, sticker number visible, and no checkmark

#### Scenario: Owned Sticker Visual

- GIVEN a sticker with status = owned
- THEN the tile MUST display: green fill background, checkmark icon, and sticker number visible

#### Scenario: Repeated Sticker Visual

- GIVEN a sticker with status = repeated
- THEN the tile MUST display: yellow/amber fill background, duplicate icon, count badge showing multiplicity, and sticker number visible

#### Scenario: State Change Animation

- GIVEN the user taps or long-presses a sticker
- WHEN the state changes
- THEN the system SHOULD provide a subtle animation (100-200ms) indicating the state transition

---

### Requirement: Collection Persistence

The system MUST persist collection state to local database immediately after each state change.

#### Scenario: Persist State After Tap

- GIVEN the user taps a sticker and the state changes
- WHEN the state change occurs
- THEN the system MUST write the new status and count to the collection_status table within 100ms

#### Scenario: Persist State After Long-Press

- GIVEN the user long-presses a sticker and the state changes
- WHEN the state change occurs
- THEN the system MUST write the new status and count to the collection_status table within 100ms

#### Scenario: Recovery After App Restart

- GIVEN the user has marked stickers as owned/repeated
- WHEN the application restarts
- THEN the system MUST restore the exact collection state from the database

---

### Requirement: Single User Support (Phase 1)

The system MUST associate all collection data with a single hardcoded user identifier for Phase 1.

#### Scenario: Default User Assignment

- GIVEN the application creates or updates collection status
- WHEN saving to the database
- THEN the system MUST use "default_user" as the user_id value

#### Scenario: Load Collection for Default User

- GIVEN the application loads collection data
- WHEN querying collection status
- THEN the system MUST query using user_id = "default_user"

---

### Requirement: Rapid Interaction Handling

The system MUST handle rapid tap/long-press sequences without crashes or data corruption.

#### Scenario: Rapid Taps

- GIVEN the user rapidly taps a sticker multiple times within 1 second
- WHEN each tap triggers a state change
- THEN the system MUST process each state change sequentially and persist the final count accurately

#### Scenario: Mixed Tap and Long-Press

- GIVEN the user rapidly alternates between tapping and long-pressing a sticker
- WHEN each interaction triggers a state change
- THEN the system MUST not crash and must preserve the correct final state

---

### Requirement: State Consistency

The system MUST maintain consistency between UI state and persisted database state.

#### Scenario: State Sync on Error

- GIVEN a database write fails after UI update
- WHEN the write operation completes with error
- THEN the system SHOULD revert the UI to the previous state and display an error indication

---

## Non-Functional Requirements

### NFR-1: State Update Latency

The system MUST complete a state change and database write within 100ms for single sticker operations.

### NFR-2: No UI Blocking

The system MUST perform database writes asynchronously so the UI never freezes during sticker interactions.

### NFR-3: Memory Efficiency

The system MUST use copy-on-write immutable state patterns to minimize memory allocations during collection updates.

### NFR-4: Grid Performance During Updates

The system MUST use RepaintBoundary per sticker tile to prevent full grid rebuilds when a single sticker's state changes.