# RKC Expence

Android personal finance application, Flutter/Dart, package `com.rkc.expence`, version `1.0.0+1`.

This is an initial implementation checkpoint. It is not the complete approved Version 1.0.
All requirements remain in [the master specification](docs/MASTER_SPECIFICATION.md).
See [feature status](docs/FEATURE_MATRIX.md) for implemented, tested, pending and blocked work.

Local SQLite transactions support income, expenses and account transfers, editing, deletion with confirmation, category selection and notes. Account balances and monthly spending derive from stored postings. Monetary amounts use integer paise. No login, paid API, Firebase service, or SMS/camera/storage permission is required by this checkpoint.

Use Flutter 3.50.0 / Dart 3.14.0. Dependency versions are locked in pubspec.lock.
SQLite transaction/migration APIs follow the [package documentation](https://pub.dev/packages/sqflite).

```sh
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter build apk --release
```

The current release build uses a **development signing key**, for testing only. Production signing is not configured. The GitHub Actions workflow uses a standard Linux runner and uploads the APK only after analysis and tests pass.

- [Test evidence and limitations](docs/TEST_REPORT.md)
- [Firebase setup](docs/FIREBASE_SETUP.md)
- [Android installation](docs/INSTALLATION.md)

Local financial data remains in Android app-private storage. Encryption, complete backup/restore, device validation and cloud sync are pending; do not rely on this checkpoint for irreplaceable records. Uninstalling clears local data. No Firebase credentials or signing secrets are committed.
