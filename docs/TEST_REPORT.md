# Validation evidence — initial development checkpoint

## Optional Google account connection checkpoint

`flutter analyze` passed with no issues and `flutter test` passed all 12 tests. The account-connection screen test uses an injected fake service: connection success, cancellation of sign-out, confirmed sign-out and connection failure with offline access retained. It is not a real Google/Firebase authentication test. Real authentication, token refresh, reconnection and process restart remain unverified on Android. No phone was detected by adb during this checkpoint. The verified local Firebase configuration matches expense-8468, com.rkc.expence, the local testing SHA-1 and includes Android/web OAuth clients. Firebase initialization is lazy on entering Account connection; local tracking can run without it. Financial data is not synchronized or assigned to the authenticated account yet.

## Bill attachment checkpoint

Analysis passed and all 11 tests passed. The new attachment test verifies the v1-to-v3 migration, multiple locally stored bills, byte retrieval, replacement without duplication, invalid-content rejection, unknown transaction rejection, removal, cascading deletion and unchanged financial totals. Android camera/gallery/PDF picker behavior, permission denial and interrupted-picker recovery are not yet device-tested. The new source has not yet been installed on the user's phone.

Firebase project ID supplied by the user: expense-8468. The existing Downloads/google-services.json was inspected and belongs to task-8468 / com.rkc.task; it was not copied into this app. Correct configuration for com.rkc.expence is required.

## Account and category management checkpoint

All 10 automated tests passed after adding account/category management. Analysis passed with no issues. The interaction test now creates an account with an opening balance, confirms the dashboard total, creates a category, searches for it, archives it and restores it. Repository tests verify renamed records retain IDs, opening balances recalculate correctly, archives preserve financial history, new transactions reject archived references, old entries remain editable and restore permits new use. An earlier screen-test failure was caused by its empty-state assertion falling outside the lazy list viewport; the final test uses an explicit larger viewport. Phone/tablet accessibility testing is still pending.

The earlier CI run 43356454015 succeeded, including APK build and artifact upload. This does not verify the newest management checkpoint's CI run.

## Budget development checkpoint

The subsequent budget change passed `flutter analyze` and all 9 automated tests. Tests now cover the v1-to-v2 schema migration preserving an existing income record, independently stored monthly/category budgets, invalid budgets and unknown categories. The screen test also exercises monthly budget editing. The APK hash below identifies the earlier checkpoint; it does not represent the new budget code. GitHub CI for the earlier corrected workflow passed analysis and tests and was still building its APK when checked.

Environment: Windows, Flutter 3.50.0 stable, Dart 3.14.0, Android SDK 37, bundled Android Studio Java 25.

| Check | Actual result |
|---|---|
| flutter doctor -v | Passed: no issues reported |
| flutter analyze | Passed: no issues found, including the screen test |
| flutter test (finance + SQLite) | Passed: 7 tests, 0 failed, 0 skipped |
| flutter test test/widget_test.dart | Passed: 1 test, 0 failed, 0 skipped |
| flutter build apk --release | Passed: app-release.apk generated, 47.4 MB |
| Android apksigner verify --print-certs | Passed: Android Debug certificate (testing key) |
| APK output metadata | com.rkc.expence, versionName 1.0.0, versionCode 1, minSdk 24 |
| GitHub Actions | Not yet executed/verified |
| Android device installation/runtime | Untested: no Android device connected |

Tests cover integer amount parsing and invalid precision; transfer conservation; edit/delete balance recalculation; partial refund caps and linked-record protection; outgoing debt principal and goal-allocation exclusion from expense totals; every day of every half-month range in 2024, 2025, 2026 and 2028; SQLite inserts/updates/deletes and rejection of invalid account transfers; income entry/edit through the actual Flutter screens with real SQLite storage.

No test was skipped in the completed runs. Eight tests passed across the two completed runs. This is not full product coverage.

Still untested or unimplemented: Android runtime/permissions/denials; physical-phone and tablet layouts; accessibility; Firebase login/rules/family sharing/emulator; reconnect and sync conflicts; backup/restore; PDF/Excel generation and sharing; recurring transactions; notifications; debt/goal workflows; receipts; widgets; SMS flow; production signing. See FEATURE_MATRIX.md.

The APK is release-mode compiled but development-signed. It is a testing build, not a production Play Store release. APK compilation does not establish final acceptance.

APK SHA-256: `76A3A120F813642E0ACB553A1314DA880990BA21885DF1336A1B94C801E8447C`.
