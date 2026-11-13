# Install a testing APK

Only install after the build is verified. This checkpoint is not the completed Version 1.0 application.

1. Open the repository on GitHub and select **Actions**.
2. Open a successful **Android testing APK** run.
3. In **Artifacts**, download **RKC-Expence-1.0.0-testing-APK** and unzip it.
4. Copy `app-release.apk` to the Android phone and open it.
5. If Android asks, allow the file manager to install unknown apps, then choose Install.
6. Turn that file manager permission off afterward.

This APK uses development signing despite being compiled in release mode. It is not a production-signed Play Store release. A future production key may require uninstalling this build: do not enter important financial records before backup/restore is implemented and verified. Uninstalling clears local data.
