# Validation evidence — initial development checkpoint

Environment: Windows, Flutter 3.50.0 stable, Dart 3.14.0, Android SDK 37, bundled Android Studio Java 25.

| Check | Actual result |
|---|---|
| flutter doctor -v | Passed: no issues reported |
| flutter analyze | Passed: no issues found, including the screen test |
| flutter test (finance + SQLite) | Passed: 7 tests, 0 failed, 0 skipped |
| flutter test test/widget_test.dart | Passed: 1 test, 0 failed, 0 skipped |
| flutter build apk --release | Passed: app-release.apk generated, 47.4 MB |
| GitHub Actions | Not yet executed/verified |
| Android device installation/runtime | Untested: no Android device connected |

Tests cover integer amount parsing and invalid precision; transfer conservation; edit/delete balance recalculation; partial refund caps and linked-record protection; outgoing debt principal and goal-allocation exclusion from expense totals; every day of every half-month range in 2024, 2025, 2026 and 2028; SQLite inserts/updates/deletes and rejection of invalid account transfers; income entry/edit through the actual Flutter screens with real SQLite storage.

No test was skipped in the completed runs. Eight tests passed across the two completed runs. This is not full product coverage.

Still untested or unimplemented: Android runtime/permissions/denials; physical-phone and tablet layouts; accessibility; Firebase login/rules/family sharing/emulator; reconnect and sync conflicts; backup/restore; PDF/Excel generation and sharing; recurring transactions; notifications; debt/goal workflows; receipts; widgets; SMS flow; production signing. See FEATURE_MATRIX.md.

The APK is release-mode compiled but development-signed. It is a testing build, not a production Play Store release. APK compilation does not establish final acceptance.
