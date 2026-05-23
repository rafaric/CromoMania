# Auth Specification

## Purpose

Enable Firebase Authentication using Google Sign In to provide secure, persistent user identity for cloud sync and multi-device support.

## Requirements

### Requirement: Firebase Initialization

The application MUST initialize Firebase before rendering any UI.

#### Scenario: Cold Start with Firebase Ready

- GIVEN the user launches the app with network available
- WHEN the app starts
- THEN Firebase MUST be initialized via `Firebase.initializeApp()` before `runApp()` is called

#### Scenario: Firebase Initialization Failure

- GIVEN Firebase initialization fails due to configuration error
- WHEN the app attempts to initialize
- THEN the app MUST display a user-friendly error message indicating Firebase setup is required
- AND the app MUST NOT crash

### Requirement: Auth State Observation

The system MUST observe Firebase Auth state changes to determine if a user is currently signed in.

#### Scenario: User Already Signed In

- GIVEN a previous sign-in session exists
- WHEN the app starts and Firebase initializes
- THEN `authStateChanges()` stream MUST emit the authenticated user
- AND the app MUST navigate to the main collection screen

#### Scenario: No Existing Sign-In

- GIVEN no previous sign-in session exists
- WHEN the app starts and Firebase initializes
- THEN `authStateChanges()` stream MUST emit `null`
- AND the app MUST navigate to the Auth Gate screen

#### Scenario: User Signs Out

- GIVEN a user is currently signed in
- WHEN the user taps "Sign Out"
- THEN `authStateChanges()` stream MUST emit `null` within 2 seconds
- AND the app MUST navigate to the Auth Gate screen

### Requirement: Google Sign In Flow

The system MUST allow users to sign in with their Google account via the Google Sign-In button.

#### Scenario: Successful Google Sign In

- GIVEN the user is on the Auth Gate screen
- WHEN the user taps "Sign in with Google"
- AND the user completes the Google consent dialog
- THEN Firebase Auth MUST return a valid `UserCredential`
- AND the user's Google profile (name, email, photo URL) MUST be available
- AND the app MUST navigate to the main collection screen

#### Scenario: User Cancels Google Sign In

- GIVEN the user is on the Auth Gate screen
- WHEN the user taps "Sign in with Google"
- AND the user cancels the Google consent dialog
- THEN `signInWithGoogle()` MUST return `null` for the Google user
- AND the app MUST remain on the Auth Gate screen
- AND no error message SHALL be shown to the user

#### Scenario: Sign In Fails Due to Network

- GIVEN the user is on the Auth Gate screen
- WHEN the user taps "Sign in with Google"
- AND the network connection is unavailable
- THEN the system MUST throw `AuthException` with message "No internet connection"
- AND the app MUST display a snackbar with the error message

### Requirement: User Profile Access

The system MUST provide access to the authenticated user's profile information.

#### Scenario: Access Current User Profile

- GIVEN a user is signed in
- WHEN any part of the application requests the current user
- THEN `FirebaseAuth.instance.currentUser` MUST return the signed-in `User` object
- AND the user's `displayName`, `email`, and `photoURL` MUST be accessible

#### Scenario: Anonymous User Profile

- GIVEN no user is signed in
- WHEN any part of the application requests the current user
- THEN `FirebaseAuth.instance.currentUser` MUST return `null`

### Requirement: Sign Out

The system MUST allow signed-in users to sign out completely.

#### Scenario: User Signs Out

- GIVEN a user is signed in
- WHEN the user taps "Sign Out" in the profile drawer
- THEN `FirebaseAuth.instance.signOut()` MUST be called
- AND `GoogleSignIn.instance.signOut()` MUST be called
- AND the auth state MUST transition to unauthenticated
- AND the app MUST navigate to the Auth Gate screen

### Requirement: Auth Error Handling

The system MUST handle authentication errors gracefully and display appropriate messages.

#### Scenario: Firebase Auth Error

- GIVEN an authentication operation fails
- WHEN the error is a known Firebase error (network, quota, etc.)
- THEN the system MUST catch the exception
- AND display a user-friendly message via SnackBar
- AND the app MUST NOT crash

#### Scenario: Invalid Google Configuration (Missing SHA-1)

- GIVEN Google Sign In is attempted without SHA-1 configured for physical device
- WHEN the user taps "Sign in with Google" on a physical device
- THEN Firebase MUST return `PlatformException` with code "MISSING_DEBUG_SHA1"
- AND the system MUST display an error message indicating SHA-1 configuration is needed

## Technical Specifications

### Auth State Flow

```
App Start → Firebase Init → Check authStateChanges()
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
              Signed In       Not Signed In    Loading
                    │               │               │
                    ▼               ▼               ▼
           Load from Firestore  Show Auth Gate  Show Loading
           Navigate to Home         Screen
```

### Required Packages

| Package | Version | Purpose |
|---------|---------|---------|
| firebase_core | ^3.0.0 | Firebase initialization |
| firebase_auth | ^5.0.0 | Authentication |
| google_sign_in | ^6.2.0 | Google Sign In UI and logic |

### Dependencies

- Android: `google-services.json` must be present in `android/app/`
- SHA-1 fingerprint must be registered in Firebase Console for physical device testing