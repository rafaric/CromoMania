# Profile Specification

## Purpose

Display authenticated user information (name, email, avatar) and provide access to account management, sync status, and sign-out functionality through a profile drawer accessible from the main navigation.

## Requirements

### Requirement: User Profile Display

The system MUST display the authenticated user's Google profile information in the profile drawer.

#### Scenario: Signed-In User Views Profile

- GIVEN a user is signed in with Google account "Juan Pérez" (juan@email.com)
- WHEN the user opens the profile drawer
- THEN the drawer MUST display:
  - Circular avatar (64x64 dp) with the user's Google profile photo
  - Display name "Juan Pérez" in large text
  - Email "juan@email.com" in secondary text

#### Scenario: User Has No Profile Photo

- GIVEN the signed-in user has no Google profile photo
- WHEN the profile drawer is displayed
- THEN a default avatar SHALL be displayed (first letter of name on colored background)

#### Scenario: Unauthenticated User

- GIVEN no user is signed in
- WHEN the profile drawer is accessed (should not be accessible)
- THEN the app MUST redirect to the Auth Gate screen

### Requirement: Profile Drawer Access

The system MUST provide a profile drawer accessible from all main screens.

#### Scenario: Open Profile Drawer

- GIVEN the user is on the Collection screen
- WHEN the user taps the menu icon or avatar in the AppBar
- THEN the profile drawer MUST slide in from the left
- AND cover approximately 80% of the screen width (or 320dp, whichever is smaller)

#### Scenario: Close Profile Drawer

- GIVEN the profile drawer is open
- WHEN the user taps the close button (X) or taps outside the drawer
- THEN the drawer MUST slide out
- AND the user MUST return to the previous screen

### Requirement: Sync Status in Profile

The system MUST display the current sync status in the profile drawer.

#### Scenario: Sync Status Display

- GIVEN a user is signed in and sync is working
- WHEN the profile drawer is open
- THEN the sync status section MUST display:
  - Current sync state (e.g., "Synced 2 min ago")
  - Number of stickers backed up (e.g., "428 stickers backed up")

#### Scenario: Offline with Pending Changes

- GIVEN the device is offline with 3 pending sync items
- WHEN the profile drawer is open
- THEN the sync status section MUST display "Offline - 3 pending"

### Requirement: Sign Out Functionality

The system MUST allow the user to sign out from within the profile drawer.

#### Scenario: User Taps Sign Out

- GIVEN a user is signed in
- WHEN the user taps the "Sign Out" button in the profile drawer
- THEN a confirmation dialog MUST appear with message "Are you sure you want to sign out?"
- AND "Cancel" and "Sign Out" buttons

#### Scenario: Confirm Sign Out

- GIVEN the sign-out confirmation dialog is shown
- WHEN the user taps "Sign Out" (confirms)
- THEN Firebase Auth MUST sign out the user
- AND Google Sign In MUST sign out the user
- AND the profile drawer MUST close
- AND the app MUST navigate to the Auth Gate screen

#### Scenario: Cancel Sign Out

- GIVEN the sign-out confirmation dialog is shown
- WHEN the user taps "Cancel"
- THEN the dialog MUST close
- AND the user MUST remain in the profile drawer

### Requirement: Settings Access

The system MUST provide access to app settings from the profile drawer.

#### Scenario: Access Settings

- GIVEN the user is signed in
- WHEN the user taps "Settings" in the profile drawer
- THEN the app MUST navigate to the Settings screen

### Requirement: Export Collection Access

The system MUST provide a way to export the collection from the profile drawer.

#### Scenario: Export Collection

- GIVEN the user is signed in
- WHEN the user taps "Export Collection" in the profile drawer
- THEN the app MUST trigger the PDF export functionality (same as Phase 1)

### Requirement: Profile Drawer Layout

The profile drawer MUST follow the specified layout structure.

#### Layout Structure:

```
┌────────────────────────────────┐
│  ╳  Close                      │  ← Header with close button
├────────────────────────────────┤
│                                │
│        ┌──────────┐            │  ← Avatar (circular, 64dp)
│        │  (◉)     │            │
│        │  Avatar  │            │
│        └──────────┘            │
│                                │
│   Display Name                 │  ← Primary text (16sp, bold)
│   user@email.com                │  ← Secondary text (14sp, muted)
│                                │
├────────────────────────────────┤
│                                │
│  ☁️ Sync Status                │  ← Section header
│  ┌──────────────────────────┐ │
│  │ ✓ Synced 2 min ago      │ │  ← Sync status card
│  │ 428 stickers backed up   │ │
│  └──────────────────────────┘ │
│                                │
├────────────────────────────────┤
│                                │
│  ⚙️ Settings                   │  ← Action items
│  📤 Export Collection          │
│  📊 Statistics                │
│                                │
├────────────────────────────────┤
│                                │
│  🚪 Sign Out                   │  ← Destructive action
│                                │
└────────────────────────────────┘
```

### Requirement: Avatar Display

The system MUST handle avatar display gracefully across different states.

#### Scenario: Valid Avatar URL

- GIVEN the user has a valid Google profile photo URL
- WHEN the avatar image is loaded
- THEN the image MUST be displayed as a circular clipping
- AND fall back to initials if image fails to load

#### Scenario: Avatar Image Load Failure

- GIVEN the avatar image URL is valid but image fails to load
- WHEN the image widget encounters an error
- THEN the system MUST display the user's initials (first letter of first and last name)
- AND use a background color derived from the user's name hash

#### Scenario: No Avatar URL

- GIVEN the user has no Google profile photo
- WHEN the avatar is rendered
- THEN the system MUST display the user's initials immediately
- AND use a background color derived from the user's name hash

## Technical Specifications

### Required Packages

| Package | Version | Purpose |
|---------|---------|---------|
| cached_network_image | ^3.3.0 | Avatar image caching and display |

### Default Avatar Colors

| Name Initial | Background Color |
|--------------|------------------|
| A-C | #4CAF50 (Green) |
| D-F | #2196F3 (Blue) |
| G-I | #9C27B0 (Purple) |
| J-L | #FF9800 (Orange) |
| M-O | #F44336 (Red) |
| P-R | #00BCD4 (Cyan) |
| S-U | #795548 (Brown) |
| V-X | #607D8B (Blue Grey) |
| Y-Z | #E91E63 (Pink) |

### Drawer Dimensions

| Property | Value |
|----------|-------|
| Width | min(320dp, 80% screen width) |
| Avatar Size | 64dp x 64dp |
| Avatar Border Radius | 32dp (circular) |
| Padding | 16dp |
| Section Spacing | 24dp |