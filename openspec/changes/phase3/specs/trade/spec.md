# Trade Specification

## Purpose

Enable users to exchange stickers with friends through bidirectional QR codes. Users generate QR codes containing their collection state (missing/repeated stickers), friends scan them to discover mutually beneficial trades, and both collections update atomically upon confirmation.

---

## Requirements

### Requirement: QR Payload Generation

The system SHALL generate a valid QR code payload containing the user's current collection state for trading purposes.

#### Scenario: Generate QR with complete collection data

- GIVEN a user is authenticated with Firebase UID "user123"
- AND the user has missing stickers [1, 5, 10, 25, 33]
- AND the user has repeated stickers [3, 7, 12, 45]
- WHEN the user requests to generate a trade QR
- THEN the system SHALL produce a JSON payload with structure:
  ```
  {
    "v": 1,
    "uid": "user123",
    "ts": <current_timestamp_ms>,
    "exp": 600,
    "album": "panini_wc2026",
    "missing": [1, 5, 10, 25, 33],
    "repeated": [3, 7, 12, 45]
  }
  ```

#### Scenario: QR payload uses integer sticker IDs only

- GIVEN a user has 100 repeated stickers
- WHEN the system generates the QR payload
- THEN the system SHALL use only integer IDs in the `missing` and `repeated` arrays
- AND the payload SHALL NOT include sticker names or images

#### Scenario: QR expiry is 10 minutes (600 seconds)

- GIVEN a user generates a trade QR
- THEN the `exp` field SHALL be set to 600
- AND the payload SHALL include the generation timestamp in `ts`

---

### Requirement: QR Display with Countdown

The system SHALL display the generated QR code with a visible countdown timer showing time remaining until expiration.

#### Scenario: QR displays countdown from 10 minutes

- GIVEN a user has generated a trade QR
- WHEN the QR is displayed
- THEN the countdown SHALL start at "10:00"
- AND decrement every second
- AND display format SHALL be "M:SS" or "MM:SS"

#### Scenario: Countdown updates in real-time

- GIVEN a QR is displayed with 5:30 remaining
- WHEN 1 second passes
- THEN the display SHALL update to "5:29"
- AND continue decrementing until expiration

#### Scenario: Expired QR shows expiration message

- GIVEN a QR code has reached 0:00 remaining
- THEN the system SHALL display "QR Expired"
- AND the QR SHALL become non-interactive
- AND the system SHALL prompt the user to generate a new QR

---

### Requirement: QR Code Scanning

The system SHALL scan QR codes containing valid trade payloads using the device camera.

#### Scenario: Camera permission granted

- GIVEN the user taps "Scan QR" button
- AND camera permission has been granted previously
- WHEN the scanner page opens
- THEN the camera preview SHALL be visible immediately

#### Scenario: Camera permission denied

- GIVEN the user taps "Scan QR" button
- AND camera permission has not been granted
- WHEN the system requests camera permission
- THEN the system SHALL show a rationale dialog explaining camera is needed for QR scanning
- AND if denied, the system SHALL display "Camera access needed to scan QR codes"
- AND the system SHALL provide a button to open app settings

#### Scenario: Valid QR scanned successfully

- GIVEN the camera is active with scanning overlay
- WHEN a valid trade QR code is detected
- THEN the system SHALL parse the JSON payload
- AND extract: version, uid, timestamp, expiry, album, missing stickers, repeated stickers
- AND navigate to the trade confirmation page

#### Scenario: Invalid QR format shows error

- GIVEN the camera is scanning
- WHEN a QR code with invalid format is scanned
- THEN the system SHALL display "This QR code is not valid for trading"
- AND the system SHALL return to scanner mode

---

### Requirement: QR Expiry Validation

The system SHALL validate that scanned QR codes have not expired before allowing trade confirmation.

#### Scenario: Fresh QR accepted

- GIVEN a QR code was generated 30 seconds ago
- WHEN the QR is scanned
- THEN the system SHALL accept the QR
- AND display remaining time as "9:30"

#### Scenario: Expired QR rejected with message

- GIVEN a QR code was generated more than 10 minutes ago
- WHEN the QR is scanned
- THEN the system SHALL reject the QR
- AND display "This QR code has expired. Ask your friend to generate a new one."
- AND navigate back to scanner

#### Scenario: QR version mismatch handled

- GIVEN a QR code has version field other than 1
- WHEN the QR is scanned
- THEN the system SHALL reject the QR
- AND display "This QR code is not compatible with this app version"

---

### Requirement: Trade Offer Calculation

The system SHALL calculate a bidirectional trade offer using set intersection between the two users' collections.

#### Scenario: Bidirectional trade with mutual benefit

- GIVEN User A's scanned QR shows missing [1, 5, 10] and repeated [3, 7]
- AND User A's current collection shows stickers 3, 7 as repeated
- AND User B's (current user's) collection shows stickers 1, 5 as missing
- AND User B's collection shows stickers 2, 6 as repeated
- WHEN the system calculates the trade offer
- THEN User B will give: [1, 5] (what User A needs that User B has extras of)
- AND User B will receive: [] (what User B needs that User A has)
- AND the offer SHALL show "You give: 2 stickers"
- AND the offer SHALL show "You receive: 0 stickers"

#### Scenario: Trade with no overlap

- GIVEN User A's scanned QR shows missing [1, 2] and repeated [3, 4]
- AND User B's (current user's) collection shows missing [5, 6] and repeated [7, 8]
- WHEN the system calculates the trade offer
- THEN the offer SHALL indicate no trade is possible
- AND the system SHALL display "No stickers to trade"

#### Scenario: Large collection performance

- GIVEN a user has 300 missing stickers
- AND 200 repeated stickers in the QR payload
- WHEN the system calculates the trade offer
- THEN the calculation SHALL complete within 2 seconds
- AND the app SHALL remain responsive

---

### Requirement: Trade Confirmation UI

The system SHALL display a clear confirmation interface showing what each party gives and receives.

#### Scenario: Confirmation shows trade summary

- GIVEN a trade offer has been calculated
- WHEN the confirmation page is displayed
- THEN the system SHALL show the partner's name or ID
- AND display "You Give" section with sticker list
- AND display "You Receive" section with sticker list
- AND show count summary (e.g., "Give 3 · Receive 2")

#### Scenario: Confirmation highlights mutual stickers

- GIVEN a sticker is in the trade offer
- WHEN displayed in the list
- THEN the sticker entry SHALL include a checkmark icon
- AND the sticker SHALL show number and name

#### Scenario: User can cancel before confirming

- GIVEN the confirmation page is displayed
- WHEN the user taps "Cancel"
- THEN the system SHALL dismiss the confirmation
- AND return to the trade page
- AND SHALL NOT update any collections

---

### Requirement: Trade Execution

The system SHALL execute the trade atomically, updating both the giving and receiving stickers in the user's collection.

#### Scenario: Successful trade execution

- GIVEN a trade offer showing User B gives [1, 5] and receives [23, 8]
- AND User B has at least 1 copy of stickers 1 and 5
- WHEN the user taps "Confirm Trade"
- THEN the system SHALL decrement stickers 1 and 5 from the collection
- AND the system SHALL increment stickers 23 and 8 in the collection
- AND the system SHALL record the trade in history
- AND the system SHALL display success message "Trade completed!"

#### Scenario: Trade fails if sticker unavailable

- GIVEN a trade offer showing User B gives sticker 1
- AND User B has sticker 1 with count of 0
- WHEN the user attempts to confirm
- THEN the system SHALL reject the trade
- AND display "You no longer have sticker #1 to trade"
- AND SHALL NOT update any collections

#### Scenario: Offline trade execution

- GIVEN the user confirms a trade while offline
- WHEN the system attempts to execute
- THEN the system SHALL execute the trade locally
- AND display "Trade saved locally. Will sync when online."
- AND record the trade for Firestore sync when connection is restored

---

### Requirement: Trade History Recording

The system SHALL record completed trades in a local table for display in the trade history view.

#### Scenario: Trade recorded in history

- GIVEN a trade is successfully executed
- WHEN the trade completes
- THEN the system SHALL save a trade record containing:
  - Partner ID
  - Partner name (or "Anonymous" if unavailable)
  - Count of stickers given
  - IDs of stickers given
  - Count of stickers received
  - IDs of stickers received
  - Trade timestamp
  - Trade type ("qr_bidirectional")

#### Scenario: History displays in reverse chronological order

- GIVEN the user has completed 10 trades
- WHEN the trade history is displayed
- THEN the most recent trade SHALL appear at the top
- AND older trades SHALL appear below in descending order by timestamp

#### Scenario: Trade history shows summary format

- GIVEN trade history entries exist
- WHEN displayed in the list
- THEN each entry SHALL show format: "📤 Gave X · Got Y · PartnerName · TimeAgo"
- AND "TimeAgo" SHALL use relative format ("2h", "1d", "3d")

---

### Requirement: Trade History Pruning

The system SHALL automatically remove old trade records beyond a retention period.

#### Scenario: Old trades pruned after 90 days

- GIVEN trade history contains records older than 90 days
- WHEN the app starts or periodically
- THEN the system SHALL delete records older than 90 days
- AND SHALL preserve newer records

---

## Data Handling

### Local Storage

The system SHALL store trade records in the local SQLite database using the following schema:

| Field | Type | Description |
|-------|------|-------------|
| id | INTEGER PRIMARY KEY | Auto-increment ID |
| partner_id | TEXT | Partner's Firebase UID |
| partner_name | TEXT | Display name, default "Anonymous" |
| stickers_given | INTEGER | Count of stickers given |
| given_ids | TEXT | JSON array of given sticker IDs |
| stickers_received | INTEGER | Count of stickers received |
| received_ids | TEXT | JSON array of received sticker IDs |
| traded_at | INTEGER | Unix timestamp of trade |
| trade_type | TEXT | "qr_bidirectional" |

---

## Dependencies

### Required Packages

| Package | Version | Purpose |
|---------|---------|---------|
| qr_flutter | ^4.1.0 | QR code generation |
| mobile_scanner | ^5.2.0 | Camera-based QR scanning |

### Platform Permissions

| Platform | Permission | Purpose |
|----------|------------|---------|
| Android | CAMERA | QR code scanning |
| iOS | NSCameraUsageDescription | QR code scanning |

---

## Error Handling

| Error Scenario | User Message | System Action |
|----------------|--------------|---------------|
| Camera permission denied | "Camera access needed to scan QR codes" | Show settings button |
| QR expired | "This QR code has expired. Ask your friend to generate a new one." | Return to scanner |
| Invalid QR format | "This QR code is not valid for trading" | Return to scanner |
| Missing sticker during trade | "You no longer have sticker #X to trade" | Abort trade |
| Network offline | "Trade saved locally. Will sync when online." | Queue sync |
| Version mismatch | "This QR code is not compatible with this app version" | Return to scanner |

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

*Spec authored 2026-05-23 for CromoManía 2026 Phase 3 (QR Trade System)*