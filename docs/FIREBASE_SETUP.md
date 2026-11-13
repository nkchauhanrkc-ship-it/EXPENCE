# Firebase setup required before cloud features can work

Cloud features are not implemented yet. Local finance tracking does not require Firebase.

1. Create a separate Firebase project named RKC Expence. Keep billing disabled (Spark).
2. Register Android application `com.rkc.expence`.
3. Download its `google-services.json`. Do not use the RKC Task project file.
4. Enable Google in Firebase Authentication and provide the support email.
5. Register SHA-1 and SHA-256 fingerprints for each actual signing key. Development and production keys differ. The Android `signingReport` Gradle task lists development fingerprints.
6. Create Firestore only after region selection and security rules are prepared. Test ownership and explicit family membership rules in the Firebase Emulator Suite before deploying.
7. Do not enable Storage, Blaze billing, or attachment upload. These require separate approval.

Keep service-account credentials, signing keystores and passwords out of Git. Android Firebase client configuration is not a service-account secret, but should be supplied to CI in a controlled manner. Release signing must use GitHub Actions secrets, never source code.

Required design work remains: local outbox, idempotent synchronization, explicit conflict handling, authenticated ownership, invitation/revocation controls, private-by-default personal records, and emulator security tests. Cloud synchronization must not be described as a historical backup.
